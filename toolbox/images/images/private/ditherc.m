function im=ditherc( r, g, b, map, qm, qe )
%DITHERC Floyd-Steinberg image dithering (MEX function).
%   DITHERC implements the dithering algorithm for the function
%   DITHER.  It has the same syntax as DITHER.
%
%   Don't use this function directly, use DITHER instead.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.13.4.1 $  $Date: 2003/01/26 05:59:21 $

%#mex

eid = sprintf('Images:%s:missingMexFile', mfilename);
error(eid, sprintf('Missing MEX-file: %s', mfilename));
