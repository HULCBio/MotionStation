function commit(c) 
%COMMIT Make database changes permanent.
%   COMMIT(C) makes all changes since the previous commit or rollback
%   permanent and releases connection's database locks.   C is the
%   database connection.
%
%   See also ROLLBACK.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:17 $

%Test for valid and open connection
if ~isconnection(c)
  error('database:database:invalidConnection','Invalid connection.')
end

%Commit connection changes
a = com.mathworks.toolbox.database.databaseConn;
x = connCommit(a,c.Handle);

%Check for exception
if x == -1
  error('database:database:commitFailure','Connection changes were not committed.')
end
