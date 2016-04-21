function n = sql2native(c,s)
%SQL2NATIVE Convert JDBC SQL grammar into system's native SQL grammar.
%   N = SQL2NATIVE(C,S) converts the SQL statement string, S, into
%   the system's native SQL grammar.  The native SQL statement is 
%   returned.  C is the database connection.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $   $Date: 2004/04/06 01:05:25 $

%Test for valid and open connection
if ~isconnection(c)
  error('database:database:invalidConnection','Invalid connection.')
end

%Java call to convert SQL statement
n = nativeSQL(c.Handle,s);
