function [s, alpha] = rhumblineinv(phi1, lambda1, phi2, lambda2, in5)
%RHUMBLINEINV Inverse rhumbline problem on a sphere or ellipsoid.
%
%   [S, ALPHA] = RHUMBLINEINV(PHI1, LAMBDA2, PHI1, LAMBDA1, ELLIPSOID)
%   calculates the distance S and azimuth ALPHA from a point at geodetic
%   latitude PHI1 and longitude LAMBDA1 to a point at geodetic latitude
%   PHI2 and longitude LAMBDA2, on the ellipsoid defined by the 1-by-2
%   vector ELLIPSOID.  PHI1, LAMBDA1, PHI2, and LAMBDA2 must be either
%   scalars or vectors of matching size.  S and AlPHA will also be this
%   size.  PHI1, LAMBDA1, PHI2, LAMBDA2, and ALPHA are in radians.  S has
%   the same length units as ELLIPSOID(1), the semimajor axis of the
%   ellipsoid.
%
%   [S, ALPHA] = RHUMBLINEINV(PHI1, LAMBDA2, PHI1, LAMBDA1, RADIUS)
%   calculates the distance and azimuth on a sphere defined by scalar
%   RADIUS.  S has the same units as RADIUS.  Use RADIUS = 1 to obtain S as
%   an angular distance in radians.
%
%   See also MERIDIANARC, RHUMBLINEFWD.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/19 01:13:44 $

phi1(phi1 >  pi/2) =  pi/2;
phi2(phi2 >  pi/2) =  pi/2;
phi1(phi1 < -pi/2) = -pi/2;
phi2(phi2 < -pi/2) = -pi/2;
dlambda = wrapnpi2pi(lambda2 - lambda1);

if numel(in5) == 1 
    % Use spherical calculations when IN5 is a scalar RADIUS.
    [s, alpha] = rhsphereinv(phi1, phi2, dlambda, in5);
else
    % Assume that IN5 is a 1-by-2 ELLIPSOID vector.
    [s, alpha] = rhellipsoidinv(phi1, phi2, dlambda, in5);
end

% Ensure that ALPHA is in the inverval [0 2*pi).
alpha = wrapnpi2pi(alpha);
alpha(alpha < 0) = alpha(alpha < 0) + 2*pi;

%--------------------------------------------------------------------------

function [s, alpha] = rhsphereinv(phi1, phi2, dlambda, radius)

% Solve the rhumbline inverse (dist-az) problem on a sphere.

% Specify a cutoff value:  If cos(ALPHA) > cutoff, use a formula for
% longitude that is exact but undefined for small cos(ALPHA). Otherwise,
% use an approximation that is both accurate and stable for very small
% cos(ALPHA).  The specific cutoff value used here is optimal in the sense
% that it leads to roughly the same error (less than 1e-10 radians in
% longitude, negligible in latitude) with both methods
cutoff = 1e-5;

psi1 = sign(phi1) .* log(tan(abs(phi1)/2 + pi/4));
psi2 = sign(phi2) .* log(tan(abs(phi2)/2 + pi/4));
alpha = atan2(dlambda, psi2 - psi1);

q = (abs(cos(alpha)) > cutoff);
s = zeros(size(q));
if any(q)
    s(q) = radius * abs((phi2(q) - phi1(q)) ./ cos(alpha(q)));
end
if any(~q)
    s(~q) = radius * cos((phi2(~q) + phi1(~q))/2) .* dlambda(~q) ./ sin(alpha(~q));
end

%--------------------------------------------------------------------------

function [s, alpha] = rhellipsoidinv(phi1, phi2, dlambda, ellipsoid)

% Solve the rhumbline inverse (dist-az) problem on an ellipsoid.
% Specify a cutoff value:  If cos(ALPHA) > cutoff, use a formula for
% longitude that is exact but undefined for small cos(ALPHA). Otherwise,
% use an approximation that is both accurate and stable for very small
% cos(ALPHA).  The specific cutoff value used here is optimal in the sense
% that it leads to roughly the same error (less than 1e-10 radians in
% longitude, negligible in latitude) with both methods
cutoff = 1e-5;

a = ellipsoid(1);
e = ellipsoid(2);

psi1 = isometric(phi1,e);
psi2 = isometric(phi2,e);
alpha = atan2(dlambda, psi2 - psi1);

q = (abs(cos(alpha)) > cutoff);
s = zeros(size(q));
if any(q)
    s(q) = abs(meridianarc(phi1(q),phi2(q),ellipsoid) ./ cos(alpha(q)));
end
if any(~q)
    phi = (phi2(~q) + phi1(~q))/2;  % Average latitude
    N = a ./ sqrt(1 - (e * sin(phi)).^2);
    s(~q) = N .* cos(phi) .* dlambda(~q) ./ sin(alpha(~q));
end

%--------------------------------------------------------------------------

function psi = isometric(phi, e)
% Convert geodetic latitude PHI to isometric latitude PSI.

% Exploit the antisymmetry of the isometric latitude:
%   Calculate tan(abs(phi)/2 + pi/4) instead of tan(abs(phi)/2 + pi/4) to
%   avoid log(0) at the south pole.
t = e * sin(abs(phi));
psi = sign(phi) .* log(tan(abs(phi)/2 + pi/4) .* ((1 - t) ./ (1 + t)).^(e/2));

%--------------------------------------------------------------------------

function w = wrapnpi2pi(u)
% Wrap an angle U (in radians) to the interval [-pi pi].  Equivalent to
% w = npi2pi(u,'radians')
w = pi*((abs(u)/pi) - 2*ceil(((abs(u)/pi)-1)/2)) .* sign(u);
