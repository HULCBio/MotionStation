function hm=hms2hm(hms)

%HMS2HM Converts time from hrs:min:sec to hr:min vector format
%
%  hm = HMS2HM(hms) converts time from the hrs:min:sec vector format
%  to hrs:min vector format.  Seconds are rounded to the nearest
%  minute.
%
%  See also HMS2HRS,  MAT2HMS, HMS2MAT, TIMEDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:32 $


if nargin==0;   error('Incorrect number of arguments');   end


%  Do all the error checking on dms format first.

[h,m,s]=hms2mat(hms);

%  Now, round the (valid) hms entry and then build up the hm output.
%
%  0.2 is used to round seconds.  0.3+0.2 = 0.5 which will round up
%  to an additional minute.  0.29+0.2 = 0.49 which will stay at
%  the curren minute.

hms=round(hms+0.2);
[h,m,s]=hms2mat(hms);
hm = mat2hms(h,m);     %  Round 60 minutes to 1 hour here
