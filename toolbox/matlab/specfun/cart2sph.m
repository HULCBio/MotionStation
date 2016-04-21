function [az,elev,r] = cart2sph(x,y,z)
%CART2SPH Transform Cartesian to spherical coordinates.
%   [TH,PHI,R] = CART2SPH(X,Y,Z) transforms corresponding elements of
%   data stored in Cartesian coordinates X,Y,Z to spherical
%   coordinates (azimuth TH, elevation PHI, and radius R).  The arrays
%   X,Y, and Z must be the same size (or any of them can be scalar).
%   TH and PHI are returned in radians.
%
%   TH is the counterclockwise angle in the xy plane measured from the
%   positive x axis.  PHI is the elevation angle from the xy plane.
%
%   See also CART2POL, SPH2CART, POL2CART.

%   L. Shure, 4-20-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/04/15 03:55:56 $

r = sqrt(x.^2+y.^2+z.^2);
elev = atan2(z,sqrt(x.^2+y.^2));
az = atan2(y,x);
