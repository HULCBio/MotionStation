function h = hot(m)
%HOT    Black-red-yellow-white color map.
%   HOT(M) returns an M-by-3 matrix containing a "hot" colormap.
%   HOT, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(hot)
%
%   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 8-17-88, 5-11-91, 8-19-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 04:27:53 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
n = fix(3/8*m);

r = [(1:n)'/n; ones(m-n,1)];
g = [zeros(n,1); (1:n)'/n; ones(m-2*n,1)];
b = [zeros(2*n,1); (1:m-2*n)'/(m-2*n)];

h = [r g b];
