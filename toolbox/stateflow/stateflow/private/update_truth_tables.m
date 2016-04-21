function errorCount = update_truth_tables(machineId)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/15 01:01:28 $

isLibrary = sf('get',machineId,'machine.isLibrary');
machineName = sf('get',machineId,'machine.name');
lockStatus = 'off';
if(isLibrary)
    % Must unlock and save lock status G146302
    lockStatus = get_param(machineName,'lock');
    set_param(machineName,'lock','off');
end
errorCount= 0;
ttFcns = truth_tables_in(machineId);
for j = 1:length(ttFcns)
    errorCount = errorCount + update_truth_table_for_fcn(ttFcns(j),1);
end

if(isLibrary)
    % Restore lock status G146302
    set_param(machineName,'lock',lockStatus);
end

if(errorCount)
    construct_error( machineId, 'Parse', 'Errors occurred during truthtable parsing', 1);    
end
