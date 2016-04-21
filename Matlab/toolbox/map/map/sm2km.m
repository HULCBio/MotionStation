function km = sm2km(sm)

%SM2KM Converts distances from statute miles to kilometers
%
%  km = SM2KM(sm) converts distances from statute miles to kilometers.
%
%  See also KM2SM, SM2DEG, SM2RAD, SM2NM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $    $Date: 2003/08/01 18:20:16 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(sm)
     warning('Imaginary parts of complex DISTANCE argument ignored')
     sm = real(sm);
end

% Exact conversion factor
% 1 statute mile = 5280 statute feet, 1 statute foot = 1200/3937 meter, 
% 1000 meters = 1 kilometer
cf = 1*5280*1200/3937/1000;
km = cf*sm;
