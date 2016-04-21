function h = nndicon(n,x,y,s)
%NNDSICON Neural Network Design utility function.

% NNDSICON(C,X,Y,S)
%   N - Icon Name.
%   X - Horizontal position.
%   Y - Vertical position.
%   S - Size (default = 15).
% Draws small icon N at position (X,Y).

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $
% First Version, 8-31-95.

%==================================================================

% DEFAULTS
if nargin < 4, s = 15; end

% COLORS
red = nnred;
blue = nndkblue;
yellow = nnyellow;
orange = [1 0.5 0];

% STORE FIGURE STATE
fig = gcf;
ax = gca;
NPF = get(fig,'nextplot');
NPA = get(gca,'nextplot');
set(fig,'nextplot','add');
set(ax,'nextplot','add');

% BOX
rect_x = [-1 1 1 -1];
rect_y = [-1 -1 1 1];
box_h = fill(x+rect_x*s,y+rect_y*s,blue,'edgecolor',red,'erasemode','none');

% ADJUST SIZE
s = s/15;
% NOTE: S is divided by 15 so plotting below can be done
% in a box with x and y values in the interval [-10, 10]
% leaving a border.

% CONTENT
if strcmp(n,'sum')
  xx = [8 -8 -2 -8 8];
  yy = [10 10 0 -10 -10];
  hh = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');

elseif strcmp(n,'f')
  xx = [6 -6 -6 6 -6 -6];
  yy = [10 10 0 0 0 -10];
  hh = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');

elseif strcmp(n,'hardlim')
  xx = [-10 10];
  yy = [-10 -10];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = [-10 0 0 10];
  yy = [-10 -10 10 10];
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];

elseif strcmp(n,'hardlims')
  xx = [-10 10];
  yy = [0 0];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = [-10 0 0 10];
  yy = [-10 -10 10 10];
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];

elseif strcmp(n,'purelin')
  xx = [-10 10];
  yy = [0 0];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = [-10 10];
  yy = [-10 10];
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];

elseif strcmp(n,'logsig')
  xx = [-10 10];
  yy = [-10 -10];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = -10:10;
  yy = logsig(xx/2)*20-10;
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];

elseif strcmp(n,'satlins')
  xx = [-10 10];
  yy = [0 0];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = [-10 -5 5 10];
  yy = [-10 -10 10 10];
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];

elseif strcmp(n,'tansig')
  xx = [-10 10];
  yy = [0 0];
  h1 = plot(xx*s+x,yy*s+y,'color',red,'linewidth',2,'erasemode','none');
  xx = -10:10;
  yy = tansig(xx/4)*10;
  h2 = plot(xx*s+x,yy*s+y,'color',yellow,'linewidth',2,'erasemode','none');
  hh = [h1;h2];
end

% RESTORE FIGURE STATE
set(ax,'nextplot',NPA);
set(fig,'nextplot',NPF);

% RETURN ICON
if nargout, h = [box_h; hh]; end
