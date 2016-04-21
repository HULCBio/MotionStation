function p = columnprivileges(d,c,s,t,l)
%COLUMNPRIVILEGES Get database column privileges.
%   P = COLUMNPRIVILEGES(D,C,S,T,L) returns the privileges for the columns associated
%   with the database metadata D, the catalog C, the schema S, the table T, and
%   the column L.
%
%   P = COLUMNPRIVILEGES(D,C,S,T) returns the privileges for all columns for the
%   given catalog, schema, and table.
%
%   See also GET, COLUMNS.

%   Author(s): C.F.Garvin, 08-05-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $   $Date: 2004/04/06 01:05:29 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Get all columns if none input
if nargin < 5
  l = columns(d,c,s,t);
elseif ischar(l)
  l = {l};
end

%Get data
tmp = [];
for i = 1:length(l)
  tmp = [tmp dmdColumnPrivileges(a,d.DMDHandle,c,s,t,l{i})];
end

%Return if no table privileges found
if isempty(tmp)
  p = [];
  return
end

%Parse return data into unique columns
eval(['y = {' tmp '};'])
z = unique(y(:,4));

for i = 1:length(z)
  j = find(strcmp(y(:,4),z(i)));
  x{i,1} = y{i,3};
  x{i,2} = z{i};
  x{i,3} = y(j,7)';
end

%Return data for given table or else return all table information
if nargin == 5
  j = find(strcmp(upper(x(:,2)),upper(l)));
  try
    p = x{j,3};
  catch
    error('database:dmd:invalidColumn','Invalid column name.')
  end
else
  p = x;
end
