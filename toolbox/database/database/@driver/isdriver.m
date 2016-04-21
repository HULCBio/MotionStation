function x = isdriver(d)
%ISDRIVER Detect if driver is a valid JDBC driver object.
%   X = ISDRIVER(D) returns 1 if D is a valid JDBC driver object.
%
%   See also DRIVER, GET, ISJDBC, ISURL.

%   Author(s): C.F.Garvin, 07-02-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $   $Date: 2002/06/17 12:01:00 $

%Establish JAVA instance handle
a = com.mathworks.toolbox.database.databaseDrivers;

%Driver validation, trapping 'no method found message' 
try
  x = driverValid(a,d.DriverHandle);
catch
  x = 0;
end
