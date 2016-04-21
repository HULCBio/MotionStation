function [phi2, lambda2, baz] = geodesicfwd(phi1, lambda1, faz, s, ellipsoid)

%   Solve the forward (direct) problem of geometric geodesy:  Given an
%   initial point (PHI1,LAMBDA1), find a second point at a specified azimuth
%   FAZ and distance S along a geodesic on the specified ELLIPSOID. All
%   angles and geodetic coordinates are in radians.  The geodetic distance
%   S must have the same units as the semimajor axis of the ellipsoid,
%   ellipsoid(1).  The azimuths are defined to be clockwise from north.
%
%   See also GEODESICINV, MERIDIANFWD.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/19 01:13:40 $

%   Adapted from U.S. National Geodetic Survey (NGS) Fortran program
%   FORWARD.FOR, Version 200208.19 by Stephen J. Frakes, incuding
%   subroutine DIRCT1 by LCDR L. Pfeifer (1975/02/20) and John G. Gergen
%   (1975/06/08).

% Compute a distance limit.  Beyond this limit, the algorithm from DIRCT1
% (below) degrades in accuracy.  The limit is twice the distance from the
% equator to the north pole, for our reference ellipsoid, minus one meter.
dd_max = 2 * meridianarc(0,pi/2,ellipsoid) - 1;
if any(s >= dd_max)
    wid = sprintf('%s:%s:longGeodesic', getcomp, mfilename);
    warning(wid,'%s\n%s',...
        'Some geodesics reach halfway around the earth or farther.',...
        'Loss of accuracy is possible.');
end

% Comments from DIRCT1:  SOLUTION OF THE GEODETIC DIRECT PROBLEM AFTER
% T.VINCENTY MODIFIED RAINSFORD'S METHOD WITH HELMERT'S ELLIPTICAL TERMS
% EFFECTIVE IN ANY AZIMUTH AND AT ANY DISTANCE SHORT OF ANTIPODAL

tol = 0.5e-13;

f = ecc2flat(ellipsoid);   % Semi-major axis of the reference ellipsoid
a = ellipsoid(1);          % Flattening of the reference ellipsoid

r = 1 - f;
tu = r * sin(phi1) ./ cos(phi1);
sf = sin(faz);
cf = cos(faz);
baz = zeros(size(phi1));
q = (cf ~= 0);
baz(q) = 2* atan2(tu(q),cf(q));
cu = 1./sqrt(tu.^2 + 1);
su = tu .* cu;
sa = cu .* sf;
c2a = -sa.^2 + 1;
x = sqrt((1/r/r - 1)*c2a + 1) + 1;
x = (x - 2)./x;
c = 1 - x;
c = (1 + (x.^2)/4)./c;
d = (0.375 * x.^2 - 1) .* x;
tu = s ./ r ./ a ./ c;
y = tu;

repeat = true;
while(repeat)
    sy = sin(y);
    cy = cos(y);
    cz = cos(baz + y);
    e = 2 * cz.^2 - 1;
    c = y;
    x = e .* cy;
    y = 2 * e - 1;
    y = (((4 * sy.^2 - 3) .* y .* cz .* d/6 + x) .* d/4 - cz) .* sy .* d + tu;
    repeat = any(abs(y - c) > tol);
end

baz = cu .* cy .* cf - su .* sy;
c = r * sqrt(sa.^2 + baz.^2);
d = su .* cy + cu .* sy .* cf;
phi2 = atan2(d,c);
c = cu .* cy - su .* sy .* cf;
x = atan2(sy .* sf, c);
c = ((-3 * c2a + 4) * f + 4) .* c2a * f/16;
d = ((e .* cy .* c + cz) .* sy .* c + y) .* sa;
lambda2 = lambda1 + x - (1 - c) .* d .* f;
baz = atan2(sa,baz) + pi;
