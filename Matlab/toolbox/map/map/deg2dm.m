function dm=deg2dm(deg)

%DEG2DM  Converts angles from degrees to deg:min vector format
%
%  dm = DEG2DM(deg) converts angles from degrees to deg:min vector
%  format.  The angle is rounded to the nearest minute.
%
%  See also DMS2DEG, DEG2DMS, MAT2DMS, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:15:43 $


if nargin==0;  error('Incorrect number of arguments');  end

%  Compute the angle in dm.
%  0.2 is used to round seconds.  0.3+0.2 = 0.5 which will round up
%  to an additional minute.  0.29+0.2 = 0.49 which will stay at
%  the curren minute.

dms = round(deg2dms(deg)+0.2);
[d,m,s] = dms2mat(dms);
dm = mat2dms(d,m);     %  Round 60 minutes to 1 degree here
