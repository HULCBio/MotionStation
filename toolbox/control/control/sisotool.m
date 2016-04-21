function varargout = sisotool(varargin);
%SISOTOOL  SISO Design Tool.
%
%   SISOTOOL opens the SISO Design Tool.  This Graphical User Interface
%   allows you to design single-input/single-output (SISO) compensators
%   by interacting with the root locus, Bode, and Nichols plots of the 
%   open-loop system.  To import the plant data into the SISO Tool, select 
%   the Import item from the File menu. By default, the loop configuration 
%   is
%             r -->[ F ]-->O--->[ C ]--->[ G ]----+---> y
%                        - |                      |
%                          +-------[ H ]----------+
%
%   SISOTOOL(G) specifies the plant model G to be used in the SISO Tool.  
%   Here G is any linear model created with TF, ZPK, or SS.
%
%   SISOTOOL(G,C) further specifies an initial value for the compensator C. 
%   Similarly, SISOTOOL(G,C,H,F) supplies additional models for the sensor H 
%   and the prefilter F.
%
%   SISOTOOL(VIEWS) or SISOTOOL(VIEWS,G,...) specifies the initial 
%   configuration of the SISO Tool.  VIEWS can be any of the following 
%   strings (or combination thereof):
%       'rlocus'      Root locus plot
%       'bode'        Bode diagram of the open-loop response
%       'nichols'     Nichols plot of the open-loop response
%       'filter'      Bode diagram of the prefilter F
%   For example 
%       sisotool({'nichols','bode'})
%   opens a SISO Design Tool showing the Nichols plot and the open-loop 
%   Bode Diagram. 
%
%   You can also use an extra argument OPTIONS (structure) to specify any
%   of the following options:
%       OPTIONS.Location    Location of C ('forward' for forward path,
%                           'feedback' for return path)
%       OPTIONS.Sign        Feedback sign (-1 for negative, +1 for positive)
%
%   See also LTIVIEW, RLOCUS, BODE, NICHOLS.

%   Karen D. Gondoly, P. Gahinet
%   Revised: Kamesh Subbarao, 12-6-2001
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.81.4.2 $  $Date: 2004/04/10 23:13:56 $

ni=nargin;
error(nargchk(0,6,ni))
ParentFig = 0; % Opened from Command Line
ValidViews = {'rlocus';'bode';'nichols';'filter'};

% Defaults
Location = 1;  % feedforward
Sign = -1;     % negative feedback
SystemName = '';

% Parse input list
% a) Views
LastInput = 0;
if ni & (iscellstr(varargin{1}) | ischar(varargin{1}))
   DesignViews = varargin{1};
   if ~iscell(DesignViews)
      DesignViews = {DesignViews};
   end
   AllValid = all(ismember(DesignViews,ValidViews));
   if ~AllValid,
      error('Supported VIEWS are ''rlocus'', ''bode'', ''nichols'', and ''filter''.')
   end
   LastInput = LastInput + 1;
else
   DesignViews = {'rlocus','bode'};
end

% System name is inherited from G
if ni>LastInput
    SystemName = inputname(LastInput+1);
end

% Models G,C,H,F
Models = cell(1,4);
ModelNames = {'G','C','H','F'};
for ct=1:min(4,ni-LastInput),
    NextArg = varargin{LastInput+1};
    isModel = (isa(NextArg,'lti') | isa(NextArg,'idmodel')); % REVISIT: should be "system" parent class
    if ~isa(NextArg,'double') & ~isModel
        % done scanning model inputs
        break
    else
        if ~isequal(NextArg,[])  % skip []'s
            Models{ct} = struct('Name',inputname(LastInput+1),'Model',NextArg);
            if ~isModel | isempty(Models{ct}.Name)
                Models{ct}.Name = sprintf('untitled%s',ModelNames{ct});
            end
        end
        LastInput = LastInput+1;
    end
end
[G,C,H,F] = deal(Models{:});

% Options (last arg)
if ni>LastInput & isa(varargin{LastInput+1},'struct')
   Options = varargin{LastInput+1};
   LastInput = LastInput+1;
else
   Options = [];
end

% There should be no more input argument
if ni>LastInput,
   error(sprintf(...
      'Input arguments are not of proper type or in the expected order.\nType HELP SISOTOOL for details.'))
end


%---- DEFAULTS AND OPTIONS -----

% Defaults
if isempty(C)
    C = struct('Name','untitledC','Model',1);
end

% a) Location
if isfield(Options,'Location')
   Location = Options.Location;
   if ~isa(Location,'char')
      error('Compensator location must be specified as a string.')
   else
      switch lower(Location(1:min(2,end))),
      case 'fo',
         Location = 1;  % forward loop
      case 'fe',
         Location = 2;  % feedback loop
      otherwise,
         error('Compensator location must be either ''feedback'' or ''forward''.')
      end 
   end
end

% b) Feedback sign
if isfield(Options,'Sign') 
   Sign = Options.Sign;
   if ~ismember(Sign,[1,-1]),
      error('Feedback sign must be either -1 or +1.')
   end 
end

%
%---- CREATE DATABASE ---------------
%

% Create GUI database
sisodb = sisogui.sisotool;

% Create model database
LoopData = sisodata.loopdata;
sisodb.LoopData = LoopData;

% Validate model data before creating GUI (avoids pain of destroying it)
DataProvided = ~isempty(G);
if DataProvided
    try
        checkdata(LoopData,G,H,F,C);
    catch
        delete(sisodb)
        rethrow(lasterror)
    end
end

% Show waitbar
hWaitbar = waitbar(0,'SISO Design GUI is loading. Please wait...');


%
%---- CREATE GUI ---------------
%

% Create figure
SISOfig = LocalOpenFig;
sisodb.Figure = SISOfig;

% Create event manager
sisodb.EventManager = ctrluis.framemgr(SISOfig);
sisodb.EventManager.EventRecorder = ctrluis.recorder;

% Initialize preferences
waitbar(0.1,hWaitbar)
sisodb.Preferences = LocalInitPref(sisodb,SISOfig);
LoopData.Compensator.Format = sisodb.Preferences.CompensatorFormat;
LoopData.Filter.Format = sisodb.Preferences.CompensatorFormat;

% Create graphical design tools (editors)
% 1 -> Root Locus Editor
% 2 -> Open-loop Bode editor  
% 3 -> Open-loop Nichols editor
% 4 -> Filter Bode editor
waitbar(0.2,hWaitbar)
ged1 = sisogui.rleditor(LoopData.Compensator,LoopData);
ged2 = sisogui.bodeditorOL(LoopData.Compensator,LoopData);
ged3 = sisogui.nicholseditor(LoopData.Compensator,LoopData);
ged4 = sisogui.bodeditorF(LoopData.Filter,LoopData);
sisodb.PlotEditors = [ged1;ged2;ged3;ged4];

% Create text editors
waitbar(0.4, hWaitbar)
ntexted = 1;
ted1 = sisogui.pzeditor(LoopData, sisodb);
ted2 = sisogui.tooldlg(sisodb.PlotEditors);
sisodb.TextEditors = [ted1;ted2];

% Pass relevant info to editors
set(sisodb.PlotEditors,...
    'EventManager',sisodb.EventManager,...
    'TextEditor', ted1,...
    'ConstraintEditor', ted2);

% Render GUI frames, menus, and toolbar
waitbar(0.5,hWaitbar)
sisodb.addcontrols;

% Install GUI-wide listeners
sisodb.addlisteners;

% Initialize plot editors
waitbar(0.6,hWaitbar)
MenuAnchor = menuanchors(sisodb);
for ct=1:length(sisodb.PlotEditors)
   % Connect editors to object hierarchy
   sisodb.connect(sisodb.PlotEditors(ct),'down');
   % Get anchors for editor status/menus in main figure
   sisodb.PlotEditors(ct).MenuAnchors = MenuAnchor(ct);
   sisodb.PlotEditors(ct).initialize(sisodb.Preferences);
end

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

% Render loop parameters
if ~isempty(SystemName)
    LoopData.SystemName = SystemName;  % triggers fig name update
end
LoopData.Configuration = Location;   % triggers config. rendering
LoopData.FeedbackSign = Sign;        % updates sign rendering

% Import model data if provided (RE: already validated, so no error here...)
if DataProvided,
    % Start transaction
    T = ctrluis.transaction(LoopData,'Name','Import',...
        'OperationStore','on','InverseOperationStore','on');
    
    % Import data
    LoopData.importdata(G,H,F,C);
    ImportStatus = 'Right-click on the plots for more design options.';
    
    % Commit and register transaction
    sisodb.EventManager.record(T);
    
    % Notify peers of data change
    LoopData.dataevent('all');
else    
    % Empty start (no plant data)
    ImportStatus = 'Use Import Model... off the File menu to import the plant data.';
end

%
%---- MAKE FIGURE VISIBLE AND COMPLETE INIT IN BACKGROUND
%

waitbar(1,hWaitbar)
close(hWaitbar)

% Make figure visible
set(SISOfig,'Visible','on')

% Turn active graphical editors on
isActive = ismember(ValidViews,DesignViews);
set(sisodb.PlotEditors(isActive),'Visible','on');

% We are just toggling the position of the rlocus edit menu
if isunix
   pp = get(sisodb.HG.Menus.Edit.Rlocus,'Position');
   set(sisodb.HG.Menus.Edit.Rlocus,'Position',pp-1,'Position',pp)
end

% Initialize status and history
sisodb.EventManager.newstatus(ImportStatus);
sisodb.EventManager.recordtxt('history',...
    sprintf('%s: Starting SISO Tool for system: %s',date,sisodb.LoopData.SystemName));

% Call the start-up message box
LocalStartUpMsgBox(sisodb);

% Return figure handle if requested
if nargout,
   varargout{1} = SISOfig;
end


%-------------------------Internal Functions-------------------------

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
    'Tag','SISODesignFig', ...
    'DockControls','off'); 

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
% Work around lack of local mouse motion callbacks
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
