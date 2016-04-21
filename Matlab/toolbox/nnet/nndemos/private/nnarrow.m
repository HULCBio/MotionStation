function h = nnarrow(x,y,w,c,t,e)
% NNARROW Neural Network Design utility function.

%  NNARROW(X,Y,W,C,T,E)
%    X - Horizontal coordinate.
%    Y - Vertical coordinate.
%    W - Width of line (in points).
%    C - Color of line.
%    T - Tag string (default = '').
%    E - Erase mode (default = 'normal');
%
%  X and Y may also have two elements each to describe
%  a vector which does not begin at the origin.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.7 $


%==================================================================

% DEFAULTS
if nargin < 6, t = ''; end
if nargin < 7, e = 'normal'; end
if length(x) == 1,x0 = 0; else x0 = x(1); end
if length(y) == 1,y0 = 0; else y0 = y(1); end
x = x(length(x));
y = y(length(y));

% LINE WIDTH
set(gcf,'units','points')
set(gca,'units','points')
axis_pos = get(gca,'pos');
axis_points = axis_pos(3);
xlim = get(gca,'xlim');
axis_width = xlim(2)-xlim(1);
w = w * axis_width/axis_points;

line_h1 = nnline([x0 x],[y0 y],w,c,e);
l = 3*w;

angle = atan2(y-y0,x-x0);
angle1 = angle+3.001*pi/4;
angle2 = angle-3.001*pi/4;
xx = [x+l*cos(angle1) x x+l*cos(angle2)];
yy = [y+l*sin(angle1) y y+l*sin(angle2)];
line_h2 = nnline(xx,yy,w,c,e);
if ~strcmp(t,'')
  text_h = text(x+l*1.5*cos(angle),y+l*1.5*sin(angle),t, ...
    'color',nndkblue, ...
    'fontsize',10, ...
    'fontname','geneva', ...
    'horizontal','center', ...
    'erasemode',e);
else
  %g3 = [];
  text_h = [];
end

if nargout, h = [line_h1; line_h2; text_h]; end
