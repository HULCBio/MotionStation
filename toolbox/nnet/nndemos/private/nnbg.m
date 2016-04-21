function fig = nnbg(n,r)
%NNBG Neural Network Design utility function.

%  NNBG(N,R)
%    N - Window name (default = figure #).
%    R - Rectangle without tf names (default = none).
%    Returns handle to new figure.
%
%  NNBG stores the following handles:
%    H(1) = Axis covering entire figure in pixel coordinates.
%    Where H is the user data of the demo figure.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $ $Date: 2002/04/14 21:20:49 $

% NEW FIG
fig = figure('visible','off');

% make this backwards compatible (doublebuffer was new in MATLAB 5.2)
try
    set(fig,'DoubleBuffer','on')
catch
end

% GET SCREEN SIZE
su = get(0,'units');
set(0,'units','points');
ss = get(0,'ScreenSize');
set(0,'units',su);
left = ss(1);
bottom = ss(2);
width = ss(3);
height = ss(4);

% CENTER FIGURE ON SCREEN
fig_x = 500;
fig_y = 400;
pos = [(width-fig_x)/2+left, (height-fig_y)/2+bottom, fig_x fig_y];

% MAKE SURE TOP LEFT CORNER IS ON SCREEN
% IF SCREEN IS TOO SMALL FOR WINDOW.
if (width < fig_x)
  pos(1) = 5;
end
if (height < fig_y)
  pos(2) = bottom+height-fig_y-40;
end

% CREATE THE FIGURE
if nargin == 0
  n = '';
end
set(fig,...
  'units','points',...
  'position',pos,...
  'resize','off', ...
  'color',nnltgray, ...
  'inverthardcopy','off', ...
  'nextplot','add',...
  'name',n,...
  'numbertitle','off');

% FIGURE AXIS
fig_axis = axes(...
  'visible','off',...
  'units','points', ...
  'position',[0 0 fig_x fig_y],...
  'xlim',[0 fig_x],'ylim',[0 fig_y],...
  'nextplot','add');

% BORDER LINE
plot([0 0 500 500 0],[0 399 399 0 0],'color',nnblack)

% SAVE HANDLES AND LOCK FIGURE
set(fig,...
  'userdata',[fig_axis],...
  'handlevisibility','callback')
hidegui(fig)

