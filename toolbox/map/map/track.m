function [outlat,outlon]=track(str,lat,lon,in3,in4,in5)

%TRACK  Connects navigational waypoints with track segments
%
%  [lat,lon] = TRACK(lat0,lon0) connects waypoints given in navigation
%  track format with track segments.  The track segments are rhumb
%  lines, which is the navigationally common method.
%
%  [lat,lon] = TRACK(lat0,lon0,geoid) computes the rhumb line tracks
%  on the ellipsoid defined by the input geoid. The geoid vector
%  is of the form [semimajor axes, eccentricity].  If omitted,
%  the unit sphere, geoid = [1 0], is assumed.
%
%  [lat,lon] = TRACK(lat0,lon0,'units') and
%  [lat,lon] = TRACK(lat0,lon0,geoid,'units') are all valid
%  calling forms, which use the inputs 'units' to define the angle
%  units of the inputs and outputs.  If omitted, 'degrees' are assumed.
%
%  [lat,lon] = TRACK(lat0,lon0,geoid,'units',npts) uses the
%  input npts to determine the number of points per track computed.
%  The input npts is a scalar, and if omitted, npts = 30.
%
%  [lat,lon] = TRACK(mat) and [lat,lon] = TRACK(mat,'units') are
%  valid calling forms, where mat = [lat0 lon0].
%
%  [lat,lon] = TRACK('track',...) uses the 'track' string to define
%  either a great circle or rhumb line tracks.  If 'track' = 'gc',
%  then the great circle tracks are computed.  If 'track' = 'rh', then
%  the rhumb line tracks are computed.  If omitted, 'rh' is assumed.
%
%  mat = TRACK(...) returns a single output argument where mat = [lat lon].
%
%  See also TRACK1, TRACK2, TRACKG, GCWAYPTS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.11.4.1 $  $Date: 2003/08/01 18:20:31 $

if nargin == 0 | (nargin == 1 & isstr(str))
	 error('Incorrect number of arguments')

elseif (nargin == 1 & ~isstr(str)) | (nargin == 2 & isstr(str))
    if ~isstr(str)       %  Shift inputs since str omitted by user
		lat = str;   str = [];
	end

    if size(lat,2) ~= 2 | ndims(lat) > 2
	    error('Input matrix must have two columns [lat lon]')
	else
	    lon = lat(:,2);      lat = lat(:,1);
	end

	geoid = [];        units = [];       npts  = [];

elseif (nargin == 2 & ~isstr(str)) | (nargin == 3 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		lon = lat;     lat = str;   str = [];
	end

	if isstr(lon)         %  track(str,mat,'units')  usage
        if size(lat,2) ~= 2 | ndims(lat) > 2
	        error('Input matrix must have two columns [lat lon]')
	    else
	        units = lon;   lon = lat(:,2);      lat = lat(:,1);
			geoid = [];    npts  = [];
	    end

    else             %  track(str,lat,lon)  usage
		geoid = [];        units = [];       npts  = [];

    end

elseif (nargin == 3 & ~isstr(str)) | (nargin == 4 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in3  = lon;     lon = lat;
		lat  = str;     str  = [];
	end

	if isstr(in3)
	    geoid = [];      units = in3;      npts  = [];
    else
	    geoid = in3;     units = [];       npts  = [];
    end


elseif (nargin == 4 & ~isstr(str)) | (nargin == 5 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in4  = in3;      in3  = lon;
		lon  = lat;      lat  = str;
		str  = [];
	end

    geoid = in3;      units = in4;      npts  = [];


elseif (nargin == 5 & ~isstr(str)) | (nargin == 6 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
	    in5  = in4;      in4  = in3;
	    in3  = lon;      lon  = lat;
		lat  = str;      str  = [];
	end

    geoid = in3;      units = in4;      npts  = in5;

end


%  Test the track string

if isempty(str)
    str = 'rh';       %  Default is rhumb line tracks
else
    validstr = strvcat('gc','rh');
	indx     = strmatch(lower(str),validstr);
	if length(indx) ~= 1;       error('Unrecognized track string')
          else;                 str = deblank(validstr(indx,:));
    end
end

%  Empty argument tests.  Set defaults

if isempty(geoid);   geoid = [0 0];       end
if isempty(units);   units = 'degrees';   end
if isempty(npts);    npts  = 30;          end

%  Input dimension tests

if ~isequal(size(lat),size(lon))
	 error('Inconsistent dimensions for lat and lon inputs.')

elseif any([min(size(lat))    min(size(lon))]    ~= 1) | ...
       any([ndims(lat) ndims(lon)] > 2)
         error('Latitude and longitude inputs must vectors')

elseif max(size(lat)) == 1
    error('At least 2 lats and 2 longs are required')

elseif max(size(npts)) ~= 1
       error('Scalar npts required')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Ensure lat and lon are column vectors

lat = lat(:);      lon = lon(:);

%  Compute vectors of start and end points

startlats = lat(1:length(lat)-1);   endlats = lat(2:length(lat));
startlons = lon(1:length(lon)-1);   endlons = lon(2:length(lon));

[outlat,outlon] = track2(str,startlats,startlons,endlats,endlons,geoid,units,npts);

%  Link all tracks into a single NaN clipped vector

[r,c] = size(outlat);
outlat(r+1,:) = NaN;       outlat = outlat(:);
outlon(r+1,:) = NaN;       outlon = outlon(:);

%  Set the output argument if necessary

if nargout < 2;  outlat = [outlat outlon];  end
