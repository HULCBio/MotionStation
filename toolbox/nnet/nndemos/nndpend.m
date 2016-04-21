function yprime = nndpend(t,y)
%NNDPEND Dynamical model of a pendulum.
%  
%  NNDPEND(T,Y)
%    T - Time
%    Y - State = [angle; angular velocity]
%   Returns Derivative of state vector.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

yprime = zeros(2,1);

yprime(1) = y(2);
yprime(2) = -sin(y(1)) - 0.2*y(2);
