function create_branch_cv_objs(subSysHndl,parentId,modelId)
% CREATE_BRANCH_CV_OBJS - Recurse through children create slsfobjs. 
% 

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/03/23 02:59:41 $

    persistent CoverageBlockTypes;
    
    switch(nargin)
        case 1,
            modelName = get_param(bdroot(subSysHndl),'Name');
            modelId = cv('find','all','modelcov.name',modelName);
            if isempty(modelId), modelId = 0; end
            parentId = 0;
        case 2,
            modelId = parentId;
            parentId = 0;
    end
        
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fix input arguments if needed
    if ischar(subSysHndl)
        subSysHndl = get_param(subSysHndl,'handle');
    end
    
    if modelId==0
            modelHandle = bdroot(subSysHndl);
            modelName = get_param(modelHandle,'Name');
            modelId = cv('new','modelcov','.name',modelName,'.handle',modelHandle);
    end
    
    if parentId==0
            parentId = create_new_slsfobjs(subSysHndl,modelId,modelId);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load CoverageBlockTypes if needed
    if isempty(CoverageBlockTypes)
         CoverageBlockTypes = create_CoverageBlockTypes;
    end
    
         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Recursively call the subsystems
    childSubSystems = find_system(subSysHndl,'SearchDepth',1, ...
                                    'FollowLinks', 'on', ...
                                    'LookUnderMasks', 'all', ...
                                    'BlockType','SubSystem');
    childSubSystems = childSubSystems(childSubSystems~=subSysHndl); % Filter out parent
    childSlsfobjIds = create_new_slsfobjs(childSubSystems,parentId,modelId);
    for i = 1:length(childSlsfobjIds)
        create_branch_cv_objs(childSubSystems(i),childSlsfobjIds(i),modelId);
    end
            
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % On the way up add leaf blocks
    childLeafBlocks = [];
    for type = CoverageBlockTypes,
        newBlocks = find_system(subSysHndl,'SearchDepth',1,'FollowLinks', 'on', ...
                                'LookUnderMasks', 'all','BlockType',type{1});
        childLeafBlocks = [childLeafBlocks;newBlocks];
    end
    childIds = create_new_slsfobjs(childLeafBlocks,parentId,modelId);
        





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_COVERAGEBLOCKTYPES
%
% Set the value of persistent string cell array CoverageBlockTypes

function CoverageBlockTypes = create_CoverageBlockTypes(),

    CoverageBlockTypes = {  'Saturate', ...
                            'Lookup', ...
                            'Lookup2D', ...
                            'Logic', ...
                            'Switch', ...
                            'Relay', ...
                            'If', ...
                            'MinMax', ...
                            'CombinatorialLogic', ...
                            'MultiPortSwitch', ...
                            'Abs', ...
                         };    


%    CoverageBlockTypes = {  'Logic', ...
%                            'RelationalOperator', ...
%                            'Saturate', ...
%                            'Switch', ...
%                            'MultiPortSwitch', ...
%                            'Relay', ...
%                            'CombinatorialLogic', ....
%                            'Abs', ...
%                            'Signum', ...
%                         };    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_NEW_SLSFOBJS
%
% Create new slsf objects in cv and resolve basic entries

function newIds = create_new_slsfobjs(slHandles,parentId,modelId),

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
    
    % Setup the treeNodes by call BlockAdoptChildren
    cv('BlockAdoptChildren',parentId,newIds);                                
                                           
                                