function decrypt_machine(machineName,password)

% Copyright 2003 The MathWorks, Inc.

machineId = sf_force_open_machine(machineName);
if(isempty(machineId))
   return;
end
sf('Decrypt',machineId,password);
