function success = sfdebug_paused(machineId)
% Given a machineId, return whether or not the debugger is paused
% in that machine at present.

% Copyright 2004 The MathWorks, Inc.

success = false;

hDebugger = sf('get',machineId,'machine.debug.dialog');

if(hDebugger & ...
   ishandle(hDebugger) & ...
   strcmp( get(hDebugger,'tag'), 'SF_DEBUGGER' ))
  
      dbInfo = get(hDebugger,'userdata');      
      if strcmp(dbInfo.debuggerStatus,'paused')
        success = true;
      end
end
