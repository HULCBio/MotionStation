function v = versioncolumns(d,c,s,t,x)
%VERSIONCOLUMNS Get automatically updated table columns.
%   P = VERSIONCOLUMNS(D,C,S,T) returns the table's columns that are 
%   automatically updated when any row value is updated given the database metadata
%   object, catalog C, schema S and table T. 
%   
%   P = VERSIONCOLUMNS(D,C,S) returns the information for all tables associated 
%   with the given catalog and schema.
%
%   P = VERSIONCOLUMNS(D,C) returns the information for all tables of all schemas
%   of the given catalog.
%
%   See also GET, PROCEDURECOLUMNS.

%   Author(s): C.F.Garvin, 08-17-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $   $Date: 2002/06/17 12:01:35 $

%Create com.mathworks.toolbox.database.databaseDMD instance
a = com.mathworks.toolbox.database.databaseDMD;

%Initiate column argument for return data, default is 2, must be < 9
if nargin < 5
  x = 2;
end

%Initialize schema if not input
if nargin < 3
  s = {};
end

%Get all tables if none given
if nargin < 4
  t = tables(d,c,s);
elseif ischar(t)
  t = {t};
end

%Get column information
tmp = [];
for i = 1:length(t)
  tmp = [tmp dmdVersionColumns(a,d.DMDHandle,c,s,t{i,1})];
end
eval(['p = {' tmp '};'])
if isempty(p)
  v = p;
else
  v = p(:,x);
end
