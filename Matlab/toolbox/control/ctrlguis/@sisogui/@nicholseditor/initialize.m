function initialize(Editor, Preferences)
%INITIALIZE  Initializes Nichols Plot Editor.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Revised: K. Subbarao 12-6-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.40 $ $Date: 2002/04/10 05:04:24 $

% Initialize preference-driven properties
Editor.FrequencyUnits = Preferences.FrequencyUnits;
Editor.ShowSystemPZ   = Preferences.ShowSystemPZ;
MenuAnchor = Editor.MenuAnchors;

% Render editor
LocalRender(Editor,Preferences,MenuAnchor);
Axes = Editor.Axes;

% Add generic listeners
Editor.addlisteners;

% Add Nichols-specific listeners
% Visibility
L1 = [handle.listener(Editor, Editor.findprop('MarginVisible'), ...
      'PropertyPostSet', @LocalSetMarginVis); ...
      handle.listener(Editor, Editor.findprop('ShowSystemPZ'), ...
      'PropertyPostSet', @LocalSetPZVis)];
set(L1,'CallbackTarget',Editor)
% Change in phase units (@axes throws DataChanged event)
L2 = handle.listener(Axes, 'DataChanged', {@LocalPostSetUnits Editor});

Editor.Listeners = [Editor.Listeners; L1 ; L2];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Initialize Nichols plot HG
% ----------------------------------------------------------------------------%
function LocalRender(Editor, Prefs, MenuAnchor)

% Get handle to host figure
SISOfig = Editor.root.Figure;
Zlevel = Editor.zlevel('backgroundline');

% Nichols Plot axes
PlotAxes = axes(...
   'Parent', SISOfig, ...
   'Units', 'norm', ...
   'Box', 'on', ...
   'Visible', 'off', ...
   'Xlim', round(unitconv([-360, 0], 'deg', Prefs.PhaseUnits)), ...
   'Ylim', [-40,40], ...
   'HelpTopicKey', 'sisonicholsplot', ...
   'ButtonDownFcn', {@LocalButtonDown Editor});
Editor.setdefaults(Prefs,PlotAxes)

% Grid options
GridOptions = gridopts('nichols');
GridOptions.Zlevel = Zlevel;

% Create @axes wrapper
% RE: Set limit modes to manual for proper limit conversion when changing units before loading data
Editor.Axes = ctrluis.axes(PlotAxes,...
   'Title','Open-Loop Nichols Editor (C)',...
   'XLabel',sprintf('Open-Loop Phase'),...
   'YLabel',sprintf('Open-Loop Gain (dB)'),...
   'XUnits', Prefs.PhaseUnits, ...
   'XlimSharing','all',...
   'YlimSharing','all',...
   'Grid',Prefs.Grid,...
   'GridFcn',{@LocalPlotGrid Editor},...
   'GridOptions',GridOptions,...
   'LimitFcn',  {@updatelims Editor}, ...
   'LayoutManager','off',...
   'EventManager',Editor.EventManager);

% Horizontal (0 dB) Line
XYdata = infline(-Inf,Inf);
npts = length(XYdata);
AxisLine = line(XYdata,zeros(1,npts),Zlevel(:,ones(1,npts)),...
   'XlimInclude','off','YlimInclude','off','HitTest', 'off', ...
   'Color', Prefs.AxesForegroundColor,'LineStyle', '-.', ...
   'Parent', PlotAxes);
set(AxisLine, 'UserData', ...
   [handle.listener(Editor,Editor.findprop('LabelColor'),...
      'PropertyPostSet', {@LocalSetColor AxisLine});...
   handle.listener(Editor.Axes,Editor.Axes.findprop('Grid'),...
      'PropertyPostSet', {@LocalSetVisible AxisLine})]);

% Build right-click menu
U = Editor.Axes.UIContextMenu;
LocalCreateMenus(Editor, U, 1);
set(get(U, 'children'), 'Enable', 'off')

% Replicate menus in main figure
LocalCreateMenus(Editor, MenuAnchor, 0);

% Create shadow line specifying portion of Nichols plot to be included in limit picking
% REVISIT: could be incorporated in NicholsPlot as XlimIncludeData
NicholsShadow = line(NaN,NaN,...
   'Parent',PlotAxes, ...
   'LineStyle','none',...
   'HitTest','off',...
   'HandleVisibility','off');

% Build structure of HG handles
Editor.HG = struct(...
   'Compensator', [], ...
   'Margins', [], ...
   'NicholsPlot', [], ...
   'NicholsShadow', NicholsShadow,...
   'System', []);


% ----------------------------------------------------------------------------%
% Plot nichols chart
% ----------------------------------------------------------------------------%
function GridHandles = LocalPlotGrid(Editor)
% Plots Nichols chart
GridHandles = Editor.Axes.plotgrid('ngrid');


% ----------------------------------------------------------------------------%
% Builds right-click menus
% ----------------------------------------------------------------------------%
function LocalCreateMenus(Editor, MenuAnchor, EditFlag)

% Edit pole/zero group
Editor.addmenu(MenuAnchor, 'add');
Editor.addmenu(MenuAnchor, 'delete');

% Menu item "edit" only in right-click menu
if EditFlag
   Editor.addmenu(MenuAnchor, 'edit');
end

% Show menu (Nichols-specific)
h = Editor.nicholsmenu(MenuAnchor, 'show');
set(h, 'Separator', 'on')

% Design Constraints/Grid/Zoom
h = [Editor.addmenu(MenuAnchor, 'constraint'); ...
      Editor.addmenu(MenuAnchor, 'grid')];
set(h(1), 'Separator', 'on');
set(h(end), 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
   h = Editor.addmenu(MenuAnchor, 'property');
   set(h, 'Separator', 'on')
end


% ----------------------------------------------------------------------------%
% Button down callbacks
% ----------------------------------------------------------------------------%
function LocalButtonDown(hSrc, event, Editor)
Editor.mouseevent('bd',hSrc);


% ----------------------------------------------------------------------------%
% Function: LocalSetColor
% ----------------------------------------------------------------------------%
function LocalSetColor(hSrc,event, AxisLine)
set(AxisLine, 'Color', event.NewValue)


% ----------------------------------------------------------------------------%
% Function: LocalSetVisible
% ----------------------------------------------------------------------------%
function LocalSetVisible(hSrc,eventdata, AxisLine)
if strcmp(eventdata.NewValue,'on')
   set(AxisLine, 'Visible', 'off')
else
   set(AxisLine, 'Visible', 'on')
end


% ----------------------------------------------------------------------------%
% Toggle margin visibility
% ----------------------------------------------------------------------------%
function LocalSetMarginVis(Editor, event)
% Callback when toggling MarginVisible state
% Update visibility of margin objects
if ~isempty(Editor.HG.Margins)
   MarginHandles = struct2cell(Editor.HG.Margins);
   set([MarginHandles{:}],'Visible',Editor.MarginVisible)
end
% Update margin display
showmargin(Editor)
% Refresh limits
updateview(Editor)


% ----------------------------------------------------------------------------%
% Toggle visibility of system poles and zeros
% ----------------------------------------------------------------------------%
function LocalSetPZVis(Editor, event)
if ~strcmp(Editor.EditMode, 'off') & strcmp(Editor.Visible, 'on')
   HG = Editor.HG;
   if strcmp(event.NewValue, 'off')
      set(HG.System, 'Visible', 'off')
   else
      set(HG.System, 'Visible', Editor.Visible)
   end
end


% ----------------------------------------------------------------------------%
% Called when changing units
% ----------------------------------------------------------------------------%
function LocalPostSetUnits(hProp,eventdata,Editor)
% Update labels
setlabels(Editor.Axes);
% Redraw plot 
update(Editor)