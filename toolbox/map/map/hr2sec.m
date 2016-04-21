function seconds = hr2sec(hrs)

%HR2SEC Converts time from hours to seconds
%
%  sec = HR2SEC(hr) converts time from hours to seconds.
%
%  See also SEC2HR, HR2HMS, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:38 $

if nargin==0
	error('Incorrect number of arguments')
elseif ~isreal(hrs)
     warning('Imaginary parts of complex TIME argument ignored')
     hrs = real(hrs);
end

seconds=hrs*3600;
