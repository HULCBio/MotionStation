function yprime = nndlay1(t,y)
%NNDLAY1 Calculates the derivative for layer 1 of the Grossberg network
%
%  NNDLAY1(t,y)
%    t - Current time
%     y - Current output
%  Returns dy.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

global p;
global bp;
global bn;
global e;

yprime = [(-y(1) + (bp - y(1))*p(1) - (y(1) + bn)*p(2));
          (-y(2) + (bp - y(2))*p(2) - (y(2) + bn)*p(1))] / e;
