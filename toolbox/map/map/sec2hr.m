function hrs = sec2hr(seconds)

%SEC2HR Converts time from seconds to hours
%
%  hr = SEC2HR(sec) converts time from seconds to hours.
%
%  See also HR2SEC, SEC2HMS, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:10 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(seconds)
     warning('Imaginary parts of complex TIME argument ignored')
     seconds = real(seconds);
end

hrs=seconds/3600;
