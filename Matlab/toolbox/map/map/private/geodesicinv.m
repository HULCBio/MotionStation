function [s, faz, baz] = geodesicinv(phi1, lambda1, phi2, lambda2, ellipsoid)

%   Solve the inverse problem of geometric geodesy:  Given a pair of points
%   with geodetic coordinates PHI1, LAMBDA1, PHI2, LAMBDA2, find the
%   distance S between them along a geodesic on the specified ELLIPSOID.
%   Also determine the forward azimuth FAZ (azimuth from point 1 to point)
%   and the back azimuth BAZ (azimuth from point 2 to point 1).  All angles
%   and geodetic coordinates are in radians.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/19 01:13:41 $

%   Adapted from U.S. National Geodetic Survey (NGS) Fortran program
%   INVERSE.FOR, Version 200208.19 by Stephen J. Frakes, including
%   subroutines GPNHRI and GPNLOA by Robert (Sid) Safford.

lambda1(lambda1 < 0) = lambda1(lambda1 < 0) + 2*pi;
lambda2(lambda2 < 0) = lambda2(lambda2 < 0) + 2*pi;

% compute the geodetic inverse
[faz, baz, s] = gpnhri(phi1, lambda1, phi2, lambda2, ellipsoid);

% check for a non distance
q = (s/ellipsoid(1) < 0.00005/6371000);
faz(q) = 0;
baz(q) = 0;

%--------------------------------------------------------------------------

function [az1,az2,s] = gpnhri(p1,e1,p2,e2,ellipsoid)

%   Adapted from Fortran subroutine GPNHRI (compute helmert rainsford
%   inverse proglem), Version 200208.09 by Robert (Sid) Safford.
% 
%   solution of the geodetic inverse problem after t. vincenty modified
%   rainsford's method with helmert's elliptical terms effective in any
%   azimuth and at any distance short of antipocal from/to stations must
%   not be the geographic pole. parameter a is the semi-major axis of the
%   reference ellipsoid finv=1/f is the inverse flattening of the reference
%   ellipsoid latitudes and longitudes in radians positive north and west
%   forward and back azimuths returned in radians clockwise from south
%   geodesic distance s returned in units of semi-major axis a
% 
%   1. do not use for meridional arcs and be careful on the equator.
%   2. azimuths are from north(+) clockwise and 
%   3. longitudes are positive east(+) 
% 
%   input parameters:
%   -----------------
%   p1           lat station 1                               radians
%   e1           lon station 1                               radians
%   p2           lat station 2                               radians
%   e2           lon station 2                               radians
%   ellipsoid    ellipsoid vector [semimajor-axis eccentricity]
%  
%   output parameters:
%   ------------------
%   az1          azi at sta 1 -> sta 2                       radians
%   az2          azi at sta 2 -> sta 1                       radians
%   s            geodetic dist between sta(s) 1 & 2          meters
%  
%   local variables and constants:
%   ------------------------------
%   a            semi-major axis of reference ellipsoid      meters
%   f            flattening (0.0033528...)
%   esq          eccentricity squared 
%   aa           constant from subroutine gpnloa                    
%   alimit       equatorial arc distance along the equator   (radians)
%   arc          meridional arc distance latitude p1 to p2 (in meters)      
%   az1          azimuth forward                          (in radians)
%   az2          azimuth back                             (in radians)
%   bb           constant from subroutine gpnloa                    
%   dlon         temporary value for difference in longitude (radians)   
%   equ          equatorial distance                       (in meters)
%   r1,r2        temporary variables    
%   s            ellipsoid distance                        (in meters)
%   sms          equatorial - geodesic distance (S - s) "Sms"       
%   ss           temporary variable     
%   tol0         tolerance for checking computation value         
%   tol1         tolerance for checking a real zero value         
%   tol2         tolerance for close to zero value  
%   twopi        two times constant pi               

az1 = zeros(size(p1));
az2 = zeros(size(p1));
s   = zeros(size(p1));

a = ellipsoid(1);
f = ecc2flat(ellipsoid);
esq  = ellipsoid(2)^2;

tol0 = 5.0d-15;
tol1 = 5.0d-14;
tol2 = 7.0d-03;

twopi = 2*pi;

% test the longitude difference with tol1
% tol1 is approximately 0.000000001 arc seconds
ss = e2 - e1;

q0 = abs(ss) < tol1;
e2(q0) = e2(q0) + tol1;
arc = meridianarc(p1(q0), p2(q0), ellipsoid);
s(q0) = abs(arc);
az1(q0) = pi;
az2(q0) = 0;
az1(q0 & (p2 > p1)) = 0;
az2(q0 & (p2 > p1)) = pi;
if all(q0)
    return
end
    
% test for longitude over 180 degrees
dlon = e2 - e1;
q1 = dlon >= 0;
q2 = q1 & (pi <= dlon) & (dlon < twopi);
ss = abs(dlon);
q3 = ~q1 & (pi <= ss) & (ss < twopi);
dlon(q2) = dlon(q2) - twopi;
dlon(q3) = dlon(q3) + twopi;

q4 = ss > pi;
ss(q4) = twopi - ss(q4);

% compute the limit in longitude (alimit), it is equal 
% to twice the distance from the equator to the pole,
% as measured along the equator (east/west)
alimit =  pi*(1 - f);

% test for anti-nodal difference      
q5 = (ss > alimit);

r1 = abs(p1);
r2 = abs(p2);

%   latitudes r1 & r2 are not near the equator
q6 = (r1 > tol2) & (r2 > tol2);

%   longitude difference is greater than lift-off point
%   now check to see if  "both"  r1 & r2 are on equator
q7 = (r1 < tol1) & (r2 > tol2);
q8 = (r2 < tol1) & (r1 > tol2);

%   check for either r1 or r2 just off the equator but < tol2
q9 = (r1 > tol1) | (r2 > tol1);
q10 = ~q0 & q5 & ~(q6 | q7 | q8) & q9;
az1(q10) = 0;
az2(q10) = 0;
s(q10) = 0;
if all(q0 & q10)
    return
end

%   compute the azimuth to anti-nodal point
q11 = ~q0 & q5 & ~(q6 | q7 | q8) & ~q9;
[az1(q11),az2(q11),sms] = gpnloa(dlon(q11),ellipsoid);

%   compute the equatorial distance & geodetic
equ = a * abs(dlon(q11));
s(q11) = equ - sms;
q12 = ~(q0 | q10 | q11);  % Flag the pairs we haven't done yet as special cases.
if ~any(q12);
    return     % We've done them all!
end

% Move on to general case ...
%  Here we split out a new routine to process a subset of the inputs
%  without the need to constantly apply the logical index q12.
[s_gen, az1_gen, az2_gen]...
    = gpnhri_gen(p1(q12),e1(q12),p2(q12),e2(q12),a,f,esq,tol0);

s(q12)   = s_gen;
az1(q12) = az1_gen;
az2(q12) = az2_gen;

%--------------------------------------------------------------------------

function [s, az1, az2] = gpnhri_gen(p1,e1,p2,e2,a,f,esq,tol0)
    
f0 = (1 - f);
b = a*f0;
epsq = esq/(1 - esq);
f2 = f*f;
f3 = f*f2;
f4 = f*f3;

% the longitude difference 
dlon = e2-e1;
ab = dlon;
kount = 0;

% the reduced latitudes    
u1 = f0*sin(p1)./cos(p1);
u2 = f0*sin(p2)./cos(p2);

u1 = atan(u1);
u2 = atan(u2);

su1 = sin(u1);
cu1 = cos(u1);

su2 = sin(u2);
cu2 = cos(u2);

repeat = true;
while(repeat)
    kount = kount + 1;
    
    clon = cos(ab);
    slon = sin(ab);
    
    csig = su1 .* su2 + cu1 .* cu2 .* clon;
    ssig = sqrt((slon .* cu2).^2 + (su2 .* cu1 - su1 .* cu2 .* clon).^2);

    sig = atan2(ssig,csig);
    sinalf = cu1 .* cu2 .* slon ./ ssig;

    w = (1 - sinalf .^ 2);
    t4 = w .* w;
    t6 = w .* t4;

    ao = f - f2*(1 + f + f2)*w/4 + 3*f3*(1 + 9*f/4)*t4/16 - 25*f4*t6/128;
    a2 =     f2*(1 + f + f2)*w/4 -   f3*(1 + 9*f/4)*t4/4 +  75*f4*t6/256;
    a4 =                             f3*(1 + 9*f/4)*t4/32 - 15*f4*t6/256;
    a6 =                                                     5*f4*t6/768;

    qo = zeros(size(p1));
    qo(w > tol0) = -2 * su1(w > tol0) .* su2(w > tol0) ./ w(w > tol0);

    q2 = csig + qo;
    q4 = 2*q2.^2 - 1;
    q6 = q2.*(4*q2.^2 - 3);
    r2 =  2*ssig.*csig;
    r3 = ssig.*(3 - 4*ssig.^2);

    s = sinalf .* (ao.*sig + a2.*ssig.*q2 + a4.*r2.*q4 + a6.*r3.*q6);
    xz = dlon + s;

    xy = abs(xz - ab);
    ab = dlon + s;
    
    repeat = ~all(xy < 0.5e-13) && (kount <= 7);
end

% the coefficients of type b      
z = epsq * w;
bo = 1 + z.*( 1/4 + z.*( -3/64 + z.*(   5/256 - z.*175/16384)));
b2 =     z.*(-1/4 + z.*(  1/16 + z.*( -15/512 + z.* 35/2048)));
b4 =             z.*z.*(-1/128 + z.*(   3/512 - z.* 35/8192));
b6 =                       z.*z.*z.*( -1/1536 + z.*  5/6144);

% the distance in meters   
s = b*(bo.*sig + b2.*ssig.*q2 + b4.*r2.*q4 + b6.*r3.*q6);

% first compute the az1 & az2 for along the equator
dlon(dlon > pi) = dlon(dlon > pi) - 2*pi;

dlon(abs(dlon) > pi) = dlon(abs(dlon) > pi) + 2*pi;

az1 = pi/2 + zeros(size(p1));
az1(dlon < 0) = 3*pi/2;

az2 = az1 + pi;
az2(az2 > 2*pi) = az2(az2 > 2*pi) - 2*pi;

% now compute the az1 & az2 for latitudes not on the equator
%   azimuths from north,longitudes positive east  
q = ~((abs(su1) < tol0) & (abs(su2) < tol0));
if any(q)
    sinalf = sinalf(q);
    az1(q) =      atan2(  sinalf.*cu2(q),  sinalf.*(su2(q) .* cu1(q) - clon(q) .* su1(q) .* cu2(q))./slon(q));
    az2(q) = pi - atan2( -sinalf.*cu1(q), -sinalf.*(su1(q) .* cu2(q) - clon(q) .* su2(q) .* cu1(q))./slon(q)); 
end
az1(az1 < 0) = az1(az1 < 0) + 2*pi;
az2(az2 < 0) = az2(az2 < 0) + 2*pi;
      
%--------------------------------------------------------------------------      

function [az1,az2,sms] = gpnloa(dl,ellipsoid)

%   Adapted from Fortran subroutine GPNLOA (COMPUTE THE LIFF-OFF-AZIMUTH
%   CONSTANTS), Version 200005.26 by Robert (Sid) Safford.
%
%   INPUT PARAMETERS:
%   -----------------
%   DL           LON DIFFERENCE
%   ELLIPSOID    ellipsoid vector [semimajor-axis eccentricity]
%  
%   OUTPUT PARAMETERS:
%   ------------------
%   AZ1          AZI AT STA 1 -> STA 2
%   AZ2          AZ2 AT STA 2 -> STA 1
%   SMS          DISTANCE ... EQUATORIAL - GEODESIC  (S - s)   "SMS"

amax = ellipsoid(1);         % SEMI-MAJOR AXIS OF REFERENCE ELLIPSOID
flat = ecc2flat(ellipsoid);  % FLATTENING (0.0033528 ... )
esq  = ellipsoid(2)^2;       % ECCENTRICITY SQUARED FOR REFERENCE ELLIPSOID

tt = 5e-13;

dlon = abs(dl);
cons = (pi - dlon)/(pi*flat);
f = flat;

% COMPUTE AN APPROXIMATE AZ
az = asin(cons);

t1 =     1;
t2 =   (-1/4)*f*(1 + f + f*f);
t4 =   (3/16)*f*f*(1 + (9/4)*f);
t6 = (-25/128)*f*f*f;

repeat = true;
iter = 0;
while(repeat)
    iter = iter + 1;
    s = cos(az);
    c2 = s.*s;
    ao = t1 + t2*c2 + t4*c2.*c2 + t6*c2.*c2.*c2;
    cs = cons./ao;
    s  = asin(cs);
    q = abs(s - az) < tt;
    az(~q) = s(~q);
    repeat = any(~q) && (iter <= 6);
end
az1 = s;

az1(dl < 0) = 2*pi - az1(dl < 0);

az2 = 2*pi - az1;

% EQUATORIAL - GEODESIC  (S - s)   "SMS"
esqp = esq/(1 - esq);
s = cos(az1);

u2 = esqp * s .* s;
u4 = u2 .* u2;
u6 = u4 .* u2;
u8 = u6 .* u2;

t1 =      1;
t2 =     (1/4)*u2;
t4 =    (-3/64)*u4;
t6 =    (5/256)*u6;
t8 = (-175/16384)*u8;

bo = t1 + t2 + t4 + t6 + t8;
s = sin(az1);
sms = amax * pi * (1 - flat*abs(s).*ao - bo*(1 - flat));
