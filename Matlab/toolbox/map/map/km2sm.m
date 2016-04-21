function sm = km2sm(km)

%KM2SM Converts distances from kilometers to statute miles
%
%  sm = KM2SM(km) converts distances from kilometers to statute miles.
%
%  See also SM2KM, KM2DEG, KM2RAD, KM2NM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $    $Date: 2003/08/01 18:16:51 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(km)
     warning('Imaginary parts of complex DISTANCE argument ignored')
     km = real(km);
end

% Exact conversion factor
% 1 kilometer = 1000 meters, 1200/3937 meters = 1 statue foot,
% 5280 statute feet = 1 statue mile
cf = 1*1000/(1200/3937)/5280;
sm=cf*km;
