function h = axes(hndl,varargin)
% Returns instance of @axes class
%
%   H = AXES(AXHANDLE) creates an @axes instance associated with the
%   HG axes AXHANDLE. 
%
%   H = AXES(FIGHANDLE) automatically creates the HG axes and parents 
%   them to the figure with handle FIGHANDLE.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:25 $

% Create @axes instance 
h = ctrluis.axes;
h.Size = [1 1 1 1];

% Validate first input argument
if prod(size(hndl))~=1 | ~ishandle(hndl)
    error('The first argument must be a single, valid handle.')
else
    hndl = handle(hndl);
end
if isa(hndl,'hg.figure')
    % Create axes
    Visibility = hndl.Visible;
    hndl = handle(axes('Parent',hndl,'Visible','off','ContentsVisible','off'));
    Position = hndl.Position;
elseif isa(hndl,'hg.axes')
    Visibility = hndl.Visible;
    Position = hndl.Position;
    % Hide axes, consistently with h.Visible=off initially
    set(hndl,'Visible','off','ContentsVisible','off')  
else
    error('The first argument must be a figure or axes handle.')
end
GridState = hndl(1).XGrid;

% Create and initialize axes array
% RE: h.Axes not used
h.Axes4d = hndl;  % array of HG axes of size GRIDSIZE
h.Axes2d = hndl;
h.Parent = hndl.Parent;
h.AxesStyle = ctrluis.axesstyle(hndl);
h.UIContextMenu = uicontextmenu('Parent',h.Parent); 

% Settings inherited from template axes
h.XLimMode = hndl.XLimMode;
h.XScale = hndl.XScale;
h.YLimMode = hndl.YLimMode;
h.YScale = hndl.YScale;
h.NextPlot = hndl.NextPlot;

% Turn DoubleBuffer=on to eliminate flashing with grids, labels,...
set(h.Parent,'DoubleBuffer','on')

% Configure axes
set(h.Axes2d,'Units','normalized','Box','on',...
   'XtickMode','auto','YtickMode','auto',...
   'Xlim',hndl.Xlim,'Ylim',hndl.Ylim,...
   'NextPlot',hndl.NextPlot,'UIContextMenu',h.UIContextMenu,...
   'XGrid','off','YGrid','off',struct(h.AxesStyle));

% Initialize properties
% RE: no listeners installed yet
h.Title = get(hndl.Title,'String');
h.XLabel = get(hndl.XLabel,'String');
h.XUnits = '';
h.YLabel = get(hndl.YLabel,'String');
h.YUnits = '';
h.TitleStyle = ctrluis.labelstyle(hndl.Title);
h.XLabelStyle = ctrluis.labelstyle(hndl.XLabel);
h.YLabelStyle = ctrluis.labelstyle(hndl.YLabel);
h.Position = Position; % RE: may be overwritten by SET below
h.LimitFcn = {@updatelims h};  % install default limit picker
h.LabelFcn = {@DefaultLabelFcn h};

% Add listeners
h.addlisteners;

% User-defined properties
% RE: Maintain h.Visible=off in order to bypass all layout/visibility computations
% (achieved by removing Visible settings from prop/value list and factoring them into
%  the VISIBILITY variable)
[Visibility,varargin] = utGetVisibleSettings(h,Visibility,varargin);
h.set('Grid',GridState',varargin{:});

% Set visibility (if Visibility=on, this initializes the position/visibility of the HG axes)
h.Visible = Visibility;

% Activate limit manager 
addlimitmgr(h);
