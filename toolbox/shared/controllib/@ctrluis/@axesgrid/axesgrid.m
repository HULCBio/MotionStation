function h = axesgrid(gridsize,hndl,varargin)
% Returns instance of @axesgrid class
%
%   H = AXESGRID([M N],AXHANDLE) creates a M-by-N grid of subplots using the
%   axes handles supplied in AXHANDLE.  The subplot properties are inherited
%   from the first axes in AXHANDLE.  Additional axes are created if necessary.
%   
%   H = AXESGRID([M N MSUB NSUB],AXHANDLE) creates a M-by-N grid where each 
%   grid cell itself contains a MSUB-by-NSUB array of subplots (nested subplots).
%
%   H = AXESGRID([M N ..],FIGHANDLE) parents all the grid axes to the figure 
%   with handle FIGHANDLE.

%   Author: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:40 $

% Create @axes instance and initialize
h = ctrluis.axesgrid;
gridsize = [gridsize,ones(1,2*(length(gridsize)==2))];
h.Size = gridsize;

% Validate first input argument
if any(~ishandle(hndl))
    error('The second argument contains invalid handles.')
else
    hndl = handle(hndl);
end
if isa(hndl,'hg.figure')
    % Create axes
    Visibility = hndl.Visible;
    hndl = handle(axes('Parent',hndl,'Visible','off','ContentsVisible','off'));
    Position = hndl.Position;
elseif isa(hndl,'hg.axes')
    Visibility = hndl(1).Visible;
    Position = hndl(1).Position;
    % Hide axes, consistently with h.Visible=off initially
    set(hndl,'Visible','off','ContentsVisible','off')
else
    error('The second argument must be a figure handle or a vector of axes handles.')
end
GridState = hndl(1).XGrid;

% Size-independent settings
h.Parent = hndl(1).Parent;
h.AxesStyle = ctrluis.axesstyle(hndl(1));
h.UIContextMenu = uicontextmenu('Parent',h.Parent); 
h.Title = get(hndl(1).Title,'String');
h.XLabel = get(hndl(1).XLabel,'String');
h.YLabel = get(hndl(1).YLabel,'String');
hTitle = hndl(1).Title;
hXLabel = hndl(1).XLabel;
hYLabel = hndl(1).YLabel;
h.TitleStyle = ctrluis.labelstyle(hTitle);
h.XLabelStyle = ctrluis.labelstyle(hXLabel);
h.YLabelStyle = ctrluis.labelstyle(hYLabel);
if gridsize(4)==1 
   h.XUnits = ''; 
else 
   h.XUnits = repmat({''},[gridsize(4) 1]); 
end    
if gridsize(3)==1 
   h.YUnits = ''; 
else 
   h.YUnits = repmat({''},[gridsize(3) 1]); 
end 
h.XUnits = repmat({''},[gridsize(4) 1]);
h.YUnits = repmat({''},[gridsize(3) 1]);
h.XScale = hndl(1).XScale;
h.YScale = hndl(1).YScale;
h.ColumnVisible = repmat({'on'},[gridsize(2)*gridsize(4) 1]);
h.ColumnLabelStyle = ctrluis.labelstyle(hTitle);
h.ColumnLabelStyle.Color = h.AxesStyle.XColor;
h.ColumnLabelStyle.FontSize = h.AxesStyle.FontSize;
h.ColumnLabelStyle.Location = 'top';
h.RowVisible = repmat({'on'},[gridsize(1)*gridsize(3) 1]);
h.RowLabelStyle = ctrluis.labelstyle(hTitle);
h.RowLabelStyle.Color = h.AxesStyle.YColor;
h.RowLabelStyle.FontSize = h.AxesStyle.FontSize;
h.RowLabelStyle.Location = 'left';
h.Position = Position; % RE: may be overwritten by SET below
h.LimitFcn = {@updatelims h};  % install default limit picker
h.LabelFcn = {@DefaultLabelFcn h};

% Turn DoubleBuffer=on to eliminate flashing with grids, labels,...
set(h.Parent,'DoubleBuffer','on')

% Size-dependent settings
initialize(h,hndl)

% Background axes (create last so that SUBPLOT does not pick it first)
h.BackgroundAxes = axes('Parent',h.Parent,'Visible','off','HandleVisibility','off',...
   'Xlim',[0 1],'Ylim',[0 1],'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],...
   'Position',Position);
Labels = get(h.BackgroundAxes,{'Title','XLabel','YLabel'});
set([Labels{:}],'HorizontalAlignment','center','HitTest','off',...
   'Units','pixel')   % to facilitate position adjustment

% User-defined properties
% RE: Maintain h.Visible=off in order to bypass all layout/visibility computations
% (achieved by removing Visible settings from prop/value list and factoring them into
%  the VISIBILITY variable)
[Visibility,varargin] = utGetVisibleSettings(h,Visibility,varargin);
h.set('Grid',GridState,varargin{:});

% Set visibility (if Visibility=on, this initializes the position/visibility of the HG axes)
h.Visible = Visibility;

% Activate limit manager 
addlimitmgr(h)
