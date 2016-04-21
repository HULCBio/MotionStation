function h = nndicon(c,x,y,f,s)
%NNDICON Icons for Neural Network Design GUI.

% NNDICON(C,'book')
%   C - Chapter number from Neural Network Design textbook.
% Draws the icon for chapter C.
%
% NNDICON(C,X,Y,F,S)
%   X - Horizontal position.
%   Y - Vertical position.
%   F - Shadow box flag (default = 0).
%   S - Size (optional).
% Draws the icon for chapter C at position (X,Y) with size S.
% If F is nonzero, then the icon casts a shadow.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% Mark Beale 6-4-94
% $Revision: 1.6 $

% DEFAULTS
visible = 'on';
book = 0;
mini = 0;
if nargin == 0, error('Not enough input arguments.'); end
if nargin < 4, f = 0; else f = 1; end
if nargin < 3, y = 0; end
if nargin < 2, x = 0; mini = 1; end
if nargin == 2,if isstr(x)
  if strcmp(lower(x),'invisible'), visible = 'off'; else book = 1; end
  x = 0; mini = 1;
end, end

% FIGURE
if mini
  pos = get(0,'defaultfigureposition');
  fig = figure(...
    'units','points',...
    'pos',[pos(1) (pos(2)+pos(4)-60) 60 60],...
    'resize','off',...
    'number','off',...
    'name','',...
    'colormap',nncolor,...
    'visible',visible);
  set(gca,...
    'units','points',...
    'pos',[0 0 60 60],...
    'xlim',[-30 29.9],...
    'ylim',[-30 29.9],...
    'nextplot','add')
  axis('equal')
  axis('off')
else
  fig = gcf;
end

% COLORS
if book
  red = [1 1 1]*0.5;
  blue = [0 0 1]*0.5;
  yellow = [1 1 1];
  orange = [1 1 1]*0.5;
else
  red = nnred;
  blue = nndkblue;
  yellow = nnyellow;
  orange = [1 0.5 0];
end

% STORE FIGURE STATE
NPF = get(fig,'nextplot');
NPA = get(gca,'nextplot');
set(fig,'nextplot','add');
set(gca,'nextplot','add');
hold on

% SHADOW
rect_x = [-1 1 1 -1];
rect_y = [-1 -1 1 1];
if f
  shadow_h = fill(x+rect_x*25+4,y+rect_y*25-4,nndkgray,...
    'edgecolor','none',...
    'erasemode','none');
else
  shadow_h = [];
end

% ICON FRAME
frame_h1 = fill(x+rect_x*25,y+rect_y*25,red, ...
  'edgecolor','none', ...
  'erasemode','none');
frame_h2 = fill(x+rect_x*20,y+rect_y*20,blue, ...
  'edgecolor','none', ...
  'erasemode','none');

% CHAPTER 0: TOC
if c == 0
  icon_h = [];

% CHAPTER 1: INTRO
elseif c == 1
  icon_h = [];

% CHAPTER 2: ARCHITECTURES
elseif c == 2
  line_h1 = nnline(x+[10 9 8 8],y+[8 7 6 -14],4,yellow,'none');
  line_h2 = nnline(x+[-10 -9 -8 -8],y+[8 7 6 -14],4,yellow,'none');
  line_h3 = nnline(x+[14 -14],y+[14 14],4,yellow,'none');
  line_h4 = nnline(x+[0 0],y+[8 -14],4,yellow,'none');
  icon_h = [line_h1; line_h2; line_h3; line_h4];

% CHAPTER 3: ILLUSTRATIVE EXAMPLE
elseif c == 3
  orange_x = [5 0 0 5 10 15 15 10]-7+x;
  orange_y = [15 10 5 0 0 5 10 15]-7+y;
  apple_x = [7.5 5 0 0 5 7.5 10 15 15 10]-7+x;
  apple_y = [13 15 10 5 0 2 0 5 10 15]-7+y;

  orange = fill(orange_x-11, orange_y+7,orange,...
    'edgecolor',yellow,...
    'linewidth',2,...
    'erasemode','none');
  apple = fill(apple_x+8, apple_y-7,red,...
    'edgecolor',yellow,...
    'linewidth',2,...
    'erasemode','none');
  slash = nnline(x+[-14 14],y+[-14 14],1,red,'none');
  icon_h = [orange; apple; slash];

% CHAPTER 4: PERCEPTRONS
elseif c == 4
  line_h1 = nnline(x+[-14 14],y+[-14 -14],3,red,'none');
  line_h2 = nnline(x+[-14 0 0 14],y+[-14 -14 14 14],4,yellow,'none');
  icon_h = [line_h1; line_h2];

% CHAPTER 5: SIGNAL AND WEIGHT VECTOR SPACES
elseif c == 5
  vec_h1 = nnarrow(x+[-14 14],y+[-14 14],2,yellow,'none');
  %vec_h2 = nnarrow(x+[-14 2],y+[-14 14],2,yellow,'none');
  icon_h = [vec_h1];

% CHAPTER 6: LINEAR TRANSFORMATIONS
elseif c == 6
  angle = [10:2:80]*pi/180;
  circle_x = cos(angle);
  circle_y = sin(angle);
  patch_h1 = patch(x-14+20*circle_x,y-14+20*circle_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h2 = patch(x-14+18*circle_x,y-14+18*circle_y,blue,...
    'erasemode','none',...
    'edgecolor','none');
  vec_h1 = nnarrow(x+[-14 14],y+[-14 -7],2,yellow,'none');
  vec_h2 = nnarrow(x+[-14 -7],y+[-14 14],2,yellow,'none');

  icon_h = [patch_h1; patch_h2; vec_h1; vec_h2];

% CHAPTER 7: SUPERVISED HEBB
elseif c == 7
  half_angle = [90:2.5:270]*pi/180;
  half_x = cos(half_angle)*8;
  half_y = sin(half_angle)*8;
  line_h1 = nnline(x+[-15 -5],y+[0 0],3,yellow,'none');
  line_h2 = nnline(x+[5 15],y+[0 0],3,yellow,'none');
  half_h1 = patch(x+half_x-2,y+half_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  half_h2 = patch(x-half_x+2,y+half_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  icon_h = [line_h1; line_h2; half_h1; half_h2];

% CHAPTER 8: SURFACES AND MINIMA
elseif c == 8
  angle = [0:10:360]*pi/180;
  circle_x = cos(angle);
  elipse_y = sin(angle);
  elipse_x = circle_x + elipse_y*0.4;
  patch_h1 = patch(x-15*elipse_x,y+15*elipse_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h2 = patch(x-11*elipse_x,y+11*elipse_y,blue,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h3 = patch(x+3*circle_x,y+3*elipse_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  icon_h = [patch_h1; patch_h2; patch_h3];
  
% CHAPTER 9: OPTIMIZATION
elseif c == 9
  angle = [0:10:360]*pi/180;
  circle_x = cos(angle);
  elipse_y = sin(angle);
  elipse_x = circle_x + elipse_y*0.4;
  patch_h1 = patch(x-14*elipse_x,y+14*elipse_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h2 = patch(x-11.8*elipse_x,y+11.8*elipse_y,blue,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h3 = patch(x-8*elipse_x,y+8*elipse_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h4 = patch(x-6*elipse_x,y+6*elipse_y,blue,...
    'erasemode','none',...
    'edgecolor','none');
  patch_h5 = patch(x+3*circle_x,y+3*elipse_y,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  line_h = nnline(x+[-20 -16 -14 -10 -5 0],y+[8 10 10 8 4 0],2,red,'none');
  icon_h = [patch_h1; patch_h2; patch_h3; patch_h4; patch_h5; line_h];
  
% CHAPTER 10: LINEAR NETWORKS
elseif c == 10
  t=0:.05*2*pi:2*pi;
  yy=30*exp(-0.4*t).*sin(t);
  xx=1:length(yy);
  xx=30*xx/length(yy)-15;
  line_h1 = nnline(x+[-14 14],y+[0 0],2,red,'none');
  line_h2 = nnline(x+xx,y+yy,2,yellow,'none');
  icon_h = [line_h1; line_h2];

% CHAPTER 11: BACKPROPAGATION

elseif c == 11
  line_h1 = nnline(x+[-14 14],y+[0 0],3,red,'none');
  n = -5:0.25:5;
  a = 2./(1+exp(-2*n))-1;
  xx = n/5*15;
  yy = a/1*15;
  line_h2 = nnline(x+xx,y+yy,4,yellow,'none');
  icon_h = [line_h1; line_h2];

% CHAPTER 12: VARIATIONS ON BACKPROPAGATION

elseif c == 12
  patch_h1 = patch(x+1+[-17 -10 -4 0 14 0 -4],...
                   y+[11 16 0 8 -15 -2 -7],yellow,...
    'erasemode','none',...
    'edgecolor','none');
  icon_h = [patch_h1];

% CHAPTER 13: ASSOCIATIVE LEARNING RULES

elseif c == 13
  radius = 6.5;
  angle = [0:10:360]*pi/180;
  full_x = cos(angle)*radius;
  full_y = sin(angle)*radius;
  half_angle = [90:10:270]*pi/180;
  half_x = cos(half_angle)*radius;
  half_y = sin(half_angle)*radius;

  line_h1 = nnline(x+[-15 -8],y+[-5 -5],4,yellow,'none');
  half_h1 = patch(x+half_x-6,y+half_y-5,yellow,...
    'erasemode','none',...
    'edgecolor','none');

  line_h2 = nnline(x+[6 15],y+[-5 -5],4,yellow,'none');
  full_h2 = patch(x-full_x+3,y+full_y-5,yellow,...
    'erasemode','none',...
    'edgecolor','none');

  line_h3 = nnline(x+[3 3],y+[15 7],4,yellow,'none');
  half_h3 = patch(x-half_y+3,y-half_x+5,yellow,...
    'erasemode','none',...
    'edgecolor','none');

  icon_h = [line_h1; line_h2; line_h3; half_h1; full_h2; half_h3];

% CHAPTER 14: COMPETITIVE

elseif c == 14
  angle = [0:20:360] * pi/180;
  cx = cos(angle);
  cy = sin(angle);
  paddle1 = patch(x-11+6*cx,y+4+6*cy,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  paddle2 = patch(x+11+6*cx,y+4+6*cy,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  handle1 = patch(x+[-13 -10 -5 -8],y+[4 5 -5 -6],yellow,...
    'erasemode','none',...
    'edgecolor','none');
  handle2 = patch(x+[13 10 5 8],y+[4 5 -5 -6],yellow,...
    'erasemode','none',...
    'edgecolor','none');
  ball = patch(x+2*cx,y+5+2*cy,yellow,...
    'erasemode','none',...
    'edgecolor','none');

  icon_h = [paddle1; paddle2; handle1; handle2; ball;];

% CHAPTER 15: GROSSBERG

elseif c == 15
  angle = [0:10:360] * pi/180;
  cx = cos(angle);
  cy = sin(angle);
  eyeball = plot(x+15*cx,y+15*cy,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');
  angle = [120:10:250] * pi/180;
  cx = cos(angle);
  cy = sin(angle);
  iris = plot(x+15+8.7*cx,y+8.7*cy,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');
  angle = [135 180 215] * pi/180;
  cx = cos(angle);
  cy = sin(angle);
  for i=1:3
    iris = [iris; plot(x+15+cx(i)*[0 8.7],y+cy(i)*[0 8.7],...
      'color',yellow,...
      'linewidth',1,...
      'erasemode','none')];
  end
  pupil = plot(x+15+3*cx,y+2*cy,...
    'color',yellow,...
    'linewidth',3,...
    'erasemode','none');
  icon_h = [eyeball; iris; pupil];

% CHAPTER 16: ART

elseif c == 16

  angle = [0:10:360] * pi/180;
  scale1 = [0.8 0.85 0.9 0.95 1.0  1.0 0.95 0.9 0.85 0.85];
  scale2 = scale1(9:-1:1);
  scale3 = [0.75 0.7 0.65 0.65 0.65 0.675 0.725 0.8 0.9];
  scale4 = fliplr(scale3);
  scale = 1.25*[scale1 scale2 scale3 scale4];
  cx = scale.*cos(angle);
  cy = scale.*sin(angle);
  face = plot(x+15*cx,y+15*cy,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');

  cx = cos(angle);
  cy = 0.5*sin(angle);
  eye1 = plot(x-8+4*cx,y+10+4*cy,...
    'color',yellow,...
    'linewidth',1,...
    'erasemode','none');

  cx = cos(angle);
  cy = 0.5*sin(angle);
  rotate = [.707 -.707; .707 .707];
  ctot = rotate*[cx; cy];
  cx = ctot(1,:);
  cy = ctot(2,:);
  eye2 = plot(x+8+4*cx,y+8+4*cy,...
    'color',yellow,...
    'linewidth',1,...
    'erasemode','none');

  cx = cos(angle);
  cy = 0.5*sin(angle);
  rotate = [.707 .707; -.707 .707];
  ctot = rotate*[cx; cy];
  cx = ctot(1,:);
  cy = ctot(2,:);
  mouth = plot(x-2+4*cx,y-9+4*cy,...
    'color',yellow,...
    'linewidth',1,...
    'erasemode','none');

  nose = nnline(x+[-1 0 1   0 -2 -4  0  2  3], ...
                y+[9  6 4.5 3 -1 -3 -3 -4 -6],1,yellow,'none');

  icon_h = [face; eye1; eye2; mouth; nose];

% CHAPTER 17: STABILITY

elseif c == 17

  angle = [0:10:180] * pi/180;
  hillx = cos(angle);
  hilly = sin(angle);
  hill = plot(x+hillx*15,y+hilly*25-15,...
    'color',yellow,...
    'linewidth',3,...
    'erasemode','none');
  angle = [0:20:360] * pi/180;
  circx = cos(angle);
  circy = sin(angle);
  ball = patch(x+3*circx,y+14+3*circy,yellow,...
    'erasemode','none',...
    'edgecolor','none');
  icon_h = [hill; ball];

% CHAPTER 18: HOPFIELD

elseif c == 18

  xx = [0 0 -12 0 0 0 12 0];
  yy = [15 10 10 -10 -15 -10 10 10];
  triangle = plot(x+xx,y+yy,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');
  angle = [0:20:360] * pi/180;
  xx = cos(angle);
  yy = sin(angle);
  circle = plot(x-5+xx*3,y-6+yy*3,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');
  xx = [-5 -5];
  yy = [-9 -15];
  line = plot(x+xx,y+yy,...
    'color',yellow,...
    'linewidth',2,...
    'erasemode','none');

  icon_h = [triangle; circle; line];

% ICON 100: SUMMATION
elseif c == 100
  line_h1 = nnline(x+[10 -10 4 -10 10],y+[14 14 0 -14 -14],3,yellow,'none');

  icon_h = [line_h1];

% ICON 101: F
elseif c == 101
  line_h1 = nnline(x+[10 -10 -10 10],y+[14 14 0 0],4,yellow,'none');
  line_h2 = nnline(x+[-10 -10],y+[0 -14],4,yellow,'none');
  icon_h = [line_h1; line_h2];

end

% BOOK STUFF
if book
  axis('off')
  axis('equal')
  set(gcf,'color',[1 1 1])
  set(gcf,'inverthardcopy','off')
end

% RESTORE FIGURE STATE
set(gca,'nextplot',NPA);
set(fig,'nextplot',NPF);

% RETURN ICON
if nargout, h = [shadow_h; frame_h1; frame_h2; icon_h]; end
