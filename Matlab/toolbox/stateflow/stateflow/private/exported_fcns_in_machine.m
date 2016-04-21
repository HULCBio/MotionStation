function exportedFcnInfo = exported_fcns_in_machine(machineId)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.3 $  $Date: 2004/04/15 00:57:42 $

machineName = sf('get',machineId,'machine.name');
charts = sf('get',machineId,'machine.charts');
charts = sf('find',charts,'chart.exportChartFunctions',1);
exportedFcnInfo = [];
for i=1:length(charts)
    chart = charts(i);
    chartName = sf('FullNameOf',chart,'/');
    exportedFunctions  = sf('find',sf('AllSubstatesOf',chart),'state.type','FUNC_STATE');
    for j=1:length(exportedFunctions)
        thisInfo = get_exported_fcn_info(exportedFunctions(j),machineName,chartName);
        exportedFcnInfo = [exportedFcnInfo,thisInfo];
    end
end

exportedFcnInfo = sort_exported_fcns_info(exportedFcnInfo);

for i=1:length(exportedFcnInfo)
    if(i~=1)
        if(strcmp(exportedFcnInfo(i-1).name,exportedFcnInfo(i).name))
            errorStr = ['Multiple exported graphical functions with the',10,...
                        'same name "',exportedFcnInfo(i).name,'" exist in charts:',10,...
                        '"',exportedFcnInfo(i-1).chartName,'"',10,...
                        '"',exportedFcnInfo(i).chartName,'"'];
            construct_error(machineId, 'Build', errorStr, 1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function thisInfo = get_exported_fcn_info(exportedFcnId,machineName,chartName)

thisInfo.machineName = machineName;
thisInfo.chartName = chartName;

thisInfo.name = sf('get',exportedFcnId,'.name');
allData = sf('DataOf',exportedFcnId);
inputData = sf('find',allData,'data.scope','FUNCTION_INPUT_DATA');
outputData = sf('find',allData,'data.scope','FUNCTION_OUTPUT_DATA');
thisInfo.inputDataInfo = [];
for i=1:length(inputData)
    inputDataInfo = get_data_info(inputData(i));
    thisInfo.inputDataInfo = [thisInfo.inputDataInfo,inputDataInfo];
end
thisInfo.outputDataInfo = [];
for i=1:length(outputData)
    outputDataInfo = get_data_info(outputData(i));
    thisInfo.outputDataInfo = [thisInfo.outputDataInfo,outputDataInfo];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dataInfo = get_data_info(dataId)
    dataInfo.type = sf('CoderDataType',dataId);
    dataInfo.size = sf('get',dataId,'data.parsedInfo.array.size');
    if(strcmp(dataInfo.type,'fixpt'))
        dataInfo.bias = sf('get',dataId,'data.fixptType.bias');
        dataInfo.slope = sf('get',dataId,'data.fixptType.slope');
        dataInfo.exponent = sf('get',dataId,'data.fixptType.exponent');
        dataInfo.baseType = sf('FixPtProps',dataId);
    else
        dataInfo.bias = [];
        dataInfo.slope = [];
        dataInfo.exponent = [];
        dataInfo.baseType = [];        
    end
