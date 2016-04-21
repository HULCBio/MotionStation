function sfLinks = machine_bind_sflinks(machineId, doFindSystem),
%
% Find all sflinks in this model and bind them to said machine.
%

% Copyright 2002-2003 The MathWorks, Inc.

   if(nargin<2)
       doFindSystem = 1;
   end
   if(ischar(machineId))
      modelH = get_param(machineId,'Handle');
      machineId = sf('find',sf('MachinesOf'),'machine.name',machineId);
   else
      modelH = sf('get', machineId, '.simulinkModel');
   end
   %%% if the current model contains Simulink library blocks that point
   %%% to old Simulink library models, SL spits out ugly warnings that say
   %%%    Warning: Run 'slupdate('oldmodel')' to convert the block diagram to the format of the current version of Simulink.
   %%% This is normally shown with callstack, which gives users an impression that
   %%% these warnings are from slsf and hence to do with Stateflow.
   %%% Furthermore, these warnings are causing tremendous slow-downs in
   %%% presence of unresolved library blocks. 
   %%% we set the warning status to 'off' to suppress callstack display and restore it later.
   
   warnStatus = warning('off', 'all');
   blocks = find_system(modelH, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'MaskType', 'Stateflow');
   get_param(blocks, 'linkstatus');
   warning(warnStatus);
   sfLinks = sf('get',machineId,'machine.sfLinks');