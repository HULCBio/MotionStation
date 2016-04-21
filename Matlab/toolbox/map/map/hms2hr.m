function hrs = hms2hr(hms, in2, in3)

%HMS2HR Converts time from hrs:min:sec to hours
%
%  hr = HMS2HR(hms) converts time from the hrs:min:sec vector format
%  to hours.
%
%  hr = HMS2HR(h,m,s) converts time from hours (h), minute (m) and
%  second (s) format to degrees.  The input matrices h, m and s must
%  be of equal size.  Minutes and seconds must be between 0 and 60.
%
%  See also HR2HMS, HMS2SEC, MAT2HMS, HMS2MAT, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:33 $



if nargin == 0 | nargin == 2
	error('Incorrect number of arguments')
elseif nargin == 1
    [h,m,s] = hms2mat(hms);
elseif nargin == 3
    h = hms;   m = in2;    s = in3;
end

%  Dimension test

if ~isequal(size(h),size(m),size(s))
    error('Inconsistent dimensions for inputs')
elseif any([~isreal(h) ~isreal(m) ~isreal(s)])  %  Avoid concat of [h m s]
    warning('Imaginary parts of complex TIME argument ignored')
	h = real(h);    m = real(m);    s = real(s);
end

%  Ensure that only one negative sign is present

if any((s<0 & m<0) | (s<0 & h<0) | (m<0 & h<0) )
    error('Multiple negative entries in a hms specification')
end

%  Construct a sign vector which has +1 when
%  time >= 0 and -1 when time < 0.  Note that the sign of the
%  time is associated with the largest nonzero component of h:m:s

negvec = (h<0) | (m<0) | (s<0);
signvec = ~negvec - negvec;

%  Compute the time in hours

hrs  = signvec.*( abs(h) + abs(m)/60 + abs(s)/3600 );
