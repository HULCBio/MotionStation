function km = nm2km(nm)

%NM2KM Converts distances from nautical miles to kilometers
%
%  km = NM2KM(nm) converts distances from nautical miles to kilometers.
%
%  See also KM2NM, NM2DEG, NM2RAD, NM2SM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:17:23 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(nm)
     warning('Imaginary parts of complex DISTANCE argument ignored')
     nm = real(nm);
end


km=1.8520*nm;
