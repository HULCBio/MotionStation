function s = meridianarc(phi1, phi2, ellipsoid)
%MERIDIANARC Calculate distance along a meridian.
%
%   S = MERIDANARC(PHI1, PHI2, ELLIPSOID) calculates the (signed) distance
%   S between latitudes PHI1 and PHI2 along a meridian on the ellipsoid
%   defined by the 1-by-2 vector ELLIPSOID.  PHI1 and PHI2 are in radians.
%   S has the same units as the semimajor axis of the ellipsoid.  S is
%   negative if phi2 is less than phi1.
%
%   See also MERIDIANFWD.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/19 01:13:34 $

% The following provides an equivalent (but less efficient) computation:
%
% s = rsphere('rectifying',ellipsoid)...
%        * (convertlat(ellipsoid,phi2,'geodetic','rectifying','radians')...
%         - convertlat(ellipsoid,phi1,'geodetic','rectifying','radians'));
  
n = ecc2n(ellipsoid(2));
n2 = n^2;

% Radius of rectifying sphere
r = ellipsoid(1) * (1 - n) * (1 - n2) * (1 + ((9/4) + (225/64)*n2)*n2);

f1 = (3/2 - (9/16) * n2) * n;
f2 = (15/16 - (15/32) * n2) * n2;
f3 = (35/48) * n * n2;
f4 = (315/512) * n2 * n2;

% Rectifying latitudes
mu1 = phi1 - f1*sin(2*phi1) + f2*sin(4*phi1) - f3*sin(6*phi1) + f4*sin(8*phi1);
mu2 = phi2 - f1*sin(2*phi2) + f2*sin(4*phi2) - f3*sin(6*phi2) + f4*sin(8*phi2);

s = r * (mu2 - mu1);
