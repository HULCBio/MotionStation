function h = nndrwrec(x,y,w,h,c)
%NNDRWREC Neural Network Design utility function.

%  NNDRWREC(X,Y,W,H,C)
%    X - Horizontal coordinate.
%    Y - Vertical coordinate.
%    W - Width of rectangle.
%    H - Height of rectangle.
%    C - Color
%  Draws a rectangle.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

sqr_x = [0 1 1 0 0];
sqr_y = [0 0 1 1 0];
g = fill(sqr_x*w+x,sqr_y*h+y,c,'edgecolor','none');
if nargout, h = g; end
