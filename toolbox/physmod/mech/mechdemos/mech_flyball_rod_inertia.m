function J = mech_flyball_rod_inertia(length, radius, density, axis)
%MECH_FLYBALL_ROD_INERTIA - return the inertia tensor of a rod
%  with length, radius, density and oriented along axis.  axis must be
%  one of the carnal axes, e.g., [0 0 1] or [1 0 0]
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.2.4.1 $ $Date: 2004/04/16 22:17:35 $ $Author: batserve $
  ;
  %
  % compute mass, then inertia
  %
  mass = mech_flyball_rod_mass(length, radius, density);
  J1 = diag(~axis) * (0.25 * mass * radius ^ 2 + (mass * length ^ 2) / 12);
  J2 = diag( axis) * (0.5 * mass * radius ^ 2);
  J  = J1 + J2;
    
% [EOF] mech_flyball_rod_mass.m
