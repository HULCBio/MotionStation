function x = isjdbc(d)
%ISJDBC Detect if driver is JDBC-compliant.
%   X = ISJDBC(D) returns 1 if D is JDBC compliant. 
%
%   See also GET, ISURL.

%   Author(s): C.F.Garvin, 06-30-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $   $Date: 2004/04/06 01:05:35 $

%Validate driver object
if ~isdriver(d)
  error('database:driver:invalidObject','Invalid driver object.')
end

%Establish JAVA instance handle
a = com.mathworks.toolbox.database.databaseDrivers;

%Test driver for jdbc compliance
x = driverJdbc(a,d.DriverHandle);
