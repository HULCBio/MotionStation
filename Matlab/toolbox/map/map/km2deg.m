function deg = km2deg(km,radius)

%KM2DEG Converts distances from kilometers to degrees
%
%  deg = KM2DEG(km) converts distances from kilometers to degrees.
%  A degree of distance is measured along a great circle of a sphere.
%
%  deg = KM2DEG(km,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in kilometers.  If omitted,
%  the default radius of the Earth is used.
%
%  See also DEG2KM, KM2RAD, KM2NM, KM2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:48 $

if nargin==0
	error('Incorrect number of arguments')
elseif nargin == 1
    radius = almanac('earth','radius','km');
elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');
end

deg = rad2deg( km2rad(km,radius) );
