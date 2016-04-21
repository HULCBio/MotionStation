function nndrwcir(x,y,r,c)
%NNDRWCIR Neural Network Design utility function.

%  NNDRWCIR(X,Y,R,C)
%    X - Horizontal coordinate.
%    Y - Vertical coordinate.
%    R - Radius.
%    C - Color.
%   Draws a filled circle.

% First Version, 8-31-95.
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

%==================================================================

angle = [0:10:350] * pi/180;
fill(cos(angle)*r+x,sin(angle)*r+y,c,'edgecolor','none');
