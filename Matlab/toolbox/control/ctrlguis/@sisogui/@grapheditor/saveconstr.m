function SavedData = saveconstr(Editor)
%SAVECONSTR  Saves design constraint.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:01:54 $

Constraints = Editor.findconstr;
nc = length(Constraints);
SavedData = struct('Type',cell(nc,1),'Data',[]);

for ct=1:nc,
    SavedData(ct).Type = Constraints(ct).describe;
    SavedData(ct).Data = Constraints(ct).save;
end