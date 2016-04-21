function yprime = nndshunt(t,y)
%NNDSHUNT Calculates the derivative for a shunting network
%
%  NNDSHUNT(T,Y)
%    T - Time
%    Y - State
%  Returns dY.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

global pp;
global pn;
global bp;
global bn;
global e;

yprime = (-y + (bp - y)*pp - (y + bn)*pn)/e;
