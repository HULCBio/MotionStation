function Menus = figmenus(sisodb)
%FIGMENUS  Add the SISO Tool figure menus.
%
%   See also SISOTOOL.

%   Karen D. Gondoly and P. Gahinet
%   Revised : Kamesh Subbarao 11-07-2001
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.53.4.3 $  $Date: 2004/04/10 23:14:27 $

% Main figure
SISOfig = sisodb.Figure;
LoopData = sisodb.LoopData;

% File menu
FileMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&File'),'HandleVis','off');
FileMenu.Import = uimenu('Parent',FileMenu.Top,...
			 'Label',xlate('&Import...'),...
			 'Callback',{@LocalImport sisodb [1 2 3 4]});
uimenu('Parent',FileMenu.Top,'Enable','off',...
       'Label',xlate('&Export...'), ...
       'Callback',{@LocalExport sisodb});  
uimenu('Parent',FileMenu.Top,'Enable','off',...
       'Label',xlate('&Save Session...'), ...
       'Separator','on', ...
       'Callback',{@LocalSave sisodb});  
uimenu('Parent',FileMenu.Top,...
       'Label',xlate('&Load Session...'), ...
       'Callback',{@LocalLoad sisodb});  

if usejava('MWT')
  uimenu('Parent',FileMenu.Top,...
	 'Label',xlate('&Toolbox Preferences...'), ...
	 'Separator','on', ...
	 'Callback','ctrlpref');
end
uimenu('Parent',FileMenu.Top, ...
       'Label',xlate('&Print...'),...
       'Callback',{@LocalPrint sisodb 'print'}, ...
       'Separator','on', ...
       'Accelerator','P');
uimenu('Parent',FileMenu.Top, ...
       'Label',xlate('Print to &Figure'),...
       'Callback',{@LocalPrint sisodb 'print2fig'});
uimenu('Parent',FileMenu.Top, ...
       'Callback',{@LocalClose sisodb},... 
       'Separator','on', ...
       'Label',xlate('&Close'), ...
       'Accelerator','W');

% Edit menu
EditMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Edit'),'HandleVis','off');
EditMenu.Undo = uimenu('Parent',EditMenu.Top,...
		       'Label',xlate('&Undo'),'Enable','off', ...
		       'Accelerator','Z',...
		       'Callback',{@LocalUndo sisodb});  
EditMenu.Redo = uimenu('Parent',EditMenu.Top,...
		       'Label',xlate('&Redo'),'Enable','off', ...
		       'Accelerator','Y',...
		       'Callback',{@LocalRedo sisodb});
% Install listener for enable state
Recorder = sisodb.EventManager.EventRecorder;
set(EditMenu.Undo,'UserData',...
    handle.listener(Recorder,findprop(Recorder,'Undo'),...
    'PropertyPostSet',{@LocalDoMenu EditMenu.Undo 1}));
set(EditMenu.Redo,'UserData',...
    handle.listener(Recorder,findprop(Recorder,'Redo'),...
    'PropertyPostSet',{@LocalDoMenu EditMenu.Redo 0}));
% Shortcuts to plot editor right-click menus
EditMenu.Rlocus = uimenu('Parent',EditMenu.Top , ...
   'Label',xlate('&Root Locus'),'Enable','off', ...
   'Visible','off');
EditMenu.BodeOL = uimenu('Parent',EditMenu.Top , ...
   'Label',xlate('&Open-Loop Bode'),'Enable','off', ...
   'Visible','off');
EditMenu.Nichols = uimenu('Parent',EditMenu.Top , ...
   'Label',xlate('&Open-Loop Nichols'),'Enable','off', ...
   'Visible','off');
EditMenu.BodeF = uimenu('Parent',EditMenu.Top , ...
   'Enable','off','Visible','off');
ViewMenus = [EditMenu.Rlocus;EditMenu.BodeOL;EditMenu.Nichols;EditMenu.BodeF];
for ct=1:length(sisodb.PlotEditors)
    % Install listener for editor visibility
    Editor = sisodb.PlotEditors(ct);
    vlsnr(ct) = handle.listener(Editor,findprop(Editor,'Visible'),...
        'PropertyPostSet',{@LocalToggleMenu sisodb.PlotEditors ViewMenus});
end
set(EditMenu.Top,'UserData',vlsnr)
if usejava('MWT')
  uimenu('Parent',EditMenu.Top , ...
	 'Separator','on', ...
	 'Callback',{@LocalEditPref sisodb}, ...
	 'Label',xlate('SISO Tool &Preferences...'));
end

% View menu
% RE: Includes all plots that can be viewed within main window
ViewMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&View'),'HandleVis','off');
ViewMenu.Editors(1) = uimenu('Parent',ViewMenu.Top, ...
    'Label',xlate('&Root Locus'), ...
    'Callback',{@LocalToggleView sisodb.PlotEditors(1) 'rlocus'});
ViewMenu.Editors(2) = uimenu('Parent',ViewMenu.Top, ...
    'Label',xlate('&Open-Loop Bode'), ...
    'Callback',{@LocalToggleView sisodb.PlotEditors(2) 'bodeOL'});
ViewMenu.Editors(3) = uimenu('Parent',ViewMenu.Top, ...
    'Label',xlate('&Open-Loop Nichols'), ...
    'Callback',{@LocalToggleView sisodb.PlotEditors(3) 'nichols'});
h = uimenu('Parent',ViewMenu.Top, ...
    'Callback',{@LocalToggleView sisodb.PlotEditors(4) 'bodeF'});
set(h,'UserData',handle.listener(LoopData,findprop(LoopData,'Configuration'),...
        'PropertyPostSet',{@LocalUpdateLabel LoopData [EditMenu.BodeF,h]}));
ViewMenu.Editors(4) = h;
uimenu('Parent',ViewMenu.Top, ...
    'Label',xlate('&System Data'),'Enable','off', ...
    'Separator','on',...
    'CallBack',{@LocalDataView sisodb 'SystemView'});      
uimenu('Parent', ViewMenu.Top, 'Enable','off', ...
       'Label', xlate('&Closed-Loop Poles'), ...
       'Callback', {@LocalPoleView sisodb});
uimenu('Parent',ViewMenu.Top, ...
    'Label',xlate('&Design History'),'Enable','off',...
    'Callback',{@LocalDataView sisodb 'HistoryView'});

% Compensator menu
CompMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Compensators'),'HandleVis','off');
if usejava('MWT')
   uimenu('Parent',CompMenu.Top, ...
      'Label',xlate('&Format...'),'Enable','off',...
      'CallBack',{@LocalFormatComp sisodb});
end
CompEdit = uimenu('Parent',CompMenu.Top, ...
   'Label',xlate('&Edit'),'Enable','off');
uimenu('Parent',CompEdit,'Label','C',...
   'CallBack',{@LocalEditComp sisodb 'C'});
uimenu('Parent',CompEdit,'Label','F',...
   'CallBack',{@LocalEditComp sisodb 'F'});

if usejava('MWT')
   uimenu('Parent',CompMenu.Top, ...
      'Separator','on', ...
      'Label',xlate('&Store/Retrieve...'),'Enable','off',...
      'CallBack',{@LocalStoreRetrieveDesign sisodb});
end

ClearMenu = uimenu('Parent',CompMenu.Top, ...
   'Label',xlate('&Clear'),'Enable','off');
uimenu('Parent',ClearMenu, ...
   'Label',xlate('C and F'),'CallBack',{@LocalClearComp sisodb 'all'});
uimenu('Parent',ClearMenu, ...
   'Label',xlate('C only'),'CallBack',{@LocalClearComp sisodb 'C'});
uimenu('Parent',ClearMenu, ...
   'Label',xlate('F only'),'CallBack',{@LocalClearComp sisodb 'F'});

% Analysis menu
AnaMenu.Top = uimenu('Parent',SISOfig,'Label',xlate('&Analysis'),'HandleVis','off');
% 1. Predefined responses
hPlot = zeros(5,1);
hPlot(1) = uimenu('Parent',AnaMenu.Top,'Label',xlate('Response to Step Command'),'Enable','off');
hPlot(2) = uimenu('Parent',AnaMenu.Top,'Label',xlate('Rejection of Step Disturbance'),'Enable','off');
hPlot(3) = uimenu('Parent',AnaMenu.Top,'Label',xlate('Closed-Loop Bode'),'Enable','off');
hPlot(4) = uimenu('Parent',AnaMenu.Top,'Label',xlate('Compensator Bode'),'Enable','off');
hPlot(5) = uimenu('Parent',AnaMenu.Top,'Label',xlate('Open-Loop Nyquist'),'Enable','off');
PlotContents = struct(...
    'PlotType',{'step';'step';'bode';'bode';'nyquist'},...
    'VisibleModels',{{'$T_r2y';'$T_r2u'};{'$S_input';'$S_output'};{'$T_r2y'};{'$C'};{'$L'}});
AnaMenu.PlotSelection = hPlot;
% 2. Custom response setup
hc = uimenu('Parent',AnaMenu.Top,...
    'Separator','on','Label',xlate('Other Loop Responses...'),...
    'Enable','off','CallBack',{@LocalSetupResp sisodb hPlot});
set(hPlot,'CallBack',{@LocalShowResp sisodb PlotContents hPlot hc}) 


% Tools menu
ToolMenu.Top= uimenu('Parent',SISOfig,'Label',xlate('&Tools'),'HandleVis','off');
% 1. Conversions
uimenu('Parent',ToolMenu.Top, ...
    'Label',xlate('Continuous/Discrete &Conversions...'),'Enable','off', ...
    'CallBack',{@LocalDiscretize sisodb});
% 2. Draw Simulink diagram
if license('test', 'SIMULINK')
    uimenu('Parent',ToolMenu.Top, ...
        'Enable','off',...
        'Label',xlate('Draw &Simulink Diagram...'), ...
        'Callback',{@LocalDraw LoopData});
end

% Window menu
WindowMenu.Top = uimenu(SISOfig, 'Label', xlate('&Window'),'HandleVis','off', ...
    'Callback', winmenu('callback'), 'Tag', 'winmenu');
winmenu(double(SISOfig));  % Initialize the submenu

% Help menu
HelpMenu.Top = uimenu('Parent',SISOfig,'Label',sprintf('&Help'),'HandleVis','off');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('SISO Design Tool &Help'), ...
   'Callback','ctrlguihelp(''sisotoolmainhelp'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Control System &Toolbox Help'), ...
   'Callback','doc(''control/'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&What''s This?'), ...
   'Separator','on',...
   'CallBack',{@LocalWhatsThis sisodb});
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Importing/Exporting Models'), ...
   'Separator','on',...
   'CallBack','ctrlguihelp(''sisoimportexport'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Tuning &Compensators'), ...
   'CallBack','ctrlguihelp(''sisocompdesign'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('Viewing Loop &Responses'), ...
   'Callback','ctrlguihelp(''sisoloopresponses'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Viewing System Data'), ...
   'Callback','ctrlguihelp(''sisomodeldata'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Storing/Retrieving Designs'), ...
   'Callback','ctrlguihelp(''sisosavecomp'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('C&ustomizing the SISO Tool'), ...
   'Callback','ctrlguihelp(''sisocustomizing'');');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&Demos'), ...
   'Separator','on',...
   'CallBack','demo toolbox control');
uimenu('Parent',HelpMenu.Top, ...
   'Label',sprintf('&About the Control System Toolbox'), ...
   'Separator','on',...
   'CallBack','aboutcst');

Menus = struct(...
    'File',FileMenu,...
    'Edit',EditMenu,...
    'View',ViewMenu,...
    'Compensator',CompMenu,...
    'Analysis',AnaMenu,...
    'Tools',ToolMenu,...
    'Window',WindowMenu,...
    'Help',HelpMenu);

%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalImport %%%
%%%%%%%%%%%%%%%%%%%
function LocalImport(hSrc,event,sisodb,AvailConfig)
% Opens Import dialog
sisodb.importdlg(AvailConfig);


%%%%%%%%%%%%%%%%%%%
%%% LocalExport %%%
%%%%%%%%%%%%%%%%%%%
function LocalExport(hSrc,event,sisodb)
% Opens export dialog

% REVISIT: remove this when Java runs on HP/IBM
if usejava('MWT')
    ExportFrame = get(hSrc,'UserData');
    if isempty(ExportFrame)
        % Create export dialog
        ExportFrame = sisodb.exportdlg;
        set(hSrc,'UserData',ExportFrame);
    else
        % Bring it up front
        set(ExportFrame,'Minimize','off','Visible','off','Visible','on');
    end
else
    % HG back up
    ExportData = sisodb.LoopData.exportdata2;
    exportlti('initialize',sisodb.Figure,ExportData,'SISO Tool Export');
end
   

%%%%%%%%%%%%%%%%%
%%% LocalSave %%%
%%%%%%%%%%%%%%%%%
function LocalSave(hSrc,event,sisodb)
% Save session to file

% Take snapshot of current state
SessionData = sisodb.save;

% Query user for file name/location
DefaultFileName = sprintf('%s.mat',sisodb.LoopData.SystemName);
[fname,p] = uiputfile(DefaultFileName,'Save Session');

% Save session data
if ischar(fname),
    [fname,r] = strtok(fname,'.');
    fullname = fullfile(p,[fname '.mat']);
    save(fullname,'SessionData');
    
    % Update status bar and history
    Msg = sprintf('Saved session to file %s.mat',fname);
    sisodb.EventManager.newstatus(Msg);
    sisodb.EventManager.recordtxt('history',Msg);
end


%%%%%%%%%%%%%%%%%
%%% LocalLoad %%%
%%%%%%%%%%%%%%%%%
function LocalLoad(hSrc,event,sisodb)
% Load session from file

% Query user for file name/location
[fname,p] = uigetfile('*.mat','Load Session');

% Save session data
if ischar(fname),
    [fname,r] = strtok(fname,'.');
    fullname = fullfile(p,[fname '.mat']);
    try 
        s = load(fullname);
        load(sisodb,s.SessionData);
        % Update status bar and history
        Msg = sprintf('Loaded session from file %s.mat',fname);
        sisodb.EventManager.newstatus(Msg);
        sisodb.EventManager.recordtxt('history',Msg);
    catch
        errordlg('Selected MAT file does not contain a valid SISO Tool session.',...
            'Load Error','modal')
    end
end


%%%%%%%%%%%%%%%%%%
%%% LocalPrint %%%
%%%%%%%%%%%%%%%%%%
function LocalPrint(hSrcProp,event,sisodb,request)
% Print callback
sisodb.print(request);


%%%%%%%%%%%%%%%%%%
%%% LocalClose %%%
%%%%%%%%%%%%%%%%%%
function LocalClose(hSrc,event,sisodb)
% Close SISO Tool
delete(sisodb.Figure);


%%%%%%%%%%%%%%%%%
%%% LocalUndo %%%
%%%%%%%%%%%%%%%%%
function LocalUndo(hMenu,event,sisodb)
% Undo callback
sisodb.EventManager.undo;


%%%%%%%%%%%%%%%%%
%%% LocalRedo %%%
%%%%%%%%%%%%%%%%%
function LocalRedo(hMenu,event,sisodb)
% Redo callback
sisodb.EventManager.redo;


%%%%%%%%%%%%%%%%%%%
%%% LocalDoMenu %%%
%%%%%%%%%%%%%%%%%%%
function LocalDoMenu(hProp,event,hMenu,MinStackLength)
% Update menu state and label
Stack = event.NewValue;
if length(Stack)<=MinStackLength
    % Empty stack
    set(hMenu,'Enable','off','Label',sprintf('&%s',get(hProp,'Name')))
else
    % Get last transaction's name
    ActionName = Stack(end).Transaction.Name;
    Label = sprintf('&%s %s',get(hProp,'Name'),ActionName);
    set(hMenu,'Enable','on','Label',Label)
end


%%%%%%%%%%%%%%%%%%%%% 
%%% LocalEditPref %%% 
%%%%%%%%%%%%%%%%%%%%% 
function LocalEditPref(hSrc,event,sisodb) 
% Edit SISO Tool prefs 
edit(sisodb.Preferences); 


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleView %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleView(hSrc,event,Editor,Type)
% Toggle editor visibility (hSrc=uimenu)
if strcmp(get(hSrc,'Checked'),'on')
    set(Editor,'Visible','off');
    Status = 'hidden';
else
    set(Editor,'Visible','on');
    Status = 'visible';
end
% Confirm operation in status bar
switch Type
case 'rlocus'
    Status = sprintf('The Root Locus plot is now %s.',Status);
case 'bodeOL'
    Status = sprintf('The open-loop Bode plot is now %s.',Status);
case 'nichols'
    Status = sprintf('The open-loop Nichols plot is now %s.',Status);
case 'bodeF'
    Fid = Editor.LoopData.describe('F','compact');
    Status = sprintf('The Bode plot of the %s F is now %s.',lower(Fid),Status);
end 
Editor.EventManager.newstatus(Status);


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleMenu(hSrc,event,Editors,ViewMenus)
% Toggle visibility of Edit menus associated with plot editors
set(ViewMenus,'Separator','off',{'Visible'},get(Editors,{'Visible'}))
idxVis = find(strcmp(get(ViewMenus,'Visible'),'on'));
if ~isempty(idxVis)
    set(ViewMenus(idxVis(1)),'Separator','on')
end

% ----------------------------------------------------------------------------%
% Function: LocalPoleView
% Purpose:  Open closed-loop pole viewer
% ----------------------------------------------------------------------------%
function LocalPoleView(hSrc, event, sisodb)
% REVISIT: remove this when Java runs on HP/IBM
if usejava('MWT')
    PolesFrame = get(hSrc, 'UserData');
    if isempty(PolesFrame)
        % Create closed-loop pole view table
        PolesFrame = clview2(sisodb);
        set(hSrc, 'UserData', PolesFrame);
    else
        % Bring it up front
        PolesFrame.setVisible(1);
        PolesFrame.toFront;
    end
else
    % HG back up
    PolesFrame = sisodb.clview;
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalDataView %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalDataView(hSrcProp,event,sisodb,ViewID)
% Launches System Data view
sisodb.addview(ViewID);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowResp %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalShowResp(hSrc,event,sisodb,PlotContents,hMenus,hCustom)
% Show subset of predefined plots
MenuIndex = find(hSrc==hMenus);
ViewInfo = get(hSrc,'UserData');  % stores handle of view associated with menu
% Update menu state
if strcmp(get(hSrc,'Checked'),'on')
   % Unselecting menu
   % RE: Relies on listener to view visibility to uncheck menu
   Views = getCurrentViews(sisodb.AnalysisView);
   Views(Views==ViewInfo.View) = [];  % remove view from list of current views
   sisodb.AnalysisView.setCurrentViews(Views)
else
   % Selecting menu
   try
      if isempty(ViewInfo)  % first selection
         % Create view
         ViewerContents = getViewerContents(sisodb);
         sisodb.setViewerContents([ViewerContents;PlotContents(MenuIndex)]);
         % Link it to the menu
         ViewerObj = sisodb.AnalysisView;
         ViewerObj.linkMenu(MenuIndex,ViewerObj.Views(length(ViewerContents)+1));
      else
         % Restore defaut contents
         RespList = resplist(sisodb);
         v = ViewInfo.View;  % handle of view associated with menu
         OldVis = get(v.Responses,{'Visible'});
         NewVis = repmat({'off'},size(OldVis));
         [junk,ia,ib] = intersect(PlotContents(MenuIndex).VisibleModels,RespList(:,1));
         NewVis(ib) = {'on'};
         idxMisMatch = find(~strcmp(OldVis,NewVis));
         set(v.Responses(idxMisMatch),{'Visible'},NewVis(idxMisMatch))
         % Add stored view to Viewer
         Views = getCurrentViews(sisodb.AnalysisView);
         sisodb.AnalysisView.setCurrentViews([Views;v]);
      end
      figure(double(sisodb.AnalysisView.Figure))
   catch
      errordlg(lasterr,'SISO Tool Error','modal')
      return
   end
   set(hSrc,'Checked','on')
end
 
% Hide dialog for custom setup
set(get(hCustom,'UserData'),'Visible','off')


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetupResp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalSetupResp(hSrc,event,sisodb,hCheckMenus)
% Open response setup dialog
% hSrc = handle of Custom... menu (UserData contains dialog handle)

% Open dialog
sisodb.respdlg(hSrc);

% Unselect all check menus
set(hCheckMenus,'Checked','off')


%%%%%%%%%%%%%%%%%%%%
%%% LocalConvert %%%
%%%%%%%%%%%%%%%%%%%%
function LocalDiscretize(hSrc,event,sisodb)
% Opens continous/discrete conversion UI

%---Callback for the Convert to Discrete/Continuous menu 
% Check at most one model in P,H,F is dynamic
LoopData = sisodb.LoopData;
if sum([isstatic(LoopData.Plant.Model) ; ...
            isstatic(LoopData.Sensor.Model) ; ...
            isstatic(LoopData.Filter.zpk)]) < 2,
    WarnTxt = {'Continuous/discrete conversions are performed' ; ...
            'independently on each of the components P, H, C, and F.';...
            ' ';...
            'The resulting feedback loop may not accurately describe';...
            'your system when all components have dynamics.';...
            ' '};
    if strcmp(questdlg(WarnTxt,'Conversion Warning','OK','Cancel','Cancel'),'Cancel')
        return
    end
end

% Open conversion GUI (modal)
sisodb.c2dtool;


%%%%%%%%%%%%%%%%%
%%% LocalDraw %%%
%%%%%%%%%%%%%%%%%
function LocalDraw(hSrcProp,event,LoopData)
% Print callback
LoopData.drawdiagram;


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalFormatComp %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalFormatComp(hSrc,event,sisodb)
% Callback for Compensator:Format menu
edit(sisodb.Preferences); 
selecttab(sisodb.Preferences,3);


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditComp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalEditComp(hSrc,event,sisodb,ComponentID)
% Callback for Compensator:Edit
PZEditor = sisodb.TextEditors(1);
switch ComponentID
case 'C'
    PZEditor.show(sisodb.LoopData.Compensator);
case 'F'
    PZEditor.show(sisodb.LoopData.Filter);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStoreRetrieveDesign %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStoreRetrieveDesign(hSrc,event,sisodb)
% Adds and Retrieves current design to design history
% REVISIT: remove this when Java runs on HP/IBM
if usejava('MWT')
    StoreRetrieveFrame = get(hSrc, 'UserData');
    if isempty(StoreRetrieveFrame)
        % Create Store Retrieve Dialog
        StoreRetrieveFrame = archivedlg(sisodb);
        set(hSrc, 'UserData', StoreRetrieveFrame);
    else
        % Bring it up front
        StoreRetrieveFrame.setVisible(1);
        StoreRetrieveFrame.toFront;
    end
end

%%%%%%%%%%%%%%%%%%%%%%
%%% LocalClearComp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalClearComp(hSrc,event,sisodb,ClearedModels)
% Callback for "clear compensator" event

LoopData = sisodb.LoopData;

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Clear',...
    'OperationStore','on','InverseOperationStore','on');

% Reset compensator to 1 (error-free, may adjust sample time)
switch lower(ClearedModels)
case 'c'
    C = struct('Name','untitledC','Model',zpk(1));
    F = [];
    Status = sprintf('Cleared the %s C.',...
        lower(LoopData.describe('C','compact')));
case 'f'
    C = [];
    F = struct('Name','untitledF','Model',zpk(1));
    Status = sprintf('Cleared the %s F.',...
        lower(LoopData.describe('F','compact')));
case 'all'
    C = struct('Name','untitledC','Model',zpk(1));
    F = struct('Name','untitledF','Model',zpk(1));
    Status = 'Cleared compensators.';
end
LoopData.importdata([],[],F,C);

% Commit and register transaction
sisodb.EventManager.record(T);

% Notify peers of data change
LoopData.dataevent('all');

% Update status bar and history
sisodb.EventManager.newstatus(Status);
sisodb.EventManager.recordtxt('history',Status);

    
%%%%%%%%%%%%%%%%%%%%%%
%%% LocalWhatsThis %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalWhatsThis(hSrc,event,sisodb)
% Callback for What's This menu item
HelpIcon = sisodb.HG.Toolbar(end);
set(HelpIcon,'State','on')


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateLabel %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateLabel(hSrc,event,LoopData,hMenu)
% Update label of Filter Bode menu
set(hMenu,'Label',sprintf('&%s Bode',LoopData.describe('F','compact')))
