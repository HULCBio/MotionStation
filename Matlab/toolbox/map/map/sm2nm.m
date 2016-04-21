function nm = sm2nm(sm)

%SM2NM Converts distances from statute miles to nautical miles
%
%  nm = SM2NM(sm) converts distances from statute miles to nautical miles.
%
%  See also NM2SM, SM2DEG, SM2RAD, SM2KM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $    $Date: 2003/08/01 18:20:17 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(sm)
     warning('Imaginary parts of complex DISTANCE argument ignored')
     sm = real(sm);
end

% Exact conversion factor
% 1 statute mile = 5280 statute feet, 1 statute foot = 1200/3937 meters
% 1852 meters = 1 nm
cf = 1*5280*(1200/3937)/1852;
nm = cf*sm;
