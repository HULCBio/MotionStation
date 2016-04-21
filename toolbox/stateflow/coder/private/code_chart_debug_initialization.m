function code_chart_debug_initialization(file...
													 ,chartFileNumber...
													 ,chart...
													 ,instancePathName...
													 ,simStructPtr)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.29.2.5.4.1 $  $Date: 2004/04/13 03:12:38 $


	global gMachineInfo gChartInfo	gDataInfo

	%%% Note that we need to count only those transitions that are not dangling
	%%% G68235
	chartTransitions = sf('find',gChartInfo.chartTransitions,'~transition.dst.id',0);
	
	transitionCount = length(chartTransitions);
	stateCount = length(sf('find',sf('get',chart,'chart.states'),'state.isNoteBox',0));
fprintf(file,'	{\n');
fprintf(file,'	unsigned int chartAlreadyPresent;\n');
fprintf(file,'	chartAlreadyPresent = sf_debug_initialize_chart(%s,\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'                                                   %.15g,\n',chartFileNumber);
fprintf(file,'                                                   %.15g,\n',stateCount);
fprintf(file,'                                                   %.15g,\n',transitionCount);
fprintf(file,'                                                   %.15g,\n',length(gChartInfo.chartDataNumbers));
fprintf(file,'                                                   %.15g,\n',length(gChartInfo.chartEvents));
fprintf(file,'                                                   %.15g,\n',length(gChartInfo.dataWithChangeEvent));
fprintf(file,'                                                   %.15g,\n',length(gChartInfo.statesWithEntryEvent));
fprintf(file,'                                                   %.15g,\n',length(gChartInfo.statesWithExitEvent));
fprintf(file,'                                                   &(%schartNumber),\n',gChartInfo.chartInstanceVarName);
fprintf(file,'                                                   &(%sinstanceNumber),\n',gChartInfo.chartInstanceVarName);
fprintf(file,'                                                   %s,\n',instancePathName);
fprintf(file,'                                                   %s);\n',simStructPtr);
fprintf(file,'	if(chartAlreadyPresent==0) {\n');
fprintf(file,'	/* this is the first instance */\n');

		index = 0;
		for data = gChartInfo.dataWithChangeEvent
fprintf(file,'	_SFD_DATA_CHANGE_EVENT_COUNT(%.15g,%.15g);\n',index,sf('get',data,'data.number'));
			index = index+1;
		end
		index = 0;
		for state = gChartInfo.statesWithEntryEvent
fprintf(file,'	_SFD_STATE_ENTRY_EVENT_COUNT(%.15g,%.15g);\n',index,sf('get',state,'state.number'));
			index = index+1;
		end
		index = 0;
		for state = gChartInfo.statesWithExitEvent
fprintf(file,'	_SFD_STATE_EXIT_EVENT_COUNT(%.15g,%.15g);\n',index,sf('get',state,'state.number'));
			index = index+1;
		end
	 disableImplicitCasting = sf('get',chart,'chart.disableImplicitCasting');



fprintf(file,' sf_debug_set_chart_disable_implicit_casting(%s,%schartNumber,%.15g);\n',gMachineInfo.machineNumberVariableName,gChartInfo.chartInstanceVarName,disableImplicitCasting);
fprintf(file,' sf_debug_set_chart_event_thresholds(%s,\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'                                     %schartNumber,\n',gChartInfo.chartInstanceVarName);
fprintf(file,'                                     %.15g,\n',gChartInfo.dataChangeEventThreshold);
fprintf(file,'                                     %.15g,\n',gChartInfo.stateEntryEventThreshold);
fprintf(file,'                                     %.15g);\n',gChartInfo.stateExitEventThreshold);
fprintf(file,' \n');

	for dataNumber = gChartInfo.chartDataNumbers
		data = gDataInfo.dataList(dataNumber+1);

		isChartInputData = is_chart_input_data(data);
		isChartOutputData	= is_chart_output_data(data);
		dataSizeArray = gDataInfo.dataSizeArrays{dataNumber+1};
		
		if(length(dataSizeArray)==0)
			numDims = 0;
			dimArray = 'NULL';
		else
fprintf(file,'		{\n');
fprintf(file,'			unsigned int dimVector[%.15g];\n',length(dataSizeArray));
			for i=0:length(dataSizeArray)-1
fprintf(file,'			dimVector[%.15g]= %.15g;\n',i,dataSizeArray(i+1));
			end
			numDims = length(dataSizeArray);
			dimArray = '&(dimVector[0])';
		end
		coderDataType = sf('CoderDataType',data);
		if(strcmp(coderDataType,'fixpt'))
			[fixPtBaseType,fixptExponent,fixptSlope,fixptBias,nBits,isSigned] =...
				sf('FixPtProps',data);
			isFixedPoint = '1';
			biasStr = sprintf('%.17g',fixptBias);
			slopeStr = sprintf('%.17g',fixptSlope);
			exponentStr = sprintf('%d',fixptExponent);
		else
			isFixedPoint = '0';
			biasStr = '0.0';
			slopeStr = '1.0';
			exponentStr = '0';
		end				

		isComplex = sf('get',data,'data.isComplex');
				
		dataName = sf('get',data,'data.name');
		isTemporaryData = ~isempty(sf('find',data,'data.scope','TEMPORARY_DATA'));
		isFcnInputData = ~isempty(sf('find',data,'data.scope','FUNCTION_INPUT_DATA'));
		isFcnOutputData = ~isempty(sf('find',data,'data.scope','FUNCTION_OUTPUT_DATA'));
		if isTemporaryData | isFcnInputData | isFcnOutputData
		    dataName = '';
		end

        v1 = dataNumber;
        v2 = sf('get',data,'data.scope');
        v3 = isChartInputData;
        v4 = isChartOutputData;
        v5 = gDataInfo.sfDataTypes{dataNumber+1};
        v6 = numDims;
        v7 = dimArray;
        v8 = isFixedPoint;
        v9 = biasStr;
        v10 = slopeStr;
        v11 = exponentStr;
		v12 = dataName;
		v13 = isComplex;

fprintf(file,'	_SFD_SET_DATA_PROPS(%.15g,%.15g,%.15g,%.15g,%s,%.15g,%s,%s,%s,%s,%s,"%s",%.15g);\n',v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13);
		if(length(dataSizeArray)>0)
fprintf(file,'		}\n');
		end
	end
	for event = gChartInfo.chartEvents
		[eventNumber,eventScope] = sf('get',event,'event.number','event.scope');
fprintf(file,'	_SFD_EVENT_SCOPE(%.15g,%.15g);\n',eventNumber,eventScope);
	end


	for state = [gChartInfo.states,gChartInfo.functions]
		[stateNumber,decomposition,type] = sf('get',state,'state.number','state.decomposition','state.type');
fprintf(file,'	_SFD_STATE_INFO(%.15g,%.15g,%.15g);\n',stateNumber,decomposition,type);
	end

	subStates = sf('SubstatesOf',chart);
fprintf(file,'	_SFD_CH_SUBSTATE_COUNT(%.15g);\n',length(subStates));
fprintf(file,'	_SFD_CH_SUBSTATE_DECOMP(%.15g);\n',sf('get',chart,'chart.decomposition'));
	for subStateIndex=1:length(subStates)
		subStateNumber = sf('get',subStates(subStateIndex),'state.number');
fprintf(file,'	_SFD_CH_SUBSTATE_INDEX(%.15g,%.15g);\n',(subStateIndex-1),subStateNumber);
	end
	states = sf('SubstatesIn',chart);
	for state = states
		subStates = sf('SubstatesOf',state);
		stateNumber = sf('get',state,'state.number');
fprintf(file,'	_SFD_ST_SUBSTATE_COUNT(%.15g,%.15g);\n',stateNumber,length(subStates));
		for subStateIndex=1:length(subStates)
			subStateNumber = sf('get',subStates(subStateIndex),'state.number');
fprintf(file,'	_SFD_ST_SUBSTATE_INDEX(%.15g,%.15g,%.15g);\n',stateNumber,(subStateIndex-1),subStateNumber);
		end
	end
fprintf(file,'	\n');
fprintf(file,'	}\n');

	if(sf('MatlabVersion')>=600)
	    %
	    % Initialize the chart coverage:
	    %
		
		 subStates = sf('SubstatesOf',chart);
	    chartHasDurSwitch = (sf('get',chart,'chart.coverageInfo.switchCount.during')>0);
fprintf(file,' _SFD_CV_INIT_CHART(%.15g,%.15g,0,0);\n',length(subStates),chartHasDurSwitch);

	    %
	    % Initialize the coverage tool for each state.
	    %
		for state = [gChartInfo.states,gChartInfo.functions]
			[stateNumber,histSwtch,durSwtch,exitSwtch,onDecCnt,startDecMap,endDecMap] = ...
				sf('get',state...
				,'state.number'...
				,'state.coverageInfo.switchCount.history'...
				,'state.coverageInfo.switchCount.during'...
				,'state.coverageInfo.switchCount.exit'...
				,'state.coverageInfo.decisionCount'...
				,'state.coverageInfo.map.start.decision'...
				,'state.coverageInfo.map.end.decision'...
				);
	        substateCount = length(sf('SubstatesOf',state));
			if (onDecCnt>0)
				startMpVar = '&(sStartDecMap[0])';
				endMpVar   = '&(sEndDecMap[0])';
			else
				startMpVar = 'NULL';
				endMpVar   = 'NULL';
			end
fprintf(file,'	{\n');
			if (onDecCnt>0)
fprintf(file,'		static unsigned int sStartDecMap[] = %s;\n',init_string_from_vector(startDecMap,'%d'));
fprintf(file,'		static unsigned int sEndDecMap[] = %s;\n',init_string_from_vector(endDecMap,'%d'));
			end
fprintf(file,'	    _SFD_CV_INIT_STATE(%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%s,%s);\n',stateNumber,substateCount,(durSwtch>0),(exitSwtch>0),(histSwtch>0),onDecCnt,startMpVar,endMpVar);
fprintf(file,'	}\n');
	    end
fprintf(file,'\n');

	    %
	    % Initialize the coverage tool for each transition.
	    %
    	for trans = chartTransitions
    		[transNumber,startGuardMap,endGuardMap,postfixPredicateTree] = ...
    		sf('get',trans...
    		,'transition.number'...
    		,'transition.coverageInfo.map.start.guard'...
    		,'transition.coverageInfo.map.end.guard'...
			,'transition.coverageInfo.postFixPredicateTree'...
    		);
    
    		if(length(startGuardMap))
fprintf(file,'	{\n');
fprintf(file,'		static unsigned int sStartGuardMap[] = %s;\n',init_string_from_vector(startGuardMap,'%d'));
fprintf(file,'		static unsigned int sEndGuardMap[] = %s;\n',init_string_from_vector(endGuardMap,'%d'));
fprintf(file,'		static int          sPostFixPredicateTree[] = %s;\n',init_string_from_vector(postfixPredicateTree,'%d'));
    			startGuardMapVar = '&(sStartGuardMap[0])';
    			endGuardMapVar   = '&(sEndGuardMap[0])';
				postfixPredicateTreeVar = '&(sPostFixPredicateTree[0])';
    		else
    			startGuardMapVar = 'NULL';
    			endGuardMapVar = 'NULL';
				postfixPredicateTreeVar = 'NULL';
    		end
	    	postfixPredicateTreeLength = length(postfixPredicateTree);
fprintf(file,'     _SFD_CV_INIT_TRANS(%.15g,%.15g,%s,%s,%.15g,%s);\n',transNumber,length(startGuardMap),startGuardMapVar,endGuardMapVar,postfixPredicateTreeLength,postfixPredicateTreeVar);
fprintf(file,'\n');
    		if(length(startGuardMap))
fprintf(file,'	}\n');
			end
    	end

	    %
	    % Initialize the coverage tool for each EML scirpt.
	    %
	    emlFcns = sf('Private','eml_fcns_in',chart);
	    if ~isempty(emlFcns)
fprintf(file,'\n');
fprintf(file,' /* Initialization of EML Model Coverage */\n');
	    for emlFcnId = emlFcns(:)'
	        stateNumber = sf('get',emlFcnId,'state.number');
	        fcnCovInfo = sf('get',emlFcnId,'state.eml.cvMapInfo');
            
        if ~isempty(fcnCovInfo)
	        fcnCnt = length(fcnCovInfo.fcnInfo);
	        ifCnt = length(fcnCovInfo.ifInfo);
	        forCnt = length(fcnCovInfo.forInfo);
	        whileCnt = length(fcnCovInfo.whileInfo);
	        switchCnt = length(fcnCovInfo.switchInfo);
	        condCnt = fcnCovInfo.condCnt;
	        mcdcCnt = length(fcnCovInfo.mcdcInfo);
fprintf(file,' _SFD_CV_INIT_EML(%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g);\n',stateNumber,fcnCnt,ifCnt,switchCnt,forCnt,whileCnt,condCnt,mcdcCnt);
            for i=1:fcnCnt
                fcnName = fcnCovInfo.fcnInfo(i).name;
                charStartIdx = fcnCovInfo.fcnInfo(i).charStartIdx;
                charExprEndIdx = fcnCovInfo.fcnInfo(i).charExprEndIdx;
                charEndIdx = fcnCovInfo.fcnInfo(i).charEndIdx;
fprintf(file,' _SFD_CV_INIT_EML_FCN(%.15g,%.15g,"%s",%.15g,%.15g,%.15g);\n',stateNumber,i-1,fcnName,charStartIdx,charExprEndIdx,charEndIdx);
            end
            for i=1:ifCnt
                charStartIdx = fcnCovInfo.ifInfo(i).charStartIdx;
                charExprEndIdx = fcnCovInfo.ifInfo(i).charExprEndIdx;
                charElseStartIdx = fcnCovInfo.ifInfo(i).charElseStartIdx;
                charEndIdx = fcnCovInfo.ifInfo(i).charEndIdx;
fprintf(file,' _SFD_CV_INIT_EML_IF(%.15g,%.15g,%.15g,%.15g,%.15g,%.15g);\n',stateNumber,i-1,charStartIdx,charExprEndIdx,charElseStartIdx,charEndIdx);
            end

            for i=1:forCnt
                charStartIdx = fcnCovInfo.forInfo(i).charStartIdx;
                charExprEndIdx = fcnCovInfo.forInfo(i).charExprEndIdx;
                charEndIdx = fcnCovInfo.forInfo(i).charEndIdx;
fprintf(file,' _SFD_CV_INIT_EML_FOR(%.15g,%.15g,%.15g,%.15g,%.15g);\n',stateNumber,i-1,charStartIdx,charExprEndIdx,charEndIdx);
            end

            for i=1:whileCnt
                charStartIdx = fcnCovInfo.whileInfo(i).charStartIdx;
                charExprEndIdx = fcnCovInfo.whileInfo(i).charExprEndIdx;
                charEndIdx = fcnCovInfo.whileInfo(i).charEndIdx;
fprintf(file,' _SFD_CV_INIT_EML_WHILE(%.15g,%.15g,%.15g,%.15g,%.15g);\n',stateNumber,i-1,charStartIdx,charExprEndIdx,charEndIdx);
            end

            for i=1:length(fcnCovInfo.switchInfo)
                charStartIdx = fcnCovInfo.switchInfo(i).charStartIdx;
                charExprEndIdx = fcnCovInfo.switchInfo(i).charExprEndIdx;
                charEndIdx = fcnCovInfo.switchInfo(i).charEndIdx;
                caseCnt = length(fcnCovInfo.switchInfo(i).cases);
                caseStart = [fcnCovInfo.switchInfo(i).cases.charStartIdx];
                caseExprEnd = [fcnCovInfo.switchInfo(i).cases.charExprEndIdx];
fprintf(file,'	{\n');
fprintf(file,'		static unsigned int caseStart[] = %s;\n',init_string_from_vector(caseStart,'%d'));
fprintf(file,'		static unsigned int caseExprEnd[] = %s;\n',init_string_from_vector(caseExprEnd,'%d'));
fprintf(file,'     _SFD_CV_INIT_EML_SWITCH(%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,&(caseStart[0]),&(caseExprEnd[0]));\n',stateNumber,i-1,charStartIdx,charExprEndIdx,charEndIdx,caseCnt);
fprintf(file,'	}\n');
            end

            for i=1:length(fcnCovInfo.mcdcInfo)
                charStart = fcnCovInfo.mcdcInfo(i).charStartIdx;
                charEnd = fcnCovInfo.mcdcInfo(i).charEndIdx;
                condCnt = length(fcnCovInfo.mcdcInfo(i).condition);
                firstCondIdx = fcnCovInfo.mcdcInfo(i).condition(1).condIdx;
                pfxLength = length(fcnCovInfo.mcdcInfo(i).postFixExpr);
                condStart = [fcnCovInfo.mcdcInfo(i).condition.charStartIdx];
                condEnd = [fcnCovInfo.mcdcInfo(i).condition.charEndIdx];
                postFixExpr = fcnCovInfo.mcdcInfo(i).postFixExpr;
fprintf(file,'	{\n');
fprintf(file,'		static unsigned int condStart[] = %s;\n',init_string_from_vector(condStart,'%d'));
fprintf(file,'		static unsigned int condEnd[] = %s;\n',init_string_from_vector(condEnd,'%d'));
fprintf(file,'		static int          pfixExpr[] = %s;\n',init_string_from_vector(postFixExpr,'%d'));
fprintf(file,'     _SFD_CV_INIT_EML_MCDC(%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,&(condStart[0]),&(condEnd[0]),%.15g,&(pfixExpr[0]));\n',stateNumber,i-1,charStart,charEnd,condCnt,firstCondIdx,pfxLength);
fprintf(file,'	}\n');

            end
        end
        end
        end
	end

	for state = [gChartInfo.states,gChartInfo.functions]
		[stateNumber,entryWeight,duringWeight,exitWeight,...
		startEntryMap,startDuringMap,startExitMap,...
		endEntryMap,endDuringMap,endExitMap] = ...
			sf('get',state...
			,'state.number'...
			,'state.coverageInfo.index.entry'...
			,'state.coverageInfo.index.during'...
			,'state.coverageInfo.index.exit'...
			,'state.coverageInfo.map.start.entry'...
			,'state.coverageInfo.map.start.during'...
			,'state.coverageInfo.map.start.exit'...
			,'state.coverageInfo.map.end.entry'...
			,'state.coverageInfo.map.end.during'...
			,'state.coverageInfo.map.end.exit'...
			);
fprintf(file,'	_SFD_STATE_COV_WTS(%.15g,%.15g,%.15g,%.15g);\n',stateNumber,entryWeight,duringWeight,exitWeight);
fprintf(file,'	if(chartAlreadyPresent==0)\n');
fprintf(file,'	{\n');
		if(length(startEntryMap))
fprintf(file,'		static unsigned int sStartEntryMap[] = %s;\n',init_string_from_vector(startEntryMap,'%d'));
fprintf(file,'		static unsigned int sEndEntryMap[] = %s;\n',init_string_from_vector(endEntryMap,'%d'));
			startEntryMapVar = '&(sStartEntryMap[0])';
			endEntryMapVar   = '&(sEndEntryMap[0])';
		else
			startEntryMapVar = 'NULL';
			endEntryMapVar = 'NULL';
		end
		if(length(startDuringMap))
fprintf(file,'		static unsigned int sStartDuringMap[] = %s;\n',init_string_from_vector(startDuringMap,'%d'));
fprintf(file,'		static unsigned int sEndDuringMap[] = %s;\n',init_string_from_vector(endDuringMap,'%d'));
			startDuringMapVar = '&(sStartDuringMap[0])';
			endDuringMapVar   = '&(sEndDuringMap[0])';
		else
			startDuringMapVar = 'NULL';
			endDuringMapVar = 'NULL';
		end
		if(length(startExitMap))
fprintf(file,'		static unsigned int sStartExitMap[] = %s;\n',init_string_from_vector(startExitMap,'%d'));
fprintf(file,'		static unsigned int sEndExitMap[] = %s;\n',init_string_from_vector(endExitMap,'%d'));
			startExitMapVar = '&(sStartExitMap[0])';
			endExitMapVar   = '&(sEndExitMap[0])';
		else
			startExitMapVar = 'NULL';
			endExitMapVar = 'NULL';
		end
fprintf(file,'	\n');
fprintf(file,'		_SFD_STATE_COV_MAPS(%.15g,\n',stateNumber);
fprintf(file,'		%.15g,%s,%s,\n',length(startEntryMap),startEntryMapVar,endEntryMapVar);
fprintf(file,'		%.15g,%s,%s,\n',length(startDuringMap),startDuringMapVar,endDuringMapVar);
fprintf(file,'		%.15g,%s,%s);\n',length(startExitMap),startExitMapVar,endExitMapVar);
fprintf(file,'	}\n');
	end
	for trans = chartTransitions
		[transNumber,triggerWeight,guardWeight,conditionActionWeight,transitionActionWeight...
		startTriggerMap,startGuardMap,startConditionActionMap,startTransitionActionMap...
		endTriggerMap,endGuardMap,endConditionActionMap,endTransitionActionMap] = ...
		sf('get',trans...
		,'transition.number'...
		,'transition.coverageInfo.index.trigger'...
		,'transition.coverageInfo.index.guard'...
		,'transition.coverageInfo.index.conditionAction'...
		,'transition.coverageInfo.index.transitionAction'...
		,'transition.coverageInfo.map.start.trigger'...
		,'transition.coverageInfo.map.start.guard'...
		,'transition.coverageInfo.map.start.conditionAction'...
		,'transition.coverageInfo.map.start.transitionAction'...
		,'transition.coverageInfo.map.end.trigger'...
		,'transition.coverageInfo.map.end.guard'...
		,'transition.coverageInfo.map.end.conditionAction'...
		,'transition.coverageInfo.map.end.transitionAction'...
		);
fprintf(file,'	_SFD_TRANS_COV_WTS(%.15g,%.15g,%.15g,%.15g,%.15g);\n',transNumber,triggerWeight,guardWeight,conditionActionWeight,transitionActionWeight);
fprintf(file,'	if(chartAlreadyPresent==0)\n');
fprintf(file,'	{\n');
		if(length(startTriggerMap))
fprintf(file,'		static unsigned int sStartTriggerMap[] = %s;\n',init_string_from_vector(startTriggerMap,'%d'));
fprintf(file,'		static unsigned int sEndTriggerMap[] = %s;\n',init_string_from_vector(endTriggerMap,'%d'));
			startTriggerMapVar = '&(sStartTriggerMap[0])';
			endTriggerMapVar   = '&(sEndTriggerMap[0])';
		else
			startTriggerMapVar = 'NULL';
			endTriggerMapVar = 'NULL';
		end
		if(length(startGuardMap))
fprintf(file,'		static unsigned int sStartGuardMap[] = %s;\n',init_string_from_vector(startGuardMap,'%d'));
fprintf(file,'		static unsigned int sEndGuardMap[] = %s;\n',init_string_from_vector(endGuardMap,'%d'));
			startGuardMapVar = '&(sStartGuardMap[0])';
			endGuardMapVar   = '&(sEndGuardMap[0])';
		else
			startGuardMapVar = 'NULL';
			endGuardMapVar = 'NULL';
		end
		if(length(startConditionActionMap))
fprintf(file,'		static unsigned int sStartConditionActionMap[] = %s;\n',init_string_from_vector(startConditionActionMap,'%d'));
fprintf(file,'		static unsigned int sEndConditionActionMap[] = %s;\n',init_string_from_vector(endConditionActionMap,'%d'));
			startConditionActionMapVar = '&(sStartConditionActionMap[0])';
			endConditionActionMapVar   = '&(sEndConditionActionMap[0])';
		else
			startConditionActionMapVar = 'NULL';
			endConditionActionMapVar = 'NULL';
		end
		if(length(startTransitionActionMap))
fprintf(file,'		static unsigned int sStartTransitionActionMap[] = %s;\n',init_string_from_vector(startTransitionActionMap,'%d'));
fprintf(file,'		static unsigned int sEndTransitionActionMap[] = %s;\n',init_string_from_vector(endTransitionActionMap,'%d'));
			startTransitionActionMapVar = '&(sStartTransitionActionMap[0])';
			endTransitionActionMapVar   = '&(sEndTransitionActionMap[0])';
		else
			startTransitionActionMapVar = 'NULL';
			endTransitionActionMapVar = 'NULL';
		end

fprintf(file,'		_SFD_TRANS_COV_MAPS(%.15g,\n',transNumber);
fprintf(file,'		%.15g,%s,%s,\n',length(startTriggerMap),startTriggerMapVar,endTriggerMapVar);
fprintf(file,'		%.15g,%s,%s,\n',length(startGuardMap),startGuardMapVar,endGuardMapVar);
fprintf(file,'		%.15g,%s,%s,\n',length(startConditionActionMap),startConditionActionMapVar,endConditionActionMapVar);
fprintf(file,'		%.15g,%s,%s);\n',length(startTransitionActionMap),startTransitionActionMapVar,endTransitionActionMapVar);
fprintf(file,'\n');
fprintf(file,'	}\n');
	end

	for dataNumber = gChartInfo.chartDataNumbers
		data = gDataInfo.dataList(dataNumber+1);
		dataSizeArray = gDataInfo.dataSizeArrays{dataNumber+1};
		isTemporaryData = sf('IsTemporaryData',data);
		dataScope = sf('get',data,'data.scope');
		isFunctionIO = (dataScope==8) |(dataScope==9);

		isChartInputData = is_chart_input_data(data);
		isChartOutputData	= is_chart_output_data(data);
		
		if(length(dataSizeArray)==2 &...
		   (isChartInputData | isChartOutputData))
		   dataSizeArray = dataSizeArray(1)*dataSizeArray(2);
		end
      if(isTemporaryData || isFunctionIO)
fprintf(file,'	_SFD_SET_DATA_VALUE_PTR(%.15g,(void *)(NULL));	\n',dataNumber);
      end	
	end
   x = sf('Cg','get_cg_fcn_data',chart);
   str = sf('Cg','get_fcn_body',x.chartDebugDataInitializer);
fprintf(file,'%s\n',str);
fprintf(file,'}\n');



function str = init_string_from_vector(vect,formatStr)

	if(length(vect)==0)
		construct_coder_error([],'Internal error. init_string_from_vector cannot be called with empty vector');
	end

	str = ['{',sprintf(formatStr,vect(1))];
	for i=2:length(vect)
		str = [str,',',sprintf(formatStr,vect(i))];
	end
	str = [str,'}'];