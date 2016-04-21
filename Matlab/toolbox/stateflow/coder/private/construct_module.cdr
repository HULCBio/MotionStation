%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errorsOccurred = construct_module(chart)

global gTargetInfo gChartInfo

errorsOccurred= 0;

compute_chart_instance_var_names(chart);
compute_state_variable_names(chart);
compute_state_event_enums(chart);
mustExportChartFunctions = export_chart_functions(chart);

cdrModuleInfo.chartId = chart;
cdrModuleInfo.codingMultiInstance = gTargetInfo.codingMultiInstance;
cdrModuleInfo.mustExportChartFunctions = mustExportChartFunctions;
cdrModuleInfo.chartInstanceTypedef = gChartInfo.chartInstanceTypedef;
cdrModuleInfo.chartInputDataTypedef = gChartInfo.chartInputDataTypedef;
cdrModuleInfo.chartOutputDataTypedef = gChartInfo.chartOutputDataTypedef;
cdrModuleInfo.chartInstanceArgumentName = gChartInfo.chartInstanceArgumentName;
cdrModuleInfo.chartInputDataArgumentName = gChartInfo.chartInputDataArgumentName;
cdrModuleInfo.chartOutputDataArgumentName = gChartInfo.chartOutputDataArgumentName;
cdrModuleInfo.codingNoInitializer = gTargetInfo.codingNoInitializer;
if(gTargetInfo.codingRTW)
    cdrModuleInfo.codingSharedUtils = gTargetInfo.rtwProps.sharedUtilsEnabled;
    cdrModuleInfo.usedTargetFunctionLib = gTargetInfo.rtwProps.usedTargetFunctionLib;
else
    cdrModuleInfo.codingSharedUtils = false;
    cdrModuleInfo.usedTargetFunctionLib = 'NULL';
end

try,
    gChartInfo.whollyInlinable = sf('Cg','construct_module',cdrModuleInfo);
catch,
    disp(lasterr);
    errorsOccurred = 1;
    sf('Private','coder_error_count_man','add',1);
    sf('Cg','destroy_module',chart);
    return;
end

if(gTargetInfo.codingForTestGen)
    % WISH: This is a temporary hack for Bill to do his testgen
    % work. MUST GET RID OF IT AS SOON AS POSSIBLE!!!!!!!
    try,
      testgen_gateway('chart_analyze',chart,gChartInfo.whollyInlinable);
    catch,
      disp(lasterr);
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_chart_instance_var_names(chart)

global gTargetInfo gChartInfo gDataInfo

chartUniqueName = sf('CodegenNameOf',chart);

if(gTargetInfo.codingRTW)
   gChartInfo.chartInstanceTypedef  = '%<SFInfo.ChartInstanceTypedef>';
   gChartInfo.chartInstanceArgumentName = 'chartInstance';
else
   gChartInfo.chartInstanceTypedef  = ['SF',chartUniqueName,'InstanceStruct'];
   gChartInfo.chartInstanceArgumentName = 'chartInstance';
end
gChartInfo.chartInputDataTypedef = ['SF',chartUniqueName,'InputDataStruct'];
gChartInfo.chartOutputDataTypedef = ['SF',chartUniqueName,'OutputDataStruct'];
gChartInfo.chartInputDataArgumentName = 'chartInputData';
gChartInfo.chartOutputDataArgumentName = 'chartOutputData';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_state_variable_names(chart)

global gChartInfo

prefixStr = '';

for state = [chart,gChartInfo.states]
    uniqStateName = sf('CodegenNameOf',state);
    if(state==chart | sf('get',state,'state.type')==1)
        % chart, AND states get their own bit
        fieldName = [prefixStr,'is_active_',uniqStateName];
        sf('set',state,'.unique.isActive',fieldName);
    else
        % optimize it away
        sf('set',state,'.unique.isActive','');
    end
    subStates = sf('SubstatesOf',state);
    if(~isempty(subStates))
        switch sf('get',state,'.decomposition')
            case 0  % CLUSTER_STATE
                fieldName = [prefixStr,'is_',uniqStateName];
                sf('set',state,'.unique.activeChild',fieldName);
                if sf('get',state,'.history');
                    fieldName = [prefixStr,'was_',uniqStateName];
                    sf('set',state,'.unique.prevActiveChild',fieldName);
                end
            case 1  % SET_STATE
            otherwise,
                construct_coder_error(state,'Bad decomposition');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_state_event_enums(chart)
  global gMachineInfo gChartInfo


  if(~isempty(gChartInfo.chartEvents))
    chartEventNumbers = sf('get',gChartInfo.chartEvents,'event.number')+gMachineInfo.machineEventThreshold;
      sf('set',gChartInfo.chartEvents,'event.number',chartEventNumbers);
  end

  file = ''; % Dummy argument, not used in the functions

  compute_event_enum_values(chart,file,1);
  compute_state_enums(file,chart);

  return;



