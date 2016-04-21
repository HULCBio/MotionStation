function dbupdatedemo()
%DEMOUPDATE	 Updates a row in a database table.

%   Version 1.0  21-Oct-1997
%   Author(s): E.F. McGoldrick, S. Cockrell, 12/5/1997
%   Copyright 1984-2002 The MathWorks, Inc.

% $Revision: 1.11 $   $Date: 2002/06/17 12:00:44 $


% Connect to a database.

connA=database('SampleDB','','')

% Define a string array of column names in table where data will be exported.

colnames={'Calc_Date', 'Avg_Cost'}

% Assign a date to D.

D='1/20/98'

% Assign a value to the variable meanA.

meanA=25.2600

% Put the date in the first cell and the mean in the second cell.

C={D,meanA}

% Change the value of D.

D='1/19/98'

% Put the new date into cell array C.

C(1,1)={D}

% Identify the record to be updated.

whereclause='where Calc_Date = ''1/20/98'''

% Export the data.

update(connA, 'Avg_Freight_Cost', colnames, C, whereclause)

% Close the cursor and the connection.

close(connA)



