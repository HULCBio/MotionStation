function s = set(d,p,v)
%SET    Set database drivermanager properties.
%   SET(D,'PropertyName',V) sets the value of the specified 
%   properties for the database drivermanager object, D.  'PropertyName'
%   is a string or cell array of strings containing property names.   V
%   is the cell array of property values.
%
%   S = SET(D) returns the list of valid properties.
%
%   See also DRIVERMANAGER, GET.

%   Author(s): C.F.Garvin, 07-06-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $   $Date: 2004/04/06 01:05:39 $

%Build properties if none are given   
prps = {'Drivers';...
        'LoginTimeout';...
        'LogStream';...
       };   
     
     %Determine which properties are requested
if nargin == 1
  s = prps;
  return
else
  p = chkprops(d,p,prps);
end

%Establish JAVA instance handle
a = com.mathworks.toolbox.database.databaseDrivers;

%Get property values
if ~iscell(v) & ~ischar(v)
  v = num2cell(v);
elseif ~iscell(v) & ischar(v)
  v = {v};
end

for i = 1:length(p)
  tmp = v{i};
  if ~ischar(tmp) & ~isempty(class(tmp))
    tmp = num2str(tmp);
  end
  try
    eval(['driversSet' p{i} '(a,' tmp ');'])
  catch
    error('database:drivermanager:readOnlyProperty','Attempt to modify read-only Drivermanager property: %s',p{i})
  end
end
