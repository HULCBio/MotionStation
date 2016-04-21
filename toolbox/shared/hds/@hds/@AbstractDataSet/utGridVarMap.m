function GridDim = utGridVarMap(this,Vars)
% Returns index vector commensurate with VARS indicating
% which grid dimension each variable belongs to (and 
% zero if none)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:27 $
nv = length(Vars);
GridDim = zeros(nv,1);
for ct=1:length(this.Grid_)
   [ia,ib] = utIntersect(Vars,this.Grid_(ct).Variable);
   GridDim(ia) = ct;
end
