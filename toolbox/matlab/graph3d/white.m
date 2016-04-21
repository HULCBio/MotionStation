function w = white(m);
%WHITE  All white color map.
%   WHITE(M) returns an M-by-3 matrix containing a white colormap.
%   WHITE, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%      colormap(white)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 04:28:27 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
w = ones(m,3);
