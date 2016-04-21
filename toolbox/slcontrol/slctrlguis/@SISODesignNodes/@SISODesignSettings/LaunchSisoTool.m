function h = LaunchSisoTool(this)
%LAUNCHSISOTOOL  Create and launch the multi-loop SISO tool
%

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/11 00:37:05 $

if ((~isempty(this.SISODesignGUI)) && isa(this.SISODesignGUI.UserData,'sisogui.sisotool'))
    delete(this.SISODesignGUI);
end

%% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

%% Get the selected row for the operating condition
if ~isempty(this.Dialog)
    index = this.Dialog.OpCondPanel.getOpCondSelectPanel.OpCondTable.getSelectedRows + 1;
else
    index = 1;
end

%% Error out if the user has not selected an operating condition
if (index == 0)
    errordlg('Please select an operating point for linearization','Simulink Control Design')
    return
end
OpCondNode = getOpCondNode(this);
OpCondResults = OpCondNode.getChildren;

%% Get the operating point object
OpNode = OpCondResults(index); 
op = OpNode.OpPoint;

%% Get the valid blocks table data
tabledata = this.ValidElementsTableModelUDD.data;

%% Clear the status area
ExplorerFrame.clearText;

%% Extracting Linearized Models
ExplorerFrame.postText(sprintf(' - Extracting Linear Model from: %s.',this.Model))

%% Get the selected compensator blocks
Compensators = {};
for ct = 1:this.ValidElementsTableModelUDD.getRowCount
    if tabledata(ct,1)
        blockname = tabledata(ct,2);
        Compensators{end+1,1} = blockname;
        %% Get the linearizations of the Compensators
        blocktype = get_param(blockname,'BlockType');
        switch blocktype
            case 'TransferFcn'
                num = evalin('base',get_param(blockname,'Numerator'));
                den = evalin('base',get_param(blockname,'Denominator'));
                sys = zpk(tf(num,den));
                if isempty(this.ValidBlocks{ct,2})
                    Compensators{end,2} = sys;
                    this.ValidBlocks{ct,2} = sys;
                else
                    Compensators{end,2} = zpk(this.ValidBlocks{ct,2}.z,...
                        this.ValidBlocks{ct,2}.p,...
                        this.ValidBlocks{ct,2}.k);
                end
            case 'StateSpace'
                A = evalin('base',get_param(blockname,'A'));
                B = evalin('base',get_param(blockname,'B'));
                C = evalin('base',get_param(blockname,'C'));
                D = evalin('base',get_param(blockname,'D'));
                sys = zpk(ss(A,B,C,D));
                if isempty(this.ValidBlocks{ct,2})
                    Compensators{end,2} = sys;
                    this.ValidBlocks{ct,2} = sys;
                else
                    Compensators{end,2} = zpk(this.ValidBlocks{ct,2}.z,...
                        this.ValidBlocks{ct,2}.p,...
                        this.ValidBlocks{ct,2}.k);
                end
        end
        Compensators{end,2}.Name = blockname;
    end
end

%% Get the full linearized plant P
P = getOpenLoopModel(this,op,Compensators(:,1));

%% Store the number of compensators
nc = size(Compensators,1);

%% Get the number of plant inputs and outputs
[ny,nu] = size(P);
%% Store the number of closed loop responses
this.NumberResponses = (ny-nc)*(nu-nc);

%% Scan compensators
Models = cell(nc,1);   Models(:) = {1};
ModelNames = cell(nc,1);
for ct=1:nc
    NextArg = Compensators{ct,2};
    ModelNames{ct} = sprintf('C%d',ct);
    Models{ct} = NextArg;
    ModelNames{ct} = get_param(Compensators{ct,1},'Name');
end

%% Launching the SISO Tool
ExplorerFrame.postText(' - Launching the SISO Design Tool.')

%
%---- CREATE DATABASE ---------------
%

InitData = sisoinit(0,ModelNames);
InitData.Input = P.InputName(1:nu-nc);
InitData.Output = P.OutputName(1:ny-nc);
InitData.P.Value = P;
for ct=1:length(ModelNames)
   InitData.(ModelNames{ct}).Value = Models{ct};
end

%% Create model database
LoopData = sisodata.loopdata;
% LoopData.setconfig(0,ModelNames,P.InputName(1:nu-nc),P.OutputName(1:ny-nc));
LoopData.setconfig(InitData);

% Validate model data before creating GUI (avoids pain of destroying it)
try
   InitData = checkdata(LoopData,InitData);
catch
   rethrow(lasterror)
end

%% Validate model data before creating GUI (avoids pain of destroying it)
% PlantModel = struct('Name','P','Value',P);
% TunedModels = struct('Name',ModelNames,'Value',Compensators(:,2));
% try
%     [PlantModel,TunedModels] = checkdata(LoopData,PlantModel,TunedModels);
% catch
%     rethrow(lasterror)
% end

%% Create GUI database
sisodb = sisogui.sisotool;
sisodb.LoopData = LoopData;

%% Show waitbar
hWaitbar = waitbar(0,'SISO Design GUI is loading. Please wait...');

%% Specify analysis views of interest

%% Reference to Output
LoopTF = [];
for ct1 = 1:(nu-nc)
    for ct2 = 1:(ny-nc)
        LoopTF = [LoopTF;sisodata.looptransfer];
        LoopTF(end).Type = 'T';
        LoopTF(end).Index = {ct2 ct1};
        LoopTF(end).Description = sprintf('Closed Loop: r%d to y%d',ct1,ct2);
        LoopTF(end).Style = 'b';
    end
end

for ct = 1:nc
    LoopTF = [LoopTF;sisodata.looptransfer];
    LoopTF(end).Type = 'C';
    LoopTF(end).Index = ct;
    LoopTF(end).Description = ModelNames{ct};
    LoopTF(end).Style = 'r--';
end

LoopData.LoopView = LoopTF(:);

%%
%% ---- CREATE GUI ---------------
%%

% Create figure
SISOfig = LocalOpenFig;
sisodb.Figure = SISOfig;

% Create event manager
sisodb.EventManager = ctrluis.framemgr(SISOfig);
sisodb.EventManager.EventRecorder = ctrluis.recorder;

% Initialize preferences
waitbar(0.1,hWaitbar)
sisodb.Preferences = LocalInitPref(sisodb,SISOfig);
CompFormat = sisodb.Preferences.CompensatorFormat;
for ct=1:nc
    LoopData.C(ct).Format = CompFormat;
end

% Create graphical design tools (editors)
waitbar(0.2,hWaitbar)
ged1 = sisogui.rleditor(LoopData,1);      % Root Locus Editor
ged2 = sisogui.bodeditorOL(LoopData,1);   % Open-loop Bode editor
Editors = [ged1;ged2];

% Create text editors
waitbar(0.4, hWaitbar)
ntexted = 1;
ted1 = sisogui.pzeditor(LoopData, sisodb);
ted2 = sisogui.tooldlg(sisodb.PlotEditors);
sisodb.TextEditors = [ted1;ted2];

% Pass relevant info to editors
set(Editors,...
    'EventManager',sisodb.EventManager,...
    'TextEditor', ted1,...
    'ConstraintEditor', ted2);

% Render GUI frames, menus, and toolbar
waitbar(0.5,hWaitbar)
% set(SISOfig,'Visible','on')
sisodb.addcontrols;

% Install GUI-wide listeners
sisodb.addlisteners;

% Initialize plot editors
waitbar(0.6,hWaitbar)
for ct=1:length(Editors)
    Editors(ct).initialize(sisodb);
end

% RE: Installs listeners to editor visiblity
sisodb.PlotEditors = Editors;

% Store database handle and set figure callbacks
set(SISOfig,'UserData',sisodb,...
    'DeleteFcn',{@LocalCloseCB sisodb},...
    'ResizeFcn',{@LocalResizeCB sisodb},...
    'KeyPressFcn',{@LocalKeyPressCB sisodb},...
    'WindowButtonMotionFcn',{@LocalWindowButtonMotion sisodb})

%
%---- RENDER LOOP DATA ---------------
%

waitbar(0.8,hWaitbar)

% Import model data if provided (RE: already validated, so no error here...)
% Start transaction
T = ctrluis.transaction(LoopData,'Name','Import',...
    'OperationStore','on','InverseOperationStore','on');

% Import data
LoopData.importdata(InitData);
ImportStatus = 'Right-click on the plots for more design options.';

% Commit and register transaction
sisodb.EventManager.record(T);

% Notify peers of data change
LoopData.dataevent('all');

% Force update of configuration-dependent views and menus
LoopData.send('ConfigChanged')

%
%---- MAKE FIGURE VISIBLE AND COMPLETE INIT IN BACKGROUND
%

waitbar(1,hWaitbar)
close(hWaitbar)

% Make figure visible
set(SISOfig,'Visible','on')

% Turn active graphical editors on
set(sisodb.PlotEditors,'Visible','on');

% Hack to get around geck 78462
% (We are just toggling the position of the rlocus edit menu)
if isunix
    pp = get(sisodb.HG.Menus.Edit.Rlocus,'Position');
    set(sisodb.HG.Menus.Edit.Rlocus,'Position',pp-1,'Position',pp)
end

% Initialize status and history
sisodb.EventManager.newstatus(ImportStatus);
sisodb.EventManager.recordtxt('history',...
    sprintf('%s: Starting SISO Tool for system: %s.',date,sisodb.LoopData.Name));

% Call the start-up message box
LocalStartUpMsgBox(sisodb);

% Return figure handle if requested
if nargout,
    h = SISOfig;
end

% Set the color of the figure
% set(SISOfig,'Color', [0.9255    0.9137    0.8471])
%% Add the listeners to each of the controller elements
pkg = findpackage('sisodata');
cls = findclass(pkg, 'tunedmodel');
prop_gain = cls.findprop('Gain');
prop_pzgroup = cls.findprop('PZGroup');

CompensatorListeners = {};
for ct = 1:length(sisodb.LoopData.C)
    C = sisodb.LoopData.C(ct);
    CompensatorListeners{end+1,1} = handle.listener(C, prop_gain, ...
        'PropertyPostSet',{@LocalUpdateCompensator,this,...
            get_param(Compensators{ct,1},'Handle'),C});
    CompensatorListeners{end,2} = handle.listener(C, prop_pzgroup, ...
        'PropertyPostSet',{@LocalUpdateCompensator,this,...
            get_param(Compensators{ct,1},'Handle'),C});
end
this.CompensatorListeners = CompensatorListeners;

this.DesignToolButtonUDD.setText('Refresh SISO Design Tool')

%% Add a listener to change the Design Tool Button if SISOTool is closed
this.SISOToolListeners = handle.listener(sisodb,'ObjectBeingDestroyed',{@LocalDeleteSISOTOOL, this});

%% Complete
ExplorerFrame.postText(' - SISO Design Tool is ready.')

%-------------------------Internal Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeleteSISOTOOL %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDeleteSISOTOOL(es,ed,this)

%% Clear the property for the SISO Design GUI
this.SISODesignGUI = [];

%% Set the text of the launch button back to its original state
this.DesignToolButtonUDD.setText('SISO Design Tool')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateCompensator %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateCompensator(es,ed,this,FullBlockName,C)

%% Get the index
ind = find(FullBlockName == [this.ValidBlocks{:,1}]);

%% Set then new value
this.ValidBlocks{ind,2} = zpk(C);

%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%%
%%%%%%%%%%%%%%%%%%%%
function SISOfig = LocalOpenFig()

SISOfig = figure(...
    'IntegerHandle','off', ...
    'DoubleBuffer','on', ...
    'MenuBar','none', ...
    'Name',prepender('SISO Design Tool'), ...
    'NumberTitle','off', ...
    'Unit','character', ...
    'Visible','off', ...
    'Tag','SISODesignFig');

% Colormap must be set after figure is created
% (for some reason this will open a new figure if handlevis=off)
set(SISOfig,'Colormap',gray,'HandleVisibility','callback');

% Install CS help
cshelp(SISOfig);
mapfile = ctrlguihelp;
if ~isempty(mapfile)
    set(SISOfig,'HelpTopicMap',mapfile,'HelpFcn',@LocalHelpCB);
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalInitPref %%%
%%%%%%%%%%%%%%%%%%%%%
function Preferences = LocalInitPref(sisodb,SISOfig)
% Initializes preferences
Preferences = sisogui.sisoprefs(sisodb);

% Set default fonts
set(SISOfig,...
    'DefaultUIControlFontSize',Preferences.UIFontSize,...
    'DefaultAxesFontSize',Preferences.AxesFontSize,...
    'DefaultTextFontSize',Preferences.AxesFontSize)

%%%%%%%%%%%%%%%%%%%%
%%% LocalCloseCB %%%
%%%%%%%%%%%%%%%%%%%%
function LocalCloseCB(hSrc,event,sisodb)
sisodb.close;

%%%%%%%%%%%%%%%%%%%%%
%%% LocalResizeCB %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalResizeCB(hSrc,event,sisodb)
sisodb.resize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalWindowButtonMotion %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWindowButtonMotion(hSrc,event,sisodb,EventDescription)
% Hack around lack of local mouse motion callbacks
sisodb.mouseevent('wbm');

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalKeyPressCB %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalKeyPressCB(hSrc,event,sisodb)
sisodb.keyevent;

%%%%%%%%%%%%%%%%%%%
%%% LocalHelpCB %%%
%%%%%%%%%%%%%%%%%%%
function LocalHelpCB(hFigure,eventData)
% Invoke help browser
Selection = get(hFigure,'CurrentObject');
HelpTopicKey = get(Selection,'HelpTopicKey');
if length(HelpTopicKey)
    helpview(get(hFigure,'HelpTopicMap'),HelpTopicKey,'CSHelpWindow');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStartUpMsgBox %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStartUpMsgBox(sisodb)
% Reads the cstprefs.mat file and shows start-up message box if required

h = sisodb.Preferences.ToolboxPreferences;
if strcmp(h.StartUpMsgBox.SISOtool,'on')
    Handles = startupdlg(sisodb.Figure, 'SISOtool', h);
    set(Handles.Figure, 'Name', xlate('Getting Started with the SISO Design Tool'));
    set(Handles.HelpBtn,'Callback','ctrlguihelp(''sisotoolmainhelp'');');
    set(Handles.TextMsg,'String',{'The SISO Design Tool is an interactive graphical user interface that facilitates the design of compensators for single-input, single-output (SISO) feedback loops.' ...
            ' ' ...
            'Click the Help button to find out more about the SISO Design Tool.'});
end
