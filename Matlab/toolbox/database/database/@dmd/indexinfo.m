function n = indexinfo(d,c,s,t,u,x)
%INDEXINFO Get indices and statistics for database table or schema.
%   N = INDEXINFO(D,C,S,T) returns the table indices and statistics for the
%   database metadata object D, catalog C, schema S, and table T.
%
%   See also GET, TABLES.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $   $Date: 2002/06/17 12:01:30 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Initialize hidden inputs Unique and Approximate
if nargin < 6
  x = 0;
end
if nargin < 5
  u = 0;
end

%Get index information
tmp = dmdIndexInfo(a,d.DMDHandle,c,s,t,u,x);
eval(['n = {' tmp '};'])
