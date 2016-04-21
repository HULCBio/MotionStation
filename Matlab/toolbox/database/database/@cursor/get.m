function v = get(d,p)
%GET Get property of cursor object.
%   VALUE = GET(HANDLE, PROPERTY) will return the VALUE of the PROPERTY 
%   specified for the given HANDLE to a Cursor object.
%
%   VALUE  = GET(HANDLE) returns a structure where each field name is the
%   name of a property of HANDLE and each field contains the value of that
%   property.
%
%   See also SET.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.13 $ $Date: 2002/06/17 12:01:42 $

%Build property list
prps = {'Attributes';...
    'Data';...
    'DatabaseObject';...
    'RowLimit';...
    'SQLQuery';...
    'Message';...
    'Type';...
    'ResultSet';...
    'Cursor';...
    'Statement';...
    'Fetch';...
  };

if nargin == 1
  p = prps;
else
  p = chkprops(d,p,prps);
end

%Get property values
for i = 1:length(p)
  if strcmp(p{i},'RowLimit')
    v.RowLimit = getMaxRows(d.Statement);
  else
    eval(['v.' p{i} ' = d.' p{i} ';'])
  end
end

if length(p) == 1
  eval(['v = v.' char(p) ';'])
end
