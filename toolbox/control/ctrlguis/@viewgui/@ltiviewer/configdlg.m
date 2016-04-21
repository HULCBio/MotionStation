function configdlg(this)
%  CONFIGDLG  Show/hide the LTI Viewer Plot Configuration window.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/10 23:14:35 $

% Open figure
ConfigurationHandle = localOpenFigure(this);
set(this.HG.FigureMenu.EditMenu.PlotConfigurations,'UserData',ConfigurationHandle);
% Initialize contents
localRead(this,ConfigurationHandle);
% Show figure
set(ConfigurationHandle,'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%
%%% localOpenFigure %%%
%%%%%%%%%%%%%%%%%%%%%%%
function a = localOpenFigure(this);

LTIviewerFig    = this.Figure;
ConfigNumber    = length(getCurrentViews(this));

StdUnit = 'points';
PointsToPixels = 72/get(0,'ScreenPixelsPerInch');
UIColor = get(0,'DefaultUIControlBackground');

a = figure(...
   'Name',xlate('Plot Configurations'),...
   'MenuBar','none',...
   'NumberTitle','off',...
   'IntegerHandle','off',...
   'HandleVisibility','callback',...
   'Resize','off',...
   'WindowButtonMotionFcn',{@localHover this},...
   'Units','pixels',...
   'Position',[0 0 494 264],...
   'Visible','off',...
   'Color',UIColor,...
   'CloseRequestFcn',{@localClose this},...
   'Tag','ConfigureViewerAxesFig',...
   'DockControls', 'off');

%---Position figure within LTI Viewer bounds
centerfig(a,LTIviewerFig);

b = uicontrol('Parent',a, ...
   'Units','points', ...
   'Position',PointsToPixels*[8 33 346 220], ...
   'Enable','inactive',...
   'BackgroundColor',UIColor, ...
   'Style','frame');

%---Response Order controls
b = uicontrol('Parent',a, ...
   'Units','points', ...
   'Position',PointsToPixels*[360 33 127 220], ...
   'BackgroundColor',UIColor, ...
   'Style','frame');
b = uicontrol('Parent',a, ...
   'Units','points', ...
   'BackgroundColor',[0.8 0.8 0.8], ...
   'Position',PointsToPixels*[374 226 100 17], ...
   'String','Response type', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Units','points', ...
   'BackgroundColor',[0.8 0.8 0.8], ...
   'Position',PointsToPixels*[70 236 250 15], ...
   'String','Select a response plot configuration', ...
   'BackgroundColor',UIColor, ...
   'Style','text');

WhiteFramePos=[{[312 49 24 34]};
   {[286 49 24 34]};
   {[260 49 24 34]};
   {[312 85 24 34]};
   {[286 85 24 34]};
   {[260 85 24 34]};
   {[202 49 24 34]};
   {[175 49 24 34]};
   {[149 49 24 34]};
   {[189 85 37 34]};
   {[149 85 37 34]};
   {[40 85 37 34]};
   {[80 85 37 34]};
   {[40 49 37 34]};
   {[80 49 37 34]};
   {[262 192 74 23]};
   {[262 167 74 23]};
   {[262 142 74 23]};
   {[150 181 76 35]};
   {[150 143 76 35]};
   {[42 144 71 69]}];

TextPos = [{[315 55 18 18]};
   {[289 55 18 18]};
   {[263 55 18 18]};
   {[315 93 18 18]};
   {[289 93 18 18]};
   {[263 93 18 18]};
   {[205 55 18 18]};
   {[177 55 18 18]};
   {[152 55 18 18]};
   {[195 93 18 18]};
   {[157 93 18 18]};
   {[48 93 18 18]};
   {[88 93 18 18]};
   {[48 55 18 18]};
   {[88 55 18 18]};
   {[265 194 18 18]};  % {[265 194 18 18]};
   {[265 170 18 18]};  % {[265 170 18 18]};
   {[265 144 18 18]};  % {[265 144 18 18]};
   {[153 188 18 18]};
   {[153 150 18 18]};
   {[45 186 18 18]}];
TextStr = {'6';'5';'4';'3';'2';'1';'5';'4';'3';'2';'1';'1';'2';'3';'4'; ...
      '1';'2';'3';'1';'2';'1'};
GreyFramePos=[{[36 140 84 80]};
   {[146 140 84 80]};
   {[256 140 84 80]};
   {[36 45 84 80]};
   {[146 45 84 80]};
   {[256 45 84 80]}];

RadioPos = [{[16 203 20 20]};
   {[126 203 20 20]};
   {[236 203 20 20]};
   {[16 108 20 20]};
   {[126 108 20 20]};
   {[236 108 20 20]}];

MenuPos = [{[386 192 94 25]};
   {[386 162 94 25]};
   {[386 131 94 25]};
   {[386 101 94 25]};
   {[386 70 94 25]};
   {[386 39 94 25]}];

MenuLabPos = [{[366 193 18 23]};
   {[366 162 18 23]};
   {[366 131 18 23]};
   {[366 100 18 23]};
   {[366 69 18 23]};
   {[366 38 18 23]}];

AllPlotNames = {this.AvailableViews.Name};
LayoutButton = zeros(6,1);
for ctB=1:6
   PressCallback = {@localSelect ctB,a};
   LayoutButton(ctB) = uicontrol('Parent',a, ...
      'Units','points', ...
      'BackgroundColor',UIColor, ...
      'callback',PressCallback, ...
      'Position',PointsToPixels*RadioPos{ctB}, ...
      'Style','radiobutton');
   b = uicontrol('Parent',a, ...
      'Units',StdUnit, ...
      'Position',PointsToPixels*GreyFramePos{ctB}, ...
      'Enable','inactive',...
      'ButtonDownFcn',PressCallback,...
      'BackgroundColor',UIColor, ...
      'Style','frame');
   b = uicontrol('Parent',a, ...
      'String',sprintf('%d:',ctB),...
      'Units',StdUnit, ...
      'Position',PointsToPixels*MenuLabPos{ctB}, ...
      'BackgroundColor',UIColor, ...
      'Style','text');
   PlotTypeMenu(ctB) = uicontrol('Parent',a, ...
      'Units','points', ...
      'Enable','off',...
      'Position',PointsToPixels*MenuPos{ctB}, ...
      'Style','popupmenu', ...
      'String',AllPlotNames,...
      'BackgroundColor',UIColor + (1-UIColor)*ispc);
end
set(PlotTypeMenu(1:ConfigNumber),'Enable','on');
set(LayoutButton(ConfigNumber),'Value',1);

for ct=1:length(WhiteFramePos)
   b = uicontrol('Parent',a, ...
      'BackgroundColor',[1 1 1], ...
      'Units',StdUnit, ...
      'Position',PointsToPixels*WhiteFramePos{ct}, ...
      'Enable','inactive',...
      'HitTest','off',...
      'Style','frame');
   b = uicontrol('Parent',a, ...
      'BackgroundColor',[1 1 1], ...
      'String',TextStr{ct},...
      'Units',StdUnit, ...
      'Enable','inactive',...
      'HitTest','off',...
      'Position',PointsToPixels*TextPos{ct}, ...
      'Style','text');
end

Handles.OKButton = uicontrol('Parent',a, ...
   'Units','points', ...
   'Callback',{@localOK this,a}, ...
   'Position',PointsToPixels*[105 6 55 23], ...
   'BackgroundColor',UIColor, ...
   'String','OK');
Handles.CloseButton = uicontrol('Parent',a, ...
   'Units','points', ...
   'Position',PointsToPixels*[170 6 55 23], ...
   'Callback',{@localClose this}, ...
   'BackgroundColor',UIColor, ...
   'String',xlate('Cancel'));
Handles.HelpButton = uicontrol('Parent',a, ...
   'Units','points', ...
   'Position',PointsToPixels*[235 6 55 23], ...
   'String',xlate('Help'), ...
   'BackgroundColor',UIColor, ...
   'Callback','ctrlguihelp(''viewer_plotconfigurations'');');
Handles.ApplyButton = uicontrol('Parent',a, ...
   'Units','points', ...
   'Callback',{@localApply this,a}, ...
   'Position',PointsToPixels*[300 6 55 23], ...
   'BackgroundColor',UIColor, ...
   'String',xlate('Apply'));

%---Listen for destruction of the Viewer Object
Handles.Listeners(1) = handle.listener(this,...
   'ObjectBeingDestroyed',{@localDelete a});
Handles.Listeners(2) = handle.listener(this,'ConfigurationChanged',{@localUpdate this,a});
ud.Handles = Handles;
%---Store info in figure UserData
set(a,'UserData',struct('Parent',LTIviewerFig,...
   'LayoutButtons',LayoutButton,...
   'PlotTypeMenus',PlotTypeMenu,...
   'Handles',Handles));


%%%%%%%%%%%%%%%%%
%%% localRead %%%
%%%%%%%%%%%%%%%%%
function localRead(this,ConfigWindow)
%
%---Get window info
ud = get(ConfigWindow,'UserData');
% %---this info
[UniqueViews,junk,iu] = unique(getCurrentViews(this,'Type'));
[junk,ia] = intersect({this.AvailableViews.Alias},UniqueViews);
idx = ia(iu);  % index vector of the current views in the available views list.
%---Determine list of values for each popup
Values = 1:length(this.AvailableViews);
Values(idx) = [];
Values = [idx(:);Values(:)];
for ctB=1:6
     set(ud.PlotTypeMenus(ctB),'Value',Values(ctB));
end

%%%%%%%%%%%%%%%%%%%
%%% localSelect %%%
%%%%%%%%%%%%%%%%%%%
function localSelect(eventSrc,eventData,ConfigNumber,ConfigWindow)
% Callback when pressing on configuration selector or corresponding pictogram
Ud = get(ConfigWindow,'UserData');
% Update radio button states
set(Ud.LayoutButtons,'Value',0);
set(Ud.LayoutButtons(ConfigNumber),'Value',1);
% Disable plot type selectors for inactive configurations
set(Ud.PlotTypeMenus(1:ConfigNumber),'Enable','on');
set(Ud.PlotTypeMenus(ConfigNumber+1:end),'Enable','off');


%%%%%%%%%%%%%%%
%%% localOK %%%
%%%%%%%%%%%%%%%
function localOK(eventSrc,eventData,this,ConfigWindow)
% OK button callback
localApply(eventSrc,eventData,this,ConfigWindow);
localClose(eventSrc,eventData,this);


%%%%%%%%%%%%%%%%%%
%%% localApply %%%
%%%%%%%%%%%%%%%%%%
function localApply(eventSrc,eventData,this,ConfigWindow)
% Apply button callback
% Get list of new plot types
ud = get(ConfigWindow,'UserData');
LayoutVals = get(ud.LayoutButtons,'Value');
NewConfig = find([LayoutVals{:}]);
NewVals = get(ud.PlotTypeMenus(1:NewConfig),{'Value'});
NewViews = {this.AvailableViews([NewVals{:}]).Alias};
% Update configuration
if ~isequal(getCurrentViews(this),NewViews)
   set(this.Figure,'Pointer','watch');
   this.setCurrentViews(NewViews);
   set(this.Figure,'Pointer','arrow');
end
this.EventManager.newstatus('Configuration change completed.');

%%%%%%%%%%%%%%%%%%
%%% localClose %%%
%%%%%%%%%%%%%%%%%%
function localClose(eventSrc,eventData,this)
% CloseRequestFcn
if ~strcmpi(get(eventSrc,'Type'),'figure')
   eventSrc = get(eventSrc,'Parent');
end
set(eventSrc,'Visible','off');
this.EventManager.newstatus('LTI Viewer');

%%%%%%%%%%%%%%%%%%%
%%% localDelete %%%
%%%%%%%%%%%%%%%%%%%
function localDelete(eventSrc,eventData,ConfigWindow)
% Delete figure
delete(ConfigWindow);

%%%%%%%%%%%%%%%%%%%
%%% localUpdate %%%
%%%%%%%%%%%%%%%%%%%
function localUpdate(eventSrc,eventData,this,ConfigWindow)
% Update figure
if strcmpi(get(ConfigWindow,'Visible'),'on')
   localSelect([],[],length(getCurrentViews(this)),ConfigWindow);
   localRead(this,ConfigWindow);
end

%%%%%%%%%%%%%%%%%%
%%% localHover %%%
%%%%%%%%%%%%%%%%%%
function localHover(eventSrc,eventData,this)
% Update Viewer status bar while hovering in this GUI
this.EventManager.poststatus('Change the number and type of response plots shown in this LTI Viewer.');
