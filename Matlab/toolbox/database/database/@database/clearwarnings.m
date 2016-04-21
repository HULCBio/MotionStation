function clearwarnings(c)
%CLEARWARNINGS Clear warnings for database connection.
%   CLEARWARNINGS(C) clears the warnings reported for the database
%   connection, C.
%
%   See also GET.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $   $Date: 2004/04/06 01:05:15 $

%Test for valid and open connection
if ~isconnection(c)
  error('database:database:invalidConnection','Invalid connection.')
end

%Clear connection warnings
a = com.mathworks.toolbox.database.databaseConn;
x = connClearWarnings(a,c.Handle);

%Check for exception
if x == -1
  error('database:database:clearWarningsFailure','Connection warnings were not cleared.')
end
  
