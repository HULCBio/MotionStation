function [mapout,lat,lon] = neworig(map,maplegend,origin,direction,units)

%NEWORIG  Transformation of a regular matrix map to a new coordinate system origin
%
%  [map,lat,lon] = NEWORIG(map0,maplegend,origin) and
%  [map,lat,lon] = neworig(map0,maplegend,origin,'forward') will
%  transform a regular matrix map into an oblique aspect, while
%  preserving the matrix storage format.  In other words, the oblique map
%  origin is not necessarily at (0,0) in the Greenwich coordinate frame.
%  This allows operations to be performed on the matrix representing the
%  oblique map.  For example, azimuthal calculations for a point in a matrix
%  map become row and column operations if the matrix map is
%  transformed so that the north pole of the oblique map represents
%  the desired point on the globe.
%
%  [map,lat,lon] = neworig(map0,maplegend,origin,'inverse') transforms
%  the regular matrix map from the oblique frame to the Greenwich
%  coordinate frame.
%
%  See also  ROTATEM, SETPOSTN, ORG2POL


%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:17:20 $


if nargin < 3
	error('Incorrect number of arguments')

elseif nargin == 3
    direction = [];     units = [];

elseif nargin == 4
    units = [];
end

%  Empty argument tests

if isempty(direction);   direction = 'forward';    end
if isempty(units);       units     = 'degrees';    end

%   Compute the starting grid locations

[lat,lon] = meshgrat(map,maplegend,size(map));

%  Convert units

lat    = angledim(lat,units,'radians');
lon    = angledim(lon,units,'radians');
origin = angledim(origin,units,'radians');


%  Set the proper direction for rotatem.  If the user has entered
%  forward, then this is actually an inverse using rotatem.  We
%  must find out what Greenwich coordinates will produce the [lat lon]
%  grid.  It is the codes of these Greenwich coordinates that we
%  want to move into the positions corresponding to [lat lon].  This
%  process works in reverse when the user is going in the inverse direction.

if lower(direction(1)) == 'f';
     direction = 'inverse';
elseif lower(direction(1)) == 'i'
     direction = 'forward';
else
     error('Unrecognized direction string')
end

%  Rotate the grid to the corresponding starting locations.

[lat,lon] = rotatem(lat,lon,origin,direction);

%  Adjust longitudes based upon whether maplegend starts above
%  or below zero.  In other words, allow for a 0 to 360 degree
%  longitude range as well as a -180 to 180 degree range.  At
%  this points, lon will always be in -180 to 180.

if maplegend(3) >= 0;  lon = zero22pi(lon,'radians','exact');   end

%  Convert the grid to the units in which the map is stored

lat = angledim(lat,'radians',units);
lon = angledim(lon,'radians',units);

%  Compute the starting positions of the map coordinates

indx = setpostn(map,maplegend,lat(:),lon(:));

%  Set these indices in the new map.

[r,c] = size(map);
mapout = map(indx);
mapout = reshape(mapout,r,c);

