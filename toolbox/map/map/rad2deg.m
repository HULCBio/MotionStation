function D=rad2deg(R)

%RAD2DEG Converts angles from radians to degrees
%
%  deg = RAD2DEG(rad) converts angles from radians to degrees.
%
%  See also DEG2RAD, RAD2DMS, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:19:49 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(R)
     warning('Imaginary parts of complex ANGLE argument ignored')
     R = real(R);
end

D = R*180/pi;
