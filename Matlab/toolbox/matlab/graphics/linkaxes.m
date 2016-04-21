function linkaxes(ax,option)
%LINKAXES Synchronize limits of specified axes
%  Use LINKAXES to synchronize the individual axis limits
%  on different subplots within a figure. This is useful
%  when you want to zoom or pan in one subplot and display 
%  the same range of data in another subplot.
%
%  LINKAXES 
%  Links the x and y-axis limits for all axes (i.e. all 
%  subplots) in the current figure.
%
%  LINKAXES(AX) Links x and y-axis limits of the axes specified
%  in AX.
%
%  LINKAXES(AX,OPTION) Links the axes AX according to the 
%  specified option. The option argument can be one of the 
%  following strings: 
%        'x'   ...link x-axis only
%        'y'   ...link y-axis only
%        'xy'  ...link x-axis and y-axis
%        'off' ...remove linking
%
%  See the LINKPROP function for more advanced capabilities 
%  that allows linking object properties on any graphics object.
%
%  Example (Linked Zoom & Pan):
%
%  ax(1) = subplot(2,2,1);
%  plot(rand(1,10)*10,'Parent',ax(1));
%  ax(2) = subplot(2,2,2);
%  plot(rand(1,10)*100,'Parent',ax(2));
%  linkaxes(ax,'x');
%  % Interactively zoom and pan to see link effect
%
%  See also LINKPROP, ZOOM, PAN.

% Copyright 2003 The MathWorks, Inc.

if nargin==0
    fig = get(0,'CurrentFigure');
    if isempty(fig), return; end
    ax = findobj(fig,'Type','Axes');
    nondatachild = logical([]);
    for k=length(ax):-1:1
      nondatachild(k) = isappdata(ax(k),'NonDataObject');
    end
    ax(nondatachild) = [];
    option = 'xy';
    
elseif nargin==1
    option = 'xy';
end

h = handle(ax);
if ~all(ishandle(h)) || ~all(isa(h,'hg.axes'))
    error('Matlab:graphics:linkaxes','First input argument must be axes handles');
end

% Remove any prior links to input handles
localRemoveLink(ax)

% Flush graphics queue so that all axes
% are forced to update their limits. Otherwise,
% calling XLimMode below may get the wrong axis limits
drawnow;

% Create new link
switch option
    case 'x'
        set(ax,'XLimMode','manual','YLimMode','manual');
        hlink = linkprop(ax,'XLim');
    case 'y'
        set(ax,'XLimMode','manual','YLimMode','manual');
        hlink = linkprop(ax,'YLim');
    case 'xy'
        set(ax,'XLimMode','manual','YLimMode','manual');
        hlink = linkprop(ax,{'XLim','YLim'});
    case 'off'
        hlink = [];
end

KEY = 'graphics_linkaxes';
setappdata(ax(1),KEY,hlink);

%--------------------------------------------------%
function localRemoveLink(ax)

KEY = 'graphics_linkaxes';

for n = 1:length(ax)
  % Remove this handle from previous link object
  hlink = getappdata(ax(n),KEY);
  if ~isempty(hlink) && ishandle(hlink)
      removetarget(hlink,ax(n));
  end
end

% Deletion of link object will occur implicitly 
% when no more handles reference the link object
