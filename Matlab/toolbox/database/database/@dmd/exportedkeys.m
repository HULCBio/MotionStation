function e = exportedkeys(d,c,s,t)
%EXPORTEDKEYS Get information about exported foreign keys.
%   E = EXPORTEDKEYS(D,C,S,T) returns the exported key information for a given
%   database metadata object D, catalog C, schema S, and table T.
%
%   E = EXPORTEDKEYS(D,C,S) returns the exported key information for all tables
%   associated with the database metadata object D, catalog C, and schema S.
%
%   See also GET, IMPORTEDKEYS.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2002/06/17 12:01:20 $

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

%Get exported key information
tmp = [];
for i = 1:length(t)
  tmp = [tmp dmdExportedKeys(a,d.DMDHandle,c,s,t{i})];    
end
eval(['e = {' tmp '};'])
