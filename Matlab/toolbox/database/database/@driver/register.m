function register(d)
%REGISTER Load database driver.
%   REGISTER(D) loads the database driver D.
%
%   See also UNREGISTER.

%   Author(s): C.F.Garvin, 06-30-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $   $Date: 2004/04/06 01:05:37 $

if ~isdriver(d)
  error('database:driver:invalidObject','Invalid driver object.')
end

%Establish JAVA instance handle
a = com.mathworks.toolbox.database.databaseDrivers;

%Load driver
driversRegisterDriver(a,d.DriverHandle);
