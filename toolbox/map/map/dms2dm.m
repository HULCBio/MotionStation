function dm=dms2dm(dms)

%DMS2DM Converts angles from deg:min:sec to deg:min vector format
%
%  dm = DMS2DM(dms) converts from the deg:min:sec vector format
%  to deg:min vector format.  Seconds are rounded to the nearest
%  minute.
%
%  See also DMS2DEG,  MAT2DMS, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:15:55 $


if nargin==0;   error('Incorrect number of arguments');   end

%  Do all the error checking on dms format first.

[d,m,s]=dms2mat(dms);

%  Now, round the (valid) dms entry and then build up the dm output.
%
%  0.2 is used to round seconds.  0.3+0.2 = 0.5 which will round up
%  to an additional minute.  0.29+0.2 = 0.49 which will stay at
%  the current minute.

dms = round(dms+0.2);
[d,m,s] = dms2mat(dms);
dm = mat2dms(d,m);     %  Round 60 minutes to 1 degree here
