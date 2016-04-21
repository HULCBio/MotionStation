function FigureMenu = figmenus(this);
%  FIGMENUS Creates customized menus for the figure.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16.4.2 $  $Date: 2002/11/11 22:22:56 $
%
%---File Menu
FigMenu.FileMenu.Main = uimenu(this.Figure,'Label',xlate('&File'),'HandleVis','off');
FigMenu.FileMenu.NewViewer = uimenu(FigMenu.FileMenu.Main,...
   'Label',xlate('&New Viewer'),'Accelerator','N','Callback','ltiview;');
FigMenu.FileMenu.Import = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',xlate('&Import...'),'Callback',{@localImport this});
FigMenu.FileMenu.Export = uimenu(FigMenu.FileMenu.Main,...
   'Label',xlate('&Export...'),'Callback',{@localExport this});
if usejava('MWT')
   FigMenu.FileMenu.ToolboxPreferences = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
      'Label',xlate('&Toolbox Preferences...'),'Callback','ctrlpref');
end
FigMenu.FileMenu.PageSetup = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',xlate('Pa&ge Setup...'),'Callback',{@localPageSetup this});
FigMenu.FileMenu.Print = uimenu(FigMenu.FileMenu.Main,...
   'Label',xlate('&Print...'),'Accelerator','P','Callback',{@localPrintPaper this});
FigMenu.FileMenu.PrintToFigure = uimenu(FigMenu.FileMenu.Main,...
   'Label',xlate('Print to &Figure'),'Callback',{@localPrintFigure this});
FigMenu.FileMenu.Close = uimenu(FigMenu.FileMenu.Main,'Separator','on',...
   'Label',xlate('&Close'),'Accelerator','W','CallBack',{@localClose this});
% -------------------------------------------------------------------------
%---Edit Menu
FigMenu.EditMenu.Main = uimenu(this.Figure,'Label',xlate('&Edit'),'HandleVis','off');
FigMenu.EditMenu.PlotConfigurations = uimenu(FigMenu.EditMenu.Main,...
   'Label',xlate('Plot &Configurations...'),'Callback',{@localPlotConfig this});
FigMenu.EditMenu.RefreshSystems = uimenu(FigMenu.EditMenu.Main,...
   'Label', xlate('&Refresh Systems'),'Callback',{@localRefresh this});
FigMenu.EditMenu.DeleteSystems = uimenu(FigMenu.EditMenu.Main,...
   'Label', xlate('&Delete Systems...'),'Callback',{@localDelete this});
FigMenu.EditMenu.LineStyles = uimenu(FigMenu.EditMenu.Main,'Separator','on',...
   'Label', xlate('&Line Styles...'),'Callback',{@localLineStyle this});
FigMenu.EditMenu.ViewerPreferences = uimenu(FigMenu.EditMenu.Main,...
   'Label',xlate('Viewer &Preferences...'),'Callback',{@localViewPref this});
% -------------------------------------------------------------------------
%---Simulink Menu
FigMenu.SimulinkMenu.Main = uimenu(this.Figure,'Label',xlate('&Simulink'),'Visible','off','HandleVis','off');
FigMenu.SimulinkMenu.LinearizeMenu = uimenu(FigMenu.SimulinkMenu.Main,'Label',xlate('Get Linearized &Model'));
FigMenu.SimulinkMenu.ICMenu = uimenu(FigMenu.SimulinkMenu.Main,'Label',xlate('Set &Operating Point...'),'Separator','on');
FigMenu.SimulinkMenu.DeleteMenu = uimenu(FigMenu.SimulinkMenu.Main,'Label',xlate('&Remove Input/Output Points')); 
% -------------------------------------------------------------------------
%---Window Menu
FigMenu.WinMenu.Main = uimenu(this.Figure,'Tag','winmenu','HandleVis','off',...
   'Label',xlate('&Window'),'Callback',winmenu('callback'));
% -------------------------------------------------------------------------
%---Initialize the submenu
winmenu(this.Figure);
% -------------------------------------------------------------------------
% ---Help Menu
FigMenu.HelpMenu.Main = uimenu(this.Figure,'Label',xlate('&Help'),'HandleVis','off');
FigMenu.HelpMenu.ViewerHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('LTI Viewer &Help'),'Callback','ctrlguihelp(''viewermainhelp'');');
FigMenu.HelpMenu.ToolboxHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('Control System &Toolbox Help'),'Callback','doc(''control/'');');
FigMenu.HelpMenu.IOPointsHelp = uimenu(FigMenu.HelpMenu.Main,'Separator','on',...
   'Label',sprintf('Specifying Input/Output &Points'),'Visible','off','Callback','ctrlguihelp(''viewer_iopoints'');');
FigMenu.HelpMenu.OperatingPointHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('Setting &Operating Point'),'Visible','off','Callback','ctrlguihelp(''viewer_operatingpoint'');');
FigMenu.HelpMenu.ImportExportHelp = uimenu(FigMenu.HelpMenu.Main,'Separator','on',...
   'Label',sprintf('&Importing/Exporting Models'),'Callback','ctrlguihelp(''viewer_importexport'');');
FigMenu.HelpMenu.RespTypeHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('Selecting &Response Types'),'Callback','ctrlguihelp(''viewer_responsetypes'');');
FigMenu.HelpMenu.MIMOHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('Analyzing &MIMO Models'),'Callback','ctrlguihelp(''viewer_mimomodels'');');
FigMenu.HelpMenu.PropPrefHelp = uimenu(FigMenu.HelpMenu.Main,...
   'Label',sprintf('C&ustomizing the LTI Viewer'),'Callback','ctrlguihelp(''viewer_customizing'');');
FigMenu.HelpMenu.DemosHelp = uimenu(FigMenu.HelpMenu.Main,'Separator','on',...
   'Label',sprintf('&Demos'),'Callback','demo toolbox control');
FigMenu.HelpMenu.AboutHelp = uimenu(FigMenu.HelpMenu.Main,'Separator','on',...
   'Label',sprintf('&About the Control System Toolbox'),'Callback','aboutcst');
% -------------------------------------------------------------------------
FigureMenu = FigMenu;
% -------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pass these callbacks to class methods %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localImport
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localImport(eventSrc,eventData,this)
%
importdlg(this);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localExport
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localExport(eventSrc,eventData,this)
%
if usejava('MWT')
   ExportFrame = get(eventSrc,'UserData');
   if isempty(ExportFrame)
      % Create export dialog
      ExportFrame = this.exportdlg;
      set(eventSrc,'UserData',ExportFrame);
   else
      % Bring it up front
      set(ExportFrame,'Minimize','off','Visible','off','Visible','on');
   end
else
   % HG back up
   exportdlg2(this);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localPageSetup
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localPageSetup(eventSrc,eventData,this)
pagesetupdlg(double(this.Figure));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localPrint
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localPrintPaper(eventSrc,eventData,this)
print(this,'printer');

function localPrintFigure(eventSrc,eventData,this)
print(this,'figure');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localRefresh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localRefresh(eventSrc,eventData,this)
refreshsys(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localDelete
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDelete(eventSrc,eventData,this)
%
if usejava('MWT')
   DeleteFrame = get(eventSrc,'UserData');
   if isempty(DeleteFrame)
      % Create delete dialog
      DeleteFrame = this.deletedlg;
      set(eventSrc,'UserData',DeleteFrame);
   else
      % Bring it up front
      set(DeleteFrame,'Minimize','off','Visible','off','Visible','on');
   end
else
   % HG back up
   deletedlg2(this);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localLineStyle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localLineStyle(eventSrc,eventData,this)
%

StyleFrame = get(eventSrc,'UserData');
if isempty(StyleFrame)
   % Create style dialog
   StyleFrame = styledlg(this);
   set(eventSrc,'UserData',StyleFrame);
else
   % Bring it up front
   set(StyleFrame,'Visible','on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localViewPref
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localViewPref(eventSrc,eventData,this)
if usejava('MWT')
    edit(this.Preferences);
else
    errordlg(sprintf('This feature requires  Java.'),sprintf('Viewer Preferences'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localClose
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localClose(eventSrc,eventData,this)
close(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  localPlotConfig
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localPlotConfig(eventSrc,eventData,this)
%
ConfigFrame = get(eventSrc,'UserData');
if isempty(ConfigFrame)
   % Create configuration dialog
   configdlg(this);
else
   % Bring it up front
   set(ConfigFrame,'Visible','on');
end
