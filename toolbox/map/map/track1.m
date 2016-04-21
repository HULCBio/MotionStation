function [latout,lonout] = track1(str,lat,lon,az,in4,in5,in6,in7)

%TRACK1  Track lines defined by starting point, azimuth and range
% 
%   [lat,lon] = TRACK1(lat0,lon0,az) computes complete great circle
%   tracks on a sphere starting at the point lat0, lon0 and bearing
%   along the input azimuth, az.  The inputs can be scalar or column
%   vectors.
% 
%   [lat,lon] = TRACK1(lat0,lon0,az,rng) uses the input rng to define
%   the range of the great circle computed.  The range input is in
%   degrees of arc length along a sphere.  If range is a column vector,
%   then the track is computed from the starting point, with positive
%   distance measured easterly.  If range is a two column matrix, then
%   the track is computed starting at the range in the first column and
%   ending at the range in the second column.  If rng = [], then the
%   complete track is computed.
% 
%   [lat,lon] = TRACK1(lat0,lon0,az,rng,geoid) computes the great circle
%   track on the ellipsoid defined by the input geoid. The geoid vector
%   is of the form [semimajor axis, eccentricity].  If the semimajor
%   axis is non-zero, rng is assumed to be in distance units matching
%   the units of the semimajor axis.  However, if geoid = [], or if the
%   semimajor axis is zero, then rad is interpreted as an angle and the
%   tracks are computed on a sphere as in the preceding syntax.
% 
%   [lat,lon] = TRACK1(lat0,lon0,az,'units'),
%   [lat,lon] = TRACK1(lat0,lon0,az,rng,'units'), and
%   [lat,lon] = TRACK1(lat0,lon0,az,rng,geoid,'units') are all valid
%   calling forms, which use the inputs 'units' to define the angle
%   units of the inputs and outputs.  If omitted, 'degrees' are assumed.
% 
%   [lat,lon] = TRACK1(lat0,lon0,az,rng,geoid,'units',npts) uses the
%   scalar input npts to determine the number of points per track
%   computed.  The default value of npts is 100.
% 
%   [lat,lon] = TRACK1('track',...) uses the 'track' string to define
%   either a great circle or rhumb line track.  If 'track' = 'gc',
%   then the great circle tracks are computed.  If 'track' = 'rh', then
%   the rhumb line tracks are computed.  If omitted, 'gc' is assumed.
% 
%   mat = TRACK1(...) returns a single output argument where
%   mat = [lat lon].  This is useful if only a single track is computed.
% 
%   Multiple tracks can be defined from a single starting point by
%   providing scalar lat0, lon0 inputs and column vectors for az and
%   rng if desired.
% 
%   See also TRACK2, TRACKG, SCIRCLE1.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:32 $


if nargin == 0
     error('Incorrect number of arguments')

elseif (nargin < 3  & ~isstr(str)) | (nargin == 3 & isstr(str))
	 error('Incorrect number of arguments')

elseif (nargin == 3 & ~isstr(str)) | (nargin == 4 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		az  = lon;       lon = lat;
		lat = str;       str = [];
	end

	rng = [];    npts  = [];     geoid = [];     units = [];

elseif (nargin == 4 & ~isstr(str)) | (nargin == 5 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in4 = az;        az  = lon;
		lon = lat;       lat = str;
		str = [];
	end

	if isstr(in4)
         units = in4;     geoid = [];     rng = [];     npts = [];
    else
         units = [];      geoid = [];     rng = in4;    npts = [];
    end

elseif (nargin == 5 & ~isstr(str)) | (nargin == 6 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in5 = in4;       in4 = az;
		az  = lon;       lon = lat;
		lat = str;       str = [];
	end

	if isstr(in5)
		rng   = in4;      units = in5;     geoid = [];     npts = [];
    else
		rng   = in4;      units = [];      geoid = in5;    npts = [];
    end

elseif (nargin == 6 & ~isstr(str)) | (nargin == 7 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in6 = in5;       in5 = in4;
		in4 = az;        az  = lon;
		lon = lat;       lat = str;
		str = [];
	end

    rng   = in4;      geoid = in5;      units = in6;    npts = [];

elseif (nargin == 7 & ~isstr(str)) | (nargin == 8 & isstr(str))

    if ~isstr(str)       %  Shift inputs since str omitted by user
		in7 = in6;      in6 = in5;
		in5 = in4;      in4 = az;
		az  = lon;      lon = lat;
		lat = str;      str = [];
	end

    rng   = in4;      geoid = in5;      units = in6;    npts = in7;
end

%  Test the track string

if isempty(str)
    str = 'gc';
else
    validstr = strvcat('gc','rh');
	indx     = strmatch(lower(str),validstr);
	if length(indx) ~= 1;   error('Unrecognized track string');  end
    str = validstr(indx,:);
end

%  Allow for scalar starting point, but vectorized azimuths.  Multiple
%  tracks starting from the same point

if length(lat) == 1 & length(lon) == 1 & length(az) ~= 0
    lat = lat(ones(size(az)));   lon = lon(ones(size(az)));
end

%  Empty argument tests

if isempty(geoid);   geoid = [0 0];       end
if isempty(units);   units = 'degrees';   end
if isempty(npts);    npts  = 100;         end
rhumbdefault = 0;          %  Don't perform rhumb line range limit calcs
if isempty(rng)
    if geoid(1) == 0;    rng = angledim([-180 180],'degrees',units);
	    else;            rng = [0 2*pi]*geoid(1);
    end

	 rng = rng(ones([size(lat,1) 1]), :);
    if strcmp(str,'rh')
	    rhumbdefault = 1;    %  Perform rhumb line range limit calcs
	end
end

%  Dimension tests

if ~isequal(size(lat),size(lon),size(az))
    error('Inconsistent dimensions for lat,long, and azimuth inputs.')

elseif ndims(lat) > 2 | size(lat,2) ~= 1
    error('Lat,long, and azimuth inputs must be column vectors.')

elseif size(lat,1) ~= size(rng,1)
    error('Inconsistent dimensions for starting points and ranges.')

elseif ndims(rng) > 2 | size(rng,2) > 2
    error('Range input must have two columns or less')
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

if geoid(1) == 0;    
	rng = angledim(rng,units,'radians');   
end

%  Expand the range vector

if rhumbdefault  %  Default limits for rhumb line calculation.
                 %  Simple +/-180 does not guarantee a pole to pole rhumb line.
   indx1 = find( abs(cos(az))<eps ) ;    %  Tracks directly along parallels
   indx  = 1:prod(size(az));     indx(indx1) = [];  %  All other tracks
	negrng   = zeros(size(az));     posrng   = zeros(size(az));

	if geoid(1) == 0;    rec = lat;
	   else;             rec = geod2rec(lat,geoid,'radians');
	end
	negcolat = pi/2+rec;              poscolat = pi/2-rec;

   negrng(indx)  = -abs(negcolat(indx)./cos(az(indx)));
   posrng(indx)  = abs(poscolat(indx)./cos(az(indx)));

	posrng(indx1) = pi*cos(rec(indx1));  %  Directly along
	negrng(indx1) = -posrng(indx1);      %  parallels

   if geoid(1) ~= 0    %  Convert from radians if necessary
         radius = rsphere('rectifying',geoid);
         negrng = negrng*radius;  posrng = posrng*radius;
	end

elseif size(rng,2) == 1       %  Single column range inputs
    negrng = zeros(size(rng));  posrng = rng;

else                          %  Two column range inputs (not rhumb default)
    negrng = rng(:,1);          posrng = rng(:,2);
end

%  Use real(npts) to avoid a cumbersome warning for complex n in linspace

rng = zeros([size(negrng,1) npts]);
for i = 1:size(rng,1)
	rng(i,:) = linspace(negrng(i),posrng(i),real(npts));
end

%  Compute the tracks
%  Each track occupies a row of the output matrices.


biglat = lat(:,ones([1,size(rng,2)]) );
biglon = lon(:,ones([1,size(rng,2)]) );
bigaz  = az(:,ones([1,size(rng,2)]) );

[lattrk,lontrk] = reckon(str,biglat,biglon,rng,bigaz,geoid,'radians');

%  Convert the results to the desired units
%  Transpose the reckongc results so that each track occupies
%  one column of the output matrices.

lattrk = angledim(lattrk','radians',units);
lontrk = angledim(lontrk','radians',units);

%  Set the output arguments

if nargout <= 1
     latout = [lattrk lontrk];
elseif nargout == 2
     latout = lattrk;  lonout = lontrk;
end
