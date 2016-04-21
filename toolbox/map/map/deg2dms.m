function dms=deg2dms(deg)

%DEG2DMS Converts angles from degrees to deg:min:sec vector format
%
%  dms = DEG2DM(deg) converts angles from degrees to deg:min:sec vector
%  format.
%
%  See also DMS2DEG, DEG2RAD, MAT2DMS, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:15:44 $


if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(deg)
     warning('Imaginary parts of complex ANGLE argument ignored')
     deg = real(deg);
end

%  Test for empty inputs

if isempty(deg);     dms = [];   return;   end

%  Construct a sign vector which has +1 when deg >= 0 and -1 when deg < 0.

signvec = sign(deg);
signvec = signvec + (signvec == 0);    %  Enforce +1 when deg == 0

%  Compute the degrees, minutes and seconds


deg = abs(deg);             %  Work in absolute value.  Signvec will set sign later
d   = fix(deg);             %  Degrees
ms  = 60*(deg - d);         %  Minutes and seconds
m   = fix(ms);              %  Minutes
s   = 60*(ms - m);          %  Seconds

%  Determine where to store the sign of the angle.  It should be
%  associated with the largest nonzero component of d:m:s.

dsign = signvec .* (d~=0);                %  Associate with degrees
msign = signvec .* (d==0 & m~=0);         %  Assoicate with minutes (d = 0)
ssign = signvec .* (d==0 & m==0 & s~=0);  %  Associate with seconds (d = m = 0)

%  In the application of signs below, the comparison with 0 is used so that
%  the sign vector contains only +1 and -1.  Any zero occurances causes
%  data to be lost when the sign has been applied to a higher component
%  of d:m:s.

d = ((dsign==0) + dsign).*d;      %  Apply signs to the degrees
m = ((msign==0) + msign).*m;      %  Apply signs to minutes
s = ((ssign==0) + ssign).*s;      %  Apply signs to seconds

dms = mat2dms(d,m,s);     %  Construct the dms vector for output


