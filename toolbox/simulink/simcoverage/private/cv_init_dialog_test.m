function newModelId = cv_init_dialog_test(modelId,modelName),
%CV_INIT_DIALOG_TEST - Initialize coverage tool from settings Dlg
%

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/15 00:37:20 $

    try,
       prevLastErr = lasterr;
       forceSlSfCoverageOn = evalin('base','forceSlSfCoverageOn');
    catch,
       lasterr(prevLastErr);
       forceSlSfCoverageOn = 0;
    end

    if (forceSlSfCoverageOn)
        set_param(modelName,'RecordCoverage','on');
        disp('Coverage Instrumentation is being forced on by the variable forceSlSfCoverageOn');
    else
        if strcmp(get_param(modelName,'RecordCoverage'),'off')
            newModelId = 0;
            return;
        end    
    end

    modelH = get_param(modelName,'Handle');

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % First try to resolve the coverage root.  Return early 
    % on failure.
    coveragePath = get_param(modelH,'CovPath');
    if ~isempty(coveragePath) && length(coveragePath)>1
        coveragePath = coveragePath(2:end); % Remove the initial '/'
        
        fullPath = [modelName '/' coveragePath];
        try
            covRoot = get_param(fullPath,'Handle');
            if ~strcmp(get_param(covRoot,'BlockType'),'SubSystem')
                covRoot = [];
            end
        catch
            covRoot = [];
        end
    else
        coveragePath = '';
        covRoot = modelH;
    end
	if isempty(covRoot)
	    warning(['Invalid coverage path, "' coveragePath '"  Model Coverage will be disabled.']);
	    newModelId = 0;
	    return;
	end
	

    if (modelId==0)
        newModelId = cvmodel(modelH);
    else
        newModelId = modelId;
    end

    % Apply the dialog options
    settingStr = get_param(modelH,'CovMetricSettings');
    cv_dialog_options('applyOptions',settingStr);
    
    
	% Create the testdata object
	testId = cv('new', 	'testdata'  					    ...
			,'.type',				    'DLGENABLED_TST' 	...
			,'.modelcov',				newModelId 		    ...
			,'.rootPath',				coveragePath);

    % Enable the appropriate coverage metrics
    metricNames = cv_metric_names([],settingStr);
  
  
    for met = metricNames(:)',
        cv('set',testId,['testdata.settings.' met{1}],1);
    end
    
    cv('set',newModelId,'modelcov.activeTest',testId);