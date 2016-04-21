function yprime = nndhop(t,y)
%NNDHOP Calculates the derivative for Hopfield network
%
%  NNDHOP(t,y)
%    t - Current time
%    y - Current output
%  Returns dy.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

global lambda;
global W;
global b;

a = 2/pi*atan(lambda*pi*y*0.5);
yprime = -y+W*a+b;
