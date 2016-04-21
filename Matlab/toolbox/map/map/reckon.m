function [latout,lonout] = reckon(varargin)

%RECKON  Compute position at a specified azimuth and range.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, RNG, AZ), for scalar inputs,
%   calculates a position (LATOUT, LONOUT) at a given range RNG and azimuth
%   AZ along a great circle from a starting point defined by LAT and LON.
%   LAT and LON are in degrees.  The range is in degrees of arc length on a
%   sphere.  The input azimuth is in degrees, measured clockwise from due
%   north.  RECKON calculates multiple positions when given four non-scalar
%   inputs of matching size.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, RNG, AZ, UNITS), where UNITS is any
%   valid angle units string, specifies the angular units of the inputs and
%   outputs, including RNG.  The default value is 'degrees'.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, RNG, AZ, ELLIPSOID) calculates
%   positions along a geodesic on an ellipsoid, as specified by the
%   two-element vector ELLIPSOID.  The range, RNG, is in linear distance
%   units matching the units of the semimajor axis of the ellipsoid (the
%   first element of ELLIPSOID).
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, RNG, AZ, ELLIPSOID, UNITS)
%   calculates positions on the specified ellipsoid with LAT, LON, AZ,
%   LATOUT, and LONOUT in the specified angle units. 
%
%   [LATOUT,LONOUT] = RECKON(TRACK,...) calculates positions on great
%   circles (or geodesics) if TRACK is 'gc' and along rhumb lines if TRACK
%   is 'rh'. The default value is 'gc'.
%
%   See also AZIMUTH, DISTANCE.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.4 $  $Date: 2004/04/19 01:13:45 $

[useGeodesic,lat,lon,rng,az,ellipsoid,units,insize] = parseInputs(varargin{:});
if useGeodesic
    if ellipsoid(2) ~= 0
        [newlat,newlon] = geodesicfwd(lat,lon,az,rng,ellipsoid);
    else
        [newlat,newlon] = reckongc(lat,lon,rng,az,ellipsoid(1));
    end
else
    if ellipsoid(2) ~= 0
        [newlat,newlon] = rhumblinefwd(lat,lon,az,rng,ellipsoid);
    else
        [newlat,newlon] = rhumblinefwd(lat,lon,az,rng,ellipsoid(1));
    end
end

newlon = npi2pi(newlon,'radians');

newlat = reshape(angledim(newlat,'radians',units),insize);
newlon = reshape(angledim(newlon,'radians',units),insize);

%  Set the output arguments
if nargout <= 1
    % Undocumented command-line output for single points.
    latout = [newlat newlon];
elseif nargout == 2
    latout = newlat;
    lonout = newlon;
end

%--------------------------------------------------------------------------

function [newlat,newlon] = reckongc(lat, lon, rng, az, a)

% Compute points on great circle  at specified azimuths and ranges.  LAT,
% LON, and AZ are angles in radians, and RNG is a distance having the same
% units as the semimajor axis of the reference ellipsoid, A.

% Reference
% ---------
% J. P. Snyder, "Map Projections - A Working Manual,"  US Geological Survey
% Professional Paper 1395, US Government Printing Office, Washington, DC,
% 1987, pp. 29-32.

% Convert the range to an angle on the sphere (in radians).
rng = rng / a;

% Ensure correct azimuths at either pole.
epsilon = 10*epsm('radians');    % Set tolerance
az(lat >= pi/2-epsilon) = pi;    % starting at north pole
az(lat <= epsilon-pi/2) = 0;     % starting at south pole

% Calculate coordinates of great circle end point using spherical trig.
newlat = asin( sin(lat).*cos(rng) + cos(lat).*sin(rng).*cos(az) );

newlon = lon + atan2( sin(rng).*sin(az),...
                      cos(lat).*cos(rng) - sin(lat).*sin(rng).*cos(az) );

%--------------------------------------------------------------------------

function [useGeodesic,lat,lon,rng,az,ellipsoid,units,insize] ...
                                              = parseInputs(varargin)

% Handle optional first input argument.
if (nargin >= 1) && ischar(varargin{1})
    trackstr = varargin{1};
    varargin(1) = [];
else
    trackstr = 'gc';
end

% Check TRACKSTR.
switch(lower(trackstr))
    case {'g','gc'}
        useGeodesic = true;
    case {'r','rh'}
        useGeodesic = false;
    otherwise
        error('Unrecognized track string')
end

% Check argument counting after stripping off first argument.
n = numel(varargin);
error(nargchk(4,6,n))

% Assign the fixed arguments.
lat = varargin{1};
lon = varargin{2};
rng = varargin{3};
az  = varargin{4};
                         
% Parse the optional arguments: ELLIPSOID and UNITS.
ellipsoid = [];
units     = 'degrees';

if (n == 5)
	if ischar(varargin{5})
	    units = varargin{5};
    else
        ellipsoid = varargin{5};
    end
end

if (n == 6)
	ellipsoid = varargin{5};
    units     = varargin{6};
end

% If ELLIPSOID was omitted, use a unit sphere.
if isempty(ellipsoid)
    ellipsoid = [1 0];
    % Make sure RNG is a distance on the unit sphere.
    rng = angledim(rng,units,'radians');
end

% Check for matching dimensions.
if ~isequal(size(lat),size(lon),size(az),size(rng))
    error('Lat, long, azimuth and range inputs must have same dimension');
end

% Make sure angles are in radians and convert the input
% arrays to column vectors.
insize = size(lat);
lat = angledim(lat(:),units,'radians');
lon = angledim(lon(:),units,'radians');
az  = angledim(az(:),units,'radians');
rng = rng(:);

% Check the ellipsoid.
if ellipsoid(1) == 0
    % Ensure a nonzero semimajor axis (note: should be an error)
    % warning('Semimajor axis of ELLIPSOID must be positive, reset to 1.');
    ellipsoid(1) = 1;
end
[ellipsoid,msg] = geoidtst(ellipsoid);
error(msg)
