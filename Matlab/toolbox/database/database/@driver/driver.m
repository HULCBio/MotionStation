function o = driver(d)
%DRIVER Construct database driver object.
%   D = DRIVER(S) constructs a database driver object from variable
%   S which is a database URL string of the form jdbc:odbc:<name> or 
%   <name>.  The first driver which recognizes the given database URL is
%   returned.
%
%   See also GET, ISDRIVER, ISJDBC, ISURL, REGISTER.

%   Author(s): C.F.Garvin, 06-30-98
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $   $Date: 2004/04/06 01:05:33 $

%Create parent object for generic methods
dbobj = dbtbx;
if nargin == 0
  t.DriverHandle = [];
  o = class(t,'driver',dbobj);
  return
end

if isa(d,'char')   %Create driver object from database URL string
    
  a = com.mathworks.toolbox.database.databaseDrivers;      %com.mathworks.toolbox.database.databaseDrivers constructor
  tmp = driverReturn(a,d);  %Find driver recognizing url
  
  try                       %Create driver object
    x = driverValid(a,tmp);
    t.DriverHandle = tmp;
    o = class(t,'driver',dbobj);
  catch
    error('database:driver:createObjectFailure','Unable to create database driver object.')
  end
  
elseif isa(d,'driver')   %Return given driver object
  
  o = d;
  
elseif isfield(d,'DriverHandle')  %Create driver object from driver structure
  
  o = class(d,'driver',dbobj);
  
else
  
  error('database:driver:createObjectFailure','Unable to create database driver object.')
  
end
