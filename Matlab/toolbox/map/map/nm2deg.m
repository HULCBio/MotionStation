function deg = nm2deg(nm,radius)

%NM2DEG Converts distances from nautical miles to degrees
%
%  deg = NM2DEG(nm) converts distances from nautical miles to degrees.
%  A degree of distance is measured along a great circle of a sphere.
%
%  deg = NM2DEG(nm,radius) uses the second input to determine the
%  radius of the sphere.  If radius is a string, then it is evaluated
%  as an ALMANAC body to determine the spherical radius.  If numerical,
%  it is the radius of the desired sphere in nautical miles.  If omitted,
%  the default radius of the Earth is used.
%
%  See also DEG2NM, NM2RAD, NM2KM, NM2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:17:22 $

if nargin==0
	error('Incorrect number of arguments')
elseif nargin == 1
    radius = almanac('earth','radius','km');
elseif nargin == 2 & isstr(radius)
	radius = almanac(radius,'radius','km');
elseif nargin == 2 & ~isstr(radius)
    radius = nm2km(radius);
end

deg = km2deg( nm2km(nm),radius);
