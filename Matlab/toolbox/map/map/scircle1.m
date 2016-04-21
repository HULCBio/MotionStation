function [latout,lonout] = scircle1(str,lat,lon,rng,in4,in5,in6,in7)

%SCIRCLE1  Small circle defined by its center, range and azimuth
% 
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad) computes small circles (on a 
%   sphere) with a center at the point lat0, lon0 and radius rad.  The
%   inputs can be scalar or column vectors.  The input radius is in
%   degrees of arc length on a sphere.
% 
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,az) uses the input az to define
%   the small circle arcs computed.  The arc azimuths are measured
%   clockwise from due north.  If az is a column vector, then the
%   arc length is computed from due north.  If az is a two-column
%   matrix, then the small circle arcs are computed starting at the
%   azimuth in the first column and ending at the azimuth in the
%   second column.  If az = [], then a complete small circle is computed.
% 
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,az,geoid) computes small circles
%   on the ellipsoid defined by the input geoid, rather than assuming a
%   sphere. The geoid vector is of the form [semimajor axis, eccentricity].
%   If the semimajor axis is non-zero, rad is assumed to be in distance
%   units matching the units of the semimajor axis.  However, if geoid = [],
%   or if the semimajor axis is zero, then rad is interpreted as an angle
%   and the small circles are computed on a sphere as in the preceding
%   syntax.
% 
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,'units'),
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,az,'units'), and
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,az,geoid,'units') are all valid
%   calling forms, which use the inputs 'units' to define the angle
%   units of the inputs and outputs.  If omitted, 'degrees' are assumed.
% 
%   [lat,lon] = SCIRCLE1(lat0,lon0,rad,az,geoid,'units',npts) uses the scalar
%   input npts to determine the number of points per small circle
%   computed.  The default value of npts is 100.
% 
%   [lat,lon] = SCIRCLE1('track',...) uses the 'track' string to define
%   either a great circle or rhumb line radius.  If 'track' = 'gc',
%   then small circles are computed.  If 'track' = 'rh', then
%   the circles with radii of constant rhumb line distance are computed.
%   If omitted, 'gc' is assumed.
% 
%   mat = SCIRCLE1(...) returns a single output argument where
%   mat = [lat lon].  This is useful if only a single circle is computed.
% 
%   Multiple circles can be defined from a single starting point by
%   providing scalar lat0, lon0 inputs and column vectors for rad and
%   az if desired.
% 
%   See also SCIRCLE2, SCIRCLEG, TRACK1.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:05 $


if nargin == 0
     error('Incorrect number of arguments')

elseif (nargin < 3  & ~isstr(str)) |  (nargin == 3 & isstr(str))
	 error('Incorrect number of arguments')

elseif (nargin == 3 & ~isstr(str)) | (nargin == 4 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		rng = lon;       lon = lat;
		lat = str;       str = [];
	end

	npts  = [];       az    = [];
	geoid = [];       units = [];

elseif (nargin == 4 & ~isstr(str)) | (nargin == 5 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in4 = rng;       rng = lon;
		lon = lat;       lat = str;
		str = [];
	end


	if isstr(in4)
         az    = [];        geoid = [];       units = in4;     npts = [];
    else
		 az    = in4;       geoid = [];       units = [];      npts = [];
    end

elseif (nargin == 5 & ~isstr(str)) | (nargin == 6 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in5 = in4;       in4 = rng;
		rng = lon;       lon = lat;
		lat = str;       str = [];
	end

	if isstr(in5)
		az    = in4;       units = in5;       geoid = [];      npts = [];
    else
        az    = in4;       units = [];        geoid = in5;     npts = [];
    end

elseif (nargin == 6 & ~isstr(str)) | (nargin == 7 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in6 = in5;       in5 = in4;
		in4 = rng;       rng = lon;
		lon = lat;       lat = str;
		str = [];
	end

    az    = in4;      geoid = in5;      units = in6;      npts = [];

elseif (nargin == 7 & ~isstr(str)) | (nargin == 8 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in7 = in6;       in6 = in5;
		in5 = in4;       in4 = rng;
		rng = lon;       lon = lat;
		lat = str;       str = [];
	end


    az    = in4;      geoid = in5;      units = in6;      npts = in7;

end

%  Test the track string

if isempty(str)
    str = 'gc';
else
    validstr = strvcat('gc','rh');
	indx     = strmatch(lower(str),validstr);
	if length(indx) ~= 1;       error('Unrecognized track string')
          else;                 str = deblank(validstr(indx,:));
    end
end


%  Allow for scalar starting point, but vectorized azimuths.  Multiple
%  circles starting from the same point

if length(lat) == 1 & length(lon) == 1 & length(rng) ~= 0
    lat = lat(ones(size(rng)));   lon = lon(ones(size(rng)));
end

%  Empty argument tests.  Set defaults

if isempty(geoid);   geoid = [0 0];       end
if isempty(units);   units = 'degrees';   end
if isempty(npts);    npts  = 100;         end
if isempty(az)
     az = angledim([0 360],'degrees',units);
     az = az(ones([size(lat,1) 1]), :);
end

%  Dimension tests

if ~isequal(size(lat),size(lon),size(rng))
    error('Inconsistent dimensions for lat,long, and range inputs.')

elseif ndims(lat) > 2 | size(lat,2) ~= 1
    error('Lat,long, and range inputs must be column vectors.')

elseif size(lat,1) ~= size(az,1)
    error('Inconsistent dimensions for starting points and azimuths.')

elseif ndims(az) > 2 | size(az,2) > 2
    error('Azimuth input must have two columns or less')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Angle unit conversion

lat = angledim(lat,units,'radians');
lon = angledim(lon,units,'radians');
az  = angledim(az,units,'radians');

%  Convert the range to radians if no radius or semimajor axis provided
%  Otherwise, reckon will take care of the conversion of the range inputs

if geoid(1) == 0;    rng = angledim(rng,units,'radians');   end

%  Expand the azimuth inputs

if size(az,2) == 1       %  Single column azimuth inputs
    negaz = zeros(size(az));  posaz = az;

else                     %  Two column azimuth inputs
    negaz = az(:,1);          posaz = az(:,2);
end

%  Use real(npts) to avoid a cumbersome warning for complex n in linspace

az = zeros([size(negaz,1) npts]);
for i = 1:size(az,1)
	
%  Handle case where limits give more than half of the circle.
%  Go clockwise from start to end. 	
	
	if negaz(i) > posaz(i) ; 
		posaz(i) = posaz(i)+2*pi;
	end
		
	az(i,:) = linspace(negaz(i),posaz(i),real(npts));	
end

%  Compute the circles.
%  Each circle occupies a row of the output matrices.

biglat = lat(:,ones([1,size(az,2)]) );
biglon = lon(:,ones([1,size(az,2)]) );
bigrng = rng(:,ones([1,size(az,2)]) );

[latc,lonc] = reckon(str,biglat,biglon,bigrng,az,geoid,'radians');

%  Convert the results to the desired units

latc = angledim(latc','radians',units);
lonc = angledim(lonc','radians',units);

%  Set the output arguments

if nargout <= 1
     latout = [latc lonc];
elseif nargout == 2
     latout = latc;  lonout = lonc;
end
