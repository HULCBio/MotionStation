function x = isconnection(c)
%ISCONNECTION Detect if database connection is valid.
%   X = ISCONNECTION(C) returns 1 if C is a valid database connection
%   and 0 otherwise.
%
%   See also ISREADONLY.

%   Author(s): C.F.Garvin, 07-08-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $   $Date: 2002/06/17 12:02:07 $

%Create databaseConn object
a = com.mathworks.toolbox.database.databaseConn;

try                 %Test connection
  x = connIsConnection(a,c.Handle);
catch               %Invalid connection throws exception, return 0
  x = 0;
end
