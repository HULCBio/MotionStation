function km = rad2km(rad,radius)

%RAD2KM Converts distances from radians to kilometers
%
%  km = RAD2KM(rad) converts distances from radians to kilometers.
%  A radian of distance is measured along a great circle of a sphere.
%
%  km = RAD2KM(rad,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in kilometers.  If omitted,
%  the default radius of the Earth is used.
%
%  See also KM2RAD, RAD2DEG, RAD2NM, RAD2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:19:52 $

if nargin==0
	error('Incorrect number of arguments')
elseif nargin == 1
    radius = almanac('earth','radius','km');
elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');
end

if max(size(radius)) ~= 1
     error('Scalar radius required')
elseif any([~isreal(rad) ~isreal(radius)])
     warning('Imaginary parts of complex DISTANCE and/or RADIUS arguments ignored')
     rad = real(rad);   radius = real(radius);
end

km = radius*rad;
