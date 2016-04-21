function update_truthtable_data(machineId)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 01:01:29 $

ttFcns = truth_tables_in(machineId);
for j = 1:length(ttFcns)
    truth_table_man('update_data', ttFcns(j));
    truth_table_man('update_layout_data', ttFcns(j));
end
