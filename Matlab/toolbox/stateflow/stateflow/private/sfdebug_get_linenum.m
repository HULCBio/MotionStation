function [objectId, linenum] = sfdebug_get_linenum(machineId)

% Copyright 2004 The MathWorks, Inc.

if(~validate_machine_id(machineId)) return; end;

objectId=0;
linenum=0;

runningTarget = sf('get',machineId,'machine.debug.runningTarget');

if(runningTarget &... 
   sf('ishandle',runningTarget) &...
   ~isempty(sf('get',runningTarget,'target.id')))
  mexFunctionName = sf('get',machineId,'machine.debug.runningMexFunction');
  [objectId,linenum] = ...
      feval(mexFunctionName,...
            'sf_debug_api',...
            'get',...
            'currentobjectid',...
            'currentoptionalinteger');
end

return;

function success = validate_machine_id(machineId)

	if ~sf('ishandle',machineId) | isempty(sf('get',machineId,'machine.id'))
		success = 0;
	else
		success = 1;
	end
