function x = isreadonly(c)
%ISREADONLY Detect if database connection is read-only.
%   X = ISREADONLY(C) returns 1 if the database connection, C, is
%   read-only and 0 otherwise.
%
%   See also ISCONNECTION.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $   $Date: 2004/04/06 01:05:21 $

%Test for valid and open connection
if ~isconnection(c)
  error('database:database:invalidConnection','Invalid connection.')
end

%Check for read-only connection
a = com.mathworks.toolbox.database.databaseConn;
x = connIsReadOnly(a,c.Handle);
