function hh = colordef(arg1,arg2)
%COLORDEF Set color defaults.
%   COLORDEF WHITE or COLORDEF BLACK changes the color defaults on the
%   root so that subsequent figures produce plots with a white or
%   black axes background color.  The figure background color is
%   changed to be a shade of gray and many other defaults are changed
%   so that there will be adequate contrast for most plots.
%
%   COLORDEF NONE will set the defaults to their MATLAB 4 values.
%   The most noticeable difference is that the axis background is set
%   to 'none' so that the axis background and figure background colors
%   are the same.  The figure background color is set to black.
%
%   COLORDEF(FIG,OPTION) changes the defaults of the figure FIG
%   based on OPTION.  OPTION can be 'white','black', or 'none'.
%   The figure must be cleared first (via CLF) before using this
%   variant of COLORDEF.
%
%   H = COLORDEF('new',OPTION) returns a handle to a new figure
%   created with the specified default OPTION.  This form of the
%   command is handy in GUI's where you may want to control the
%   default environment.  The figure is created with 'visible','off'
%   to prevent flashing.
%
%   See also WHITEBG.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 04:29:03 $


error(nargchk(1,2,nargin));

if nargin==1,
  fig = 0;
  option = arg1;
elseif nargin==2
  fig = arg1;
  option = arg2;
  if (fig ~= 0) & ~isstr(fig) & ~isempty(findobj(fig,'type','axes')),
     error('The figure must be cleared to use COLORDEF(FIG,OPTION).');
  end
end

if strcmp(fig,'new')
  fig = figure('visible','off');
end

switch option
case 'white'
  wdefault(fig)
case 'black'
  kdefault(fig)
case 'none'
  default4(fig)
otherwise
  error(sprintf('Unknown color default option: %s.',option))
end

if nargout>0, hh = fig; end

%----------------------------------------------------------
function kdefault(fig)
%KDEFAULT Black figure and axes defaults.
%   KDEFAULT sets up certain figure and axes defaults
%   for plots with a black background.
%
%   KDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[0 0 0])
if isunix 
   fc = [.35 .35 .35]; % On UNIX compensate for no gamma correction.
else
  fc = [.2 .2 .2];
end
if fig==0,
  set(fig,'defaultfigurecolor',fc)
else
  set(fig,'color',fc)
end
set(fig,'defaultaxescolor',[0 0 0])
set(fig,'defaultaxescolororder', ...
   1-[0 0 1;0 1 0;1 0 0;0 1 1;1 0 1;1 1 0;.25 .25 .25]) % ymcbgrw
if fig == 0
  cmap = 'defaultfigurecolormap';
else
  cmap = 'colormap';
end
set(fig,cmap,jet(64))
set(fig,'defaultsurfaceedgecolor',[0 0 0])

%------------------------------------------------------------
function wdefault(fig)
%WDEFAULT White figure and axes defaults.
%   KDEFAULT sets up certain figure and axes defaults
%   for plots with a white background.
%
%   WDEFAULT(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end

whitebg(fig,[1 1 1])
if fig==0,
  set(fig,'defaultfigurecolor',[.8 .8 .8])
else
  set(fig,'color',[.8 .8 .8])
end
set(fig,'defaultaxescolor',[1 1 1])
set(fig,'defaultaxescolororder', ...
    [0 0 1;0 .5 0;1 0 0;0 .75 .75;.75 0 .75;.75 .75 0;.25 .25 .25]) % bgrymck
if fig == 0
  cmap = 'defaultfigurecolormap';
else
  cmap = 'colormap';
end
set(fig,cmap,jet(64))
set(fig,'defaultsurfaceedgecolor',[0 0 0])

%----------------------------------------------------------------
function default4(fig)
%DEFAULT MATLAB version 4.0 figure and axes defaults.
%   DEFAULT4 sets certain figure and axes defaults to match what were
%   the defaults for MATLAB version 4.0.
%
%   DEFAULT4(FIG) only affects the figure with handle FIG.

if nargin==0, fig = 0; end
set(fig,'defaultaxescolor','none')
whitebg(fig,[0 0 0])
set(fig,'defaultaxescolororder',[1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1]) % ymcrgb
if fig == 0
  cmap = 'defaultfigurecolormap';
else
  cmap = 'colormap';
end
set(fig,cmap,hsv(64))
set(fig,'defaultsurfaceedgecolor',[0 0 0])
