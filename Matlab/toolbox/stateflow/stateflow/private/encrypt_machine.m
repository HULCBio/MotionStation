function encrypt_machine(machineName,password)

% Copyright 2003 The MathWorks, Inc.

machineId = sf_force_open_machine(machineName);
if(isempty(machineId))
   return;
end
sfclose(sf('get',machineId,'machine.charts'));
emlFcns = eml_fcns_in(machineId);
for j = 1:length(emlFcns)
    eml_man('close_ui', emlFcns(j));
end

ttFcns = truth_tables_in(machineId);
for j = 1:length(ttFcns)
    truth_table_man('destroy_ui', ttFcns(j));
end

sf('Encrypt',machineId,password);
