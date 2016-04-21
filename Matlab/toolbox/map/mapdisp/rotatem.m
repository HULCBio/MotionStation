function [lat1,lon1] = rotatem(lat,lon,origin,direction,units)

%ROTATEM  Rotate map data for specified origin and orientation
%
%  [lat1,lon1] = ROTATEM(lat,lon,origin,'forward') uses
%  Euler angle rotations to transform data from one coordinate
%  system to another.  In the forward direction, ROTATEM transforms
%  from a Greenwich system to a coordinate system specified by
%  the origin input.  This transformed system is centered at
%  lat = origin(1), lon = origin(2) and has an north pole orientation
%  defined by origin(3).  If origin(3) is omitted, then origin(3) = 0.
%  These three elements of origin correspond to Euler angle
%  rotations about the Y, X and Z axes respectively, executed
%  in a rotation order of X, Y and Z.
%
%  [lat1,lon1] = ROTATEM(lat,lon,origin,'inverse') transforms from
%  the rotated system to the Greenwich coordinate system.
%
%  [lat1,lon1] = ROTATEM(...,'units') uses the input 'units' to define
%  the angle units of all inputs and outputs.  If omitted, 'radians'
%  is assumed.
%
%  See also Any Projection M-File

%  Note:  The rotation calculations are highly sensitive to
%         round-off errors, especially around the poles and
%         +/- 180 in longitude.  It is extremely difficult to
%         be consistent in the forward and inverse directions
%         near these signularities.  Hence, the various truncation
%         schemes employed below.

%  Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:22:34 $

%  Input dimension tests
	
if nargin == 5     %  Transform to radians only if necessary.  Angledim is time consuming
       lat = angledim(lat,units,'radians');
		 lon = angledim(lon,units,'radians');
		 origin = angledim(origin,units,'radians');
elseif nargin ~= 4
    error('Incorrect number of arguments')
end

if any([ndims(lat) ndims(lon)] > 2)
    error('Lat and lon data must not contain pages');

elseif ~isequal(size(lat),size(lon))
    error('Inconsistent dimensions on LAT and LON arguments');

elseif isequal(sort(size(origin)),[1 2])
    origin(3) = 0;

elseif ~isequal(sort(size(origin)),[1 3])
    error('Origin input must be a 2 or 3 element vector')
end


%  Construct the three rotation matrices.
%  Rot1 is about the x axis
%  Rot2 is about the y axis
%  Rot3 is about the z axis

rot1 = [cos(origin(2))  sin(origin(2))  0
       -sin(origin(2))  cos(origin(2))  0
	    0               0               1];

rot2 = [cos(origin(1))  0     sin(origin(1))
        0               1     0
	   -sin(origin(1)) 0     cos(origin(1))];

rot3 = [1      0               0
        0     cos(origin(3))  sin(origin(3))
        0    -sin(origin(3))  cos(origin(3))];


%  Construct the complete euler angle rotation matrix

if strcmp(direction,'forward')
    rotation = rot3 * rot2 * rot1;
elseif strcmp(direction,'inverse')
    rotation = (rot3 * rot2 * rot1)';
else
    error('Unrecognized DIRECTION string.')
end

%  Move pi/2 points epsilon inward to prevent round-off problems
%  with identically pi/2 points.  The longitude data collapses
%  to zero if a point is identically at + or - pi/2

epsilon = 10*epsm('radians');
indx = find(abs(pi/2 - abs(lat)) <= epsilon);
if ~isempty(indx)
	lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
end

%  Eliminate confusion with points at identically +180 or -180 degrees

if strcmp(direction,'forward')
    lon = npi2pi(lon,'radians','inward');
end

%  Compute the new x,y,z point in cartesian space

x = rotation(1,1) * cos(lat).*cos(lon) + ...
    rotation(1,2) * cos(lat).*sin(lon) + ...
	rotation(1,3) * sin(lat);

y = rotation(2,1) * cos(lat).*cos(lon) + ...
    rotation(2,2) * cos(lat).*sin(lon) + ...
	rotation(2,3) * sin(lat);

z = rotation(3,1) * cos(lat).*cos(lon) + ...
    rotation(3,2) * cos(lat).*sin(lon) + ...
	rotation(3,3) * sin(lat);

%  Points with essentially zero x and y will be treated as 0,0.  Otherwise,
%  the atan2 operation in cart2sph treats these small distances as
%  coordinates and computes the corresponding angle (generally much
%  greater than zero.  Typically closer to 45 degrees).

epsilon = 1.0E-8;
indx = find(abs(x) <= epsilon & abs(y) <= epsilon);
if ~isempty(indx);   x(indx) = 0;  y(indx) = 0;   end

%  Transform the cartesian point to spherical coordinates

[lon1, lat1] = cart2sph(x,y,z);

%  Transform from radians if necessary
%  Avoid angledim calls since they are time consuming.

if nargin == 5
       lat1 = angledim(lat1,'radians',units);
		 lon1 = angledim(lon1,'radians',units);
end

