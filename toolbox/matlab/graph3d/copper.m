function c = copper(m)
%COPPER Linear copper-tone color map.
%   COPPER(M) returns an M-by-3 matrix containing a "copper" colormap.
%   COPPER, by itself, is the same length as the current colormap.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(copper)
%
%   See also HSV, GRAY, HOT, COOL, BONE, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 8-17-88, 8-19-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 04:27:33 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
c = min(1,gray(m)*diag([1.2500 0.7812 0.4975]));
