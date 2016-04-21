function dist = stdist(lat,lon,geoid,units,method)

%STDIST  Standard distance for geographic data
%
%  d = STDIST(lat,lon) computes the average standard distance for
%  geographic data.  This function assumes that the data is distributed
%  on a sphere.  In contrast, STD assumes that the data is distributed on
%  a cartesian plane.  The result is a single value based on the
%  great-circle distance of the data points from their geographic
%  mean point.  When lat and lon are vectors, a single distance
%  is returned.  When lat and long are matrices, a row vector of
%  distances is given, providing the distances for each column of
%  lat and lon.  N-dimensional arrays are not allowed.  Distances are
%  returned in degrees of angle units.
%
%  d = STDIST(lat,lon,geoid) computes the average standard distance
%  on the ellipsoid defined by the input geoid. The geoid vector
%  is of the form [semimajor axes, eccentricity].  If omitted, the
%  unit sphere, geoid = [1 0], is assumed.  The output deviations are
%  returned in the same distance units as geoid(1).
%
%  d = STDIST(lat,lon,'units') and d = STDIST(lat,lon,geoid,'units')
%  use the input 'units' to define the angle units of the inputs and
%  outputs.  If omitted, 'degrees' are assumed.
%
%  d = STDIST(lat,lon,geoid,'units','method') uses the 'method' string
%  to define the calculation of standard distance.  'linear' computes
%  the average distance; 'quadratic' computes the square root of the
%  average squared distance; 'cubic' computes the cube root of the
%  average cubed distance.
%
%  See also MEANM, STDM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:24 $


if nargin < 2
    error('Incorrect number of arguments')
elseif nargin == 2
    geoid = [];       units = [];   method = [];
elseif nargin == 3
     if isstr(geoid)
	       units = geoid;     geoid = [];   method = [];
	 else
	       units = [];    method = [];
	 end
elseif nargin == 4
     method = [];
end

%  Empty argument tests

nogeoid=0;

if isempty(units);   units = 'degrees';   end
if isempty(geoid);   geoid = [1 0];  nogeoid=1;     end
if isempty(method)
     method = 'linear';
else
     strmat = strvcat('linear','quadratic','cubic');
     indx = strmatch(lower(method),strmat);
     if length(indx) ~= 1;   error('Unrecognized method string'); end
     method = deblank(strmat(indx,:));
end

%  Input dimension tests

if ndims(lat)>2
	error('Latitude and longitude inputs limited to two dimensions.')
end

if ~isequal(size(lat),size(lon))
    error('Inconsistent dimensions on latitude and longitude inputs')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  if lat and lon are vectors, make them columns

if size(lat,1)==1
	lat=lat(:); lon=lon(:);
end

%  Compute the mean location

[latbar,lonbar] = meanm(lat,lon,geoid,units);

%  Transform the latitudes to a conformal sphere.  Necessary
%  if an ellipsoid is used.  No effect if a sphere.

lat = geod2cnf(lat,geoid,units);

%  Expand the mean point for interface with the distance function

biglat = latbar(ones([size(lat,1),1]),:);

biglon = lonbar(ones([size(lon,1),1]),:);

%  Calculate the great circle distance from each point to the centriod

rng = distance('gc',biglat,biglon,lat,lon,geoid,units);

% if no geoid was entered, a default [1 0] radians was used.  In this
% case, convert to the input angle 'units'.  Otherwise, input geoids
% specify the desired distance units

if nogeoid
	rng=angledim(rng,'radians',units);
end

%  Compute the average range using the appropriate method

switch  method
    case 'linear',       dist = mean(rng);
    case 'quadratic',    dist = sqrt(mean(rng.^2));
    case 'cubic',        dist = mean(rng.^3) .^ (1/3);
end
