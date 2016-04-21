function p = pink(m)
%PINK   Pastel shades of pink color map.
%   PINK(M) returns an M-by-3 matrix containing a "pink" colormap.
%   PINK, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(pink)
%
%   See also HSV, GRAY, HOT, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 5-11-91, 8-19-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 04:27:31 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
p = sqrt((2*gray(m) + hot(m))/3);
