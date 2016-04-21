function yprime = nndalay1(t,y)
%NNDALAY1 Calculates the derivative for layer 1 of the Grossberg network
%
%  NNDALAY1(t,y)
%    t - Current time
%    y - Current output
%  Returns dy.


% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

global p;
global bp;
global bn;
global W21;

e= 0.1;
j = 2;

yprime = [-y(1) + (bp - y(1))*(p(1)+W21(1,j)) - (y(1) + bn);
          -y(2) + (bp - y(2))*(p(2)+W21(2,j)) - (y(2) + bn) ]/e;
