function c = autumn(m)
%AUTUMN Shades of red and yellow color map.
%   AUTUMN(M) returns an M-by-3 matrix containing a "autumn" colormap.
%   AUTUMN, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(autumn)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:27:03 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1);
c = [ones(m,1) r zeros(m,1)];
