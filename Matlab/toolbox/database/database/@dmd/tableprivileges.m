function p = tableprivileges(d,c,s,t)
%TABLEPRIVILEGES Get database table privileges.
%   P = TABLEPRIVILEGES(D,C,S,T) returns the privileges for the tables associated
%   with the database metadata D, the catalog C, the schema S, and the table T.
%
%   P = TABLEPRIVILEGES(D,C,S) returns the privileges for all tables for the given
%   catalog and schema.
%
%   P = TABLEPRIVILEGES(D,C) returns the privilges for all tables of all schemas
%   of the given catalog.
%
%   See also GET, TABLES.

%   Author(s): C.F.Garvin, 08-05-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $   $Date: 2004/04/06 01:05:32 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Initialize schema if not input
if nargin < 3
  s = {};
end

%Get the list of tables and privileges
tmp = dmdTablePrivileges(a,d.DMDHandle,c,s);

%Return if no table privileges found
if isempty(tmp)
  p = [];
  return
end

%Parse return data into unique tables
eval(['y = {' tmp '};'])
z = unique(y(:,3));

for i = 1:length(z)
  j = find(strcmp(y(:,3),z(i)));
  x{i,1} = z{i};
  x{i,2} = y(j,6)';
end

%Return data for given table or else return all table information
if nargin == 4
  j = find(strcmp(upper(x(:,1)),upper(t)));
  try
    p = x{j,2};
  catch
    error('database:dmd:invalidTable','Invalid table name.')
  end
else
  p = x;
end
