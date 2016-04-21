function sfdebugger(machineIdentifier)
%SFDEBUGGER Opens Stateflow Debugger.
%   SFDEBUGGER('MODELNAME') opens the Stateflow Debugger Window
%   belonging to Stateflow model 'MODELNAME'
%   SFDEBUGGER(MODELHANDLE) opens the Stateflow Debugger Window
%   belonging to Stateflow model whose handle is MODELHANDLE
%   SFDEBUGGER(MACHINEID) opens the Stateflow Debugger Window
%   belonging to Stateflow model whose Stateflow Id is MACHINEID
%   

% $Revision: 1.8.2.1 $

%   Vijaya Raghavan
%   Copyright 1995-2002 The MathWorks, Inc.
if(nargin ==0)
	if(~isempty(gcs))
		machineIdentifier = bdroot(gcs);
	else
		disp('sfdebugger called with no arguments. There is no current system open for debugging.');
		return;
	end
end

if(isnumeric(machineIdentifier))
   % it is a handle
   try,
      machineName = get_param(machineIdentifier,'name');
      machineId = sf('find',all,'machine.name',machineName);
      if(isempty(machineId))
         disp(sprintf('Specified simulink model %s does not have Stateflow blocks.',machineName));
         return;
      end
   catch,
      machineId = sf('get',machineIdentifier,'machine.id');
      if(isempty(machineId))
         disp(['Invalid machine id passed to sfdebugger']);
         return;
      end
   end
else
   machineId = sf('find','all','machine.name',machineIdentifier);
	if(isempty(machineId))
		disp(sprintf('No Stateflow machine named %s present.',machineIdentifier));
		return;
	end
end

sfdebug('gui','init',machineId);

