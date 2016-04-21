function dbinsertdemo()
%DBINSERTDEMO Inserts rows into a database table.

%   Version 1.0  21-Oct-1997
%   Author(s): E.F. McGoldrick, 12/5/1997
%   Copyright 1984-2002 The MathWorks, Inc.

% $Revision: 1.11 $   $Date: 2002/06/17 12:00:46 $

% Connect to a database.

connA=database('SampleDB','','')

% Open cursor and execute a SQL statement.

cursorA=exec(connA,'select freight from orders')

% Import three rows of data.

cursorA=fetch(cursorA, 3)

% View the data you imported.

AA=cursorA.Data

% Calculate the average freight cost.

rowsA=rows(cursorA)
meanA=sum([AA{:}])/double(rowsA)

% Assign a date to D.

D='1/20/98'

% Create a cell array for the data to be exported.

C=cell(1,2)

% Put the date in the first cell and the mean in the second cell.

C(1,1)={D}
C(1,2)={meanA}

% Define a string array of column names in table where data will be exported.

colnames={'Calc_Date', 'Avg_Cost'}

% Determine autocommit status.

get(connA, 'autocommit')

% Export data into Avg_Freight_Cost table.

insert(connA, 'Avg_Freight_Cost', colnames, C)

% Close the cursor and the connection.

close(cursorA)
close(connA)
