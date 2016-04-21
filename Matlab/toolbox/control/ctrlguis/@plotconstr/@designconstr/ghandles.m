function h = ghandles(Constr)
%GHANDLES  Collects HG objects making up design constraint.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:12:37 $

if isempty(Constr.HG)
    h = [];
else
    h = [Constr.HG.Markers(:);Constr.HG.Edge(:);Constr.HG.Patch(:)];
end
