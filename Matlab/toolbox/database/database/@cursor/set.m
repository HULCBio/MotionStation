function s = set(h,p,v)
%SET Set RowLimit for cursor fetch.
%   SET(H, 'PROPERTY', 'VALUE') sets the VALUE of the given PROPERTY for the
%   Database Cursor object, H.
%
%   S = SET(H) returns the list of valid properties.
%
%   See also GET.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.15.4.2 $ $Date: 2004/04/06 01:05:12 $

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

%Determine which properties are requested
if nargin == 1
  s = prps;
  return
else
  p = chkprops(h,p,prps);
end

for i = 1:length(p)
  if any(strcmp(p{i},{'Attributes';'Data';'DatabaseObject';'SQLQuery';'Message';'Type';...
        'ResultSet';'Cursor';'Statement';'Fetch'}))
    error('database:cursor:readOnlyProperty','Attempt to modify read-only Cursor property: %s',p{i})
  elseif strcmp(p{i},'RowLimit')
    if ~iscell(v)
      v = num2cell(v);
    end
    setMaxRows(h.Statement,v{i})
  end
end
