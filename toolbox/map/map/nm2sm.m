function sm = nm2sm(nm)

%NM2SM Converts distances from nautical miles to statute miles
%
%  sm = NM2SM(nm) converts distances from nautical miles to statute miles.
%
%  See also SM2NM, NM2DEG, NM2RAD, NM2KM, DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $    $Date: 2003/08/01 18:17:25 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(nm)
     warning('Imaginary parts of complex distance argument ignored')
     nm = real(nm);
end

% Exact conversion factor
% 1 nm = 1852 meters, 1200/3937 meters = 1 statute foot,
% 5280 statute feet = 1 statute mile
cf = 1*1852/(1200/3937)/5280;
sm=nm*cf;
