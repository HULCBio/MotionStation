function varargout = cvsf(method,varargin)
%CVSF Coverage interface to SF debugger
%

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.11.2.6 $  $Date: 2004/04/15 00:37:27 $

switch(method)
    case 'InitChartInstance'
        chartId = varargin{1};
        slFullPath = varargin{2};
        [cvStateIds,cvTransIds,cvDataInd,cvChartId] = init_chart_instance(chartId,slFullPath);
        varargout{1} = cvStateIds;
        varargout{2} = cvTransIds;
        if nargout == 3  % Temporary bridge to old sf_debuglib call
            varargout{3} = cvChartId;
        else
            varargout{3} = cvDataInd;
            varargout{4} = cvChartId;
        end
    case 'ReloadIds'
        cvChartId = varargin{1};
        reload_old_instance_ids(cvChartId);
    otherwise
        error(sprintf('Unknown method, %s, in cvsf',method));
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INIT_CHART_INSTANCE
%   Recreate the chart hierarchy in the coverage tool and install the
%   resulting IDs in the debugger instance info.

function [cvStateIds,cvTransIds,cvDataInd,cvChartId] = init_chart_instance(chartId,slFullPath),

    cvStateIds = [];
    cvTransIds = [];
    cvChartId = [];

	SREnum = cv_metric_names('sigrange');
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the chart subsystem slsfobj
    slHandle = get_param(slFullPath,'Handle');
    cvChartSubsysId = get_param(slHandle,'CoverageId');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure the chart parent 
    % subsystem was created
    if (cvChartSubsysId==0)
        cvChartId = 0;
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Special case the EML script block
    isEMLBlock = sf('get',chartId,'chart.type') == 2;
    if isEMLBlock
        cv('set',cvChartSubsysId,'.refClass',-99);  % -99 ==> EML script block (no SF)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the chart ID and set its
    % parent to the subsystem block.
    modelcovId = cv('get',cvChartSubsysId,'.modelcov');
    cvChartId = cv('new','slsfobj',     1, ...
                    '.origin',          'STATEFLOW_OBJ', ...
                    '.modelcov',        modelcovId, ...
                    '.refClass',        sf('get','default','chart.isa'));
    cv('BlockAdoptChildren',cvChartSubsysId,cvChartId);
   	cv('set',cvChartId,'.handle',chartId);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the State slsfobjs
    stateIds = sf('get',chartId,'chart.states');
    stateIds = sf('find',stateIds,'~state.isNoteBox',1);	% Filter notes
    if ~isempty(stateIds)
        stateNmbrs = sf('get',stateIds,'.number');
        [sortNmbrs,sortI] = sort(stateNmbrs);
        stateIds = stateIds(sortI);
    
        cvStateIds = cv('new','slsfobj',length(stateIds), ...
                        '.origin',          'STATEFLOW_OBJ', ...
                        '.modelcov',        modelcovId, ...
                        '.refClass',        sf('get','default','state.isa'));
        
        % Special case for EML script blocks the function name is 
        % applied.
        if isEMLBlock
            cv('set',cvStateIds(1),'.name',sf('get',chartId,'.eml.name'));
        end
        
        for i=1:length(stateIds)
        	cv('set',cvStateIds(i),'.handle',stateIds(i));
            % Set the cv name to the label of Boxes
            if (sf('get',stateIds(i),'.type')==3) % is this a box
        	    cv('set',cvStateIds(i),'.name',sf('get',stateIds(i),'.labelString'));
            end
            
            % If this is an EML chart create a cv.codeblock and cache the script contents
            if (sf('get',stateIds(i),'state.eml.isEML'))
                codeBlockId = cv('new','codeblock',	1,'.slsfobj',cvStateIds(i), ...
                                        'codeblock.code',sf('get',stateIds(i),'state.eml.script'));
                cv('CodeBloc','refresh',codeBlockId);
                cv('set',cvStateIds(i),'.code',codeBlockId);
            end
    	end
        create_decendent_hierarchy(chartId,cvStateIds,chartId,cvChartId);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create the Trans slsfobjs
    transIds = sf('Private','chart_real_transitions',chartId);
	transIds = sf('find',transIds,'~transition.dst.id',0);	% Filter dangling transitions
    if ~isempty(transIds)
        transNmbrs = sf('get',transIds,'.number');
        [sortNmbrs,sortI] = sort(transNmbrs);
        transIds = transIds(sortI);
    
        cvTransIds = cv('new','slsfobj',length(transIds), ...
                        '.origin',          'STATEFLOW_OBJ', ...
                        '.modelcov',        modelcovId, ...
                        '.refClass',        sf('get','default','transition.isa'));
        for i=1:length(transIds)
       		cv('set',cvTransIds(i),'.handle',transIds(i));
    	end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Place each trans within the
    % state hierarchy
    for i=1:length(transIds)
        trans = transIds(i);
        sfParent = sf('get',trans,'.linkNode.parent');
        if (sfParent==chartId)
            cv('BlockAdoptChildren',cvChartId,cvTransIds(i));
        else
            cv('BlockAdoptChildren',cvStateIds(sf('get',sfParent,'state.number')+1),cvTransIds(i));
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add signalranger to the 
    % chart
	[dnames,dwidths,dnumbers] =  cv_sf_chart_data(chartId);
        cvDataInd = 99999*ones(1,max(dnumbers)+1);
	[sortNumbers,sortI] = sort(dnumbers);
	for i=1:length(sortNumbers)
	    cvDataInd(sortNumbers(i)+1) = i-1;
	end
	
	srId = cv('new','sigranger',		1, ...
				'slsfobj',				cvChartId);     
	cv('set',srId,'.cov.allWidths',		dwidths(sortI)');
     
	%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Add the signal ranger to
	% the chart object
	cv('MetricInsert',cvChartId,SREnum,srId);
				


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_DECENDENT_HIERARCHY
%   Recreate the chart hierarchy in the coverage tool and install the
%   resulting IDs in the debugger instance info.

function create_decendent_hierarchy(sfId,stateCvIds,sfChartId,cvChartId),

    sfSubstates = sf('AllSubstatesOf',sfId);
    sfSubstates = sf('find',sfSubstates,'~state.isNoteBox',1);	% Filter notes

    cvChildren = stateCvIds(sf('get',sfSubstates,'state.number')+1);

    if (sfId==sfChartId)
        cvParent = cvChartId;
    else
        cvParent = stateCvIds(sf('get',sfId,'state.number')+1);
    end

    cv('BlockAdoptChildren',cvParent,cvChildren);

    % Call each child recursively
    for child = sfSubstates(:)',
        create_decendent_hierarchy(child,stateCvIds,sfChartId,cvChartId);
    end



     


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RELOAD_OLD_INSTANCE_IDS
%   Find the arrays of cvStateIds and cvTransIds and install these
%   in the debugger portion of the Stateflow S-Function

function reload_old_instance_ids(cvChartId),

    sfIsa.state = sf('get','default','state.isa');
    sfIsa.trans = sf('get','default','transition.isa');

    mixedIds = cv('DecendentsOf',cvChartId);

    % If we haven't initialized the chart, return now
    if isempty(mixedIds)
        return;
    end

    mixedIsa = cv('get',mixedIds,'.refClass');

    cvStates = mixedIds(mixedIsa==sfIsa.state);
    cvTrans = mixedIds(mixedIsa==sfIsa.trans);

    % Reorder the states so they match the sequence of sf numbers:
    sfStates = cv('get',cvStates,'.handle');
    stateNmbrs = sf('get',sfStates,'.number');
    [sortNmbrs,sortI] = sort(stateNmbrs);
    cvStates = cvStates(sortI);

    % Reorder the trans so they match the sequence of sf numbers:
    sfTrans = cv('get',cvTrans,'.handle');
    transNmbrs = sf('get',sfTrans,'.number');
    [sortNmbrs,sortI] = sort(transNmbrs);
    cvTrans = cvTrans(sortI);

    % Find the path to the Simulink block
    parent = cv('get',cvChartId,'.treeNode.parent');
    parentH = cv('get',parent,'.handle');
    path = sl_full_path(parentH);

    % Call the generated S-Function with the new Ids
    chartId = cv('get',cvChartId,'.handle');
    machineId = sf('get',chartId,'.machine');
    modelId = cv('get',cvChartId,'.modelcov');
    sfunName =  [cv('get',modelId,'.name') '_sfun'];
    feval(sfunName,'sf_debug_api','set_instance_cv_ids', machineId, chartId, path, cvStates, cvTrans, cvChartId);    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SL_FULL_PATH
%   Get the full path from a double handle

function path = sl_full_path(handle)
    path = getfullname(handle);
    %parent = get_param(handle,'Parent');
    %path = [parent '/' get_param(handle,'Name')];