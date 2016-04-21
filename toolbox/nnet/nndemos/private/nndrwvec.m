function h = nndrwvec(x,y,w,l,c,t,e)
%NNDRWVEC Neural Network Design utility function.

%  NNDRWVEC(X,Y,W,L,C,T)
%    X - Horizontal coordinate.
%    Y - Vertical coordinate.
%    W - Width of line.
%    L - Length of arrow.
%    C - Color of line.
%    T - Tag string (default = '').
%    E - Erase mode (default = 'normal');
%
%  X and Y may also have two elements each to describe
%  a vector which does not begin at the origin.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.8 $

%==================================================================

% DEFAULT

if nargin < 6, t = ''; end
if nargin < 7, e = 'normal'; end
if length(x) == 1,x0 = 0; else x0 = x(1); end
if length(y) == 1,y0 = 0; else y0 = y(1); end
x = x(length(x));
y = y(length(y));

angle = atan2(y-y0,x-x0);
angle1 = angle+3.001*pi/4;
angle2 = angle-3.001*pi/4;
xx = [x0 x (x+l*cos(angle1)) x (x+l*cos(angle2))];
yy = [y0 y (y+l*sin(angle1)) y (y+l*sin(angle2))];

set(gcf,'nextplot','add')

g2 = plot(xx,yy,'color',c,'linewidth',w,'erasemode',e);
if ~strcmp(t,'')
  g3 = text(x+l*1.5*cos(angle),y+l*1.5*sin(angle),t, ...
    'color',nndkblue, ...
    'fontsize',10, ...
    'fontname','geneva', ...
    'horizontal','center', ...
    'erasemode',e);
else
  g3 = [];
end

if nargout, h = [g2 g3]; end
