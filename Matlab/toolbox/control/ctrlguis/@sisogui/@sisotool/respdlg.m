function respdlg(sisodb,hMenu)
%RESPDLG  Opens and manages dialog for configuring loop response plots.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Revised  : N. Hickey
%              K. Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.24.4.2 $  $Date: 2004/04/10 23:14:30 $

% Check if dialog already exists

Dialog = get(hMenu,'UserData');
if ~isempty(Dialog) & ishandle(Dialog)
    % Grab last config
    PlotConfig = get(Dialog,'UserData');
else
    % Create the dialog
    Dialog = LocalCreateDialog(sisodb);
    set(hMenu,'UserData',Dialog)
    
    % Initialize configuration data structure
    % RE: Plot Contents = struct array with fields
    %    PlotType: string
    %    OpenLoop: 5x1 bool vector (selection of open-loop models)
    %    ClosedLoop: 5x1 bool vector (selection of closed-loop models)
    PlotConfig = struct('LoopConfig',[],'PlotContents',[]);
end

% Update loop configuration
PlotConfig.LoopConfig = sisodb.LoopData.Configuration;

% Initialize plot contents
ViewerContents = getViewerContents(sisodb);
if isempty(ViewerContents)
    % Default setup
    ViewerContents = struct('PlotType','step','VisibleModels',{{'$T_r2y'}}); 
end
PlotConfig.PlotContents = LocalFormatContent(ViewerContents,resplist(sisodb));

% Initialize dialog
Handles = getappdata(Dialog,'Handles');
set(Handles.List,'Value',1)

LocalUpdateLoopConfig(PlotConfig,Handles);
LocalUpdateList(PlotConfig,Handles);
LocalUpdateContents(PlotConfig,Handles);

% Store plot config info in UserData
set(Dialog,'UserData',PlotConfig)

% Bring dialog to front
figure(Dialog)


%----------------- Callback functions -----------------


%%%%%%%%%%%%%%%%
% LocalDestroy %
%%%%%%%%%%%%%%%%
function LocalDestroy(hSrc,event,Dialog)
% Callback when closing SISO Tool
delete(Dialog)


%%%%%%%%%%%%%%%%%%%
%%% LocalCancel %%%
%%%%%%%%%%%%%%%%%%%
function LocalCancel(hSrc,event,Dialog)
% Hide dialog
set(Dialog,'Visible','off')


%%%%%%%%%%%%%%%
%%% LocalOK %%%
%%%%%%%%%%%%%%%
function LocalOK(hSrc,event,Dialog,sisodb)
% OK callback
RespList = resplist(sisodb); % code names for loop transfer functions
OpenLoopAlias = RespList(strcmp(RespList(:,3),'open'),1);
ClosedLoopAlias = RespList(strcmp(RespList(:,3),'closed'),1);

% Build setup structure
PlotConfig = get(Dialog,'UserData');
Contents = PlotConfig.PlotContents;
PlotTypes = {Contents.PlotType}.';
Selections = cell(size(Contents));
for ct=1:length(Contents)
   % Replace booleans by standard names
   Selections{ct} = [ClosedLoopAlias(Contents(ct).ClosedLoop) ; OpenLoopAlias(Contents(ct).OpenLoop)];
end
idxValid = find(~(cellfun('isempty',Selections) | strcmp(PlotTypes,'none')));
ViewerContents = struct('PlotType',PlotTypes(idxValid),'VisibleModels',Selections(idxValid));

% Hide dialog
set(Dialog,'Visible','off')

% Pass setup to LTI Viewer
if length(ViewerContents)
    setViewerContents(sisodb,ViewerContents);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalFormatContent %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function PlotContents = LocalFormatContent(ViewerContents,RespList)
% Transforms Viewer contents description into local PlotContents structure
OpenLoopAlias = RespList(strcmp(RespList(:,3),'open'),1);
ClosedLoopAlias = RespList(strcmp(RespList(:,3),'closed'),1);

DefaultPlots(1:6,:) = {'none'}; 
PlotContents = struct(...
   'PlotType',DefaultPlots,... 
   'OpenLoop',false(5,1),...
   'ClosedLoop',false(5,1)); 
for ct=1:length(ViewerContents)
    PlotContents(ct).PlotType = ViewerContents(ct).PlotType;
    [junk,ia,ib] = intersect(ViewerContents(ct).VisibleModels,OpenLoopAlias);
    PlotContents(ct).OpenLoop(ib) = true;
    [junk,ia,ib] = intersect(ViewerContents(ct).VisibleModels,ClosedLoopAlias);
    PlotContents(ct).ClosedLoop(ib) = true;
end


%%%%%%%%%%%%%%%%%%%%
%%% LocalSetType %%%
%%%%%%%%%%%%%%%%%%%%
function LocalSetType(hSrc,event,Dialog)
% Change plot type from popup menu
PlotConfig = get(Dialog,'UserData');
Handles = getappdata(Dialog,'Handles');

% Get new type for selected plot
PlotNum = get(Handles.List,'Value');
PlotTypes = get(hSrc,'String');
NewType = PlotTypes{get(hSrc,'Value')};

% Update database
PlotConfig.PlotContents(PlotNum).PlotType = NewType;
set(Dialog,'UserData',PlotConfig)

% Update GUI
LocalUpdateList(PlotConfig,Handles);
LocalUpdateContents(PlotConfig,Handles);
    

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSelectPlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSelectPlot(hSrc,event,Dialog)
% Callback when selecting plot in master list
PlotConfig = get(Dialog,'UserData');
Handles = getappdata(Dialog,'Handles');

% Update GUI
LocalUpdateList(PlotConfig,Handles);
LocalUpdateContents(PlotConfig,Handles);
    

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSelectModel %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSelectModel(hSrc,event,Dialog,OpenClosedFlag)
% Checkbox callback
PlotConfig = get(Dialog,'UserData');
Handles = getappdata(Dialog,'Handles');

% Selected plot
PlotNum = get(Handles.List,'Value');
% Update data base
if strcmp(OpenClosedFlag,'open')
    NewValues = get(Handles.Check.Open,{'Value'});
    PlotConfig.PlotContents(PlotNum).OpenLoop = logical(cat(1,NewValues{:}));
else
    NewValues = get(Handles.Check.Closed,{'Value'});
    PlotConfig.PlotContents(PlotNum).ClosedLoop = logical(cat(1,NewValues{:}));
end    
set(Dialog,'UserData',PlotConfig)


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalChangeConfig %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalChangeConfig(hProp,event,Dialog)
% Callback when changing loop configuration
PlotConfig = get(Dialog,'UserData');
PlotConfig.LoopConfig = event.NewValue;
% Update rendering
LocalUpdateLoopConfig(PlotConfig,getappdata(Dialog,'Handles'));
% Save config change
set(Dialog,'UserData',PlotConfig)


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateList %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateList(PlotConfig,Handles)
% Updates plot list frame
% 1) List box contents
PlotList = {PlotConfig.PlotContents.PlotType};
SelectionType = PlotList{get(Handles.List,'Value')};  % type of highlighted plot
for ct=1:6,
    PlotList{ct} = sprintf('%d. %s',ct,PlotList{ct});
end
set(Handles.List,'String',PlotList);
% 2) Update popup
set(Handles.Type,'Value',find(strcmp(SelectionType,get(Handles.Type,'String'))))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateLoopConfig %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateLoopConfig(PlotConfig,Handles)
% Updates loop configuration diagram
NewConfig = PlotConfig.LoopConfig;
% Update plot
ConfigHandles = loopstruct(NewConfig,Handles.Axes,'signal');
% Update closed-loop model description
OLText = {'Loop Transfer L';'Compensator C';'Filter F';'Plant G';'Sensor H'};
switch NewConfig
case {1,2}
   CLText = {'r to y  (FCGS)';'r to u  (FCS)';'du to y  (GS)';'dy to y  (S)';'n to y  (CGS)'};
case 3
   CLText = {'r to y  (F+C)GS ';'r to u   (F+C)S ';'du to y  (GS)';'dy to y  (S)';'n to y  (CGS)'};    
case 4
   CLText = {'r to y  (CGS)';'r to u  (CS)';'du to y  (GS)';'dy to y  (S)';'n to y  (F-C)GS '};  
end
set(Handles.Text.Open,{'String'},OLText);
set(Handles.Text.Closed,{'String'},CLText);
switch NewConfig
case {1,2,3}
    LoopTransferStr = 'Loop Transfer: L = CGH';
    SensitivityStr  = 'Sensitivity:  S = 1/(1+L)';
case 4
    % Filter forms a minor-loop
    LoopTransferStr = 'Loop Transfer: L = GH/(1-FGH)';
    SensitivityStr  = 'Sensitivity:  S = 1/(1+(C-F)GH)';
end
set(Handles.LoopTransfer,'String',LoopTransferStr);
set(Handles.Sensitivity,'String',SensitivityStr);

% Set CS help keys
c = struct2cell(ConfigHandles);
set(cat(1,c{:}),'HelpTopicKey','sisoresploopdiagram')


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateContents %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateContents(PlotConfig,Handles)
% Updates plot contents frame
PlotNum = get(Handles.List,'Value');
% 1) Update frame title
set(Handles.Title,'String',sprintf('Contents of Plot %d',PlotNum))
% 2) Update check/enable state
Contents = PlotConfig.PlotContents(PlotNum);
hCheck = Handles.Check;
if strcmp(Contents.PlotType,'none')
    set([hCheck.Open;hCheck.Closed],'Enable','off','Value',0)
else
    set([hCheck.Open;hCheck.Closed],'Enable','on')
    set(hCheck.Open,{'Value'},num2cell(Contents.OpenLoop,2))
    set(hCheck.Closed,{'Value'},num2cell(Contents.ClosedLoop,2))
end


%----------------- Rendering functions -----------------


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateDialog %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function Dialog = LocalCreateDialog(sisodb)

% Dimensioning Params (in char. units)
FigW = 81;
FigH = 24; 
Params = struct(...
   'hBorder',1.5,...
   'vBorder',0.5,...
   'TextH',1.1,...
   'EditH',1.5,...
   'Toffset',2,...
   'StdUnit','character',...
   'StdColor',get(0,'DefaultUIControlBackground'));

% Create dialog figure
Dialog = figure(...
   'Units',Params.StdUnit, ...
   'Color',Params.StdColor, ...
   'MenuBar','none', ...
   'Visible','off',...
   'IntegerHandle','off',...
   'HandleVisibility','callback',...
   'Name',xlate('Response Plot Setup'), ...
   'NumberTitle','off', ...
   'Position',[3 7 FigW FigH], ...
   'Resize','off',...
   'DockControls', 'off');

centerfig(Dialog,sisodb.Figure);
set(Dialog,'CloseRequestFcn',{@LocalCancel Dialog})

% Buttons
[ButtonPos,hButtons] = LocalCreateButtons(Dialog,FigW,Params);

% Plot Contents frame
X0 = 0.39*FigW;  Y0 = ButtonPos(4)+2*Params.vBorder;
PCFPos = [X0 Y0 FigW-X0-Params.hBorder NaN];
[PCFPos,Handles.Check,Handles.Text,Handles.Title] = LocalCreateContents(Dialog,PCFPos,Params);

% Plot List frame
PLFPos = [Params.hBorder Y0 FigW-3*Params.hBorder-PCFPos(3) PCFPos(4)];
[Handles.List,Handles.Type] = LocalCreateList(Dialog,PLFPos,Params);

% Feedback structure
AxisH = FigH-PCFPos(2)-PCFPos(4)-3.2;  AxisW = 0.6*FigW;
X0 = 0.05*FigW;  Y0 = FigH-AxisH-1.2;      
Handles.Axes = axes('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'Color',Params.StdColor, ...
    'Xcolor',Params.StdColor, ...
    'Ycolor',Params.StdColor, ...
    'Position',[X0 Y0 AxisW AxisH],... 
    'HelpTopicKey','sisoresploopdiagram',...
    'XTick',[],'YTick',[]);

% Definitions
X0 = .59*FigW;   Y0 = FigH-.85*AxisH;
props = struct('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Horizontal','left',...
    'HelpTopicKey','sisoresploopdiagram',...
    'Style','text');
Handles.Sensitivity = uicontrol(props,'Position',[X0 Y0 35 Params.TextH]);

Y0 = Y0 + 2*Params.TextH;
Handles.LoopTransfer = uicontrol(props,'Position',[X0 Y0 35 Params.TextH]);

% Hook up callbacks
set(Handles.Type,'Callback',{@LocalSetType Dialog})
set(Handles.List,'Callback',{@LocalSelectPlot Dialog})
set(Handles.Check.Open,'Callback',{@LocalSelectModel Dialog 'open'})
set(Handles.Check.Closed,'Callback',{@LocalSelectModel Dialog 'closed'})
set(hButtons(1),'Callback',{@LocalOK Dialog sisodb});
set(hButtons(2),'Callback',{@LocalCancel Dialog});

% Listeners
LoopData = sisodb.LoopData;
Listeners(1) = handle.listener(LoopData,...
    'ObjectBeingDestroyed',{@LocalDestroy Dialog});
Listeners(2) = handle.listener(LoopData,findprop(LoopData,'Configuration'),...
    'PropertyPostSet',{@LocalChangeConfig Dialog});

% Store GUI data
setappdata(Dialog,'Handles',Handles);
setappdata(Dialog,'Listeners',Listeners);

% Intall CS help
cshelp(Dialog,sisodb.Figure);


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateList %%%
%%%%%%%%%%%%%%%%%%%%%%%
function [hList,hType] = LocalCreateList(Dialog,PLFPos,Params)

X0 = PLFPos(1); Y0 = PLFPos(2);
HTKey = 'sisorespplotlist';

% Frame
F = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',PLFPos, ...
    'Style','frame');
uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[X0+Params.Toffset Y0+PLFPos(4)-Params.TextH/2 7 Params.TextH], ...
    'FontWeight','bold',...
    'String','Plots', ...
    'HelpTopicKey',HTKey,...
    'Style','text');

% Plot Type
X0 = X0 + Params.hBorder;
Y0 = Y0 + 1.8*Params.vBorder;
PlotTypes = {'step';'impulse';'bode';'nyquist';'nichols';'pzmap';'none'};
uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[X0 Y0 11 Params.TextH], ...
    'Style','text',...
    'Horizontal','left',...
    'HelpTopicKey',HTKey,...
    'String','Change to:');
hType = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',[1 1 1], ...
    'Position',[X0+11.5 Y0-0.2 PLFPos(3)-11.5-2*Params.hBorder Params.EditH], ...
    'String',PlotTypes,...
    'HelpTopicKey',HTKey,...
    'Style','popupmenu');

% Plot list
Y0 = Y0+1.5*Params.TextH;
LBH = PLFPos(4) - (Y0-PLFPos(2)) - 2*Params.vBorder;
hList = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',[1 1 1], ...
    'Position',[X0 Y0 PLFPos(3)-2*Params.hBorder LBH], ...
    'HelpTopicKey',HTKey,...
    'Style','listbox');


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateContents %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [PCFPos,hCheck,hText,hTitle] = LocalCreateContents(Dialog,PCFPos,Params)
% Creates plot contents frame

% Frame
F = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[PCFPos(1:3) 15], ...
    'Style','frame');
HTKey = 'sisorespplotcontents';

% Check boxes 
X01 = PCFPos(1)+Params.Toffset+1; 
X02 = X01+0.47*PCFPos(3);
Y0 = PCFPos(2)+1.8*Params.vBorder;
hCheck = struct('Open',zeros(5,1),'Closed',zeros(5,1));
hText = struct('Open',zeros(5,1),'Closed',zeros(5,1));
for ct=5:-1:1,
    hCheck.Closed(ct) = uicontrol('Parent',Dialog, ...
        'Unit',Params.StdUnit,...
        'BackgroundColor',Params.StdColor, ...
        'Position',[X01+0.5 Y0 3 1.5], ...
        'HelpTopicKey',HTKey,...
        'Style','checkbox');
    hText.Closed(ct) = uicontrol('Parent',Dialog, ...
        'Unit',Params.StdUnit,...
        'BackgroundColor',Params.StdColor, ...
        'Position',[X01+4.5 Y0+.15*Params.TextH 16 Params.TextH], ...
        'Style','text',...
        'HelpTopicKey',HTKey,...
        'Horizontal','left');
    hCheck.Open(ct) = uicontrol('Parent',Dialog, ...
        'Unit',Params.StdUnit,...
        'BackgroundColor',Params.StdColor, ...
        'Position',[X02+0.5 Y0 3 1.5], ...
        'HelpTopicKey',HTKey,...
        'Style','checkbox');
    hText.Open(ct) = uicontrol('Parent',Dialog, ...
        'Unit',Params.StdUnit,...
        'BackgroundColor',Params.StdColor, ...
        'Position',[X02+4.5 Y0+.15*Params.TextH 16 Params.TextH], ...
        'Style','text',...
        'HelpTopicKey',HTKey,...
        'Horizontal','left');
    Y0 = Y0 + 1.5*Params.TextH;
end

% Headers
Y0 = Y0 + 0.1*Params.TextH;
uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[X01 Y0 20 Params.TextH], ...
    'Style','text',...
    'Horizontal','left',...
    'HelpTopicKey',HTKey,...
    'String','Closed-Loop:');
uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[X02 Y0 20 Params.TextH], ...
    'Horizontal','left',...
    'Style','text',...
    'HelpTopicKey',HTKey,...
    'String','Open-Loop:');

% Frame
FH = Y0 + 2.5*Params.TextH - PCFPos(2);
PCFPos(4) = FH;
set(F,'Position',PCFPos);
hTitle = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[PCFPos(1)+Params.Toffset PCFPos(2)+FH-Params.TextH/2 26 Params.TextH], ...
    'String','Contents of Plot No.1', ...
    'FontWeight','bold',...
    'HelpTopicKey',HTKey,...
    'Style','text');


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateButtons %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ButtonPos,Buttons] = LocalCreateButtons(Dialog,FigW,Params)
% Adds OK/Cancel/Help buttons

BW = 12;  BH = 1.5;  Gap = 2;
ButtonPos = [FigW-3*BW-Params.hBorder-2*Gap Params.vBorder BW BH];

Buttons(1) = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'Position',ButtonPos, ...
    'String','OK');
ButtonPos(1) = ButtonPos(1) + BW + Gap;
Buttons(2) = uicontrol('Parent',Dialog, ...
    'Callback','',...
    'Unit',Params.StdUnit,...
    'Position',ButtonPos, ...
    'String','Cancel',...
    'Callback',@LocalCancel);
ButtonPos(1) = ButtonPos(1) + BW + Gap;
Buttons(3) = uicontrol('Parent',Dialog, ...
    'Unit',Params.StdUnit,...
    'Callback','ctrlguihelp(''sisoresponsedialog'');',...
    'Position',ButtonPos, ...
    'String','Help');
