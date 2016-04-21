function yprime = nndhopi(t,y)
%NNDHOPI Calculates the derivative for sample Hopfield network
%
% NNDHOPI(t,y)
%   t - Current time
%   y - Current output
% Returns dy

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.5 $

global W;
global b;

% Assuming infinite Lambda:

yprime = 0.5*W*y + b;
