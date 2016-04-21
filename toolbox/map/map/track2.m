function [latout,lonout] = track2(str,lat1,lon1,lat2,lon2,in5,in6,in7)

%TRACK2  Track lines defined by a starting and ending point
% 
%   [lat,lon] = TRACK2(lat1,lon1,lat2,lon2) computes great circle
%   tracks on a sphere starting at the point lat1, lon1 and ending at
%   lat2, lon2.  The inputs can be scalar or column vectors.
% 
%   [lat,lon] = TRACK2(lat1,lon1,lat2,lon2,geoid) computes the great circle
%   track on the ellipsoid defined by the input geoid. The geoid vector
%   is of the form [semimajor axis, eccentricity].  If geoid = [], a sphere
%   is assumed.
% 
%   [lat,lon] = TRACK2(lat1,lon1,lat2,lon2,'units') and
%   [lat,lon] = TRACK2(lat1,lon1,lat2,lon2,geoid,'units') are all valid
%   calling forms, which use the inputs 'units' to define the angle
%   units of the inputs and outputs.  If omitted, 'degrees' are assumed.
% 
%   [lat,lon] = TRACK2(lat1,lon1,lat2,lon2,geoid,'units',npts) uses the
%   scalar input npts to determine the number of points per track computed.
%   The default value of npts is 100.
% 
%   [lat,lon] = TRACK2('track',...) uses the 'track' string to define
%   either a great circle or rhumb line track.  If 'track' = 'gc',
%   then the great circle tracks are computed.  If 'track' = 'rh', then
%   the rhumb line tracks are computed.  If omitted, 'gc' is assumed.
% 
%   mat = TRACK2(...) returns a single output argument where
%   mat = [lat lon].  This is useful if only a single track is computed.
% 
%   Multiple tracks can be defined from a single starting point by
%   providing scalar lat1, lon1 inputs and column vectors for lat2, lon2.
% 
%   See also TRACK1, TRACKG, SCIRCLE2.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:33 $


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

	geoid = [];        units = [];       npts  = [];

elseif (nargin == 5 & ~isstr(str)) | (nargin == 6 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in5  = lon2;     lon2 = lat2;
		lat2 = lon1;     lon1 = lat1;
		lat1 = str;      str  = [];
	end

	if isstr(in5)
	    geoid = [];      units = in5;      npts  = [];
    else
	    geoid = in5;     units = [];       npts  = [];
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

    geoid = in5;      units = in6;      npts  = in7;

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
%  tracks starting from the same point

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

% Set tolerance

epsilon=epsm('radians');

%  If a track starts at a pole, ensure it traverses
%  straight down the appropriate longitude

indx=find(abs(lat1)>=pi/2-epsilon); 	 % starting at pole

lon1(indx)=lon2(indx); % Tracks originating at a pole
					   % traverse the starting meridian


%  Compute distance and course

az  = azimuth(str,lat1,lon1,lat2,lon2,geoid,'radians');
rng = distance(str,lat1,lon1,lat2,lon2,geoid,'radians');

%  Compute the tracks

[lattrk,lontrk] = track1(str,lat1,lon1,az,rng,geoid,'radians',npts);

%  Convert the results to the desired units

lattrk = angledim(lattrk,'radians',units);
lontrk = angledim(lontrk,'radians',units);

%  Set the output arguments

if nargout <= 1
     latout = [lattrk lontrk];
elseif nargout == 2
     latout = lattrk;  lonout = lontrk;
end