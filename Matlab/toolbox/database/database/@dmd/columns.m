function p = columns(d,c,s,t)
%COLUMNS Get database table column names.
%   P = COLUMNS(D,C,S,T) returns the columns for the given database metadata D, 
%   the catalog C, the schema S, and the table T.
%
%   P = COLUMNS(D,C,S) returns the columns for all tables for the given
%   catalog and schema.
%
%   P = COLUMNS(D,C) returns all columns for all tables of all schemas for the 
%   given catalog.
%
%   See also GET, COLUMNNAMES, COLUMNPRIVILEGES.

%   Author(s): C.F.Garvin, 08-05-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $   $Date: 2004/04/06 01:05:30 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Set schema to null if not entered
if nargin < 3
  s = {};
end

%Get the list of tables and columns, trap null schema entry
tmp = dmdColumns(a,d.DMDHandle,c,s);

%Return if no table columns found
if ~(tmp.size)
  p = [];
  return
end

%Parse vector of columns info
ncols = 14;   %Columns result set has 14 columns
y = system_dependent(44,tmp,tmp.size/ncols)';
z = unique(y(:,3));

%Return table and corresponding column information
for i = 1:length(z)
  j = find(strcmp(y(:,3),z(i)));
  x{i,1} = z{i};
  x{i,2} = y(j,4)';
end

%Return columns for given table or else return all table information
if nargin == 4 & ~isempty(t)
  j = find(strcmp(upper(x(:,1)),upper(t)));
  try
    p = x{j,2};
  catch
    error('database:dmd:invalidTable','Invalid table name.')
  end
else
  p = x;
end
