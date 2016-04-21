function rollback(c) 
%ROLLBACK Undo database changes.
%   ROLLBACK(C) drops all changes since the previous commit or rollback
%   and releases connection's database locks.   C is the database connection.
%
%   See also COMMIT.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:23 $

%Test for valid and open connection
if ~isconnection(c)
  error('database:database:invalidConnection','Invalid connection.')
end

%Rollback connection changes
a = com.mathworks.toolbox.database.databaseConn;
x = connRollback(a,c.Handle);

%Check for exception
if x == -1
  error('database:database:rollbackFailure','Connection changes were not rolled back.')
end
