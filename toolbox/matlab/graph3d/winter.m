function c = winter(m)
%WINTER Shades of blue and green color map.
%   WINTER(M) returns an M-by-3 matrix containing a "winter" colormap.
%   WINTER, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(winter)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:27:29 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1); 
c = [zeros(m,1) r .5+(1-r)/2];
