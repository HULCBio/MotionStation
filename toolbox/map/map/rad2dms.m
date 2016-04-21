function dms=rad2dms(rad)

%RAD2DMS Converts angles from radians to deg:min:sec vector format
%
%  dms = RAD2DMS(rad) converts angles from radians to deg:min:sec vector
%  format.
%
%  See also DMS2RAD, RAD2DEG, MAT2DMS, DMS2MAT, ANGLEDIM, ANGL2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:19:51 $

if nargin==0;  error('Incorrect number of arguments');   end

%  Compute the angle in dms by first transforming from rad to deg.

dms = deg2dms(rad2deg(rad));

