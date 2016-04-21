function compute_machine_info(target)

   global gMachineInfo gTargetInfo gDataInfo

   if(isempty(sf('get',gMachineInfo.target,'target.id')))
       construct_coder_error([],sprintf('sfc invoked with an invalid target id %d.',gMachineInfo.target),1);
   end


   gMachineInfo.machineName = sf('get',gMachineInfo.machineId,'machine.name');
   gMachineInfo.charts = sf('get',gMachineInfo.machineId,'machine.charts');
   chartFileNumbers = sf('get',gMachineInfo.charts,'chart.chartFileNumber');
   [sortedNums,sortedIndices] = sort(chartFileNumbers);
   gMachineInfo.charts = gMachineInfo.charts(sortedIndices);
   if(~gTargetInfo.codingSFunction & ~gTargetInfo.codingRTW)
       %% For custom target code generation, filter out charts which have
       %% noCodegen flag set
       gMachineInfo.charts = sf('find',gMachineInfo.charts,'chart.noCodegenForCustomTargets',0);
   end
   for i=1:length(gMachineInfo.charts)
       sf('set',gMachineInfo.charts(i),'chart.number',i-1);
   end
   sf('set',gMachineInfo.machineId,'machine.activeTarget',gMachineInfo.target);
   sf('set',gMachineInfo.machineId,'machine.activeParentTarget',gMachineInfo.parentTarget);
   gMachineInfo.exportedFcnInfo = sf('get',get_relevant_machine,'machine.exportedFcnInfo');

   gMachineInfo.machineDataThreshold = length(sf('DataOf',gMachineInfo.machineId));

   gDataInfo.dataList = sf('DataIn',gMachineInfo.machineId);
   gDataInfo.dataNumbers = sf('get',gDataInfo.dataList,'data.number')';
   [sortedNumbers,indices] = sort(gDataInfo.dataNumbers);
   gDataInfo.dataList = gDataInfo.dataList(indices);
   gDataInfo.dataNumbers = sortedNumbers;

   gMachineInfo.eventList = sf('EventsIn',gMachineInfo.machineId);

   gMachineInfo.machineNumberVariableName = ['_',gMachineInfo.machineName,'MachineNumber_'];
   gMachineInfo.machineData = sf('DataOf',gMachineInfo.machineId);
   gMachineInfo.machineDataNumbers = sf('get',gMachineInfo.machineData,'data.number')';

   gMachineInfo.localData = sf('find',gMachineInfo.machineData,'data.scope','LOCAL_DATA');
   gMachineInfo.localDataNumbers = sf('get',gMachineInfo.localData,'data.number')';

   gMachineInfo.constantData = sf('find',gMachineInfo.machineData,'data.scope','CONSTANT_DATA');
   gMachineInfo.constantDataNumbers = sf('get',gMachineInfo.constantData,'data.number')';

   gMachineInfo.parameterData = sf('find',gMachineInfo.machineData,'data.scope','PARAMETER_DATA');
   gMachineInfo.parameterDataNumbers = sf('get',gMachineInfo.parameterData,'data.number')';

   gMachineInfo.exportedData = sf('find',gMachineInfo.machineData,'data.scope','EXPORTED_DATA');
   gMachineInfo.exportedDataNumbers = sf('get',gMachineInfo.exportedData,'data.number')';

   gMachineInfo.importedData = sf('find',gMachineInfo.machineData,'data.scope','IMPORTED_DATA');
   gMachineInfo.importedDataNumbers = sf('get',gMachineInfo.importedData,'data.number')';

   gMachineInfo.importedEvents = sf('find',gMachineInfo.eventList,'event.scope','IMPORTED_EVENT');
   gMachineInfo.exportedEvents = sf('find',gMachineInfo.eventList,'event.scope','EXPORTED_EVENT');


   gMachineInfo.machineEvents = sf('EventsOf',gMachineInfo.machineId);

   if gTargetInfo.codingLibrary & ~isempty(gMachineInfo.machineEvents)
       construct_coder_error(gMachineInfo.machineId,'Library machines cannot have machine-parented events',1);
   end

   gMachineInfo.localEvents = sf('find',gMachineInfo.machineEvents,'event.scope','LOCAL_EVENT');
   gMachineInfo.importedEvents = sf('find',gMachineInfo.machineEvents,'event.scope','IMPORTED_EVENT');
   gMachineInfo.exportedEvents = sf('find',gMachineInfo.machineEvents,'event.scope','EXPORTED_EVENT');


   gMachineInfo.eventVariableType = 'uint8_T';


   if gTargetInfo.codingRTW
       gMachineInfo.eventVariableName = '%<SLibGetSFEventName()>';
       hasMachineData = ~isempty(setxor(gMachineInfo.machineData, gMachineInfo.constantData));
       hasMachineEvents = ~isempty(gMachineInfo.machineEvents);
       if gTargetInfo.mdlrefInfo.isMultiInst
           if (hasMachineEvents | hasMachineData)
               str = sprintf(gTargetInfo.mdlrefInfo.err);
               construct_coder_error(gMachineInfo.machineId,str,1);
           end
       elseif(gTargetInfo.isErtMultiInstanced)
           if(hasMachineEvents)
               str = sprintf('ERT option "Generate reusable code" cannot be used \nin the presence of machine parented events.');
               construct_coder_error(gMachineInfo.machineId,str,1);
           end
           if(hasMachineData)
               if(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Error'))
                   str = sprintf('ERT option "Generate reusable code" cannot be used \nin the presence of machine parented data \nwhen the ERT option "Reusable code error diagnostic"  \nis set to "Error".');
                   construct_coder_error(gMachineInfo.machineId,str,1);
               elseif(strcmp(gTargetInfo.ertMultiInstanceErrCode,'Warning'))
                   warning('ERT option "Generate reusable code" may give unexpected results in the presence of\nmachine parented data.');
               end
           end
       end
   elseif gTargetInfo.codingSFunction
       gMachineInfo.eventVariableName = '_sfEvent_';
   else
       gMachineInfo.eventVariableName = sprintf('_sfEvent_%s_',gMachineInfo.machineName);
   end


   gMachineInfo.sfPrefix = '__sf_';

   dataCount = length(gDataInfo.dataList);
   gDataInfo.dataTypes = cell(1,dataCount);
   gDataInfo.sfDataTypes = cell(1,dataCount);
   gDataInfo.slDataTypes = cell(1,dataCount);


   sf('UpdateChartUniqueNamesIn',gMachineInfo.machineId);

   sf('UpdateUniqueNamesIn',gMachineInfo.machineId,...
       gTargetInfo.codingPreserveNames,...
       gTargetInfo.codingPreserveNamesWithParent);

   initialize_data_information(gMachineInfo.machineData,gMachineInfo.machineDataNumbers);
   compute_machine_event_enums;

function compute_machine_event_enums
    global gMachineInfo gDataInfo
%   $Revision: 1.1.6.7 $  $Date: 2003/12/31 19:55:13 $

    for event = [gMachineInfo.localEvents,gMachineInfo.importedEvents,gMachineInfo.exportedEvents]
        eventUniqueName = sf('CodegenNameOf',event);
        eventNumber = sf('get',event,'event.number');
        enumVal = eventNumber;
        enumStr = ['event_',eventUniqueName];
        sf('set',event,'event.eventEnumStr',enumStr,'event.eventEnumeration',enumVal);
    end

    gMachineInfo.machineDataWithChangeEvent = sf('find',[gMachineInfo.localData,gMachineInfo.exportedData],'data.hasChangeEvent',1);

    gMachineInfo.machineDataChangeEventThreshold = length(gMachineInfo.localEvents) + length(gMachineInfo.importedEvents) + length(gMachineInfo.exportedEvents);
    gMachineInfo.machineEventThreshold = gMachineInfo.machineDataChangeEventThreshold+...
                            length(gMachineInfo.machineDataWithChangeEvent);

    enumVal = gMachineInfo.machineDataChangeEventThreshold;
    for data =  gMachineInfo.machineDataWithChangeEvent
       dataNumber = sf('get',data,'data.number');
       dataUniqueName = sf('CodegenNameOf',data);
        enumStr = ['data_change_in_',dataUniqueName];
        sf('set',data,'data.changeEventEnumStr',enumStr,'data.changeEventEnumeration',enumVal);
        enumVal = enumVal+1;
    end
