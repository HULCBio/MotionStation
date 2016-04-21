function c2dtool(sisodb)
%C2DTOOL Opens and operates the Conversion window

%   Authors: Karen D. Gondoly and P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.33.4.2 $  $Date: 2004/04/10 23:14:21 $

LoopData = sisodb.LoopData;

% Conversion methods
Methods = {...
        'zoh' , 'Zero-Order Hold';...
        'foh' , 'First-Order Hold';...
        'tustin' , 'Tustin';...
        'prewarp' , 'Tustin w/Prewarping';...
        'matched' , 'Matched Pole-Zero'};

% Open window
ConvertFig = LocalOpenFig(sisodb,Methods);

% Install listeners
lsnr(1) = handle.listener(LoopData,...
    'ObjectBeingDestroyed',{@LocalClose ConvertFig});
lsnr(2) = handle.listener(LoopData,...
    'LoopDataChanged',{@LocalClose ConvertFig});

% Store model data
UIData = struct(...
    'G',LoopData.Plant.Model,...
    'H',LoopData.Sensor.Model,...
    'F',LoopData.Filter.zpk,...
    'C',LoopData.Compensator.zpk,...
    'Listener',lsnr);
set(ConvertFig,'UserData',UIData,'Visible','on')


%------------------------ Callback Functions --------------------

%%%%%%%%%%%%%%
% LocalClose %
%%%%%%%%%%%%%%
function LocalClose(hSrc,event,ConvertFig)
% Close constraint dialog when GUI is closed
delete(ConvertFig)


%%%%%%%%%%%%%%%%
% LocalConvert %
%%%%%%%%%%%%%%%%
function LocalConvert(hSrc,event,Methods,sisodb,Handles,CloseFlag)
% Converts initial model data to selected domain using specified parameters

FigUd = get(Handles.Figure,'UserData');  % contains initial model data
InitialTs = FigUd.C.Ts;                  % initial sample time

% Determine target domain
ToContinuous = (get(Handles.DiscreteButton,'Value')==0);

% Get conversion method and related data
Selections = get(Handles.Method(:,2),{'Value'});
Methods = Methods(cat(1,Selections{:}));

% Critical frequencies (for prewarp method only)
CritFreq = cell(4,1);
ipw = find(strcmp(Methods,'prewarp'));
CritFreq(ipw) = get(Handles.Method(ipw,4),{'UserData'});


% Perform conversion
try
    if ToContinuous
        % D2C conversion
        ConvertFcn = 'd2c';
        Args = [Methods,CritFreq];
        ActionDetails = 'Converted the loop components to continuous time.';
    else
        % C2D or D2D conversion
        TargetTs = abs(get(Handles.SampleTimeEdit,'UserData'));
        Args = cell(4,1);
        Args(:,1) = {TargetTs};
        if InitialTs,
            % D2D conversion
            ConvertFcn = 'd2d';
            ActionDetails = sprintf('Resampled the loop components to new sample time of %0.3g seconds.',...
                TargetTs);
        else
            ConvertFcn = 'c2d';
            Args = [Args,Methods,CritFreq];
            ActionDetails = sprintf('Discretized the loop components using a sample time of %0.3g seconds.',...
                TargetTs);
        end
    end
    
    % Perform conversion
    G = feval(ConvertFcn,FigUd.G,Args{1,:});
    C = feval(ConvertFcn,FigUd.C,Args{2,:});
    F = feval(ConvertFcn,FigUd.F,Args{3,:});
    H = feval(ConvertFcn,FigUd.H,Args{4,:});
    
catch         
    errmsg = fliplr(strtok(fliplr(lasterr),sprintf('\n')));
    errordlg(errmsg,'Conversion Error','modal');
    return
    
end

% Unlock all axes limits
idxVis = find(strcmp(get(sisodb.PlotEditors,'Visible'),'on'));
for ct=idxVis',
    zoomout(sisodb.PlotEditors(ct));
end

% Import converted models 
LoopData = sisodb.LoopData;
EventMgr = sisodb.EventManager;
G = struct('Name',LoopData.Plant.Name,'Model',G);
H = struct('Name',LoopData.Sensor.Name,'Model',H);
F = struct('Name',LoopData.Filter.Name,'Model',F);
C = struct('Name',LoopData.Compensator.Name,'Model',C);

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Conversion',...
    'OperationStore','on','InverseOperationStore','on');

% Perform conversion and register transaction (error-free here)
LoopData.importdata(G,H,F,C);

% Commit and store transaction
EventMgr.record(T);

% Disable listener for closing the Conversion dialog when a DataChanged event is fired,
% notify peers of data change, and reenable listener
DataListener = FigUd.Listener(2); 
set(DataListener,'Enabled','off'); 
dataevent(LoopData,'all');
set(DataListener,'Enabled','on'); 

% Close system data view if open
% REVISIT: should update
DataViews = sisodb.DataViews;
delete(findobj(DataViews(ishandle(DataViews)),'flat','Tag','SystemView'))

% Update status and command history
EventMgr.newstatus(ActionDetails);
EventMgr.recordtxt('history',ActionDetails);

% Exit
if CloseFlag
    % Close window if requested
    delete(Handles.Figure)
else
    % Disable OK
    set(Handles.OK,'Enable','off');
end


%%%%%%%%%%%%%%%%%%
% LocalSetDomain %
%%%%%%%%%%%%%%%%%%
function LocalSetDomain(hSrc,event,ConversionType,Handles)
% Sets the target domain (continuous or discrete)

if strcmp(ConversionType,'d2c')
    % Target domain = continuous
    set(Handles.ContinuousButton,'Value',1)
    set(Handles.DiscreteButton,'Value',0)
    set([Handles.SampleTimeEdit,Handles.SampleTimeText],'Enable','off')
    set(Handles.Method,'Enable','on')
else
    % Target domain = discrete
    set(Handles.ContinuousButton,'Value',0)
    set(Handles.DiscreteButton,'Value',1)
    set([Handles.SampleTimeEdit,Handles.SampleTimeText],'Enable','on')
    if strcmp(ConversionType,'d2d')
        % discrete to discrete
        set(Handles.Method,'Enable','off')
    else
        set(Handles.Method,'Enable','on')
    end
end
set(Handles.OK,'Enable','On')


%%%%%%%%%%%%%%%%%%
% LocalSetMethod %
%%%%%%%%%%%%%%%%%%
function LocalSetMethod(hPopUp,event,Handles,Methods)
% Sets the conversion method

SelectedMethod = Methods{get(hPopUp,'Value')};
iPop = find(Handles.Method(:,2)==hPopUp);
if strcmp(SelectedMethod,'prewarp')
    set(Handles.Method(iPop,[3 4]),'Visible','on')
else
    set(Handles.Method(iPop,[3 4]),'Visible','off')
end
set(Handles.OK,'Enable','On')


%%%%%%%%%%%%%
% LocalEdit %
%%%%%%%%%%%%%
function LocalEdit(hEdit,event,Item,hOK)
% Edit the sample time or ctritical frequency
InputStr = get(hEdit,'String');
InputValue = eval(InputStr,'[]');

if ~isequal(size(InputValue),[1 1]) | ~isreal(InputValue) | ...
        ~isfinite(InputValue) | InputValue<=0,
    % Revert to previous value in edit box
    switch Item
    case 'Ts'
        warndlg(xlate('You must enter a valid nonnegative sample time.'), ...
            xlate('Conversion Warning'));
    case 'CF'
        warndlg(xlate('You must enter a valid critical frequency greater then zero.'), ...
            xlate('Conversion Warning'));
    end
    set(hEdit,'String',num2str(get(hEdit,'UserData')));
else
    % Log new value in
    InputStr = num2str(InputValue);
    set(hEdit,'UserData',InputValue,'String',InputStr)
end 

set(hOK,'Enable','On')



%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%% 
%%%%%%%%%%%%%%%%%%%%
function ConvertFig = LocalOpenFig(sisodb,Methods)

Ts = sisodb.LoopData.Ts;
if Ts
    % FOH not offered for DT
    Methods = Methods([1,3:5],:);
end

% Parameters
StdColor = get(0,'DefaultUIControlBackground');
StdUnit = 'character';
FigW = 53;
FigH = 22.5;
hBorder = 1.5;
vBorder = 0.5;
EditH = 1.5;
TextH = 1.1;
Toffset = 2;

% Create figure
ConvertFig = figure('Color',StdColor, ...
   'IntegerHandle','off', ...
   'Units',StdUnit,...
   'Resize','off',...
   'MenuBar','none', ...
   'Name',xlate('Continuous/Discrete Conversions'), ...
   'NumberTitle','off', ...
   'HandleVisibility','callback',...
   'Visible','off',...
   'Position',[10 10 FigW FigH],...
   'DockControls', 'off');

Handles.Figure = ConvertFig;
centerfig(ConvertFig,sisodb.Figure);

% Button group
BW = (FigW-5*hBorder)/4;  BH = 1.5;
X0 = hBorder; Y0 = vBorder;
Handles.OK = uicontrol('Parent',ConvertFig, ...
   'Units',StdUnit, ...
   'Position',[X0 Y0 BW BH], ...
   'String','OK');
X0 = X0+hBorder+BW;
uicontrol('Parent',ConvertFig, ...
   'Units',StdUnit, ...
   'Callback',{@LocalClose ConvertFig}, ...
   'Position',[X0 Y0 BW BH], ...
   'String','Cancel');
X0 = X0+hBorder+BW;
uicontrol('Parent',ConvertFig, ...
   'Units',StdUnit, ...
   'Callback','ctrlguihelp(''sisoconversion'');', ...
   'Position',[X0 Y0 BW BH], ...
   'String','Help');
X0 = X0+hBorder+BW;
Handles.Apply = uicontrol('Parent',ConvertFig, ...
   'Units',StdUnit, ...
   'Position',[X0 Y0 BW BH], ...
   'String','Apply');

% Method frame
Y0 = Y0+BH+vBorder; FW = FigW-2*hBorder; FH = 4*EditH+9*vBorder;
HTKey = 'sisoconversionmethod';
uicontrol('Parent',ConvertFig, ...
    'BackgroundColor',StdColor, ...
    'Units',StdUnit, ...
    'Position',[hBorder Y0 FW FH], ...
    'HelpTopicKey',HTKey,...
    'Style','frame');
uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Position',[hBorder+Toffset Y0+FH-TextH/2 20 TextH], ...
    'String','Conversion Method', ...
    'HelpTopicKey',HTKey,...
    'Style','text');
X0 = 3*hBorder; Y1 = Y0+2*vBorder; 
Handles.Method = zeros(4,4);
Components = {'G:';'C:';'F:';'H:'};
PW = 0.52*FW;  X1 = X0+3.5;  X2 = X1+PW+1;  X3 = X2+3;  EditW = FW-X3-hBorder;
for ct=4:-1:1,
    Handles.Method(ct,1) = uicontrol('Parent',ConvertFig, ...
        'Units',StdUnit, ...
        'BackgroundColor',StdColor, ...
        'HorizontalAlignment','left', ...
        'Position',[X0 Y1+(EditH-TextH)/2 3 TextH], ...
        'String',Components{ct}, ...
        'HelpTopicKey',HTKey,...
        'Style','text');
    Handles.Method(ct,2) = uicontrol('Parent',ConvertFig, ...
        'Units',StdUnit, ...
        'BackgroundColor',[1 1 1], ...
        'Position',[X1 Y1 PW EditH], ...
        'Style','popupmenu', ...
        'String',Methods(:,2),...
        'HelpTopicKey',HTKey,...
        'Value',1);
    Handles.Method(ct,3) = uicontrol('Parent',ConvertFig, ...
        'Units',StdUnit, ...
        'BackgroundColor',StdColor, ...
        'HorizontalAlignment','left', ...
        'Position',[X2 Y1+(EditH-TextH)/2 3 TextH], ...
        'String','at', ...
        'Visible','off',...
        'HelpTopicKey',HTKey,...
        'Style','text');    
    Handles.Method(ct,4) = uicontrol('Parent',ConvertFig, ...
        'Units',StdUnit, ...
        'BackgroundColor',[1 1 1], ...
        'HorizontalAlignment','left', ...
        'Position',[X3 Y1 EditW EditH], ...
        'Style','edit', ...
        'Visible','off',...
        'String','1',...
        'HelpTopicKey',HTKey,...
        'UserData',1);
    Y1 = Y1 + EditH + 1.45 * vBorder;
end

% Domain frame
Y0 = Y0+FH+2*vBorder; FH = 3*EditH+6*vBorder;
HTKey = 'sisoconversiondomain';
uicontrol('Parent',ConvertFig, ...
    'BackgroundColor',StdColor, ...
    'Units',StdUnit, ...
    'Position',[hBorder Y0 FW FH], ...
    'HelpTopicKey',HTKey,...
    'Style','frame');
uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Position',[hBorder+Toffset Y0+FH-TextH/2 11 TextH], ...
    'String','Convert to', ...
    'HelpTopicKey',HTKey,...
    'Style','text');
X0 = hBorder + 9;  Y0 = Y0 + 2*vBorder;
Handles.SampleTimeText = uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'HorizontalAlignment','left', ...
    'Position',[X0 Y0+(EditH-TextH)/2 19 TextH], ...
    'String','Sample time (sec):', ...
    'HelpTopicKey',HTKey,...
    'Style','text');
Handles.SampleTimeEdit = uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',[1 1 1], ...
    'HorizontalAlignment','left', ...
    'Position',[X0+20 Y0 0.3*FW EditH], ...
    'HelpTopicKey',HTKey,...
    'Style','edit');
X0 = 3*hBorder; Y0 = Y0+EditH+0.9*vBorder;
Handles.DiscreteButton = uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Horizontal','left', ...   
    'Position',[X0 Y0 0.8*FW EditH], ...
    'HelpTopicKey',HTKey,...
    'Style','radiobutton');
Y0 = Y0+EditH+0.8*vBorder;
Handles.ContinuousButton = uicontrol('Parent',ConvertFig, ...
    'Units',StdUnit, ...
    'BackgroundColor',StdColor, ...
    'Position',[X0 Y0 0.5*FW EditH], ...
    'Horizontal','left', ...   
    'String','Continuous time', ...
    'HelpTopicKey',HTKey,...
    'Style','radiobutton');

% Initialize based on current domain
if Ts
    % Current domain = discrete 
    set(Handles.DiscreteButton,'String','Discrete time with new sample time',...
        'Callback',{@LocalSetDomain 'd2d' Handles})
    set(Handles.ContinuousButton,'Enable','on')
    set(Handles.SampleTimeEdit,'String',num2str(Ts),'UserData',Ts)
    LocalSetDomain([],[],'d2c',Handles);
else
    % Current domain = continuous
    set(Handles.DiscreteButton,'String','Discrete time',...
        'Callback',{@LocalSetDomain 'c2d' Handles})
    set(Handles.ContinuousButton,'Enable','off')
    set(Handles.SampleTimeEdit,'String','1','UserData',1)
    LocalSetDomain([],[],'c2d',Handles);
end

% Callbacks
set(Handles.ContinuousButton,'Callback',{@LocalSetDomain 'd2c' Handles})
set(Handles.Method(:,2),'Callback',{@LocalSetMethod Handles Methods(:,1)})
set(Handles.Method(:,4),'Callback',{@LocalEdit 'CF' Handles.OK})
set(Handles.SampleTimeEdit,'Callback',{@LocalEdit 'Ts' Handles.OK})
set(Handles.OK,'Callback',{@LocalConvert Methods(:,1) sisodb Handles 1})
set(Handles.Apply,'Callback',{@LocalConvert Methods(:,1) sisodb Handles 0})

% Install CS help
% RE: Do this last for proper initialization when opened while CS help is on
cshelp(ConvertFig,sisodb.Figure);


