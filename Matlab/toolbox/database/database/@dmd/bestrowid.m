function b = bestrowid(d,c,s,t,n,x)
%BESTROWID Get database table unique row identifier.
%   B = BESTROWID(D,C,S,T) returns the set of table columns that 
%   uniquely identifies a row.  D is the database metadata object, C is the
%   catalog, S is the schema, and T is the table.
%
%   B = BESTROWID(D,C,S) returns the unique row identifier for all tables
%   associated with the given catalog and schema.
%
%   See also COLUMNS, GET, TABLES.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $   $Date: 2002/06/17 12:01:26 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Set return index, must be less than 9, for all data, set x = 1:8.
if nargin < 6
  x = 2;
end

%Set default scope argument (hidden input)
if nargin < 5
  n = 0;
end

%Create empty S is not entered
if nargin < 3
  s = [];
end

%Get table list if no table input, include type TABLE only
if nargin < 4 | isempty(t)
  y = tables(d,c,s);
  i = find(strcmp(y(:,2),'TABLE'));
  t = y(i,1);
elseif ischar(t)
  t = {t};
end

%Get column information
tmp = [];
L = length(t);
for i = 1:L
  if isempty(s)
    tmp = [tmp dmdBestRowIdentifier(a,d.DMDHandle,c,t{i},n)];
  else
    tmp = [tmp dmdBestRowIdentifier(a,d.DMDHandle,c,s,t{i},n)];
  end
end

%Return data
eval(['y = {' tmp '};'])
if isempty(y)
  b = y;
elseif L == 1
  b = y(:,x);
else
  b = [t y(:,x)];
end

