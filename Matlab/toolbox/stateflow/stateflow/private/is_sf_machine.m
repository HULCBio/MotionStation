function isSfMachine = is_sf_machine(machineId)

% Copyright 2002 The MathWorks, Inc.

    isSfMachine = 0;
    if(isempty(machineId) | machineId==0 | machineId==-1)
        return;
    end
    isSfMachine = sf('IsSfMachine',machineId);