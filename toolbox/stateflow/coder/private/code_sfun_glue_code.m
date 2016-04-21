function file = code_sfun_glue_code(fileNameInfo,file,...
                             chart,...
                             chartUniqueName)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.40.4.19.2.1 $  $Date: 2004/04/13 03:12:39 $

    %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
    global gTargetInfo gChartInfo gDataInfo gMachineInfo

    disableImplicitCasting = sf('get',chart,'chart.disableImplicitCasting');
    chartExecuteAtInitialization    = sf('get',chart,'chart.executeAtInitialization');
    chartFileNumber = sf('get',chart,'chart.chartFileNumber');

   [uniqueWkspDataNames,wkspData,II,JJ] = sf('Private','get_wksp_data_names_for_chart',chart);
   uniqueWskpData = wkspData(II);

   uniqueWskpDataNumbers = sf('get',uniqueWskpData,'data.number');
fprintf(file,'/* SFunction Glue Code */\n');

   if gChartInfo.hasTestPoint
fprintf(file,'static void init_test_point_mapping_info(SimStruct *S);\n');
   end

fprintf(file,'void sf_%s_get_check_sum(mxArray *plhs[])\n',chartUniqueName);
fprintf(file,'{\n');
        checksumVector = sf('get',chart,'chart.checksum');
        for i=1:4
fprintf(file,'         ((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
        end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'mxArray *sf_%s_get_autoinheritance_info(void)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'     const char *autoinheritanceInfoStructFieldNames[] = {"checksum","inputTypes","outputSizes","outputTypes"};\n');
fprintf(file,'     mxArray *mxAutoinheritanceInfo = NULL;\n');
fprintf(file,'     mxArray *mxChecksum = NULL;\n');
fprintf(file,'     mxArray *mxInputTypes = NULL;\n');
fprintf(file,'     mxArray *mxOutputSizes = NULL;\n');
fprintf(file,'     mxArray *mxOutputTypes = NULL;\n');
fprintf(file,'\n');
fprintf(file,'     mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,\n');
fprintf(file,'                                sizeof(autoinheritanceInfoStructFieldNames)/sizeof(char *),\n');
fprintf(file,'                                autoinheritanceInfoStructFieldNames);\n');
fprintf(file,'\n');
fprintf(file,'     mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);\n');
        checksumVector = sf('SyncEMLAutoinheritanceChecksum', chart);
        for i=1:4
fprintf(file,'         ((real_T *)mxGetPr((mxChecksum)))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
        end
fprintf(file,'\n');
	    numInputs = length(gChartInfo.chartInputData);
fprintf(file,'     mxInputTypes = mxCreateDoubleMatrix(1,%.15g,mxREAL);\n',numInputs);
        for i=0:numInputs-1
            data = gChartInfo.chartInputData(i+1);
            dataType = sf('get', data, '.parsedInfo.dataType');
fprintf(file,'         ((real_T *)mxGetPr((mxInputTypes)))[%.15g] = (real_T)(%.15gU);\n',(i),dataType);
        end
fprintf(file,'\n');
        numOutputs = length(gChartInfo.chartOutputData);
fprintf(file,'     mxOutputSizes = mxCreateDoubleMatrix(2,%.15g,mxREAL);\n',numOutputs);
fprintf(file,'     mxOutputTypes = mxCreateDoubleMatrix(1,%.15g,mxREAL);\n',numOutputs);
        for i=0:numOutputs-1
            data = gChartInfo.chartOutputData(i+1);
            dataSize = sf('get', data, '.parsedInfo.array.size');
            while (length(dataSize)<2)
                dataSize(end+1) = 1;
            end
fprintf(file,'         ((real_T *)mxGetPr((mxOutputSizes)))[%.15g] = (real_T)(%.15gU);\n',(2*i),dataSize(1));
fprintf(file,'         ((real_T *)mxGetPr((mxOutputSizes)))[%.15g] = (real_T)(%.15gU);\n',(2*i+1),dataSize(2));
            dataType = sf('get', data, '.parsedInfo.dataType');
fprintf(file,'         ((real_T *)mxGetPr((mxOutputTypes)))[%.15g] = (real_T)(%.15gU);\n',(i),dataType);
        end
fprintf(file,'\n');
fprintf(file,'     mxSetFieldByNumber(mxAutoinheritanceInfo,0,0,mxChecksum);\n');
fprintf(file,'     mxSetFieldByNumber(mxAutoinheritanceInfo,0,1,mxInputTypes);\n');
fprintf(file,'     mxSetFieldByNumber(mxAutoinheritanceInfo,0,2,mxOutputSizes);\n');
fprintf(file,'     mxSetFieldByNumber(mxAutoinheritanceInfo,0,3,mxOutputTypes);\n');
fprintf(file,'\n');
fprintf(file,'     return(mxAutoinheritanceInfo);\n');
fprintf(file,'}\n');
fprintf(file,'\n');
   if(gChartInfo.codingDebug)
fprintf(file,'static void chart_debug_initialization(SimStruct *S)\n');
fprintf(file,'{\n');
      if(gTargetInfo.codingMultiInstance)
fprintf(file,'      %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'      chartInstance = ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;\n');
      end
fprintf(file,'   if(ssIsFirstInitCond(S)) {\n');
fprintf(file,'      /* do this only if simulation is starting */\n');
         if gTargetInfo.codingSFunction
            instancePathName = 'ssGetPath(S)';
            simstructPtr = '(void *)S';
         else
            instancePathName = 'NULL';
            simstructPtr = 'NULL';
         end
         if(~chartExecuteAtInitialization)
fprintf(file,'         if(!sim_mode_is_rtw_gen(S)) {\n');
         end
   	      fclose(file);
   	         	      
         	%%% Note that we need to count only those transitions that are not dangling
         	%%% G68235
	      	chartTransitions = sf('find',gChartInfo.chartTransitions,'~transition.dst.id',0);
   	      chartNumber = sf('get',chart,'chart.number');
   	      debugInfo.chart = chart;
   	      debugInfo.chartStates = gChartInfo.states;
   	      debugInfo.chartFunctions = gChartInfo.functions;
   	      debugInfo.chartTransitions = chartTransitions;
   	      debugInfo.chartDataNumbers = gChartInfo.chartDataNumbers;
   	      debugInfo.chartEvents = gChartInfo.chartEvents;
   	      debugInfo.instancePathName = instancePathName;
   	      debugInfo.simStructPtr = simstructPtr;
   	      debugInfo.dataChangeEventThreshold = gChartInfo.dataChangeEventThreshold;
   	      debugInfo.stateEntryEventThreshold = gChartInfo.stateEntryEventThreshold;
   	      debugInfo.stateExitEventThreshold = gChartInfo.stateExitEventThreshold;
   	      debugInfo.fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
   	      debugInfo.dataList = gDataInfo.dataList;
   	      debugInfo.statesWithEntryEvent = gChartInfo.statesWithEntryEvent;  
   	      debugInfo.statesWithExitEvent = gChartInfo.statesWithExitEvent;
   	      debugInfo.dataWithChangeEvent = gChartInfo.dataWithChangeEvent;
   	      debugInfo.chartInstanceVarName = gChartInfo.chartInstanceVarName;
   	      debugInfo.machineNumberVariableName = gMachineInfo.machineNumberVariableName;
   	      sf('Cg','dump_chart_debug_init',debugInfo);
   	      file = fopen(debugInfo.fileName,'a');
         if(~chartExecuteAtInitialization)
fprintf(file,'         }\n');
         end
fprintf(file,'   } else {\n');
fprintf(file,'      sf_debug_reset_current_state_configuration(%s,%schartNumber,%sinstanceNumber);\n',gMachineInfo.machineNumberVariableName,gChartInfo.chartInstanceVarName,gChartInfo.chartInstanceVarName);
fprintf(file,'   }\n');
fprintf(file,'}\n');
fprintf(file,'\n');
   end
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_initialize_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
      if(gChartInfo.codingDebug)
fprintf(file,'   chart_debug_initialization(((%s*) chartInstanceVar)->S);\n',gChartInfo.chartInstanceTypedef);
      end
fprintf(file,'   initialize_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
      if(gChartInfo.codingDebug)
fprintf(file,'   chart_debug_initialization(chartInstance.S);\n');
      end
fprintf(file,'   initialize_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_enable_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   enable_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   enable_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_disable_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   disable_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'   disable_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');

fprintf(file,'static void sf_opaque_gateway_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   sf_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    sf_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_terminate_%s(void *chartInstanceVar)\n',chartUniqueName);
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,' if(chartInstanceVar!=NULL) {\n');
fprintf(file,'     SimStruct *S = ((%s*) chartInstanceVar)->S;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'     sf_clear_rtw_identifier(S);\n');
fprintf(file,'     finalize_%s((%s*) chartInstanceVar);\n',chartUniqueName,gChartInfo.chartInstanceTypedef);

        if gChartInfo.hasTestPoint
fprintf(file,'     if(!sim_mode_is_rtw_gen(S)) {\n');
fprintf(file,'        ssSetModelMappingInfoPtr(S, NULL);\n');
fprintf(file,'     }\n');
        end

fprintf(file,'     free((void *)chartInstanceVar);\n');
fprintf(file,'     ssSetUserData(S,NULL);\n');
fprintf(file,' }\n');
   else
fprintf(file,'   finalize_%s();\n',chartUniqueName);
   end
fprintf(file,'}\n');
fprintf(file,'\n');
   if gChartInfo.chartHasContinuousTime
fprintf(file,'static void sf_opaque_store_current_config(void *chartInstanceVar)\n');
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   store_current_config((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    store_current_config();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_restore_before_last_major_step(void *chartInstanceVar)\n');
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   restore_before_last_major_step((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    restore_before_last_major_step();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void sf_opaque_restore_last_major_step(void *chartInstanceVar)\n');
fprintf(file,'{\n');
    if gTargetInfo.codingMultiInstance
fprintf(file,'   restore_last_major_step((%s*) chartInstanceVar);\n',gChartInfo.chartInstanceTypedef);
   else
fprintf(file,'    restore_last_major_step();\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');

   end
fprintf(file,'static void mdlSetWorkWidths_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
      for i=1:length(gChartInfo.functionsToBeExported)
         expFcnName = sf('get',gChartInfo.functionsToBeExported(i),'.name');
fprintf(file,'   ssRegMdlInfo(S, "%s", MDL_INFO_ID_GRPFCNNAME, 0, 0, (void*) ssGetPath(S));\n',expFcnName);
      end
      %%% set number of s-function parameters
      if(length(uniqueWskpData)>0)
         for i= 1:length(uniqueWskpData)
            if(i==1)
               paramNames = sprintf('"p%d"',i);
            else
               paramNames = sprintf('%s,"p%d"',paramNames,i);
            end
         end
fprintf(file,'   /* Actual parameters from chart:\n');
fprintf(file,'      %s\n',sprintf('%s ',uniqueWkspDataNames{:}));
fprintf(file,'   */\n');
fprintf(file,'   const char_T *rtParamNames[] = {%s};\n',paramNames);
fprintf(file,'\n');
fprintf(file,'   ssSetNumRunTimeParams(S,ssGetSFcnParamsCount(S));\n');
         for i= 1:length(uniqueWskpData)
            dataId = uniqueWskpData(i);
            dataNumber = sf('get',dataId,'data.number');
               actualDataType = sf('CoderDataType',dataId);
fprintf(file,'   /* registration for %s*/\n',uniqueWkspDataNames{i});
               if(strcmp(actualDataType,'fixpt'))
                   [fixPtBaseType,fixptExponent,fixptSlope,fixptBias] =...
                       sf('FixPtProps',dataId);
fprintf(file,'     {\n');
fprintf(file,'         DTypeId dataTypeId =\n');
fprintf(file,'         sf_get_fixpt_data_type_id(S,\n');
fprintf(file,'                                             %s,\n',gDataInfo.slDataTypes{dataNumber+1});
fprintf(file,'                                             (int)%s,\n',sprintf('%d',fixptExponent));
fprintf(file,'                                             (double)%s,\n',sprintf('%.17g',fixptSlope));
fprintf(file,'                                             (double)%s);\n',sprintf('%.17g',fixptBias));
fprintf(file,'         ssRegDlgParamAsRunTimeParam(S, %.15g, %.15g, rtParamNames[%.15g], dataTypeId);\n',(i-1),(i-1),(i-1));
fprintf(file,'      }\n');
            else
fprintf(file,'         ssRegDlgParamAsRunTimeParam(S, %.15g, %.15g, rtParamNames[%.15g], %s);\n',(i-1),(i-1),(i-1),gDataInfo.slDataTypes{dataNumber+1});
            end
         end
fprintf(file,'\n');
     end

fprintf(file,' if(sim_mode_is_rtw_gen(S)) {\n');
fprintf(file,'     int_T chartIsInlinable =\n');
fprintf(file,'               (int_T)sf_is_chart_inlinable("%s",%.15g);\n',gMachineInfo.machineName,chartFileNumber);
fprintf(file,'     int_T chartIsMultiInstanced =\n');
fprintf(file,'               (int_T)sf_is_chart_multi_instanced("%s",%.15g);\n',gMachineInfo.machineName,chartFileNumber);
fprintf(file,'         ssSetStateflowIsInlinable(S,chartIsInlinable);\n');
fprintf(file,'     ssSetEnableFcnIsTrivial(S,1);\n');
fprintf(file,'     ssSetDisableFcnIsTrivial(S,1);\n');
        portNum = 0;
fprintf(file,'     if(chartIsInlinable) {            \n');
            for dataNumber = gChartInfo.chartInputDataNumbers
              %%% if the chart is wholy inlinable, 
              %%% its inputs reusable for RTW optimization
fprintf(file,'           ssSetInputPortOptimOpts(S, %.15g, SS_REUSABLE_AND_LOCAL);\n',portNum);
              portNum = portNum + 1;
            end
            if(length(gChartInfo.chartInputDataNumbers)>0)
fprintf(file,'             sf_mark_chart_expressionable_inputs(S,"%s",%.15g,%.15g);\n',gMachineInfo.machineName,chartFileNumber,length(gChartInfo.chartInputDataNumbers));
            end
            if(length(gChartInfo.chartOutputDataNumbers)>0)
fprintf(file,'             sf_mark_chart_reusable_outputs(S,"%s",%.15g,%.15g);\n',gMachineInfo.machineName,chartFileNumber,length(gChartInfo.chartOutputDataNumbers));
            end
fprintf(file,'     }\n');
        if ~isempty(gChartInfo.chartInputEvents)          
fprintf(file,'       ssSetInputPortOptimOpts(S, %.15g, SS_REUSABLE_AND_LOCAL);\n',portNum);
        end
fprintf(file,'     if (!sf_is_chart_instance_optimized_out("%s",%.15g)) {\n',gMachineInfo.machineName,chartFileNumber);
fprintf(file,'         int dtId;\n');
fprintf(file,'         char *chartInstanceTypedefName =\n');
fprintf(file,'             sf_chart_instance_typedef_name("%s",%.15g);\n',gMachineInfo.machineName,chartFileNumber);
fprintf(file,'         dtId = ssRegisterDataType(S, chartInstanceTypedefName);\n');
fprintf(file,'         if (dtId == INVALID_DTYPE_ID ) return;\n');

fprintf(file,'         /* Register the size of the udt */\n');
fprintf(file,'         if (!ssSetDataTypeSize(S, dtId, 8)) return;\n');

fprintf(file,'         if(!ssSetNumDWork(S,1)) return;\n');
fprintf(file,'         ssSetDWorkDataType(S, 0, dtId);\n');
fprintf(file,'         ssSetDWorkWidth(S, 0, 1);\n');
fprintf(file,'         ssSetDWorkName(S, 0, "ChartInstance"); /*optional name, less than 16 chars*/\n');
            %% This needs to be featured off until tsfrtw('lvlTwoA15') is working.
fprintf(file,'         sf_set_rtw_identifier(S);\n');
fprintf(file,'     }\n');
            hasMachineEvents = ~isempty(gMachineInfo.machineEvents);
            hasExportedChartFunctions = sf('get', chart,'chart.exportChartFunctions');   
            hasFcnCallOutputs = ~isempty(gChartInfo.chartFcnCallOutputEvents);
            if(0 && hasFcnCallOutputs)
fprintf(file,'           ssSetHasSubFunctions(S,1);\n');
            else
fprintf(file,'           ssSetHasSubFunctions(S,!(chartIsInlinable));\n');
            end
            if ~(hasMachineEvents || hasExportedChartFunctions)
fprintf(file,'           ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);\n');
            end
            if (sf('get',chart,'chart.executeAtInitialization'))
fprintf(file,'           ssSetCallsOutputInInitFcn(S,1);\n');
            end
fprintf(file,' }\n');
fprintf(file,'\n');
    checksumVector = double((sf('get',chart,'chart.checksum')));
fprintf(file,' ssSetChecksum0(S,(%.15gU));\n',checksumVector(1));
fprintf(file,' ssSetChecksum1(S,(%.15gU));\n',checksumVector(2));
fprintf(file,' ssSetChecksum2(S,(%.15gU));\n',checksumVector(3));
fprintf(file,' ssSetChecksum3(S,(%.15gU));\n',checksumVector(4));
fprintf(file,'\n');
   if(sf('Feature','Sl Event Binding'))
fprintf(file,'   ssSetExplicitFCSSCtrl(S,1);\n');
   end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void mdlRTW_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
      if(sf('Feature','RTW New Symbol Naming'))
fprintf(file,'     sf_write_symbol_mapping(S, "%s", %.15g);\n',gMachineInfo.machineName,chartFileNumber);
      end
      if(sf('Private','is_eml_chart',chart))
fprintf(file,'	   ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");\n');
      else
fprintf(file,'	   ssWriteRTWStrParam(S, "StateflowChartType", "Stateflow");\n');
      end
fprintf(file,'      \n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'static void mdlStart_%s(SimStruct *S)\n',chartUniqueName);
fprintf(file,'{\n');
       if gTargetInfo.codingMultiInstance
fprintf(file,' %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,' chartInstance = (%s *)malloc(sizeof(%s));\n',gChartInfo.chartInstanceTypedef,gChartInfo.chartInstanceTypedef);
fprintf(file,' if(chartInstance==NULL) {\n');
fprintf(file,'     sf_mex_error_message("Could not allocate memory for chart instance.");\n');
fprintf(file,' }\n');
fprintf(file,' %schartInfo.chartInstance = chartInstance;\n',gChartInfo.chartInstanceVarName);
       else
fprintf(file,' %schartInfo.chartInstance = NULL;\n',gChartInfo.chartInstanceVarName);
       end
      
fprintf(file,' %schartInfo.isEMLChart = %.15g;\n',gChartInfo.chartInstanceVarName,sf('Private','is_eml_chart',chart));
fprintf(file,' %schartInfo.chartInitialized = 0;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.sFunctionGateway = sf_opaque_gateway_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.initializeChart = sf_opaque_initialize_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.terminateChart = sf_opaque_terminate_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.enableChart = sf_opaque_enable_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.disableChart = sf_opaque_disable_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.mdlRTW = mdlRTW_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.mdlStart = mdlStart_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);
fprintf(file,' %schartInfo.mdlSetWorkWidths = mdlSetWorkWidths_%s;\n',gChartInfo.chartInstanceVarName,chartUniqueName);

       if gChartInfo.chartHasContinuousTime
fprintf(file,' %schartInfo.restoreLastMajorStepConfiguration = sf_opaque_restore_last_major_step;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.restoreBeforeLastMajorStepConfiguration = sf_opaque_restore_before_last_major_step;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.storeCurrentConfiguration = sf_opaque_store_current_config;\n',gChartInfo.chartInstanceVarName);
       else
fprintf(file,' %schartInfo.restoreLastMajorStepConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.restoreBeforeLastMajorStepConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' %schartInfo.storeCurrentConfiguration = NULL;\n',gChartInfo.chartInstanceVarName);
       end
      
fprintf(file,' %sS = S;\n',gChartInfo.chartInstanceVarName);
fprintf(file,' ssSetUserData(S,(void *)(&(%schartInfo))); %s\n',gChartInfo.chartInstanceVarName,sf_comment('/* register the chart instance with simstruct */'));

      if gChartInfo.hasTestPoint
fprintf(file,'\n');
fprintf(file,'     if(!sim_mode_is_rtw_gen(S)) {\n');
fprintf(file,'       init_test_point_mapping_info(S);\n');
fprintf(file,'     }\n');
      end
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'void %s_method_dispatcher(SimStruct *S, int_T method, void *data)\n',chartUniqueName);
fprintf(file,'{\n');
fprintf(file,'  switch (method) {\n');
fprintf(file,'  case SS_CALL_MDL_START:\n');
fprintf(file,'    mdlStart_%s(S);\n',chartUniqueName);
fprintf(file,'    break;\n');
fprintf(file,'  case SS_CALL_MDL_SET_WORK_WIDTHS:\n');
fprintf(file,'    mdlSetWorkWidths_%s(S);\n',chartUniqueName);
fprintf(file,'    break;\n');
fprintf(file,'  default:\n');
fprintf(file,'    /* Unhandled method */\n');
fprintf(file,'    sf_mex_error_message("Stateflow Internal Error:\\n"\n');
fprintf(file,'                         "Error calling %s_method_dispatcher.\\n"\n',chartUniqueName);
fprintf(file,'                         "Can''t handle method %%d.\\n", method);\n');
fprintf(file,'    break;\n');
fprintf(file,'  }\n');
fprintf(file,'}\n');
fprintf(file,'\n');

   if gChartInfo.hasTestPoint
      dump_capi_data_mapping_info_code(file, chart);
   end
   
   return;

function dataTypeMap = construct_capi_data_type_map(testPointData, testPointStates)

   global gDataInfo
   
   numTpData = length(testPointData);
   dataTypeMap = cell(numTpData, 1);
   
   tpDataNumbers = sf('get', testPointData, 'data.number');
   isComplex = sf('get', testPointData, 'data.isComplex');

   for i = 1:numTpData
      %%% {cName, mwName, numElements, elemMapIndex, dataSize, slDataId, isComplex, isPointer} as a string
      
      idx = tpDataNumbers(i) + 1;
      mwTypeName = gDataInfo.dataTypes{idx};
      cTypeName = mwTypeName; %%% should not matter
      slTypeName = gDataInfo.slDataTypes{idx};
      
      dataTypeEntry = sprintf('{"%s", "%s", 0, 0, sizeof(%s), %s, %d, 0}', ...
                              cTypeName, mwTypeName, mwTypeName, slTypeName, isComplex(i));
                              
      dataTypeMap{i} = dataTypeEntry;
   end

   if ~isempty(testPointStates)
      stateTpTypeEntry = '{"uint8_T", "uint8_T", 0, 0, sizeof(uint8_T), SS_UINT8, 0, 0}';
      dataTypeMap{numTpData+1} = stateTpTypeEntry;
   end

   return;
      
function fixPointMap = construct_capi_fixed_point_map(testPointData, testPointStates)

   numTpData = length(testPointData);
   fixPointMap = cell(numTpData, 1);
   
   nonFixptEntry.slope    = 1.0;
   nonFixptEntry.bias     = 0.0;
   nonFixptEntry.exponent = 0;
   nonFixptEntry.scaling  = 'rtwCAPI_FIX_RESERVED';
   nonFixptEntry.signed = 0;
   
   for i = 1:numTpData
      actualDataType = sf('CoderDataType', testPointData(i));
      if strcmp(actualDataType,'fixpt')
         [baseType, exponent, slope, bias, nBits, isSigned] = sf('FixPtProps', testPointData(i));
         
         fixPointEntry.slope    = slope;
         fixPointEntry.bias     = bias;
         fixPointEntry.exponent = exponent;
         fixPointEntry.scaling  = 'rtwCAPI_FIX_UNIFORM_SCALING';
         fixPointEntry.signed   = isSigned;
      else
         fixPointEntry = nonFixptEntry;
      end
      fixPointMap{i} = fixPointEntry;
   end
   
   if ~isempty(testPointStates)
      fixPointMap{numTpData+1} = nonFixptEntry;
   end

   return;
   
function dimensionMap = construct_capi_dimension_map(testPointData, testPointStates)

   global gDataInfo

   numTpData = length(testPointData);
   dimensionMap = cell(numTpData, 1);
   
   tpDataNumbers = sf('get', testPointData, 'data.number');
   
   for i = 1:numTpData
      %%% dataOrientation, dimArrIdx, numDims, dims   as a structure

      idx = tpDataNumbers(i) + 1;
      dataSize = gDataInfo.dataSizeArrays{idx};
      
      dimensionEntry.numDims = 2; %%% scalar, vector, or matrix, all unified to have 2 dimensions
      dimensionEntry.dimArrIdx = 0; %%% initialize to 0 first
      
      if isempty(dataSize) || prod(dataSize) == 1
         dimensionEntry.orient = 'rtwCAPI_SCALAR';
         dimensionEntry.dims   = [1 1];
      elseif length(dataSize) == 1
         dimensionEntry.orient = 'rtwCAPI_VECTOR';
         dimensionEntry.dims   = [dataSize 1];
      elseif length(dataSize) == 2
         dimensionEntry.orient = 'rtwCAPI_MATRIX_COL_MAJOR';
         dimensionEntry.dims   = dataSize;
      else
         dimensionEntry = [];
         error('Testpoint data can only be scalar, vector, or matrix.');
      end

      dimensionMap{i} = dimensionEntry;
   end
   
   if ~isempty(testPointStates)
      stateTpDimEntry.numDims = 2;
      stateTpDimEntry.dimArrIdx = 0;
      stateTpDimEntry.orient = 'rtwCAPI_SCALAR';
      stateTpDimEntry.dims   = [1 1];
      dimensionMap{numTpData+1} = stateTpDimEntry;
   end

   return;
   
function [uniqMap, mapping] = uniquify_capi_string_map(map)

   [uniqMap, tmp, mapping] = unique(map);
   return;
   
function [uniqMap, mapping, valueMap] = uniquify_capi_fixpt_map(map, valueArrayName)

   numEntries = length(map);
   
   %%% construct value map for fixpt slope, bias first
   values = zeros(2*numEntries, 1);
   for i = 1:numEntries
      values(2*i - 1) = map{i}.slope;
      values(2*i)     = map{i}.bias;
   end
   [valueMap, tmp, valueMapping] = unique(values);
   
   nonFixptItemStr = '{NULL, NULL, rtwCAPI_FIX_RESERVED, 0, 0}';
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      slopeIdx = valueMapping(2*i - 1);
      biasIdx  = valueMapping(2*i);
                    
      if strcmp(map{i}.scaling, 'rtwCAPI_FIX_RESERVED')
         strMap{i} = nonFixptItemStr;
      else
         strMap{i} = sprintf('{&%s[%d], &%s[%d], %s, %d, %d}', ...
                             valueArrayName, slopeIdx-1, valueArrayName, biasIdx-1, ...
                             map{i}.scaling, map{i}.exponent, map{i}.signed);
      end
   end
   
   [uniqMap, tmp, mapping] = unique(strMap);
   return;

function [uniqMap, mapping] = uniquify_capi_dimension_map(map)

   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      strMap{i} = sprintf('%s|%d|[%d,%d]', map{i}.orient, map{i}.numDims, map{i}.dims(1), map{i}.dims(2));
   end
   
   [tmp, uniqSampleIdx, mapping] = unique(strMap);
   uniqMap = map(uniqSampleIdx);

   idx = 0;
   for i = 1:length(uniqMap)
      uniqMap{i}.dimArrIdx = idx;
      idx = idx + uniqMap{i}.numDims;
   end

   return;
   
function dump_capi_string_map(file, map)

   numEntries = length(map);

   strBuf = '';
   for i = 1:numEntries
      strBuf = sprintf('%s%s,\n', strBuf, map{i});
   end

   if ~isempty(strBuf)
      strBuf = strBuf(1:end-2); %%% remove trailing ",\n"
fprintf(file,'   %s\n',strBuf);
   end

   return;

function dump_capi_data_type_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_DataTypeMap dataTypeMap[] = {\n');
fprintf(file,'   /* cName, mwName, numElements, elemMapIndex, dataSize, slDataId, isComplex, isPointer */\n');
   dump_capi_string_map(file, map);
fprintf(file,'};\n');

   return;
   
function dump_capi_fixed_point_value_array(file, fixPtValueMap, fixPtValArrName)

   numEntries = length(fixPtValueMap);
fprintf(file,'\n');
fprintf(file,'static real_T %s[%.15g] = {\n',fixPtValArrName,numEntries);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      strMap{i} = sprintf('%g', fixPtValueMap(i));
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_fixed_point_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_FixPtMap fixedPointMap[] = {\n');
fprintf(file,'   /* *fracSlope, *bias, scaleType, exponent, isSigned */\n');
   dump_capi_string_map(file, map);
fprintf(file,'};\n');

   return;

function dump_capi_dimension_map_struct(file, map)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_DimensionMap dimensionMap[] = {\n');
fprintf(file,'   /* dataOrientation, dimArrayIndex, numDims*/\n');
   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      strMap{i} = sprintf('{%s, %d, %d}', map{i}.orient, map{i}.dimArrIdx, map{i}.numDims);
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_dimension_array(file, map)

fprintf(file,'\n');
fprintf(file,'static const uint_T dimensionArray[] = {\n');
   numEntries = length(map);
   strMap = cell(numEntries, 1);
   for i = 1:numEntries
      %%% Assumption here is all sizes have 2 dimensions for simplicity. otherwise, we must write a loop.
      strMap{i} = sprintf('%d, %d', map{i}.dims(1), map{i}.dims(2));
   end
   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

% A dummy sample time map to satisfy !NULL assertion in floating scope code
function dump_capi_sample_time_map_struct(file)

fprintf(file,'\n');
fprintf(file,'static real_T sfCAPIsampleTimeZero = 0.0;\n');
fprintf(file,'static const rtwCAPI_SampleTimeMap sampleTimeMap[] = {\n');
fprintf(file,'   /* *period, *offset, taskId, contextTid, mode */\n');
fprintf(file,'   {&sfCAPIsampleTimeZero, &sfCAPIsampleTimeZero, 0, 0, 0}\n');
fprintf(file,'};\n');

   return;
   
function dump_capi_test_point_signals_struct(file, ...
                                             chart, ...
                                             testPointData, ...
                                             testPointStates, ...
                                             dataTypeMapping, ...
                                             fixPointMapping, ...
                                             dimensionMapping)

fprintf(file,'\n');
fprintf(file,'static const rtwCAPI_Signals testPointSignals[] = {\n');
fprintf(file,'   /* addrMapIndex, sysNum, SFRelativePath, dataName, portNumber, dataTypeIndex, dimIndex, fixPtIdx, sTimeIndex */\n');
   numTpData = length(testPointData);
   numTpStates = length(testPointStates);
   strMap = cell(numTpData+numTpStates, 1);
   
   for i = 1:numTpData
      sfRelativePath = sf('FullNameOf', testPointData(i), chart, '.');
      dataName = sf('get', testPointData(i), 'data.name');
      strMap{i} = sprintf('{%d, 0,"StateflowChart/%s", "%s", 0, %d, %d, %d, 0}', ...
                          i-1, sfRelativePath, dataName, ...
                          dataTypeMapping(i)-1, dimensionMapping(i)-1, fixPointMapping(i)-1);
   end

   idx = numTpData + 1;
   for i = 1:numTpStates
      sfRelativePath = sf('FullNameOf', testPointStates(i), chart, '.');
      stateName = sf('get', testPointStates(i), 'state.name');
      strMap{idx} = sprintf('{%d, 0, "StateflowChart/%s", "%s", 0, %d, %d, %d, 0}', ...
                            idx-1, sfRelativePath, stateName, ...
                            dataTypeMapping(numTpData+1)-1, dimensionMapping(numTpData+1)-1, fixPointMapping(numTpData+1)-1);
      idx = idx + 1;
   end

   dump_capi_string_map(file, strMap);
fprintf(file,'};\n');

   return;

function dump_capi_data_mapping_static_info_struct(file, testPointData, testPointStates)

   numTestPoints = length(testPointData) + length(testPointStates);
   
fprintf(file,'\n');
fprintf(file,'static rtwCAPI_ModelMappingStaticInfo testPointMappingStaticInfo = {\n');
fprintf(file,'   /* block signal monitoring */\n');
fprintf(file,'   {\n');
fprintf(file,'      testPointSignals,  /* Block signals Array  */\n');
fprintf(file,'      %.15g   /* Num Block IO signals */\n',numTestPoints);
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* parameter tuning */\n');
fprintf(file,'   {\n');
fprintf(file,'      NULL,   /* Block parameters Array    */\n');
fprintf(file,'      0,      /* Num block parameters      */\n');
fprintf(file,'      NULL,   /* Variable parameters Array */\n');
fprintf(file,'      0       /* Num variable parameters   */\n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* block states */\n');
fprintf(file,'   {\n');
fprintf(file,'      NULL,   /* Block States array        */\n');
fprintf(file,'      0       /* Num Block States          */\n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* Static maps */\n');
fprintf(file,'   {\n');
fprintf(file,'      dataTypeMap,    /* Data Type Map            */\n');
fprintf(file,'      dimensionMap,   /* Data Dimension Map       */\n');
fprintf(file,'      fixedPointMap,  /* Fixed Point Map          */\n');
fprintf(file,'      NULL,           /* Structure Element map    */\n');
fprintf(file,'      sampleTimeMap,  /* Sample Times Map         */\n');
fprintf(file,'      dimensionArray  /* Dimension Array          */     \n');
fprintf(file,'   },\n');
fprintf(file,'\n');
fprintf(file,'   /* Target type */\n');
fprintf(file,'   "float"\n');
fprintf(file,'};\n');

   return;

function dump_capi_init_data_mapping_info_fcn(file, chart)

   global gTargetInfo gChartInfo
   tpInfoAccessFcns = sf('Cg', 'get_testpoint_accessfcn_names', chart);
   
fprintf(file,'\n');
fprintf(file,'static void init_test_point_mapping_info(SimStruct *S) {\n');
fprintf(file,'   rtwCAPI_ModelMappingInfo *testPointMappingInfo;\n');
fprintf(file,'   void **testPointAddrMap;\n');
   if gTargetInfo.codingMultiInstance
fprintf(file,'   %s *chartInstance;\n',gChartInfo.chartInstanceTypedef);
fprintf(file,'\n');
fprintf(file,'   chartInstance = ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;\n');
fprintf(file,'   %s(chartInstance);\n',tpInfoAccessFcns.initAddrMapFcn);
fprintf(file,'   testPointMappingInfo = %s(chartInstance);\n',tpInfoAccessFcns.mappingInfoAccessFcn);
fprintf(file,'   testPointAddrMap = %s(chartInstance);\n',tpInfoAccessFcns.addrMapAccessFcn);
   else
fprintf(file,'\n');
fprintf(file,'   %s();\n',tpInfoAccessFcns.initAddrMapFcn);
fprintf(file,'   testPointMappingInfo = %s();\n',tpInfoAccessFcns.mappingInfoAccessFcn);
fprintf(file,'   testPointAddrMap = %s();\n',tpInfoAccessFcns.addrMapAccessFcn);
   end
fprintf(file,'\n');
fprintf(file,'   rtwCAPI_SetStaticMap(*testPointMappingInfo, &testPointMappingStaticInfo);\n');
fprintf(file,'   rtwCAPI_SetPath(*testPointMappingInfo, "");\n');
fprintf(file,'   rtwCAPI_SetFullPath(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetDataAddressMap(*testPointMappingInfo, testPointAddrMap);\n');
fprintf(file,'   rtwCAPI_SetChildMMIArray(*testPointMappingInfo, NULL);\n');
fprintf(file,'   rtwCAPI_SetChildMMIArrayLen(*testPointMappingInfo, 0);\n');
fprintf(file,'\n');
fprintf(file,'   ssSetModelMappingInfoPtr(S, testPointMappingInfo);\n');
fprintf(file,'}\n');

   return;

function dump_capi_data_mapping_info_code(file, chart)
   
   global gChartInfo
   
   if ~gChartInfo.hasTestPoint
      return;
   end

   testPointData = gChartInfo.testPoints.data;
   testPointStates = gChartInfo.testPoints.state;
   
   dataTypeMap = construct_capi_data_type_map(testPointData, testPointStates);
   fixPointMap = construct_capi_fixed_point_map(testPointData, testPointStates);
   dimensionMap = construct_capi_dimension_map(testPointData, testPointStates);
   
   fixPtValArrName = 'fixPtSlopeBiasVals';
   [dataTypeMap, dataTypeUniqMapping] = uniquify_capi_string_map(dataTypeMap);
   [fixPointMap, fixPointUniqMapping, fixPtValueMap] = uniquify_capi_fixpt_map(fixPointMap, fixPtValArrName);
   [dimensionMap, dimensionUniqMapping] = uniquify_capi_dimension_map(dimensionMap);
   
   dump_capi_data_type_map_struct(file, dataTypeMap);
   dump_capi_fixed_point_value_array(file, fixPtValueMap, fixPtValArrName);
   dump_capi_fixed_point_map_struct(file, fixPointMap);
   dump_capi_dimension_map_struct(file, dimensionMap);
   dump_capi_dimension_array(file, dimensionMap);
   dump_capi_sample_time_map_struct(file);
   dump_capi_test_point_signals_struct(file, chart, testPointData, testPointStates, ...
                                       dataTypeUniqMapping, ...
                                       fixPointUniqMapping, ...
                                       dimensionUniqMapping);
   dump_capi_data_mapping_static_info_struct(file, testPointData, testPointStates);
   dump_capi_init_data_mapping_info_fcn(file, chart);
   
   return;
   
