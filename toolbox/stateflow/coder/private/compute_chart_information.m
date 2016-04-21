function	compute_chart_information(chart)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.17.6.11.2.1.2.1 $  $Date: 2004/04/22 12:30:14 $


	global gTargetInfo gChartInfo gMachineInfo

	gChartInfo.chartUniquePrefix = ''; % WISH remove it

	sortAllStatesByName = 1; % this will override the geometrical sort
                            % for AND states => required for G84273
    gChartInfo.encryptionEnabled = sf('get',chart,'chart.encryption.enabled');

    if(gChartInfo.encryptionEnabled)
        gChartInfo.codingDebug = 0;
    else
        gChartInfo.codingDebug = gTargetInfo.codingDebug;
    end

	gChartInfo.states = sf('SubstatesIn',chart,sortAllStatesByName);% passing 1 to get a lexicographic
	gChartInfo.functions = sf('FunctionsIn',chart);
	gChartInfo.chartTransitions = sf('Private','chart_real_transitions',chart);

	if(export_chart_functions(chart))
		gChartInfo.functionsToBeExported = sf('find',gChartInfo.functions,'state.treeNode.parent',chart);
	else
		gChartInfo.functionsToBeExported = [];
	end
	gChartInfo.functionsNotToBeExported = sf('Private','vset',gChartInfo.functions,'-',gChartInfo.functionsToBeExported);

	gChartInfo.chartData = sf('DataIn',chart);
	gChartInfo.chartDataNumbers = sf('get',gChartInfo.chartData,'data.number')';

	allTemporaryData = sf('find',gChartInfo.chartData,'data.scope','TEMPORARY_DATA');

	chartTemporaryData = sf('find',allTemporaryData,'data.linkNode.parent',chart);
	funcTemporaryData = sf('find',allTemporaryData,'~data.linkNode.parent',chart);


	% WISH fix this later. for now we consider temporary data same as local data

	if(sf('HasAtleastOneSubstate',chart))
		% has substates. cannot have temporary data
		gChartInfo.chartLocalData = [chartTemporaryData,sf('find',gChartInfo.chartData,'data.scope','LOCAL_DATA')];
		gChartInfo.chartLocalDataNumbers = sf('get',gChartInfo.chartLocalData,'data.number')';
		chartTemporaryData = [];
		chartTemporaryDataNumbers = [];
	else
		% stateless chart. can have temporary data
		gChartInfo.chartLocalData = [sf('find',gChartInfo.chartData,'data.scope','LOCAL_DATA')];
		gChartInfo.chartLocalDataNumbers = sf('get',gChartInfo.chartLocalData,'data.number')';
		chartTemporaryDataNumbers = sf('get',chartTemporaryData,'data.number')';
	end
	funcTemporaryDataNumbers = sf('get',funcTemporaryData,'data.number')';

	gChartInfo.chartConstantData = sf('find',gChartInfo.chartData,'data.scope','CONSTANT_DATA');
	gChartInfo.chartConstantDataNumbers = sf('get',gChartInfo.chartConstantData,'data.number')';

	chartParentedData = sf('DataOf',chart);

	gChartInfo.chartInputData = sf('find',chartParentedData,'data.scope','INPUT_DATA');
	gChartInfo.chartInputDataNumbers = sf('get',gChartInfo.chartInputData,'data.number')';

	gChartInfo.chartOutputData = sf('find',chartParentedData,'data.scope','OUTPUT_DATA');
	gChartInfo.chartOutputDataNumbers = sf('get',gChartInfo.chartOutputData,'data.number')';

    gChartInfo.chartEvents = sf('EventsIn',chart);
    gChartInfo.chartLocalEvents = sf('find',gChartInfo.chartEvents,'event.scope','LOCAL_EVENT');
    gChartInfo.chartOutputEvents = sf('find',gChartInfo.chartEvents,'event.scope','OUTPUT_EVENT');
    gChartInfo.chartInputEvents = sf('find',gChartInfo.chartEvents,'event.scope','INPUT_EVENT');
    gChartInfo.chartFcnCallOutputEvents = sf('find',gChartInfo.chartOutputEvents,'event.trigger','FUNCTION_CALL_EVENT');
    sf('set',gChartInfo.chartFcnCallOutputEvents,'event.functionCallIndex',[0:(length(gChartInfo.chartFcnCallOutputEvents)-1)]');

	gChartInfo.chartHasContinuousTime = 0;
	if gTargetInfo.codingSFunction
		[chartUpdateMethod,gChartInfo.chartSampleTime] = sf('get',chart,'chart.updateMethod','chart.sampleTime');
		switch(chartUpdateMethod)
		case 0 %%% INHERITED
			gChartInfo.chartSampleTime = 'INHERITED_SAMPLE_TIME';
			gChartInfo.chartSampleTimeString = '';
		case 1 %%% DISCRETE
			if(isempty(gChartInfo.chartSampleTime))
				% if sample time string is empty, error
				sf('Private','chartdlg','construct',chart);
				msgString = sprintf('Sampled update was specified and no sample time was entered in chart \n %s (#%d)' ,sf('FullNameOf',chart,'/'),chart);
				construct_coder_error(chart,msgString);
				gChartInfo.chartSampleTimeString = '0.0';
			else
				gChartInfo.chartSampleTimeString = gChartInfo.chartSampleTime;
			end
		case 2 %%% CONTINUOUS
			gChartInfo.chartSampleTime = 'CONTINUOUS_SAMPLE_TIME';
			gChartInfo.chartHasContinuousTime = 1;
			gChartInfo.chartSampleTimeString = '';
		otherwise
			construct_coder_error(chart,sprintf('Chart %d has invalid updateMethod',chart));
		end
	elseif gTargetInfo.codingRTW
	   if(sf('get',chart,'chart.updateMethod')==2)
	      msgString = sprintf('Continuous update specified for this chart %s (#%d).\n This is not supported for RTW.',...
	      sf('FullNameOf',chart,'/'),chart);
				construct_coder_error(chart,msgString);
	   end
	      
		gChartInfo.chartSampleTime = 'INHERITED_SAMPLE_TIME';
		gChartInfo.chartHasContinuousTime = 0;
		gChartInfo.chartSampleTimeString = '';
	else
		gChartInfo.chartSampleTime = 'INHERITED_SAMPLE_TIME';
		gChartInfo.chartHasContinuousTime = 0;
		gChartInfo.chartSampleTimeString = '';
	end

	if(gTargetInfo.codingSFunction)
		if(gTargetInfo.codingLibrary)
			if(length(gChartInfo.functionsToBeExported)>0)
				% This is a library chart which exports graphical functions.
				% Override the multi-instance switch
				gTargetInfo.codingMultiInstance = 0;
			else
				gTargetInfo.codingMultiInstance = 1;
			end
		end
	end

	if gTargetInfo.codingRTW
		gChartInfo.chartInstanceVarName = '%<LibSFChartInstance(block)>';
	else
		if(gTargetInfo.codingMultiInstance)
			gChartInfo.chartInstanceVarName = 'chartInstance->';
		else
			gChartInfo.chartInstanceVarName = 'chartInstance.';
		end
	end

   sf('UpdateUniqueNamesIn',chart,...
      gTargetInfo.codingPreserveNames,...
      gTargetInfo.codingPreserveNamesWithParent);

   initialize_data_information(gChartInfo.chartData,gChartInfo.chartDataNumbers);

   %%% Collect all testpoint data and states
   gChartInfo.testPoints = sf('TestPointsIn', chart, gChartInfo.codingDebug);
   gChartInfo.hasTestPoint = ~isempty(gChartInfo.testPoints.data) || ~isempty(gChartInfo.testPoints.state);
   
   sf('Cg','name_temporal_counters',chart,'temporalCounter_i');
