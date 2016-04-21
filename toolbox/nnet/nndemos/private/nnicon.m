function nnicon(n,x,y,s,f)
%NNICON Icons for Neural Network Toolbox GUI.

%  NNICON(N,X,Y,S,F)
%    N - Name of icon.
%    X - Horizontal coordinate.
%    Y - Vertical coordinate.
%         S - Size.
%    F - Shadow box flag (default = 0).
%  Draws icon N at [X,Y] and with size S.
%
%  Here are the icon names:
%    'compet'     Competitive transfer function
%    'hardlim'    Hard limit transfer function
%    'hardlims'   Symmetric hard limit transfer function
%    'logsig'     Log sigmoid transfer function
%    'linear'     Linear transfer function
%    'purelin'    Linear transfer function
%    'radbas'     Radial basis transfer function
%    'satlin'     Saturating linear transfer function
%    'satlins'    Symmetric saturating linear transfer function
%    'sum'        Summation
%    'tansig'     Hyperbolic Tangent sigmoid transfer function

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 5, f = 0; else f = 1; end
if nargin < 4, s = 25; end
if nargin < 3, y = 0; end
if nargin < 2, x = 0; end
if nargin < 1, n = 'tansig'; end

NP = get(gca,'nextplot');
set(gca,'nextplot','add');
hold on

% SHADOW
rect_x = [-1 1 1 -1];
rect_y = [-1 -1 1 1];
if f
  shadow_h = fill(x+rect_x*s+4,y+rect_y*s-4,nndkgray,...
    'edgecolor','none',...
    'erasemode','none');
else
  shadow_h = [];
end

% ICON FRAME
frame_h1 = fill(x+rect_x*s,y+rect_y*s,red, ...
  'edgecolor','none', ...
  'erasemode','none');
frame_h2 = fill(x+rect_x*s*0.8,y+rect_y*s*0.8,blue, ...
  'edgecolor','none', ...
  'erasemode','none');

% COMPETITIVE

if strcmp(n,'compet')
  angle = [45:5:315] * pi/180;
  c_x = cos(angle);
  c_y = sin(angle);
  xx = [c_x*(s*17/25) fliplr(c_x)*(s*12/25)];
  yy = [c_y*(s*17/25) fliplr(c_y)*(s*12/25)];
  icon_h = patch(x+xx+2,y+yy,yellow,...
    'erasemode','none',...
    'edgecolor','none');

% HARD LIMIT

elseif strcmp(n,'hardlim')
  line_h1 = nnline(x+[-14 14],y+[-14 -14],3,red,'none');
  line_h2 = nnline(x+[-14 0 0 14],y+[-14 -14 14 14],4,yellow,'none');
  icon_h = [line_h1; line_h2];
  
% SYMMETRIC HARD LIMIT

elseif strcmp(n,'hardlims')
  line_h1 = nnline(x+[-14 14],y+[0 0],3,red,'none');
  line_h2 = nnline(x+[-14 0 0 14],y+[-14 -14 14 14],4,yellow,'none');
  icon_h = [line_h1; line_h2];

% LINEAR

elseif strcmp(n,'purelin') | strcmp(n,'linear')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[0 0],s*0.1,nnred)
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[-0.6 0.6],s*0.2,nnyellow)

% LOGSIG

elseif strcmp(n,'logsig')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[-0.6 -0.6],s*0.1,nnred)
  n = -5:(10/21):5;
  a = tansig(n);
  xx = n*0.6/5;
  yy = a*0.6;
  nndrwlin(x+sx*xx,y+sy*yy,s*0.2,nnyellow)

% RADIAL BASIS

elseif strcmp(n,'radbas')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[-0.6 -0.6],s*0.1,nnred)
  n = [-2.4 -2.3 -2.2 -2.1 -2 -1.8 -1.6 -1.3 -1 -0.7 -.5 -.4 -.3 -.2 -.1];
  n = [n 0 -fliplr(n)];
  a = radbas(n);
  xx = n*0.605/2.4;
  yy = a*1.2 - 0.6;
  nndrwlin(x+sx*xx(1:18),y+sy*yy(1:18),s*0.2,nnyellow)
  nndrwlin(x+sx*xx(16:31),y+sy*yy(16:31),s*0.2,nnyellow)

% SATURATING LINEAR

elseif strcmp(n,'satlin')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[-0.6 -0.6],s*0.1,nnred)
  nndrwlin(x+sx*[-0.6 -0.4 0.4 0.6],y+sy*[-0.6 -0.6 0.6 0.6],s*0.2,nnyellow)

% SYMMETRIC SATURATING LINEAR

elseif strcmp(n,'satlins')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[0 0],s*0.1,nnred)
  nndrwlin(x+sx*[-0.6 -0.4 0.4 0.6],y+sy*[-0.6 -0.6 0.6 0.6],s*0.2,nnyellow)
  
% SUM

elseif strcmp(n,'sum')
  xx = [0.600001 0.6 -0.4 0.2 -0.4 0.6 0.600001];
  yy = [0.4 0.6 0.6 0 -0.6 -0.6 -0.4];
  nndrwlin(x+sx*xx,y+sy*yy,s*0.2,nnyellow)

% TANSIG

elseif strcmp(n,'tansig')
  nndrwlin(x+sx*[-0.6 0.6],y+sy*[0 0],s*0.1,nnred)
  n = -5:(10/21):5;
  a = tansig(n);
  xx = n*0.6/5;
  yy = a*0.5;
  nndrwlin(x+sx*xx,y+sy*yy,s*0.2,nnyellow)

end
set(gca,'nextplot',NP);
