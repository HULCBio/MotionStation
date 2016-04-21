function dbinfodemo()
%DBINFODEMO Displays info about fetched data set.

%   Version 1.0  21-Oct-1997
%   Author(s): E.F. McGoldrick, 12/5/1997
%   Copyright 1984-2002 The MathWorks, Inc.

% $Revision: 1.11 $   $Date: 2002/06/17 12:00:47 $

% Connect to a database.

connA=database('SampleDB','','')

% Open cursor and execute a SQL statement.

cursorA=exec(connA,'select country from customers');

% Fetch the first 10 rows of data.

cursorA=fetch(cursorA,10);

% Display the number of rows.

rowsA=rows(cursorA)

% Display the number of columns.

columnsA=cols(cursorA)

% Display the column names.

fieldnamesA=columnnames(cursorA)

% Display the column width.

widthA=width(cursorA,1)

% Display the attributes for the fetched data set.

attrA=attr(cursorA)

% Close the cursor and the connection.

close(cursorA)
close(connA)

