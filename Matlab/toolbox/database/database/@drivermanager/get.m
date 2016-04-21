function v = get(d,p)
%GET    Get database drivermanager properties.
%   V = GET(D,'PropertyName') returns the value of the specified 
%   properties for the database drivermanager object, D.  'PropertyName'
%   is a string or cell array of strings containing property names.
%
%   V = GET(D) returns a structure where each field name is the name
%   of a property of D and each field contains the value of that 
%   property.
%
%   See also DRIVERMANAGER, SET.

%   Author(s): C.F.Garvin, 07-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8 $   $Date: 2002/06/17 12:00:54 $

%Build properties if none are given   
prps = {'Drivers';...
        'LoginTimeout';...
        'LogStream';...
       };   

%Determine which properties are requested
if nargin == 1
  p = prps;
else
  p = chkprops(d,p,prps);
end

%Establish JAVA connection
a = com.mathworks.toolbox.database.databaseDrivers;

%Get property values
for i = 1:length(p)
  eval(['v.' p{i} ' = driversGet' p{i} '(a);'])
  if strcmp(p{i},'Drivers')
    eval(['v.Drivers = {' v.Drivers '};'])
  end
end

%Return "scalar" value for single property input
if length(p) == 1
  eval(['v = v.' char(p) ';'])
end
