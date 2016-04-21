function e = crossreference(d,pc,ps,pt,fc,fs,ft)
%CROSSREFERENCE Get information about primary and foreign keys.
%   E = CROSSREFERENCE(D,PC,PS,PT,FC,FS,FT) returns the foreign and primary key 
%   information for a given database metadata object D, primary catalog PC, 
%   primary schema PS, primary table PT, foreign catalog FC, foreign schema FS, 
%   and foreign table FT.
%
%   See also GET, EXPORTEDKEYS, IMPORTEDKEYS, PRIMARYKEYS.

%   Author(s): C.F.Garvin, 08-06-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $   $Date: 2002/06/17 12:01:29 $

%Create com.mathworks.toolbox.database.databaseDMD instance handle
a = com.mathworks.toolbox.database.databaseDMD;

%Get foreign and primary key info, assuming all inputs are given
tmp = dmdCrossReference(a,d.DMDHandle,pc,ps,pt,fc,fs,ft);

%Parse return data
eval(['e = {' tmp '};'])
