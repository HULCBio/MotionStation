function [latout,lonout] = ellipse1(varargin)

%ELLIPSE1  Ellipse defined by its center, semimajor axes, eccentricity and azimuth
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse) computes ellipses with a
%  center at the point lat0, lon0.  The ellipse is defined by the
%  third input which of the form [semimajor axis, eccentricity].  
%  The lat, lon inputs can be scalar or column vectors.  The eccentricity
%  input can be a 2 element row vector or a 2 column matrix.  The
%  ellipse input must have the same number of rows as the input lat and lon.
%  The input semimajor axes is in degrees of arc length on a sphere.  All
%  ellipses are oriented so that their semimajor axes lies due north.
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset) computes the ellipses
%  where the semimajor axis is rotated from due north by an azimuth offset.
%  The offset angle is measure clockwise from due north.  If offset =[],
%  then no offset is assumed.
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,az) uses the input az 
%  to define the ellipse arcs computed.  The arc azimuths are measured
%  clockwise from due north.  If az is a column vector, then the
%  arc length is computed from due north.  If az is a two column
%  matrix, then the ellipse arcs are computed starting at the
%  azimuth in the first column and ending at the azimuth in the
%  second column.  If az = [], then a complete ellipse is computed.
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,az,geoid) computes
%  the ellipse on the ellipsoid defined by the input geoid. The geoid vector
%  is of the form [semimajor axes, eccentricity].  If omitted, the
%  unit sphere, geoid = [1 0], is assumed.  When a geoid is supplied
%  the input semimajor axis must be in the same units as the geoid
%  semimajor axes. In this calling form, the units of the ellipse 
%  semi-major axis are not assumed to be in degrees.
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,'units'),
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,az,'units'), and
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,az,geoid,'units') are
%  all valid calling forms, which use the inputs 'units' to define 
%  the angle units of the inputs and outputs.  If omitted, 
%  'degrees' are assumed.
%
%  [lat,lon] = ELLIPSE1(lat0,lon0,ellipse,offset,az,geoid,'units',npts)
%  uses the input npts to determine the number of points per ellipse
%  computed.  The input npts is a scalar, and if omitted, npts = 100.
%
%  [lat,lon] = ELLIPSE1('track',...) uses the 'track' string to define
%  either a great circle or rhumb line distances from the ellipse center.
%  If 'track' = 'gc',  then great circle distances are computed.  
%  If 'track' = 'rh', then rhumb line distances are computed.
%  If omitted, 'gc' is assumed.
%
%  mat = ELLIPSE1(...) returns a single output argument where
%  mat = [lat lon].  This is useful if only an ellipse is computed.
%
%  Multiple circles can be defined from a single starting point by
%  providing scalar lat0, lon0 inputs and a 2 column matrix for
%  the ellipse definitions.
%
%  See also SCIRCLE1, TRACK1, AXES2ECC.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown, W. Stumpf
%  $Revision: 1.8.4.1 $    $Date: 2003/08/01 18:16:06 $


if nargin == 0
     error('Incorrect number of arguments')

elseif (nargin < 3  & ~isstr(varargin{1})) |  (nargin == 3 & isstr(varargin{1}))
	 error('Incorrect number of arguments')

elseif (nargin == 3 & ~isstr(varargin{1})) | (nargin == 4 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};
	end

	offset = [];
	npts  = [];       az    = [];
	geoid = [];       units = [];

elseif (nargin == 4 & ~isstr(varargin{1})) | (nargin == 5 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};    offset = varargin{4};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};    offset = varargin{5};
	end

	npts  = [];       az    = [];
	geoid = [];       units = [];

elseif (nargin == 5 & ~isstr(varargin{1})) | (nargin == 6 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};    offset = varargin{4};
		lastin  = varargin{5};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};    offset = varargin{5};
		lastin  = varargin{6};
	end

	if isstr(lastin)
         az    = [];        geoid = [];       units = lastin;  npts = [];
    else
		 az    = lastin;    geoid = [];       units = [];      npts = [];
    end

elseif (nargin == 6 & ~isstr(varargin{1})) | (nargin == 7 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};    offset = varargin{4};
		az      = varargin{5};    lastin = varargin{6};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};    offset = varargin{5};
		az      = varargin{6};    lastin = varargin{7};
	end

	if isstr(lastin)
		units = lastin;    geoid = [];      npts = [];
    else
        units = [];        geoid = lastin;  npts = [];
    end

elseif (nargin == 7 & ~isstr(varargin{1})) | (nargin == 8 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};    offset = varargin{4};
		az      = varargin{5};    geoid  = varargin{6};
		units   = varargin{7};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};    offset = varargin{5};
		az      = varargin{6};    geoid  = varargin{7};
		units   = varargin{8};
	end

    npts = [];

elseif (nargin == 8 & ~isstr(varargin{1})) | (nargin == 9 & isstr(varargin{1}))

    if ~isstr(varargin{1})       %  Shift inputs since str omitted by user
		str     = [];
		lat     = varargin{1};    lon    = varargin{2};
		ellipse = varargin{3};    offset = varargin{4};
		az      = varargin{5};    geoid  = varargin{6};
		units   = varargin{7};    npts   = varargin{8};
	else
		str     = varargin{1};
		lat     = varargin{2};    lon    = varargin{3};
		ellipse = varargin{4};    offset = varargin{5};
		az      = varargin{6};    geoid  = varargin{7};
		units   = varargin{8};    npts   = varargin{9};
	end

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
%  ellipses starting from the same point

if length(lat) == 1 & length(lon) == 1 & size(ellipse,1) ~= 0
    lat = lat(ones([size(ellipse,1) 1]));   lon = lon(ones([size(ellipse,1) 1]));
end

%  Empty argument tests.  Set defaults

if isempty(geoid);   geoid = [0 0];              end
if isempty(units);   units = 'degrees';          end
if isempty(npts);    npts  = 100;                end
if isempty(offset);  offset = zeros(size(lat));  end
if isempty(az)
     az = angledim([0 360],'degrees',units);
     az = az(ones([size(lat,1) 1]), :);
end

%  Dimension tests

if ~isequal(size(lat),size(lon),size(offset))
    error('Inconsistent dimensions for lat,long, and offset inputs.')

elseif ndims(lat) > 2 | size(lat,2) ~= 1
    error('Lat, long and offset  inputs must be column vectors.')

elseif size(lat,1) ~= size(ellipse,1)
    error('Inconsistent dimensions for starting points and ellipse definition.')

elseif ndims(ellipse) > 2 | size(ellipse,2) ~= 2
    error('Ellipse definition must have 2 columns.')

elseif size(lat,1) ~= size(az,1)
    error('Inconsistent dimensions for starting points and azimuths.')

elseif ndims(az) > 2 | size(az,2) > 2
    error('Azimuth input must have two columns or less')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Angle unit conversion

lat    = angledim(lat,units,'radians');
lon    = angledim(lon,units,'radians');
offset = angledim(offset,units,'radians');
az     = angledim(az,units,'radians');

%  Convert the range to radians if no radius or semimajor axis provided
%  Otherwise, reckon will take care of the conversion of the range inputs

if geoid(1) == 0;    ellipse(:,1) = angledim(ellipse(:,1),units,'radians');   end

%  Expand the azimuth inputs

if size(az,2) == 1       %  Single column azimuth inputs
    negaz = zeros(size(az));  posaz = az;

else                     %  Two column azimuth inputs
    negaz = az(:,1);          posaz = az(:,2);
end

%  Use real(npts) to avoid a cumbersome warning for complex n in linspace

az = zeros([size(negaz,1) npts]);
for i = 1:size(az,1)
	
    % shifted offset
    soffset = offset(i);
    
%  Handle case where limits give more than half of the circle.
%  Go clockwise from start to end. 	
	
	if negaz(i) > posaz(i) ; 
		posaz(i) = posaz(i)+2*pi;
        soffset = soffset+2*pi;
	end
		
	az(i,:) = linspace(negaz(i),posaz(i),real(npts));
    
% Check if offset angle falls between angular limits
	if soffset < posaz(i) & soffset > negaz(i)
        pt1_in = 1;
	else
        pt1_in = 0;
	end

	if soffset+pi < posaz(i) & soffset+pi > negaz(i)
        pt2_in = 1;
	else
        pt2_in = 0;
	end

% Add points at offset angle values if necessary    

% both offsetAngle and offsetAngle+pi are within limits
	if pt1_in == 1 & pt2_in == 1  
        
        totalNpts = real(npts);
        fine = round(0.1*totalNpts);
        totalFine = fine*4;
        remaining = totalNpts-totalFine;
        coarseSize = round(remaining/3);
        coarse1 = coarseSize;
        coarse2 = coarse1;
        coarse3 = remaining-coarse1-coarse2;
        
        dAng = deg2rad(1);
        ang1 = negaz(i);                 
        ang2 = soffset - dAng;          
        ang3 = soffset;
        ang4 = soffset + dAng;
        ang5 = (soffset + pi) - dAng;
        ang6 = soffset + pi;
        ang7 = (soffset + pi) + dAng;
        ang8 = posaz(i);
        
        if ang2 <= ang1; ang2 = ang1 + (ang1+ang2)/2; end
        if ang7 >= ang8; ang7 = ang8 - (ang7+ang8)/2; end
        
        segmentAngles = [ang1 ang2 ang3 ang4 ang5 ang6 ang7 ang8];
        segmentPoints = [coarse1 fine fine coarse2 fine fine coarse3];
        
        tempAz = [];
        for j = 1:length(segmentPoints(:))
            tempAz = [tempAz linspace(segmentAngles(j),segmentAngles(j+1),segmentPoints(j))];
        end
        
        az(i,:) = tempAz;
        
	end
    
% only offsetAngle is within limits    
	if pt1_in == 1 & pt2_in == 0  
        
        totalNpts = real(npts);
        fine = round(0.1*totalNpts);
        totalFine = fine*2;
        remaining = totalNpts-totalFine;
        coarseSize = round(remaining/2);
        coarse1 = coarseSize;
        coarse2 = remaining-coarse1;
        
        dAng = deg2rad(1);
        ang1 = negaz(i);                 
        ang2 = soffset - dAng;          
        ang3 = soffset;
        ang4 = soffset + dAng;
        ang5 = posaz(i);
        
        if ang2 <= ang1; ang2 = ang1 + (ang1+ang2)/2; end
        if ang4 >= ang5; ang4 = ang5 - (ang4+ang5)/2; end
        
        segmentAngles = [ang1 ang2 ang3 ang4 ang5];
        segmentPoints = [coarse1 fine fine coarse2];
        
        tempAz = [];
        for j = 1:length(segmentPoints(:))
            tempAz = [tempAz linspace(segmentAngles(j),segmentAngles(j+1),segmentPoints(j))];
        end
        
        az(i,:) = tempAz;
        
	end
    
% only offsetAngle+pi is within limits    
	if pt1_in == 0 & pt2_in == 1  
        
% 		az(i,:) = sort([linspace(negaz(i),posaz(i),real(npts)-1) soffset+pi]);

        totalNpts = real(npts);
        fine = round(0.1*totalNpts);
        totalFine = fine*2;
        remaining = totalNpts-totalFine;
        coarseSize = round(remaining/2);
        coarse1 = coarseSize;
        coarse2 = remaining-coarse1;
        
        dAng = deg2rad(1);
        ang1 = negaz(i);                 
        ang2 = (soffset+pi) - dAng;          
        ang3 = soffset+pi;
        ang4 = (soffset+pi) + dAng;
        ang5 = posaz(i);
        
        if ang2 <= ang1; ang2 = ang1 + (ang1+ang2)/2; end
        if ang4 >= ang5; ang4 = ang5 - (ang4+ang5)/2; end
        
        segmentAngles = [ang1 ang2 ang3 ang4 ang5];
        segmentPoints = [coarse1 fine fine coarse2];
        
        tempAz = [];
        for j = 1:length(segmentPoints(:))
            tempAz = [tempAz linspace(segmentAngles(j),segmentAngles(j+1),segmentPoints(j))];
        end
        
        az(i,:) = tempAz;

	end

end

%  Compute the circles.
%  Each circle occupies a row of the output matrices.

biglat = lat(:,ones([1,size(az,2)]) );
biglon = lon(:,ones([1,size(az,2)]) );
bigoffset = offset(:,ones([1,size(az,2)]) );

semimajor    = ellipse(:,1);
eccentricity = ellipse(:,2);
semimajor    = semimajor(:,ones([1,size(az,2)]) );
eccentricity = eccentricity(:,ones([1,size(az,2)]) );

%  Compute the radius as a function of azimuth

num    = 1-eccentricity.^2;
den    = 1 - (eccentricity.*cos(az - bigoffset)).^2;
bigrng = semimajor .* sqrt(num ./ den);

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
 
% needs an ellipsui
