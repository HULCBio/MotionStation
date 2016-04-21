function latout = convertlat(ellipsoid, latin, from, to, units)
%CONVERTLAT  Convert between geodetic and auxiliary latitudes.
%
%   LATOUT = CONVERTLAT(ELLIPSOID, LATIN, FROM, TO, UNITS) converts
%   latitude values in LATIN from type FROM to type TO.  ELLIPSOID is a
%   1-by-2 ellipsoid vector of the form [SEMIMAJORAXIS ECCENTRICITY].  (The
%   ALMANAC function offers a set of built-in ellipsoids covering most
%   widely-available map data.)  LATIN is a array of input latitude values.
%   FROM and TO are each one of the latitude type strings listed below (or
%   unambiguous abbreviations). LATIN has the angle units specified by
%   UNITS:  either 'degrees', 'radians', or unambiguous abbreviations. The
%   output array, LATOUT, has the same size and units as LATIN.
%
%   Latitude Type    Description
%   -------------    -----------
%   geodetic         The geodetic latitude is the angle that a line
%                    perpendicular to the surface of the ellipsoid at the
%                    given point makes with the equatorial plane.
%
%   authalic         The authalic latitude is maps an ellipsoid to a
%                    sphere while preserving surface area. Authalic
%                    latitudes are used in place of the geodetic latitudes
%                    when projecting the ellipsoid using an equal area
%                    projection.
%
%   conformal        The conformal latitude is used to map an ellipsoid
%                    conformally onto a sphere. Conformal latitudes are
%                    used in place of the geodetic latitudes when
%                    projecting the ellipsoid with a conformal projection.
%
%   geocentric       The geocentric latitude is the angle that a line
%                    connecting a point on the surface of the ellipsoid to
%                    the its center makes with the equatorial plane.
%
%   isometric        The isometric latitude is a nonlinear function of the
%                    geodetic latitude.  It is directly proportional to the
%                    spacing of parallels of geodetic latitude from the
%                    Equator on the ellipsoidal Mercator projection.
%
%   parametric       The parametric latitude of a point on the ellipsoid is
%                    the latitude on a sphere of radius a, where a is the
%                    semimajor axis of the ellipsoid, for which the
%                    parallel has the same radius as the parallel of
%                    geodetic latitude.
%
%   rectifying       The rectifying latitude is used to map an ellipsoid
%                    to a sphere in such a way that distance is preserved
%                    along meridians.  Rectifying latitudes are used in
%                    place of the geodetic latitudes when projecting the
%                    ellipsoid using an equidistant projection.
%  
%   Note
%   ----
%   To properly project rectified latitudes, the radius must also be scaled
%   to assure the equal meridional distance property. This is accomplished
%   by RSPHERE.
%
%   Example
%   -------
%   % Plot the difference between the auxiliary latitudes and geocentric
%   % latitude, from equator to pole, using the GRS 80 ellipsoid.  Avoid
%   % the polar region with the isometric latitude, and scale down the
%   % difference by a factor of 200.
%   grs80 = almanac('earth','ellipsoid','m','grs80');
%   geodetic = 0:2:90;
%   authalic   = convertlat(grs80,geodetic,'geodetic','authalic',  'deg');
%   conformal  = convertlat(grs80,geodetic,'geodetic','conformal', 'deg');
%   geocentric = convertlat(grs80,geodetic,'geodetic','geocentric','deg');
%   parametric = convertlat(grs80,geodetic,'geodetic','parametric','deg');
%   rectifying = convertlat(grs80,geodetic,'geodetic','rectifying','deg');
%   isometric = convertlat(grs80,geodetic(1:end-5),'geodetic','isometric','deg');
%   plot(geodetic, (authalic   - geodetic),...
%        geodetic, (conformal  - geodetic),...
%        geodetic, (geocentric - geodetic),...
%        geodetic, (parametric - geodetic),...
%        geodetic, (rectifying - geodetic),...
%        geodetic(1:end-5), (isometric - geodetic(1:end-5))/200);
%   title('Auxiliary Latitudes vs. Geodetic')
%   xlabel('geodetic latitude, degrees')
%   ylabel('departure from geodetic, degrees');
%   legend('authalic','conformal','geocentric','parametric','rectifying',...
%          'isometric/200');
%
%   See also ALMANAC, RSPHERE.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:22 $

%--------------------------------------------------------------------------
% We have a computational subfunction to take geodetic latitude to and from
% each auxiliary latitude type. They do no argument parsing and their input
% and output latitudes are in radians.  The formulae employed in the
% subfunctions were taken from:
%    J. P. Snyder, "Map Projections - A Working Manual,"  US Geological
%    Survey Professional Paper 1395, US Government Printing Office,
%    Washington, DC, 1987, pp. 13-18.
%--------------------------------------------------------------------------

if strcmp(units,'nocheck')
    % Short-cut for internal use: Assume radians and bypass arg checking.
    lat = latin;
    if ~strcmp(from,'geodetic')
        fcn = str2func([from '2geodetic']);
        lat = fcn(ellipsoid(2),lat,mfilename);
    end

    if ~strcmp(to,'geodetic')
        fcn = str2func(['geodetic2' to]);
        lat = fcn(ellipsoid(2),lat,mfilename);
    end
    latout = lat;
    return;
end

%--------------------------------------------------------------------------
% Public use with arg checking, units of radians or degrees.

lattypes = {'geodetic','authalic',  'geocentric', 'conformal',...
            'isometric', 'parametric', 'rectifying'};
   
ellipsoid = checkellipsoid(ellipsoid, mfilename, 'ELLIPSOID',1);
checkinput(latin,{'double'},{'real'}, mfilename, 'LATIN', 2);
from  = checkstrs(from, lattypes, mfilename, 'FROM', 3);
to    = checkstrs(to,   lattypes, mfilename, 'TO', 4);
units = checkstrs(units,{'degrees','radians'}, mfilename, 'UNITS', 5);

lat = latin;
if ~strcmp(units,'radians')
    lat = (pi/180) * lat;
end

if ~strcmp(from,'geodetic')
    fcn = str2func([from '2geodetic']);
    lat = fcn(ellipsoid(2),lat,mfilename);
end

if ~strcmp(to,'geodetic')
    fcn = str2func(['geodetic2' to]);
    lat = fcn(ellipsoid(2),lat,mfilename);
end

if ~strcmp(units,'radians')
    lat = (180/pi) * lat;
end
latout = lat;

%--------------------------------------------------------------------------
function latout = authalic2geodetic(e,latin,function_name)

checkecc(e,function_name);

fact1 = e^2 /3 + 31*e^4 /180 + 517*e^6 /5040;
fact2 = 23*e^4 /360 + 251*e^6 /3780;
fact3 = 761*e^6 /45360;

%  Truncated series expansion.
latout = latin + ...
         fact1*sin(2*latin) + ...
		 fact2*sin(4*latin) + ...
         fact3*sin(6*latin);

%--------------------------------------------------------------------------
function latout = geodetic2authalic(e,latin,function_name)

checkecc(e,function_name);

fact1 = e^2 /3 + 31*e^4 /180 + 59*e^6 /560;
fact2 = 17*e^4 /360 + 61*e^6 /1260;
fact3 = 383*e^6 /45360;

%  Truncated series expansion.
latout = latin - ...
         fact1*sin(2*latin) + ...
		 fact2*sin(4*latin) - ...
         fact3*sin(6*latin);

%--------------------------------------------------------------------------
function latout = geocentric2geodetic(e,latin,function_name)
latout = atan2( sin(latin), (1-e^2)*cos(latin) );

%--------------------------------------------------------------------------
function latout = geodetic2geocentric(e,latin,function_name)
latout = atan2( (1-e^2)*sin(latin), cos(latin) );

%--------------------------------------------------------------------------
function latout = parametric2geodetic(e,latin,function_name)
latout = atan2( sin(latin), sqrt(1-e^2)*cos(latin) );

%--------------------------------------------------------------------------
function latout = geodetic2parametric(e,latin,function_name)
latout = atan2( sqrt(1-e^2)*sin(latin), cos(latin) );

%--------------------------------------------------------------------------
function latout = conformal2geodetic(e,latin,function_name)

checkecc(e,function_name);

fact1 = e^2 /2 + 5*e^4 /24 + e^6 /12 + 13*e^8 /360;
fact2 = 7*e^4 /48 + 29*e^6 /240 + 811*e^8 /11520;
fact3 = 7*e^6 /120 + 81*e^8 /1120;
fact4 = 4279*e^8 /161280;

%  Truncated series expansion.
latout = latin + ...
         fact1*sin(2*latin) + ...
		 fact2*sin(4*latin) + ...
         fact3*sin(6*latin) + ...
		 fact4*sin(8*latin);
     
%--------------------------------------------------------------------------
function chi = geodetic2conformal(ecc,phi,function_name)

fact1 = 1 - ecc*sin(phi); 
fact2 = 1 + ecc*sin(phi);
chi = 2 * atan(tan(pi/4 + phi/2) .* (fact1./fact2).^(ecc/2)) - pi/2;

%--------------------------------------------------------------------------
function latout = isometric2geodetic(e,latin,function_name)
    
latcnf = 2 * atan(exp(latin)) - pi/2;    % Compute the conformal latitude.
latout = conformal2geodetic(e,latcnf,function_name);

%--------------------------------------------------------------------------
function latout = geodetic2isometric(e,latin,function_name)

% Exploit the antisymmetry of the auxiliary latitude:
%   Work with positive values of conformal latitude ('latcnf' below) to
%   avoid log(0) at the South Pole.
latcnf = geodetic2conformal(e,abs(latin),function_name); % Compute conformal.
latout = sign(latin) .* log(tan(pi/4 + latcnf/2));       % Compute isometric.

%--------------------------------------------------------------------------
function latout = rectifying2geodetic(ecc,latin,function_name)

checkecc(ecc,function_name);

n = ecc2n(ecc);
fact1 = 3*n /2 - 27*n^3 /32;
fact2 = 21*n^2 /16 - 55*n^4 /32;
fact3 = 151*n^3 /96;
fact4 = 1097*n^4 /512;

%  Truncated series expansion.
latout = latin + ...
         fact1*sin(2*latin) + ...
		 fact2*sin(4*latin) + ...
         fact3*sin(6*latin) + ...
		 fact4*sin(8*latin);

%--------------------------------------------------------------------------
function latout = geodetic2rectifying(ecc,latin,function_name)

checkecc(ecc,function_name);

n = ecc2n(ecc);
fact1 = 3*n /2 - 9*n^3 /16;
fact2 = 15*n^2 /16 - 15*n^4 /32;
fact3 = 35*n^3 /48;
fact4 = 315*n^4 /512;

%  Truncated series expansion.
latout = latin - ...                
         fact1*sin(2*latin) + ...
		 fact2*sin(4*latin) - ...
         fact3*sin(6*latin) + ...
		 fact4*sin(8*latin);

%--------------------------------------------------------------------------
function checkecc(ecc,function_name)
if ecc > 0.5
    wid = sprintf('%s:%s:highEccentricity',getcomp,function_name);
    warning(wid,'%s','Auxiliary sphere approximation weakens with eccentricity > 0.5');
end
