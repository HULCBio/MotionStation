function initialize(Editor,Preferences)
%INITIALIZE  Initializes Root Locus Editor.

%   Author(s): P. Gahinet
%   Revised  : K. Subbarao 12-6-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.42 $ $Date: 2002/04/10 04:57:44 $

% Initialize preference-driven properties
Editor.FrequencyUnits = Preferences.FrequencyUnits;
MenuAnchor = Editor.MenuAnchors;

% Render editor
LocalRender(Editor,Preferences,MenuAnchor);

% Add generic listeners
Editor.addlisteners;

% Add root-locus-specific listeners
p = [Editor.findprop('AxisEqual');...
    Editor.findprop('FrequencyUnits');...
    Editor.findprop('GridOptions')];
L = handle.listener(Editor,p,'PropertyPostSet',@updateview);
L.CallbackTarget = Editor;
Editor.Listeners = [Editor.Listeners ; L];


%---------------- Local Functions ------------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalRender %%%
%%%%%%%%%%%%%%%%%%%
function LocalRender(Editor,Preferences,MenuAnchor)

SISOfig = Editor.root.Figure; % host figure
Zlevel = Editor.zlevel('backgroundline');

% Plot axes
PlotAxes = axes(...
    'Parent',SISOfig,...
    'Units','norm', ...
    'Visible','off', ...
    'Xlim',[-1,1], ...
    'Ylim',[-1 1],...
    'Box','on',...
    'HelpTopicKey','sisorootlocusplot',...
    'ButtonDownFcn',{@LocalButtonDown Editor});
Editor.setdefaults(Preferences,PlotAxes)

% Grid options
GridOptions = gridopts('pzmap');
GridOptions.Zlevel = Zlevel;

% Create @axes wrapper
Editor.Axes = ctrluis.axes(PlotAxes,...
   'Title','Root Locus Editor (C)',...
   'XLabel','Real Axis',...
   'YLabel','Imag Axis',...
   'XlimSharing','all',...
   'YlimSharing','all',...
   'Grid',Preferences.Grid,...
   'GridFcn',{@LocalPlotGrid Editor},...
   'GridOptions',GridOptions,...
   'LimitFcn',  {@updatelims Editor}, ...
   'LayoutManager','off',...
   'EventManager',Editor.EventManager);

% Plot X and Y axis lines
XYdata = infline(-Inf,Inf);
npts = length(XYdata);
AxisLines(1,1) = line(XYdata,zeros(1,npts),Zlevel(:,ones(1,npts)),...
   'Color',Preferences.AxesForegroundColor,...
   'LineStyle',':','Parent',PlotAxes,...
   'HitTest','off','XlimInclude','off','YlimInclude','off');
AxisLines(2,1) = line(zeros(1,npts),XYdata,Zlevel(:,ones(1,npts)),...
   'Color',Preferences.AxesForegroundColor,...
   'LineStyle',':','Parent',PlotAxes,...
   'HitTest','off','XlimInclude','off','YlimInclude','off');
theta = 0:0.062831:2*pi;
Circle = line(cos(theta),sin(theta),Zlevel(:,ones(1,length(theta))),...
   'Color',Preferences.AxesForegroundColor,...
   'Parent',PlotAxes,'LineStyle',':','HitTest','off','Visible','off');
L = handle.listener(Editor,Editor.findprop('LabelColor'),...
   'PropertyPostSet',{@LocalSetColor [AxisLines;Circle]});
set(AxisLines(1),'UserData',L);

% Always include origin
Origin = line([-1 -1 1 1],[-1 1 -1 1],-Zlevel(ones(1,4)),...
   'LineStyle','none','Parent',PlotAxes,'HitTest','off');

% Build right-click menu
U = Editor.Axes.UIContextMenu;
LocalAddMenus(Editor,U,1);
set(get(U,'children'),'Enable','off')

% Replicate menus in main figure
LocalAddMenus(Editor,MenuAnchor,0);

% Create shadow line specifying root locus portion to be included in limit picking
% REVISIT: could be incorporated in Locus as XlimIncludeData
LocusShadow = line(NaN,NaN,...
   'Parent',PlotAxes, ...
   'LineStyle','none',...
   'HitTest','off',...
   'HandleVisibility','off');

% Data structure of HG objects
% RE: HG.Compensator stores the list of (unique) pole/zero handles
Editor.HG = struct(...
   'AxisLines',AxisLines,...
   'Origin',Origin,...
   'ClosedLoop',[],...
   'Compensator',[],...
   'Locus',[],...
   'LocusShadow',LocusShadow,...
   'System',[],...
   'UnitCircle',Circle);

%-------------------------- Local Functions ------------------------

%%%%%%%%%%%%%%%%%
% LocalPlotGrid %
%%%%%%%%%%%%%%%%%
function GridHandles = LocalPlotGrid(Editor)
% Plots S or Z grid
Ts = Editor.LoopData.Ts;
Axes = Editor.Axes;

% Update grid options
% REVISIT: simplify
Options = Axes.GridOptions;
Options.FrequencyUnits = Editor.FrequencyUnits;
Options.GridLabelType = Editor.GridOptions.GridLabelType;
Options.SampleTime = Ts;
Axes.GridOptions = Options;

% Generate and plot new grid 
if Ts==0
   GridHandles = Axes.plotgrid('sgrid');
else
   GridHandles = Axes.plotgrid('zgrid');
   set(Editor.HG.UnitCircle,'Visible','off') 
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddMenus %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalAddMenus(Editor,MenuAnchor,EditFlag)
% Builds right-click menus

% Edit pole/zero group
addmenu(Editor,MenuAnchor,'add');
addmenu(Editor,MenuAnchor,'delete');
if EditFlag
    addmenu(Editor,MenuAnchor,'edit');
end

% Design Constraints/Grid/Zoom
h = [Editor.addmenu(MenuAnchor, 'constraint'); ...
     Editor.addmenu(MenuAnchor, 'grid')];
set(h(1), 'Separator', 'on');
set(h(end), 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
    h = addmenu(Editor,MenuAnchor,'property');
    set(h,'Separator','on')
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalButtonDown %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalButtonDown(hSrc,event,Editor)
% Button down callbacks
Editor.mouseevent('bd',hSrc);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetColor %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetColor(hSrc,event,AxisLines)
set(AxisLines,'Color',event.NewValue)