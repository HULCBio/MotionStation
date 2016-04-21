function ted_the_editors(machineId),
%TED_THE_EDITORS( MACHINEID )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/15 01:01:06 $

	charts = sf('get', machineId, '.charts');
	for chart = charts(:)', 
        sf('LoseFocusFcn', chart);
		% Update any truthtable editors that are open
        truthTables = truth_tables_in(chart);
        for j = 1:length(truthTables)
            truth_table_man('update_data',truthTables(j),'stop_editing');    
        end
    end;
