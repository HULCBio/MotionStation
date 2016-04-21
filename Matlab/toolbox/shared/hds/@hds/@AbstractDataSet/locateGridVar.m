function GridDim = locateGridVar(this,Variable)
%LOCATEGRIDVAR  Locates variable in grid.
%
%   GDIM = LOCATEGRIDVAR(D,VAR) returns the grid dimension DIM
%   to which the variable VAR belongs, and [] if VAR is not
%   part of the grid.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:13 $
GridDim = [];
for ct=1:length(this.Grid_)
   if any(Variable == this.Grid_(ct).Variable)
      GridDim = ct;
      break;
   end
end