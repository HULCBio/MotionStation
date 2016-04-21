function c = summer(m)
%SUMMER Shades of green and yellow colormap.
%   SUMMER(M) returns an M-by-3 matrix containing a "summer" colormap.
%   SUMMER, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(summer)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 04:27:59 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1); 
c = [r .5+r/2 .4*ones(m,1)];
