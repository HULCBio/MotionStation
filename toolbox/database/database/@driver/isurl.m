function x = isurl(d,s)
%ISURL Detect if the database URL is valid.
%   X = ISURL(D,S) returns 1 if S is a valid database URL for the given  
%   driver, D.  The given URL, of the form 'jdbc:odbc:<name>' for
%   example, is tested against the given database driver object D.
%
%   See also GET, ISJDBC.

%   Author(s): C.F.Garvin, 06-30-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $   $Date: 2004/04/06 01:05:36 $

%Validate driver object
if ~isdriver(d)
  error('database:driver:invalidObject','Invalid driver object.')
end

%Establish instance handle to JAVA routines
a = com.mathworks.toolbox.database.databaseDrivers;
  
%Test URL against given driver
x = driverURL(a,d.DriverHandle,s);
