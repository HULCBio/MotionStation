function varargout = build_sl_hierarchy(rootSysHndl,rootSlsfId,modelId)
% Generate the tree structure of the model and insert
% all block types that require instrumentation
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2004/04/15 00:37:13 $

    persistent CoverageBlockTypes Sfun_name_list;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load CoverageBlockTypes if needed
    if isempty(CoverageBlockTypes)
         CoverageBlockTypes = create_CoverageBlockTypes;
         Sfun_name_list = create_sfun_name_list;
    end
    
    % Determine if assertion related blocks need coverage
    if (strcmp(cv('Feature','disable assert coverage'),'on'))
        skipAssert = 1;
    else
        skipAssert = 0;
    end

	% Determine if in autoscaling mode
	isAutoscale = cv_is_model_autoscale(bdroot(rootSysHndl));

    if (nargin==1)
        modelName = get_param(bdroot(rootSysHndl),'Name');
        modelId = cv('find','all','modelcov.name',modelName);
        rootSlsfId = 0;
        if isempty(modelId), modelId = 0; end
    end
    
    if (rootSlsfId==0)
        rootSlsfId = create_new_slsfobjs(rootSysHndl,modelId);
    else
        % Make sure the root handle is installed in Simulink
	    if bdroot(rootSysHndl)~=rootSysHndl
            set_param(rootSysHndl,'CoverageId',rootSlsfId);
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fix input arguments if needed
    if ischar(rootSysHndl)
        rootSysHndl = get_param(subSysHndl,'handle');
    end
    
    if modelId==0
        modelHandle = bdroot(rootSysHndl);
        modelName = get_param(modelHandle,'Name');
        modelId = cv('new','modelcov','.name',modelName,'.handle',modelHandle);
    end
    
    

	% Get all the subsystem blocks
	subsys_blks = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                    'LookUnderMasks', 'all', ...
                                    'BlockType','SubSystem', ...
                                    'DisableCoverage','off');
    
	% Filter the root if it is not a model handle
	if bdroot(rootSysHndl)~=rootSysHndl
		subsys_blks = subsys_blks(subsys_blks~=rootSysHndl);
	end
	
	% Arrange the subsystems contiguosly by parent
	subsys_par = get_param(get_param(subsys_blks,'Parent'),'Handle');
	if iscell(subsys_par)
		subsys_par = cat(1,subsys_par{:});		% convert to numeric vector
		[subsys_par,sortI] = sort(subsys_par);
		subsys_blks = subsys_blks(sortI);
	end
	
	% Filter out the assert related blocks if needed
	if (skipAssert)
	    assertRelated = strcmp(get_param(subsys_blks,'UsedByAssertionBlockOnly'),'on');
	    subsys_blks(assertRelated) = [];
		subsys_par(assertRelated) = [];
	end
	
	% Filter out all non-Stateflow block if autoscaling
	if isAutoscale
		filter_non_stateflow(subsys_blks, subsys_par);
	end

	% Create the shadow coverage objects for each subsystem
	subsys_cvIds = create_new_slsfobjs(subsys_blks,modelId);
	subsys_cvIds = [subsys_cvIds;rootSlsfId];
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Build the hierarchy of subsystems
	
	% Create a single index for each parent
	sysGroups = find( [-1 ; subsys_par] ~= [subsys_par ; -1]); 
	
	for i=1:(length(sysGroups)-1)
		children = subsys_cvIds( (sysGroups(i)):(sysGroups(i+1)-1) );
		parent = subsys_cvIds([subsys_blks;rootSysHndl]==subsys_par(sysGroups(i)));
		cv('BlockAdoptChildren',parent,children); 
	end             
		

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add all leaf blocks
    leafBlocks = [];
    for type = CoverageBlockTypes,
        newBlocks = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all','BlockType',type{1}, ...
                                'DisableCoverage','off');
        
        % We need to filter S-Functions based on the FunctionName
        if strcmp(type{1},'S-Function')
            startBlocks = newBlocks;
            funcNames = get_param(startBlocks,'FunctionName');
            newBlocks = [];
            for funcType = Sfun_name_list,
                matchesInd = strcmp(funcNames,funcType{1});
                newBlocks = [newBlocks;startBlocks(matchesInd)];
            end
        end
        leafBlocks = [leafBlocks;newBlocks];
    end
    
	% Arrange the leaf blocks contiguosly by parent
	leafBlocks_par = get_param(get_param(leafBlocks,'Parent'),'Handle');
	if iscell(leafBlocks_par)
		leafBlocks_par = cat(1,leafBlocks_par{:});		% convert to numeric vector
		[leafBlocks_par,sortI] = sort(leafBlocks_par);
		leafBlocks = leafBlocks(sortI);
	end
	
	% Filter out the assert related blocks if needed
	if (skipAssert)
	    assertRelated = strcmp(get_param(leafBlocks,'UsedByAssertionBlockOnly'),'on');
	    leafBlocks(assertRelated) = [];
	    leafBlocks_par(assertRelated) = [];
	end
	
	% Filter out all non-Stateflow block if autoscaling
	if isAutoscale
		filter_non_stateflow(subsys_blks, subsys_par);
	end
	
	leafBlocks_cvIds = create_new_slsfobjs(leafBlocks,modelId);
	
	leafSysGroups = find( [-1 ; leafBlocks_par] ~= [leafBlocks_par ; -1]); 

	for i=1:(length(leafSysGroups)-1)
		children = leafBlocks_cvIds( (leafSysGroups(i)):(leafSysGroups(i+1)-1) );
		parent = subsys_cvIds([subsys_blks;rootSysHndl]==leafBlocks_par(leafSysGroups(i)));
		cv('BlockAdoptChildren',parent,children); 
	end             
        
	% Find all the remaining blocks and create sigranger objects for recording the 
	% range of output values.
	leftOvers = find_system(rootSysHndl,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all','CoverageId',0, ...
                                'DisableCoverage','off');

    % Remove merge blocks because their ouput is virtualized and we don't want 
    % to pollute the report with noise.
    isMerge = strcmp(get_param(leftOvers,'BlockType'),'Merge');
    leftOvers(isMerge) = [];

    leftOver_par = get_param(get_param(leftOvers,'Parent'),'Handle');
	if iscell(leftOver_par)
		leftOver_par = cat(1,leftOver_par{:});		% convert to numeric vector
		[leftOver_par,sortI] = sort(leftOver_par);
		leftOvers = leftOvers(sortI);
	end
	leftOverSysGroups = find( [-1 ; leftOver_par] ~= [leftOver_par ; -1]); 
 
    leftOver_cvids = create_new_slsfobjs(leftOvers,modelId);
                                
	for i=1:(length(leftOverSysGroups)-1)
		children = leftOver_cvids( (leftOverSysGroups(i)):(leftOverSysGroups(i+1)-1) );
		parent = subsys_cvIds([subsys_blks;rootSysHndl]==leftOver_par(leftOverSysGroups(i)));
		cv('BlockAdoptChildren',parent,children); 
	end             

        
    if nargout>0
        varargout{1} = rootSlsfId;
    end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_COVERAGEBLOCKTYPES
%
% Set the value of persistent string cell array CoverageBlockTypes

function CoverageBlockTypes = create_CoverageBlockTypes(),

    % This list has a direct impact on the block order within the
    % model hierarchy.  Keep the list alphabetic to montain a degree
    % of consistency

    CoverageBlockTypes = { ...
                            'Abs', ...
                            'CombinatorialLogic', ...
                            'DiscreteIntegrator', ...
                            'Fcn',...
                            'ForIterator', ...
                            'If', ...
                            'Logic', ...
                            'Lookup', ...
                            'Lookup2D', ...
                            'MinMax', ...
                            'MultiPortSwitch', ...
                            'RateLimiter', ...
                            'Relay', ...
                            'Saturate', ...
                            'S-Function', ...   % Must also check the FunctionName
                            'Switch', ...
                            'SwitchCase', ...
                            'WhileIterator' ...
                         };    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_SFUN_NAME_LIST
%
% Set the value of persistent string cell array sfun_name_list

function sfun_name_list = create_sfun_name_list(),

    % This is the list of S-Function function names that 
    % have built in coverage support
    
    sfun_name_list =    { ...
                            'sfun_kflookupnd', ...
                            'sfun_lookupnd', ...
                            'sfun_nddirectlook' ...
                        };    
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_NEW_SLSFOBJS
%
% Create new slsf objects in cv and resolve basic entries

function newIds = create_new_slsfobjs(slHandles,modelId),

    newIds = zeros(size(slHandles));

    if length(slHandles)==1
        names{1} = get_param(slHandles,'Name');
    else
        names = get_param(slHandles,'Name');
    end

    for i=1:length(slHandles),
        newIds(i) = cv('new','slsfobj', '.handle',      slHandles(i), ...
                                        '.name',        names{i}, ...
                                        '.origin',      1, ...
                                        '.modelcov',    modelId);
        set_param(slHandles(i),'CoverageId',newIds(i));
    end
    
                                           
function filter_non_stateflow(blocks, parents)
	                                    	nonSF = ~is_stateflow_block(blocks);
	blocks(nonSF)  = [];
	parents(nonSF) = [];

function result = is_stateflow_block(block)

	result = strcmp(get_param(block, 'MaskType'), 'Stateflow');


