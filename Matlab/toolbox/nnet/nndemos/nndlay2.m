function yprime = nndlay2(t,y)
%NNDLAY2 Calculates the derivative for layer 2 of the Grossberg network
%
%  NNDLAY2(t,y)
%    t - Current time
%    y - Current output
%  Returns dy.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

global p;
global tf;
global W2;

yprime = zeros(2,1);
bp = 1;
bn = 0;
e = 0.1;

i1 = W2(1,:)*p;
i2 = W2(2,:)*p;

if tf == 1
  a = y;
elseif tf == 2
  a = 10*(y.^2)/(1+y.^2);
elseif tf == 3
  a = 10*(y.^2);
else
  a = 1-exp(-y);
end

yprime(1) = (-y(1) + (bp - y(1))*(a(1)+i1) - (y(1) + bn)*a(2))/e;
yprime(2) = (-y(2) + (bp - y(2))*(a(2)+i2) - (y(2) + bn)*a(1))/e;
