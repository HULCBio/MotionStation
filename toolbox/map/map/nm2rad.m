function rad=nm2rad(nm,radius)

%NM2RAD Converts distances from nautical miles to radians
%
%  rad = NM2RAD(nm) converts distances from nautical miles to radians.
%  A radian of distance is measured along a great circle of a sphere.
%
%  rad = NM2RAD(nm,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in nautical miles.  If omitted,
%  the default radius of the Earth is used.
%
%  See also RAD2NM, NM2DEG, NM2KM, NM2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:17:24 $

if nargin==0
	error('Incorrect number of arguments')

elseif nargin == 1
    radius = almanac('earth','radius','km');

elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');

elseif nargin == 2 & ~isstr(radius)
    radius = nm2km(radius);
end

rad = km2rad(nm2km(nm),radius);
