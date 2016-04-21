function [machineId,machineName] = unpack_machine_id(machineId)

% Copyright 2003 The MathWorks, Inc.

if(ischar(machineId))
    machineName = machineId;
    machineId = sf_force_open_machine(machineName);
    if(isempty(machineId))
        error('There is no Stateflow machine with the name %s',machineName);
    end
end
machineName = sf('get',machineId,'machine.name');

