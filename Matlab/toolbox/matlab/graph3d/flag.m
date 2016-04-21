function map = flag(m)
%FLAG   Alternating red, white, blue, and black color map.
%   FLAG(M) returns an M-by-3 matrix containing a "flag" colormap.
%   Increasing M increases the granularity emphasized by the map.
%   FLAG, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(flag)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, BONE, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 7-4-91, 8-19-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 04:27:39 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end

% f = [red; white; blue; black]
f = [1 0 0; 1 1 1; 0 0 1; 0 0 0];

% Generate m/4 vertically stacked copies of f with Kronecker product.
e = ones(ceil(m/4),1);
map = kron(e,f);
map = map(1:m,:);
