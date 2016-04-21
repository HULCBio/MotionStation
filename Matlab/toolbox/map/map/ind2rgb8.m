function RGB = ind2rgb8(X, CMAP)
%IND2RGB8 Convert an indexed image to a uint8 RGB image.
%
%   RGB = IND2RGB8(X,CMAP) creates an RGB image of class uint8.  X must be
%   uint8, uint16, or double, and CMAP must be a valid MATLAB colormap.
%
%   Example 
%   -------
%      % Convert the 'boston.tif' image to RGB.
%      [X, cmap, R, bbox] = geotiffread('boston.tif');
%      RGB = ind2rgb8(X, cmap);
%      mapshow(RGB, R);
%
%   See also IND2RGB.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:57:26 $ 

RGB = ind2rgb8c(X, CMAP);
