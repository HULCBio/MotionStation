function sm = rad2sm(rad,radius)

%RAD2SM Converts distances from radians to statute miles
%
%  sm = RAD2SM(rad) converts distances from radians to statute miles.
%  A radian of distance is measured along a great circle of a sphere.
%
%  sm = RAD2SM(rad,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in statute miles.  If omitted,
%  the default radius of the Earth is used.
%
%  See also SM2RAD, RAD2DEG, RAD2KM, RAD2NM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:19:54 $

if nargin==0
	error('Incorrect number of arguments')

elseif nargin == 1
    radius = almanac('earth','radius','km');
elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');
elseif nargin == 2 & ~isstr(radius)
    radius = sm2km(radius);
end


sm = km2sm(rad2km(rad,radius));
