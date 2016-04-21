function [x,y,z] = sph2cart(az,elev,r)
%SPH2CART Transform spherical to Cartesian coordinates.
%   [X,Y,Z] = SPH2CART(TH,PHI,R) transforms corresponding elements of
%   data stored in spherical coordinates (azimuth TH, elevation PHI,
%   radius R) to Cartesian coordinates X,Y,Z.  The arrays TH, PHI, and
%   R must be the same size (or any of them can be scalar).  TH and
%   PHI must be in radians.
%
%   TH is the counterclockwise angle in the xy plane measured from the
%   positive x axis.  PHI is the elevation angle from the xy plane.
%
%   See also CART2SPH, CART2POL, POL2CART.

%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/04/15 03:54:33 $

z = r .* sin(elev);
x = r .* cos(elev) .* cos(az);
y = r .* cos(elev) .* sin(az);
