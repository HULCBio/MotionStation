function yprime = nndalay2(t,y)
%NNDALAY2 Calculates the derivative for layer 2 of the Grossberg network
%
%  NNDALAY2(t,y)
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
global A;

w1 = [0.5 0.5];
w2 = [1 0];
e = 0.1;

i1 = w1*p;
i2 = w2*p;

a = (A*y.^2) .* (y>0);

yprime = [-y(1) + (bp - y(1))*(a(1)+i1) - (y(1) + bn)*a(2);
          -y(2) + (bp - y(2))*(a(2)+i2) - (y(2) + bn)*a(1)] /e;
