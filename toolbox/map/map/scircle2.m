function [latout,lonout] = scircle2(str,lat1,lon1,lat2,lon2,in5,in6,in7)

%SCIRCLE2  Small circle defined by its center and perimeter
% 
%   [lat,lon] = SCIRCLE2(lat1,lon1,lat2,lon2) computes small circles
%   (on a sphere) with centers at the point lat1, lon1 and points on
%   the circles at lat2, lon2.  The inputs can be scalar or column vectors.
% 
%   [lat,lon] = SCIRCLE2(lat1,lon1,lat2,lon2,geoid) computes the small
%   circle on the ellipsoid defined by the input geoid, rather than
%   assuming a sphere. The geoid vector is of the form [semimajor axis,
%   eccentricity].  If geoid = [], a sphere is assumed.
% 
%   [lat,lon] = SCIRCLE2(lat1,lon1,lat2,lon2,'units') and
%   [lat,lon] = SCIRCLE2(lat1,lon1,lat2,lon2,geoid,'units') are all valid
%   calling forms, which use the inputs 'units' to define the angle
%   units of the inputs and outputs.  If omitted, 'degrees' are assumed.
% 
%   [lat,lon] = SCIRCLE2(lat1,lon1,lat2,lon2,geoid,'units',npts) uses
%   the scalar input npts to determine the number of points per track
%   computed.  The default value of npts is 100.
% 
%   [lat,lon] = SCIRCLE2('track',...) uses the 'track' string to define
%   either a great circle or rhumb line radius.  If 'track' = 'gc',
%   then small circles are computed.  If 'track' = 'rh', then
%   the circles with radii of constant rhumb line distance are computed.
%   If omitted, 'gc' is assumed.
% 
%   mat = SCIRCLE2(...) returns a single output argument where
%   mat = [lat lon].  This is useful if only a single circle is computed.
% 
%   Multiple circles can be defined from a single center point by
%   providing scalar lat1, lon1 inputs and column vectors for the points
%   on the circumference, lat2, lon2.
% 
%   See also SCIRCLE1, SCIRCLEG, TRACK2.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:06 $


if nargin == 0
     error('Incorrect number of arguments')

elseif (nargin < 4  & ~isstr(str)) | (nargin == 4 & isstr(str))
	 error('Incorrect number of arguments')

elseif (nargin == 4 & ~isstr(str)) | (nargin == 5 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		lon2 = lat2;     lat2 = lon1;
		lon1 = lat1;     lat1 = str;
		str  = [];
	end

	geoid = [];    units = [];    npts  = [];

elseif (nargin == 5 & ~isstr(str)) | (nargin == 6 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in5  = lon2;     lon2 = lat2;
		lat2 = lon1;     lon1 = lat1;
		lat1 = str;      str  = [];
	end

	if isstr(in5)
	    geoid = [];     units = in5;     npts  = [];
    else
	    geoid = in5;    units = [];      npts  = [];
    end


elseif (nargin == 6 & ~isstr(str)) | (nargin == 7 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in6  = in5;      in5  = lon2;
		lon2 = lat2;     lat2 = lon1;
		lon1 = lat1;     lat1 = str;
		str  = [];
	end

    geoid = in5;      units = in6;      npts  = [];


elseif (nargin == 7 & ~isstr(str)) | (nargin == 8 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in7  = in6;      in6  = in5;
	    in5  = lon2;     lon2 = lat2;
		lat2 = lon1;     lon1 = lat1;
		lat1 = str;      str  = [];
	end

    geoid = in5;      units = in6;       npts  = in7;

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

if length(lat1) == 1 & length(lon1) == 1 & length(lat2) ~= 0
    lat1 = lat1(ones(size(lat2)));   lon1 = lon1(ones(size(lat2)));
end

%  Empty argument tests.  Set defaults

if isempty(geoid);   geoid = [0 0];       end
if isempty(units);   units = 'degrees';   end
if isempty(npts);    npts  = 100;         end


%  Dimension tests

if ~isequal(size(lat1),size(lon1),size(lat2),size(lon2))
      error('Inconsistent dimensions on latitude and longitude inputs')

elseif max(size(npts)) ~= 1
       error('Scalar npts required')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

% Ensure that inputs are column vectors

lat1 = lat1(:);    lon1 = lon1(:);
lat2 = lat2(:);    lon2 = lon2(:);

%  Angle unit conversion

lat1 = angledim(lat1,units,'radians');
lon1 = angledim(lon1,units,'radians');
lat2 = angledim(lat2,units,'radians');
lon2 = angledim(lon2,units,'radians');


%  Compute azimuth and range

rng = distance(str,lat1,lon1,lat2,lon2,geoid,'radians');
az  = 2*pi;             az = az(ones([size(lat1,1) 1]));

%  Compute circles

[latc,lonc] = scircle1(str,lat1,lon1,rng,az,geoid,'radians',npts);

%  Convert the results to the desired units

latc = angledim(latc,'radians',units);
lonc = angledim(lonc,'radians',units);

%  Set the output arguments

if nargout <= 1
     latout = [latc lonc];
elseif nargout == 2
     latout = latc;  lonout = lonc;
end