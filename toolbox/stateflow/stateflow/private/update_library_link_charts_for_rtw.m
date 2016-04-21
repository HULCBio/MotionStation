function update_library_link_charts_for_rtw(machineName)

% Copyright 2002-2003 The MathWorks, Inc.

machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
linkMachines = get_link_machine_list(machineName,'rtw');
[dirtyStatusOfMain,lockedStatusOfMain] = update_chart_blocks(machineName);
dirtyStatiiOfLinks = cell(length(linkMachines),1);
lockedStatiiOfLinks = cell(length(linkMachines),1);
for i=1:length(linkMachines)
   [dirtyStatus,lockedStatus] = update_chart_blocks(linkMachines{i});
   dirtyStatiiOfLinks{i} = dirtyStatus;
   lockedStatiiOfLinks{i} = lockedStatus;
end

% IMPORTANT: We must bind the links first and then restore the
% lock and dirty settings. Otherwise the changes are
% ignored by Simulink. hence the reason for caching away the lock
% and dirty settings.
machine_bind_sflinks(machineName);
% for some reason, machine_bind_sf_links
% doesnt seem to do it all. hence
% we explicitly try to set these properties
% if needed. his may explain strange bus with library
% charts
warnStatus = warning('off', 'all');
sfLinks = sf('get',machineId,'machine.sfLinks');
for i=1:length(sfLinks)
   blockH = sfLinks(i);
   refBlock = get_param(blockH,'ReferenceBlock');
   treatAsAtomic = get_param(refBlock,'TreatAsAtomicUnit');
   rtwSysCode = get_param(refBlock,'RTWSystemCode');
   if(~isequal(get_param(blockH,'TreatAsAtomicUnit'),treatAsAtomic))
      set_param(blockH,'TreatAsAtomicUnit',treatAsAtomic);
   end
   if(~isequal(get_param(blockH,'RTWSystemCode'),rtwSysCode))
      set_param(blockH,'RTWSystemCode',rtwSysCode);
   end
end
warning(warnStatus);

for i=1:length(linkMachines)
   set_param(linkMachines{i},'Dirty',dirtyStatiiOfLinks{i});
   set_param(linkMachines{i},'Lock',lockedStatiiOfLinks{i});
end
set_param(machineName,'Dirty',dirtyStatusOfMain);
set_param(machineName,'Lock',lockedStatusOfMain);

function sfRTWInterfaceLevel = getSFRTWInterfaceLevel()
  lasterrmsg = lasterr();
  lastslerr  = sllasterror();
  try 
    sfRTWInterfaceLevel = feature('RTWSFInterfaceLevel');
  catch
    sfRTWInterfaceLevel = 0;
    lasterr(lasterrmsg);
    sllasterror(lastslerr);
  end  
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dirtyFlag,lockFlag] = update_chart_blocks(machineName)

dirtyFlag = get_param(machineName,'dirty');
lockFlag = get_param(machineName,'lock');
sfInterfaceEnabled = (getSFRTWInterfaceLevel() > 0);
set_param(machineName,'lock','off');
machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
charts = sf('get',machineId,'machine.charts');
hasMachineEvents = length(sf('EventsOf',machineId))>0;

infoStruct = sf('Private','infomatman','load','binary',machineName,'rtw');

for i=1:length(charts)
   chartNumber = find(infoStruct.chartFileNumbers==sf('get',charts(i), 'chart.chartFileNumber'));
   isInlinable = strcmp(infoStruct.chartInfo(chartNumber).Inline,'Yes');
   blockH = sf('Private','chart2block',charts(i));
   hasExportedChartFunctions = sf('get', charts(i),'chart.exportChartFunctions');   chartEvents = sf('find',sf('EventsOf',charts(i)),'event.scope','OUTPUT_EVENT');
   hasFcnCallOutputs = ~isempty(sf('find',chartEvents,'event.trigger','FUNCTION_CALL_EVENT'));
   if (hasMachineEvents || hasExportedChartFunctions)
      set_param(blockH,'TreatAsAtomicUnit','on');
      set_param(blockH,'RTWSystemCode','Function');
   elseif hasFcnCallOutputs && sfInterfaceEnabled
      set_param(blockH,'TreatAsAtomicUnit','on');
      set_param(blockH,'RTWSystemCode','Reusable function');     
   elseif isInlinable
      set_param(blockH,'TreatAsAtomicUnit','off');
      set_param(blockH,'RTWSystemCode','Auto');
   else
      set_param(blockH,'TreatAsAtomicUnit','on');
      set_param(blockH,'RTWSystemCode','Reusable function');
   end
end
%endfunction
