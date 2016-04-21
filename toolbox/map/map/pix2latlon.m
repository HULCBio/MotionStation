function [lat, lon] = pix2latlon(R, row, col)
%PIX2LATLON Convert pixel coordinates to latitude-longitude coordinates.
%
%   [LAT, LON] = PIX2LATLON(R,ROW,COL) calculates latitude-longitude
%   coordinates LAT, LON from pixel coordinates ROW, COL.  R is a 3-by-2
%   referencing matrix defining a 2-dimensional affine transformation from
%   pixel coordinates to spatial coordinates.  ROW and COL are vectors or
%   arrays of matching size.  The outputs LAT and LON have the same size
%   as ROW and COL.
%
%   Example 
%   -------
%      % Find the latitude and longitude of the upper left and lower right 
%      % outer corners of a 2-by-2 degree gridded data set.
%      R = makerefmat(1, 89, 2, 2);
%      [UL_lat, UL_lon] = pix2latlon(R, .5, .5)
%      [LR_lat, LR_lon] = pix2latlon(R, 90.5, 180.5)
%
%   See also LATLON2PIX, MAKEREFMAT, PIX2MAP.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/02/01 21:57:34 $ 

checknargin(3,3,nargin,mfilename);
[lon, lat] = pix2map(R, row, col);
