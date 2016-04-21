function varargout = powergui(varargin)
%POWERGUI Graphical user interface for the analysis of SimPowerSystems
%    circuits.
%
%    The POWERGUI block from POWERLIB opens a graphical user interface that 
%    displays steady-state values of measured currents and voltages, as well as 
%    states variables (inductor currents and capacitor voltages). 
%
%    The POWERGUI interface can be used to modify the initial states in order 
%    to start the simulation from any initial conditions. It also allows load 
%    flow computation and initialization of three phase networks containing 
%    machines.
%
%    Place the powergui block from powerlib in a model and double-click on it
%    to open the graphical user interface.
%
%    See also POWERINIT

%   Patrice Brunelle 05-08-1998, 31-mar-2004
%   Copyright 1997-2004 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.8 $

if nargin==0
    Message=['Graphical user interface for the analysis of SimPowerSystems circuits. ',setstr(10),...
            'Place the Powergui block in the top-level of your model and double-click on it to open the GUI.'];
    disp(Message);
    return
end
%            
if nargin == 1 | nargin == 2 % LAUNCH GUI
    %
    PowerguiBlock = varargin{1};
    RootSystem = bdroot(PowerguiBlock);
    if strcmp(RootSystem,'powerlib')|strcmp(RootSystem,'powerlib2')
        Message=['Graphical user interface for the analysis of SimPowerSystems circuits. ',...
                'Place this block in the top-level of your model and double-click on it to open the GUI.'];
        warndlg(Message,'POWERGUI');
        return
    end
    %
    if nargin == 1 & ~isempty(find_system(RootSystem,'LookUnderMasks','on','followlinks','on','PhysicalDomain','powersysdomain'))
          Message = 'This is an old version of the Powergui block. Please update your model to use the most recent version of the Powergui block from the powerlib library.';
          warndlg(Message,'POWERGUI');
          return    
    end
    %
    GUIHandles = get_param(PowerguiBlock,'UserData');
    if ~isempty(GUIHandles)
        if ishandle(GUIHandles.powergui)
            % the Powergui is already opened.
            FigureHandle = figure(GUIHandles.powergui);
            if nargout > 0
                varargout{1} = FigureHandle;
            end
            return
        end
    else
        % create GUIHandles:
        fig = openfig(mfilename,'reuse');
        if nargout > 0
            varargout{1} = fig;
        end
        GUIHandles.powergui = fig;
        GUIHandles.steadystate = [];
        GUIHandles.initstates = [];
        GUIHandles.loadflow = [];
        GUIHandles.ltiview = [];
        GUIHandles.zmeter = [];
        GUIHandles.ffttool = [];
        GUIHandles.report = [];
    end
    %
    fig = openfig(mfilename,'reuse');
    if nargout > 0
        varargout{1} = fig;
    end
    GUIHandles.powergui = fig;
    %
    set(fig,'Color',get(fig,'DefaultUIcontrolBackgroundColor'));
    kids = get(fig,'children');
    set(kids,'BackgroundColor',get(fig,'DefaultUIcontrolBackgroundColor'));
    set(findobj(kids,'Style','Edit'),'BackgroundColor',[1 1 1]);
    %
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    handles.block = PowerguiBlock;
    handles.system = RootSystem;
    set(fig,'name',handles.system);
    %
    guidata(fig, handles);
    set_param(handles.block,'UserData',GUIHandles);
    %
    % Set the "Sample Time" value.
    Ts = get_param(handles.block,'Ts');
    set(handles.edit1,'String',Ts);
    %
    % Set the phasor "frequency" value.
    LFfreq = get_param(handles.block,'frequency');
    set(handles.edit2,'String',LFfreq);
    %
    % patch for gecko#212513.
    [PhasorSimulation,DiscreteSimulation,ContinuousSimulation] = getPowerguiInfo(handles.system);
    
    % Hide/show the corresponding fields
    if PhasorSimulation
        set(handles.checkbox2,'value',1);
        set(handles.radiobutton1,'value',0);
        set(handles.edit1,'Enable','off');
        set(handles.text3,'Enable','off');
        set(handles.edit2,'Enable','on');
        set(handles.text4,'Enable','on');
        set(handles.edit1,'String','0');
        set_param(handles.block,'Ts','0');
    end
    %
    if DiscreteSimulation
        set(handles.checkbox3,'value',1);
        set(handles.radiobutton1,'value',0);
        set(handles.edit2,'Enable','off');
        set(handles.text4,'Enable','off');
        set(handles.edit1,'Enable','on');
        set(handles.text3,'Enable','on');
    end
    %
    if ContinuousSimulation
        set(handles.radiobutton1,'value',1); 
        set(handles.edit1,'Enable','off');
        set(handles.text3,'Enable','off');
        set(handles.edit2,'Enable','off');
        set(handles.text4,'Enable','off');
        %
        set(handles.edit1,'String','0');
        set_param(handles.block,'Ts','0');
    end
    % end of patch gecko#212513.      
    %
    % Set the "hide messages.." checkbox
    echomessages = get_param(handles.block,'echomessages');
    set(handles.checkbox1,'value',strcmp(echomessages,'off'));
    %
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    catch
        disp(lasterr);
    end
    
end


function varargout = checkbox1_Callback(h, eventdata, handles, varargin)
% callback echo off
value = get(handles.checkbox1,'Value');
if value
    set_param(handles.block,'echomessages','off');
else
    set_param(handles.block,'echomessages','on');
end


function varargout = checkbox2_Callback(h, eventdata, handles, varargin)
% checkbox for the phasor simulation : the phasor solution is activated
% each time we select this checkbox.
if isempty(varargin)
    set(handles.checkbox2,'value',1);
    set(handles.radiobutton1,'value',0);
    set(handles.checkbox3,'value',0);
    set(handles.edit1,'Enable','off');
    set(handles.text3,'Enable','off');
%     set_param(handles.block,'Ts','0');
    set(handles.edit2,'Enable','on')
    set(handles.text4,'Enable','on')
    fr = get(handles.edit2,'string');
    set_param(handles.block,'frequency',fr);
    set_param(handles.block,'methode','on');
end
SetTheMeasurementOutputSignalType(handles.system,'on');


function varargout = edit1_Callback(h, eventdata, handles, varargin)
% edit Ts for the discretisation
Ts = get(handles.edit1,'string');
set_param(handles.block,'Ts',Ts);


function varargout = edit2_Callback(h, eventdata, handles, varargin)
% edit for the load flow frequency
LFfreq = get(handles.edit2,'string');
set_param(handles.block,'frequency',LFfreq);


function varargout = checkbox3_Callback(h, eventdata, handles, varargin)
% Check button for discretisation
isdiscrete = get(handles.checkbox3,'value');
if ~isdiscrete 
    set(handles.checkbox3,'value',1);
else
    set(handles.radiobutton1,'value',0);
    set(handles.checkbox2,'value',0);
    set(handles.edit2,'Enable','off');
    set(handles.text4,'Enable','off');
    set_param(handles.block,'methode','off');
    handles = powergui('checkbox2_tozero',h, eventdata, handles, varargin);
    set(handles.edit1,'Enable','on')
    set(handles.text3,'Enable','on')
    Ts = get(handles.edit1,'string');
    set_param(handles.block,'Ts',Ts);
end


function varargout = radiobutton1_Callback(h, eventdata, handles, varargin) % Added by KDG
iscontinuous = get(handles.radiobutton1,'value');
if ~iscontinuous
    set(handles.radiobutton1,'value',1); 
else
    val2 = get(handles.checkbox2,'value');
    val3 = get(handles.checkbox3,'value');
    if val2,
        set(handles.checkbox2,'value',0)
        set(handles.edit2,'Enable','off');
        set(handles.text4,'Enable','off');
        set_param(handles.block,'methode','off');
        handles = powergui('checkbox2_tozero',h, eventdata, handles, varargin);
    end
    if val3,
        set(handles.checkbox3,'value',0);
        set(handles.edit1,'Enable','off');
        set(handles.text3,'Enable','off');        
    end
    set_param(handles.block,'Ts','0');
end


function varargout = checkbox4_Callback(h, eventdata, handles, varargin)
% Opens the Steady State Tools
set(handles.checkbox4,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbsteadystate(handles.system,handles.block);
end
set(handles.figure1,'Pointer','arrow')
set(handles.checkbox4,'enable','on');


function varargout = checkbox5_Callback(h, eventdata, handles, varargin)
% Opens the Initial States Tool
set(handles.checkbox5,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbinitstates(handles.system,handles.block);
end
set(handles.figure1,'Pointer','arrow');
set(handles.checkbox5,'enable','on');


function varargout = checkbox6_Callback(h, eventdata, handles, varargin)
% Opens the Load flow tools
set(handles.checkbox6,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbloadflow('OpenGui',handles.system,handles.block);
end
set(handles.figure1,'Pointer','arrow');
set(handles.checkbox6,'enable','on');


function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
% Open the LTI Viewer tools
set(handles.pushbutton2,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbltiview(handles.system,handles.block);
end
set(handles.figure1,'Pointer','arrow');
set(handles.pushbutton2,'enable','on');


function varargout = pushbutton3_Callback(h, eventdata, handles, varargin)
% Open the IMPEDANCEMEAS GUI
set(handles.pushbutton3,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbzmeter(handles.system,handles.block);
end
set(handles.figure1,'Pointer','arrow');    
set(handles.pushbutton3,'enable','on');


function varargout = pushbutton4_Callback(h, eventdata, handles, varargin)
% Open the FFTSCOPE GUI
set(handles.pushbutton4,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbfftscope(handles.block);
end
set(handles.figure1,'Pointer','arrow');
set(handles.pushbutton4,'enable','on');


function varargout = pushbutton5_Callback(h, eventdata, handles, varargin)
set(handles.pushbutton5,'enable','off');
psbreport(handles.system,handles.block);
set(handles.pushbutton5,'enable','on');


function varargout = Close_Callback(h, eventdata, handles, varargin)
% Close the powergui main window and all its childs windows.

if isempty(handles)
    % this function is called by the modelclosefcn or the deletefcn of
    % powergui block
    block = h;
else
    % this function is called by the close or the x button of powergui
    % interface.
    block = handles.block;
end

GUIHandles = get_param(block,'userData');
if isempty(GUIHandles)|~isstruct(GUIHandles)
    return
end
if ishandle(GUIHandles.steadystate)
    delete(GUIHandles.steadystate)
end
if ishandle(GUIHandles.initstates)
    delete(GUIHandles.initstates)
end
if ishandle(GUIHandles.loadflow)
    delete(GUIHandles.loadflow)
end
if ishandle(GUIHandles.ltiview)
    delete(GUIHandles.ltiview)
end
if ishandle(GUIHandles.zmeter)
    delete(GUIHandles.zmeter)
end
if ishandle(GUIHandles.ffttool)
    delete(GUIHandles.ffttool)
end
if ishandle(GUIHandles.report)
    delete(GUIHandles.report)
end
if ishandle(GUIHandles.powergui)
    delete(GUIHandles.powergui)
end


function varargout = Copy_Callback(block, deleteblock, handles, varargin)
%
system = bdroot(block);
if strcmp(system,'powerlib')
    return
end
if deleteblock
    methode = 'off';
else
    methode = get_param(block,'methode');
end
if strcmp(methode,'on')
    % phasor mode:
    handles.system=system;
    powergui('checkbox2_Callback',[], [], handles, 1);
else
    handles.system=system;
    powergui('checkbox2_tozero',[], [], handles, 1);
end
    
    

function varargout = pushbutton7_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton7.
set(handles.pushbutton7,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    psbhysteresis
end
set(handles.figure1,'Pointer','arrow');
set(handles.pushbutton7,'enable','on');


function varargout = LineConstant_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.pushbutton7.
set(handles.LineConstant,'enable','off');
set(handles.figure1,'Pointer','watch');
try
    power_lineparam;
end
set(handles.figure1,'Pointer','arrow');
set(handles.LineConstant,'enable','on');


function varargout = powergui_initfcn(h, eventdata, block, system);


function handles = checkbox2_tozero(h, eventdata, handles, varargin)
SetTheMeasurementOutputSignalType(handles.system,'off');


function varargout = Help_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol Help button.
web(psbhelp);


function SetTheMeasurementOutputSignalType(system,Etat)
% 
% Do not follow the links. The measurement blocks inside linked subsystems
% are not updated.
ThreePhaseMeasurements = find_system(system,'LookUnderMasks','on','MaskType','Three-Phase VI Measurement');
for i=1:length(ThreePhaseMeasurements)
    set_param(ThreePhaseMeasurements{i},'PhasorSimulation',Etat);
    EnabledParameters = get_param(ThreePhaseMeasurements{i},'MaskEnables');
    EnabledParameters{11}=Etat;
    set_param(ThreePhaseMeasurements{i},'MaskEnables',EnabledParameters);
end
CurrentMeasurements = find_system(system,'LookUnderMasks','on','MaskType','Current Measurement');
for i=1:length(CurrentMeasurements)
    set_param(CurrentMeasurements{i},'PhasorSimulation',Etat);
    set_param(CurrentMeasurements{i},'MaskEnables',{'on',Etat,'on'});
end
VoltageMeasurements = find_system(system,'LookUnderMasks','on','MaskType','Voltage Measurement');
for i=1:length(VoltageMeasurements)
    set_param(VoltageMeasurements{i},'PhasorSimulation',Etat);
    set_param(VoltageMeasurements{i},'MaskEnables',{'on',Etat,'on'});
end
