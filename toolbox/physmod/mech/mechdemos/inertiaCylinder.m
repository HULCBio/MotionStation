function [mass, inertia] = inertiaCylinder(dens, length, rout, rin)
% Calculates the inertia and mass of a cylinder

%   Copyright 1998-2002 The MathWorks, Inc.

%   $Revision: 1.3 $  $Date: 2002/06/27 18:42:45 $
mass = pi*(rout^2-rin^2)*length*dens;
Ix = mass*(3*(rout^2 + rin^2) + length^2)/12;
Iy = Ix;
Iz = mass*(rout^2 + rin^2)/2;
inertia = [Ix 0 0; 0 Iy 0; 0 0 Iz];
