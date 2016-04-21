function dy=pmodel(t,y)
%PMODEL Differential equation system for inverted pendulum.
%  
%  PMODEL(T,Y)
%    T - Time.
%    Y - Current state of inverted pendulum.
%  Returns derivatives of the pendulum state.
%  
%  The state vector Y has three values:
%    Y(1) - Pendulum angle from -2 pi to 2 pi radians.
%    Y(2) - Pendulum angular velocity in radians/second.
%    Y(3) - Force being applied to the pendulum.
%  
%  NOTES: Angle is 0 radians when the pendulum points up.
%         Force stays constant, its derivative is always 0.
%  
%  See also APPCS1, PLINEAR.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:25:51 $

if nargin < 2, error('Not enough input vectors.'); end

% STATE
angle = y(1);
vel   = y(2);
force = y(3);

% CALCULATE DERIVATIVES
dangle = vel;
dvel   = 9.81*sin(angle) - 2*vel + force;
dforce = zeros(size(force));

% RETURN DERIVATIVES
dy = [dangle; dvel; dforce];
