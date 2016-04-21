function km = deg2km(deg,radius)

%DEG2KM Converts distances from degrees to kilometers
%
%  km = DEG2KM(deg) converts distances from degrees to kilometers.
%  A degree of distance is measured along a great circle of a sphere.
%
%  km = DEG2KM(deg,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in kilometers.  If omitted,
%  the default radius of the Earth is used.
%
%  See also KM2DEG, DEG2RAD, DEG2NM, DEG2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:15:45 $

if nargin==0
	error('Incorrect number of arguments')
elseif nargin == 1
    radius = almanac('earth','radius','km');
elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');
end


km = rad2km(deg2rad(deg),radius);
