function rad=dms2rad(dms, in2, in3)

%DMS2RAD Converts angles from deg:min:sec to radians
%
%  rad = DMS2RAD(dms) converts from the deg:min:sec vector format
%  to radians.
%
%  rad = DMS2RAD(d,m,s) converts from degree (d), minute (m) and
%  second (s) format to radians.  The input matrices d, m and s must
%  be of equal size.  Minutes and seconds must be between 0 and 60.
%
%  See also RAD2DMS, DMS2DEG, MAT2DMS, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:15:57 $


if nargin == 0 | nargin == 2
	error('Incorrect number of arguments')
elseif nargin == 1
    [d,m,s] = dms2mat(dms);
elseif nargin == 3
    d = dms;   m = in2;    s = in3;
end

%  Compute the angle in radians by first transforming from dms to degrees.

rad = deg2rad(dms2deg(d,m,s));
