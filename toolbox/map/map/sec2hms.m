function hms=sec2hms(sec)

%SEC2HMS Converts time from seconds to hrs:min:sec vector format
%
%  hms = SEC2HMS(sec) converts time from seconds to hrs:min:sec
%  vector format.
%
%  See also HMS2SEC, SEC2HR, MAT2HMS, HMS2MAT, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:09 $


if nargin==0;   error('Incorrect number of arguments');   end

%  Compute the time in hms by first transforming from sec to hrs.

hms = hr2hms(sec2hr(sec));
