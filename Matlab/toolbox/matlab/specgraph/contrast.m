function cmap = contrast(x,m);
%CONTRAST Gray scale color map to enhance image contrast.
%   CMAP = CONTRAST(X,M) returns a gray contrast enhancing color,
%   map that is a M-by-3 matrix with 3 identical columns, so that
%       IMAGE(X)
%       COLORMAP(CMAP)
%   has a roughly equi-distributed gray scale histogram.
%   If M is omitted, the current colormap length is used.
%
%   CONTRAST works best when the image colors are ordered by
%   intensity.

%   Cleve Moler 5-8-91, 7-20-91.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/06/17 13:38:11 $

if nargin < 2, m = size(colormap,1); end
xmin = min(min(x));
xmax = max(max(x));
x = round((m-1)*(x-xmin)/(xmax-xmin));
f = find(diff(sort([x(:); (0:m)'])));
f = f/max(f);
cmap = [f f f];
