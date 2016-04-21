function v = get(d,p)
%GET    Get database driver properties.
%   V = GET(D,'PropertyName') returns the value of the specified 
%   properties for the database driver object, D.  'PropertyName' is
%   a string or cell array of strings containing property names. 
%
%   V = GET(D) returns a structure where each field name is the name
%   of a property of D and each field contains the value of that 
%   property.
%
%   See also DRIVER, ISDRIVER, ISJDBC, ISURL.

%   Author(s): C.F.Garvin, 06-30-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $   $Date: 2004/04/06 01:05:34 $

%Validate driver object
if ~isdriver(d)
  error('database:driver:invalidObject','Invalid driver object.')
end

%Build properties if none are given   
prps = {'MajorVersion';...
        'MinorVersion';...
       };   
     
%Determine which properties are requested
if nargin == 1
  p = prps;
else
  p = chkprops(d,p,prps);  
end

%Create com.mathworks.toolbox.database.databaseDrivers instance
a = com.mathworks.toolbox.database.databaseDrivers;

%Get property values
for i = 1:length(p)
  eval(['v.' p{i} ' = driver' p{i} '(a,d.DriverHandle);'])  
end

if length(p) == 1
  v = v.(char(p));
end
