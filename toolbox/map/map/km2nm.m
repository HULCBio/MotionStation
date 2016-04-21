function nm = km2nm(km)

%KM2NM Converts distances from kilometers to nautical miles
%
%  nm = KM2NM(km) converts distances from kilometers to nautical miles.
%
%  See also NM2KM, KM2DEG, KM2RAD, KM2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:49 $


if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(km)
     warning('Imaginary parts of complex DISTANCE argument ignored')
     km = real(km);
end


nm=km/1.8520;
