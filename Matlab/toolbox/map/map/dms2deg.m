function deg=dms2deg(dms, in2, in3)

%DMS2DEG Converts angles from deg:min:sec to degrees
%
%  deg = DMS2DEG(dms) converts from the deg:min:sec vector format
%  to degrees.
%
%  deg = DMS2DEG(d,m,s) converts from degree (d), minute (m) and
%  second (s) format to degrees.  The input matrices d, m and s must
%  be of equal size.  Minutes and seconds must be between 0 and 60.
%
%  See also DEG2DMS, DMS2RAD, DMS2VEC, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:15:54 $

if nargin == 0 | nargin == 2
	error('Incorrect number of arguments')
elseif nargin == 1
    [d,m,s] = dms2mat(dms);
elseif nargin == 3
    d = dms;   m = in2;    s = in3;
end

%  Dimension test

if ~isequal(size(d),size(m),size(s))
    error('Inconsistent dimensions for inputs')
elseif any([~isreal(d) ~isreal(m) ~isreal(s)])  %  Avoid concat of [d m s]
    warning('Imaginary parts of complex ANGLE argument ignored')
	d = real(d);    m = real(m);    s = real(s);
end

%  Ensure that only one negative sign is present

if any((s<0 & m<0) | (s<0 & d<0) | (m<0 & d<0) )
    error('Multiple negative entries in a DMS specification')
end

%  Construct a sign vector which has +1 when
%  angle >= 0 and -1 when angle < 0.  Note that the sign of the
%  angle is associated with the largest nonzero component of d:m:s

negvec = (d<0) | (m<0) | (s<0);
signvec = ~negvec - negvec;


%  Compute the angle in degrees

deg  = signvec.*( abs(d) + abs(m)/60 + abs(s)/3600 );
