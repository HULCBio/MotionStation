function [elevang,slantrange] = elevation(lat1,lon1,alt1,lat2,lon2,alt2,angleunits,in8)

% ELEVATION Calculates elevation angle between points on a geoid
%
%  elevang = ELEVATION(lat1,lon1,alt1,lat2,lon2,alt2) computes the elevation
%  angle of point 2 as viewed from point 1. The elevation angle is the angle
%  of the line of sight above the local horizontal at point 1. Points are 
%  specified as latitude, longitude and altitude above the surface. Angles are 
%  in units of degrees, altitudes are in meters. The figure of the earth is 
%  assumed to the default ellipsoid. Inputs can be vectors of points. Elevations 
%  from a point to a line can be computed by providing a scalar point 1 and 
%  vector point 2.
% 
%  [elevang,slantrange] = ELEVATION(...) also returns the slant range between
%  the points in units of meters.
%
%  [elevang,slantrange] = ELEVATION(lat1,lon1,alt1,lat2,lon2,alt2,'angleunits')
%  uses the inputs 'angleunits' to define the angle units of the inputs and 
%  outputs. If omitted, 'degrees' are assumed.
%
%  [elevang,slantrange] = ELEVATION(lat1,lon1,alt1,lat2,lon2,alt2,...
%  'angleunits','zunits') uses the inputs 'zunits' to define the units of the 
%  altitude inputs and slant range outputs. If omitted, 'meters' are assumed.
%  All distance units recognized by DISTDIM are valid inputs.
% 
%  [elevang,slantrange] = ELEVATION(lat1,lon1,alt1,lat2,lon2,alt2,'angleunits',...
%  ellipsoid)  computes the elevation and slant range on the ellipsoid defined
%  by the input ellipsoid. The ellipsoid vector is of the form [semimajor axes,
%  eccentricity].  If omitted, the default ellipsoid for the earth is assumed.
%  The altitudes are input and the slant range is returned in the units of 
%  ellipsoid(1).
% 
%  See also AZIMUTH

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.1 $ $Date: 2003/08/01 18:16:05 $

altunits = 'm';
ellipsoid = almanac('earth','geoid',altunits);

if nargin < 6; error('Incorrect number of input arguments'); end
if nargin < 7; angleunits = 'degrees'; end
if nargin == 8; 
    if isstr(in8)
        altunits = in8;
        ellipsoid = almanac('earth','geoid',altunits);
    else
        ellipsoid = in8;
    end
end

%  Test the geoid parameter

[ellipsoid,msg] = geoidtst(ellipsoid);
if ~isempty(msg);   error(msg);   end
if length(ellipsoid)==1; ellipsoid(2) = 0; end

% convert to column vectors
[lat1,lon1,alt1,lat2,lon2,alt2] = deal(lat1(:),lon1(:),alt1(:),lat2(:),lon2(:),alt2(:));

% check sizes
if ~all(isequal(size(lat1),size(lon1),size(alt1))) | ...
    ~all(isequal(size(lat2),size(lon2),size(alt2)))
    error('Lat, long and alt inputs must be the same size')
end

%  Allow for scalar starting point, but vectorized end points. 

if length(lat1) == 1 & length(lat2) ~= 0
    lat1 = lat1(ones(size(lat2)));   
    lon1 = lon1(ones(size(lat2)));
    alt1 = alt1(ones(size(alt2)));
end

% check sizes again
if ~all(isequal(size(lat1),size(lon1),size(alt1),size(lat2),size(lon2),size(alt2)))
    error('Inconsistent lat, long and alt inputs')
end

% convert angles to degrees

lat1 = angledim(lat1,angleunits,'degrees');
lon1 = angledim(lon1,angleunits,'degrees');
lat2 = angledim(lat2,angleunits,'degrees');
lon2 = angledim(lon2,angleunits,'degrees');

% define globe projection 

mstruct = defaultm('globe');
mstruct.geoid = ellipsoid;
mstruct = defaultm(globe(mstruct));

% compute 3-d cartesian coordinates for heights above the ellipsoid

[x1,y1,z1] = mfwdtran(mstruct,lat1,lon1,alt1);
[x2,y2,z2] = mfwdtran(mstruct,lat2,lon2,alt2);

% slant ranges between point (in zunits)

slantrange = vectormag([x2-x1 y2-y1 z2-z1]);

% magnitude of position vectors

r1 = vectormag([x1 y1 z1]);
r2 = vectormag([x2 y2 z2]);

% Elevation angle from the center of the elipsoid using cosine law. This
% is the angle up from the center of the sphere from the line connecting
% point 1 to the center of the sphere and the line connecting point 1 to
% point 2. The subtracted 90 degrees is for the angle between the local 
% horizontal and the first line. As such this formula is for a sphere. Below
% we'll correct the elevation angle for the different orientation of local 
% horizontal of the sphere and the ellipsoid.

elevang = acos( (r1.^2 + slantrange.^2 - r2.^2)./(2.*slantrange.*r1) ) - pi/2;

% Difference in the the local horizontal between the sphere and ellipsoid 
% at the observer locations. This is positive for a target north of the observer.

diff = deg2rad(lat1-geod2cen(lat1,ellipsoid));

% When the target is north of the observer, the ellipsoidal elevation is 
% higher than the elevation angle computed for the center of the ellipsoid
% by the above difference. For a target to the south, the elevation angle 
% is lower.

diff = diff .* cos(deg2rad(azimuth(lat1,lon1,lat2,lon2,ellipsoid)));

% Add the ellipsoidal correction

elevang = elevang + diff;

% convert to same units as input angles

elevang = angledim(elevang,'radians',angleunits);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vmag = vectormag(ndimvec)

vmag = sqrt(sum(ndimvec.^2,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vang = vectorangle(vec1,vec2)

mag1 = vectormag(vec1);
mag2 = vectormag(vec2);
dot12 = dot(vec1,vec2,2);
vang = acos(dot12./(mag1.*mag2));






