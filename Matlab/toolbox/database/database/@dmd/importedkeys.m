function e = importedkeys(d,c,s,t)
%IMPORTEDKEYS Get information about imported foreign keys.
%   E = IMPORTEDKEYS(D,C,S,T) returns the imported key information for a given
%   database metadata object D, catalog C, schema S, and table T.
%
%   E = IMPORTEDKEYS(D,C,S) returns the imported key information for all tables
%   associated with the database metadata object D, catalog C, and schema S.
%
%   See also GET, EXPORTEDKEYS.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2002/06/17 12:01:22 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Create empty S if not entered
if nargin < 3
  s = [];
end

%Get list of all tables if none specified
if nargin < 4
  t = tables(d,c,s);
elseif ischar(t) 
  t = {t};
end

%Get imported key information
tmp = [];
for i = 1:length(t)
  if isempty(s)
    tmp = [tmp dmdImportedKeys(a,d.DMDHandle,c,t{i})];
  else
    tmp = [tmp dmdImportedKeys(a,d.DMDHandle,c,s,t{i})];
  end    
end
eval(['e = {' tmp '};'])
