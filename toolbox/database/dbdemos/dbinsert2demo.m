function dbinsert2demo()
%DBINSERT2DEMO Inserts rows into a database table.

%   Version 1.0  21-Oct-1997
%   Author(s): E.F. McGoldrick, 12/5/1997
%   Copyright 1984-2002 The MathWorks, Inc.

% $Revision: 1.12 $   $Date: 2002/06/17 12:00:45 $

% Open a connection.

conn=database('dbtoolboxdemo','','');

% Null numbers should be read as zeros
setdbprefs('NullNumberRead','0')

% Open a cursor and execute a fetch.

curs=exec(conn,'select * from salesVolume');
curs=fetch(curs);

% Get size of cell array

[m,n]=size(curs.Data);

% Calculate monthly totals for the product entries.

for i = 2:n
  tmp = curs.Data(:,i);
  monthly(i-1,1) = sum([tmp{:}]);
end
colNames{1,1} = 'salesTotal';

% Convert to cell array

monthlyTotals=num2cell(monthly)

% insert the data.

insert(conn,'yearlySales',colNames,monthlyTotals);

% Close the cursor and the connection.

close(curs);
close(conn);
