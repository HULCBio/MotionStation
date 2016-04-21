function generate_results(mode, testId),
%GENERATE_RESULTS - Perform all steps necessary to produce coverage
%results (workspace variables, coloring, report generation, etc.)
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/10/14 18:13:33 $

    global gCovDisplayOnModel;
    gCovDisplayOnModel = 0;
        
    switch(lower(mode))
    case 'pause'
        modeEnum = 1;
    case 'term'
        modeEnum = 2;
    otherwise,
        error('Unkown mode');
    end

    modelId = cv('get',testId,'.modelcov');
    modelH = cv('get',modelId,'.handle');

    % Get Dialog Settings
    varName = get_param(modelH,'CovSaveName');
    incVarName = strcmp(get_param(modelH,'CovNameIncrementing'),'on');
    makeReport = strcmp(get_param(modelH,'CovHtmlReporting'),'on');
    reportOptions = get_param(modelH,'CovHTMLOptions');
    relatedData = get_param(modelH,'CovCompData');
    modelName = cv('get',modelId,'.name');
    saveCumulativeToWorkspaceVar = strcmp(get_param(modelH, 'CovSaveCumulativeToWorkspaceVar'), 'on');
    saveSingleToWorkspaceVar = strcmp(get_param(modelH, 'CovSaveSingleToWorkspaceVar'), 'on');
    cumulativeVarName = get_param(modelH, 'CovCumulativeVarName');
    cumulativeReport = strcmp(get_param(modelH, 'CovCumulativeReport'), 'on');
    settingStr = get_param(modelH,'CovMetricSettings');
    modelDisplay = ~any(settingStr == 'e');
    
	% Autoscaling is only performed at the end of a simulation
	if (modeEnum==2)
    	isAutoscale = cv_is_model_autoscale(modelName);
    	
    	if isAutoscale
    		% Get range structure
    		covData = cvdata(testId);
    
    		% Add data to structure
    		cv_append_autoscale_data(covData)
    
    		% If we forced coverage, restore settings and return early
			isForce = cv_autoscale_settings('isForce', modelH);
            if isForce
                cv_autoscale_settings('restore', modelH);
        		return;
        	end
    	end
	end
	
    if (saveSingleToWorkspaceVar) & (~isempty(varName))
        if (incVarName)
            idx = get_last_var_num(varName);
            actVarName = [varName num2str(idx+1)];
        else
            actVarName = varName;
        end
        
        % If we are forcing coverage in Bat suppress the output display
        
        if strcmp(get_param(0,'ForceModelCoverage'),'on')
            expression = sprintf('%s = cvdata(%d);',actVarName,testId);
        else
            expression = sprintf('%s = cvdata(%d)',actVarName,testId);
        end
        evalin('base',expression);
    end

    % Warn about unsupported blocks
    if (strcmp(cv('Feature','skip uninstrumented'),'on'))
        metricNames = cv_metric_names([],settingStr);
        coveragePath = get_param(modelH,'CovPath');
        rootFullPath = modelName;
        if ~isempty(coveragePath)
            coveragePath = coveragePath(2:end); % Remove the initial '/'
            if ~isempty(coveragePath)
                rootFullPath = [rootFullPath '/' coveragePath];
            end
        end
        hasConditions = any(strcmp(metricNames,'condition')) | any(strcmp(metricNames,'mcdc'));
        cvmissingblks(rootFullPath,~hasConditions);
    end

	% Track cumulative results if this the end of a simulation
	% otherwise they will be counted twice
	if saveCumulativeToWorkspaceVar && modeEnum==2 && (~isempty(cumulativeVarName))
		%Calculate cumulative results
		rootId     = cv('get', testId, '.linkNode.parent');
		oldTotalId = cv('get', rootId, '.runningTotal');
		currentRun = cvdata(testId);
		if (isempty(oldTotalId) || oldTotalId == 0)
			newTotal = cvdata(testId);
		else %if (oldTotalId == 0)
			oldTotal = cvdata(oldTotalId);
			newTotal = currentRun + oldTotal;

			%Commit derived data to data dictionary
			newTotal = commitdd(newTotal);
		end; %if (oldTotalId == 0)

		%Record cumulative results
		cv('set', rootId, '.runningTotal', newTotal.id);

		assignin('base', cumulativeVarName, newTotal);
	end; %if saveCumulativeToWorkspaceVar & (~isempty(cumulativeVarName))


	if makeReport
		fileName = [ modelName '_cov.html'];
		if modelDisplay
		    gCovDisplayOnModel = 1;
		end
		if cumulativeReport && modeEnum==2
			if (oldTotalId == 0)
				cvhtml(fileName, cvdata(testId), reportOptions);
			else
				%Cumulative report
				delta = newTotal - oldTotal;
				delta = commitdd(delta);
				cv('set', currentRun.id, '.label', 'Current Run');
				cv('set', delta.id,      '.label', 'Delta');
				cv('set', newTotal.id,   '.label', 'Cumulative');
				cvhtml(fileName, currentRun, delta, newTotal, reportOptions, '-Cumulative_Report');
			end;
		else %if cumulativeReport
			if isempty(relatedData)
				cvhtml(fileName, cvdata(testId), reportOptions);
			else %if isempty(relatedData)
				Param = resolve_additional_data(relatedData);
				if isempty(Param)
					cvhtml(fileName, cvdata(testId), reportOptions);
				else
					cvhtml(fileName, Param{:}, cvdata(testId), reportOptions);
				end; %if isempty(Param)
			end %if isempty(relatedData)
		end; %if cumulativeReport
    else
        if modelDisplay
            dataTotal = cvdata(testId);
            if ~isempty(relatedData)
                dataVect = resolve_additional_data(relatedData);
                for i=1:length(dataVect)
                    dataTotal = dataTotal + dataVect{i};
                end
            end
            cvmodelview(dataTotal);
        end
	end %if makeReport


function dataVect = resolve_additional_data(dataStr)
	[name,rem] = strtok(dataStr, ' ,');
	dataVect = [];
	while(~isempty(name))
		try
			testParam = evalin('base', name);
			if testParam.rootId == cv('get', testId, '.linkNode.parent')
				dataVect = [dataVect {testParam}];    
			end; %if
		catch
			warning(sprintf('Error evaluating additional data: %s', name));
		end; %try/catch
		[name,rem] = strtok(rem, ' ,');
	end %while        



function idx = get_last_var_num(varName),

    l = length(varName)+1;
    nums = [];
    nameCell = evalin('base',['who(''' varName '*'')']);

    if isempty(nameCell)
        idx = 0;
        return;
    end

    for name = nameCell',
        if (length(name{1}) >= l)
            x = str2double(name{1}(l:end));
            if ~isnan(x)
                nums = [nums x];
            end
        end
    end

    if isempty(nums)
        idx = 0;
    else
        idx = max(nums);
    end


