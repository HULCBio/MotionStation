function heatex
% HEATEX  Demonstrates the temperature control of a chemical reactor using
% a heat exchanger

%   Author(s): N. Hickey
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/10 23:13:46 $

% Create a persistent variable to hold data required by the demo
persistent figHdl

%---Return if the figure is already open
%--- (only allow 1 instance of the demo)
if ishandle(figHdl)
    return
end

%*************************************************************************
% Create the main figure in which to create the GUI
figHdl = figure( ...
    'Name','Heat Exchanger Control', ...
    'IntegerHandle','off', ...
    'NumberTitle','off', ...
    'DoubleBuffer','on', ...
    'Visible','off', ...
    'HandleVisibility','callback',...
    'DeleteFcn',@localCloseButton,...
    'DefaultAxesFontSize',8,...
    'DefaultAxesPosition',[0.075 0.6 0.59 0.35],...
    'DefaultTextFontSize',8 + 2*isunix, ...
    'DockControls', 'off');

% Initialise GUI data structure
GUI_Data = struct(...
    'Figure',figHdl, ...
    'AnimData',struct( ...
    'GraphHdl',[], ...
    'Counter',0, ...
    'dp',0, ...
    'DisplayFlag',0, ...
    'LegendHdls',[], ...
    'LineData',[], ...
    'LineHdls',[], ...
    'MimicHdl',[], ...
    'MimicObjtHdls',[], ...        
    'RefreshMimic',1, ...
    'ValveObjtHdls',[]), ...
    'CtrlStrct',[0 1], ...
    'Controls',struct( ...
    'CloseBtnHdl',[], ...	
    'CtrlPopUpHdl',[], ...
    'FFGainSldHdl',[], ...
    'FFGainTxtHdl',[], ...
    'FFDelaySldHdl',[], ...
    'FFDelayTxtHdl',[], ...
    'StartBtnHdl',[], ...
    'StopBtnAxesHdl',[], ...
    'StopBtnHdl',[]), ...
    'DgrmAxesHdl',[], ...
    'FFGainValue',1,...
    'FFDelayValue',25.3, ...
    'RunModeStatus','Stop', ...
    'StatusText','', ...
    'Simulink',struct( ...
    'Model','heatex_sim', ...
    'GetData','heatex_sim/Get Data', ...
    'DisturbanceDelay','heatex_sim/Plant Disturbance Gd/Disturbance Delay', ...
    'FBSwitch','heatex_sim/Feedback Control Gc/FB on-off Switch', ...        
    'FFSwitch','heatex_sim/Feedforward Control Gff/FF on-off Switch', ...
    'FFGain','heatex_sim/Feedforward Control Gff/FF Gain', ...
    'FFDelay','heatex_sim/Feedforward Control Gff/FF Delay'));

% Create a data structure to hold update function and figure handles
LinkData = struct( ...
    'UpDateFcn',@localUpDateDisplays, ...
    'FigHandle',figHdl, ...
    'StartFcn',@localStartButton, ...
    'StopFcn',@localStopButton, ...
    'CloseFcn',@localCloseButton, ...	
    'UpDateStrctFcn',@localUpDateStructure);

%====================================
% Simulink file must be open for variables to be passed to it
open_system(GUI_Data.Simulink.Model);
GUI_Data.Simulink.WindowOpen = 1;
% Set the user data field of the heatex_getdata S function block
set_param(GUI_Data.Simulink.GetData,'UserData',LinkData);
% Set up the default FeedBack control system switch  FB on and FF off
set_param(GUI_Data.Simulink.FBSwitch, 'sw', num2str(GUI_Data.CtrlStrct(1)));
set_param(GUI_Data.Simulink.FFSwitch, 'sw',  num2str(GUI_Data.CtrlStrct(2)));
% set the Simulink callback functions
set_param(GUI_Data.Simulink.Model,'StartFcn','heatex_clbk(''Start'')');
set_param(GUI_Data.Simulink.Model,'StopFcn','heatex_clbk(''Stop'')');
set_param(GUI_Data.Simulink.Model,'CloseFcn','heatex_clbk(''Close'')');
set_param(GUI_Data.Simulink.FFSwitch,'OpenFcn','manswitch(''Open'');heatex_clbk(''FFSelect'')');
set_param(GUI_Data.Simulink.FBSwitch,'OpenFcn','manswitch(''Open'');heatex_clbk(''FBSelect'')');
% Set the default FeedForward controller values
set_param(GUI_Data.Simulink.FFGain,'Gain',num2str(GUI_Data.FFGainValue));
set_param(GUI_Data.Simulink.FFGain,'UserData',num2str(GUI_Data.FFGainValue));
set_param(GUI_Data.Simulink.FFDelay,'DelayTime',num2str(GUI_Data.FFDelayValue));
set_param(GUI_Data.Simulink.FFDelay,'UserData',num2str(GUI_Data.FFDelayValue));
%====================================

%====================================
% Create reference information for all frames and buttons
frmColor = [0.7 0.7 0.7];
lblColor = frmColor;
boxColor = frmColor;
bottom = 0.01;        top = 1- 0.01;                     % Reference defintions
left = 0.01;        right = 1-left;                      % Reference defintions
frmBorder = 0.01;                                        % Spacing between the border and any object
spacing=0.04;                                            % Spacing between arbitrary objects
frmWid = 0.3;                                            % Width of the frame
btnWid=0.12;            btnHt = 0.06;                    % Button reference dimensions
sldWid = frmWid-2*frmBorder;    sldHt = btnHt/1.6;       % Slider dimensions
boxWid = btnWid*0.8;    boxHt = sldHt;                   % Text box dimensions
txtboxHt = btnHt/1.2;            % Edit Text box dimensions
cbarHt = btnHt/2;        cbtnWid = frmWid-frmBorder*2;   % PopUp dimensions
%====================================

%====================================
% Set up the CONSOLE frame as an axes use these sizes as known references
frmLft = (right-frmWid);              frmRht = frmLft+frmWid;
frmBtm = 3*bottom+btnHt;                    
frmHt  = top-frmBtm;                  frmTop = frmBtm+frmHt;
frmPos = [frmLft frmBtm frmWid frmHt];
axes( ...
    'Parent',figHdl, ...
    'Position',frmPos,...
    'Color',frmColor, ...
    'XColor',[0 0 0], ...
    'YColor',[0 0 0], ...
    'XTick',[], ...
    'YTick',[], ...
    'Box','on', ...
    'Visible','on');
%===================================

%===================================
% Set up the CONTROL DIAGRAM axes
cdfrmWid = frmWid-frmBorder*2;       cdfrmHt  = frmHt/3.5;
cdfrmLft = frmLft+frmBorder;         cdfrmBtm = top-boxHt-3*frmBorder-btnHt-cdfrmHt;
frmPos   = [frmLft+frmBorder cdfrmBtm cdfrmWid cdfrmHt];
GUI_Data.DgrmAxesHdl = axes( ...
    'Parent',figHdl, ...
    'Position',frmPos,...
    'Color',[.7 .7 .75], ...
    'XColor',[.5 .5 .75], ...
    'YColor',[.5 .5 .75], ...
    'XTick',[], ...
    'YTick',[], ...
    'Box','on', ...
    'Visible','on');
%================================

%================================
% Set up the CONTROL FEEDBACK TYPE pop up menu
% Give it a title text box
boxPos = [frmLft+frmBorder top-boxHt-3*frmBorder cbtnWid btnHt];
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String','Select Control Type:', ...
    'Interruptible','off', ...
    'FontSize',8+2*isunix, ...    
    'Background',boxColor, ...    
    'HorizontalAlignment','left');
frmPos = [frmLft+frmBorder top-boxHt-2*frmBorder-btnHt cbtnWid btnHt];
GUI_Data.Controls.CtrlPopUpHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','popup', ...
    'Units','normalized',...
    'Position',frmPos,...
    'String',{'Open-Loop','FeedBack (FB)','FeedForward (FF)','FB and FF'}, ...
    'TooltipString','Select desired control system set-up', ...            
    'Background',[1 1 1], ...        
    'Callback',{@localSelectSystem}, ...
    'Value',1);
%=================================

%=================================
% Set up the FF GAIN slider system
% First the FF Gain text box
boxPos = [frmLft+frmBorder frmBtm+17*frmBorder+btnHt+3*sldHt+2*boxHt boxWid*3 boxHt];
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String','FeedForward Gain:', ...
    'Interruptible','off', ...
    'FontSize',8+2*isunix, ...
    'Background',boxColor, ...    
    'HorizontalAlignment','left');
% next the FF GAIN slider bar
sldPos = [frmLft+frmWid/2-sldWid/2 frmBtm+16*frmBorder+btnHt+2*sldHt+2*boxHt sldWid sldHt];
GUI_Data.Controls.FFGainSldHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','slider', ...
    'Units','normalized', ...
    'Position',sldPos, ...
    'Value',1, ...
    'Min',0.1, ...
    'Max',2.0, ...
    'UserData',1, ...
    'Interruptible','off', ...
    'FontSize',8+2*isunix, ...    
    'Background',[1 1 1], ...        
    'TooltipString','Move to adjust FF Gain', ...            
    'Callback',{@localFFGainSlider});
% the FF GAIN text edit box 
boxPos = [frmLft+frmWid/2-btnWid/2.4 frmBtm+14*frmBorder+btnHt+2*sldHt+1*boxHt btnWid/1.2 txtboxHt];
GUI_Data.Controls.FFGainTxtHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','edit', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'Value',1, ...
    'Interruptible','off', ...
    'FontSize',8+2*isunix, ...
    'Background',[1 1 1], ...    
    'Callback',{@localFFGainTextEdit});
% Left text box for lower limit
boxPos = [frmLft+frmBorder frmBtm+15*frmBorder+btnHt+2*sldHt+1*boxHt boxWid/2 boxHt];
lower = get(GUI_Data.Controls.FFGainSldHdl,'Min');
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String',lower, ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...    
    'HorizontalAlignment','left');
% Right text box for upper limit
boxPos = [frmRht-frmBorder-sldWid/3 frmBtm+15*frmBorder+btnHt+2*sldHt+1*boxHt sldWid/3 boxHt];
upper = get(GUI_Data.Controls.FFGainSldHdl,'Max');
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String',upper, ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...    
    'HorizontalAlignment','right');
%====================================    

%=================================
% Set up the FF DELAY slider system
% First the FF DELAY text box
boxPos = [frmLft+frmBorder frmBtm+10*frmBorder+btnHt+2*sldHt boxWid*3 boxHt];
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String','FeedForward Delay:', ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...    
    'HorizontalAlignment','left');
% the FF DELAY slider bar    
sldPos = [frmLft+frmWid/2-sldWid/2  frmBtm+9*frmBorder+btnHt+sldHt sldWid sldHt];
GUI_Data.Controls.FFDelaySldHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','slider', ...
    'Units','normalized', ...
    'Position',sldPos, ...
    'Value',15, ...
    'Userdata',15, ...
    'Min',1, ...
    'Max',40, ...
    'Interruptible','off', ...
    'FontSize',8+2*isunix, ...
    'Background',[1 1 1], ...        
    'TooltipString','Move to adjust FF Delay Time', ...        
    'Callback',{@localFFDelaySlider});
% the FF DELAY text edit box 
boxPos = [frmLft+frmWid/2-btnWid/2.4 frmBtm+7*frmBorder+btnHt btnWid/1.2 txtboxHt];
GUI_Data.Controls.FFDelayTxtHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','edit', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'Value',1, ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...
    'Background',[1 1 1], ...        
    'Callback',{@localFFDelayTextEdit});
% Left text box for lower limit
boxPos = [frmLft+frmBorder frmBtm+8*frmBorder+btnHt boxWid/2 boxHt];
lower = get(GUI_Data.Controls.FFDelaySldHdl,'Min');
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String',lower, ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...    
    'HorizontalAlignment','left');
% Right text box for upper limit
boxPos = [frmRht-frmBorder-sldWid/3 frmBtm+8*frmBorder+btnHt sldWid/3 boxHt];
upper = get(GUI_Data.Controls.FFDelaySldHdl,'Max');
slideHndl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',boxPos, ...
    'String',upper, ...
    'Interruptible','off', ...
    'Background',boxColor, ...
    'FontSize',8+2*isunix, ...    
    'HorizontalAlignment','right');
%====================================    

%====================================
% The START button
axWid = btnWid*1.12;  axHt = btnHt*1.3;
frmPos   = [frmLft+frmBorder frmBtm+frmBorder axWid axHt];
GUI_Data.Controls.StartBtnAxes = uicontrol( ...
    'Parent',figHdl, ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos,...
    'BackGroundColor',[0 1 0]);
btnPos=[frmLft+frmBorder+axWid/2-(btnWid*1)/2 frmBtm+frmBorder+axHt/2-(btnHt*1)/2 btnWid btnHt];
GUI_Data.Controls.StartBtnHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','START', ...
    'Callback',{@localStartButton}, ...
    'TooltipString','Press to START Simulation'); 
%====================================

%====================================
% The STOP button
frmPos   = [frmRht-frmBorder-axWid frmBtm+frmBorder axWid axHt];
GUI_Data.Controls.StopBtnAxes = uicontrol( ...
    'Parent',figHdl, ...
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos,...
    'BackGroundColor',[0.7 0 0]);
btnPos=[frmRht-frmBorder-axWid/2-(btnWid*1)/2 frmBtm+frmBorder+axHt/2-(btnHt*1)/2 ...
        btnWid*1 btnHt*1];
GUI_Data.Controls.StopBtnHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','STOP', ...
    'Enable','off', ...
    'Callback',{@localStopButton}, ...
    'TooltipString','Press to STOP Simulation'); 
%================================

%====================================
% The DETAILS button
% The Callback string calls the slide show demo file
btnPos = [frmLft+frmBorder bottom btnWid btnHt];
uicontrol( ...
    'Parent',figHdl, ...    
    'Style','push', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','Details', ...
    'TooltipString','Press for control system details', ...    
    'Callback','heatex_sls');
%====================================

%====================================
% The CLOSE button
btnPos = [frmRht-frmBorder-btnWid bottom btnWid btnHt];
GUI_Data.Controls.CloseBtnHdl = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','push', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String','Close', ...
    'TooltipString','Close Figure', ...
    'Callback',@localCloseButton);
%====================================

%====================================
% The STATUS BAR
staWid = btnWid*5.5;    
frmPos=[left bottom staWid btnHt];
StatusFrame = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','frame', ...
    'Units','normalized', ...
    'Position',frmPos, ...
    'BackgroundColor',lblColor, ...
    'ForegroundColor',[0 0 0], ...
    'TooltipString','Status Bar');
txtPos=[left+0.01 bottom+0.005 btnWid*5 btnHt*0.8];
GUI_Data.StatusText = uicontrol( ...
    'Parent',figHdl, ...    
    'Style','text', ...
    'Units','normalized', ...
    'Position',txtPos, ...
    'String','Press START to run the simulation', ...    
    'HorizontalAlignment','left', ...        
    'BackgroundColor',lblColor, ...        
    'ForegroundColor',[0 0 0]);
%====================================

%====================================
% Set the user data field of the figure with the new GUI data    
set(figHdl,'UserData',GUI_Data);
% Now call the local functions to create the DISPLAY GRAPH and MIMIC DISPLAY
localDrawLoop(figHdl);
localCreateGraphDisplay(figHdl);
localCreateMimicDisplay(figHdl);    
localUpDateStructure(figHdl);
localUpDateGainAndDelayValues(figHdl);
% Now uncover the figure
set(figHdl,'Visible','on');
%====================================    


%*************************************************************************
% List the callback functions

function localSelectSystem(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
% Find the user selected control system to simulate
m = get(eventSrc,'Value');
switch m
case 1, GUI_Data.CtrlStrct = [0 0];
case 2, GUI_Data.CtrlStrct = [0 1];
case 3, GUI_Data.CtrlStrct = [1 0];
case 4, GUI_Data.CtrlStrct = [1 1];
end
set(figHdl,'Userdata',GUI_Data);
localUpDateStructure(figHdl);

function localFFGainSlider(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
GUI_Data.FFGainValue = str2num(sprintf('%1.2f',get(eventSrc,'Value')));
set(figHdl,'Userdata',GUI_Data);
localUpDateGainAndDelayValues(figHdl);

function localFFGainTextEdit(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
val = localEvalNumGain(get(eventSrc,'String'));
if ~isempty(val), GUI_Data.FFGainValue = val;end
set(figHdl,'Userdata',GUI_Data);
localUpDateGainAndDelayValues(figHdl);

function localFFDelaySlider(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
GUI_Data.FFDelayValue = str2num(sprintf('%1.2f',get(eventSrc,'Value')));;
set(figHdl,'Userdata',GUI_Data);
localUpDateGainAndDelayValues(figHdl);

function localFFDelayTextEdit(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
val = localEvalNumDelay(get(eventSrc,'String'));
if ~isempty(val), GUI_Data.FFDelayValue = val;end
set(figHdl,'Userdata',GUI_Data);
localUpDateGainAndDelayValues(figHdl);

function localStartButton(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
GUI_Data.RunModeStatus = 'Start';
GUI_Data.AnimData.RefreshMimic = 1;
set(figHdl,'Userdata',GUI_Data);
localStartStopSimulation(figHdl);

function localStopButton(eventSrc,eventData)
figHdl = get(eventSrc,'Parent');
GUI_Data = get(figHdl,'UserData');
GUI_Data.RunModeStatus = 'Stop';
set(figHdl,'Userdata',GUI_Data);
localStartStopSimulation(figHdl);

function localCloseButton(eventSrc,eventData)
switch get(eventSrc,'Type')
case 'figure'
    figHdl = eventSrc;
otherwise
    figHdl = get(eventSrc,'Parent');
end
GUI_Data = get(figHdl,'UserData');
set_param(GUI_Data.Simulink.Model,'SimulationCommand','Stop');
bdclose(GUI_Data.Simulink.Model);


%*************************************************************************
% List the local functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localStartStopSimulation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localStartStopSimulation(figHdl)
GUI_Data = get(figHdl,'UserData');

switch GUI_Data.RunModeStatus
case 'Start'
    set(GUI_Data.Controls.StartBtnHdl,'Enable','Off');
    set(GUI_Data.Controls.StartBtnAxes,'BackGroundColor',[0 0.6 0]);    
    set(GUI_Data.Controls.StopBtnHdl,'Enable','On');
    set(GUI_Data.Controls.StopBtnAxes,'BackGroundColor',[1 0 0]);
    StopTime = str2num(get_param(GUI_Data.Simulink.Model,'StopTime'));
    set(GUI_Data.AnimData.GraphHdl,'XLim',[0 StopTime]);
    set(GUI_Data.AnimData.GraphHdl,'XTick',[0:50:StopTime]);
    % Clear any lines by setting their XData and YData fields to [0]
    set(GUI_Data.AnimData.LineHdls,'EraseMode','xor','YData',[0],'XData',[0]);
    set(GUI_Data.StatusText,'String','Simulation has started');
    % Refresh the mimic diagram
    localDrawCSTR(figHdl);
    % Set the Simulink parameters and run the file
    localUpDateGainAndDelayValues(figHdl);
    set_param(GUI_Data.Simulink.Model,'SimulationCommand','Start')
case 'Stop'
    set(GUI_Data.Controls.StartBtnHdl,'Enable','On');
    set(GUI_Data.Controls.StartBtnAxes,'BackGroundColor',[0 1 0]);    
    set(GUI_Data.Controls.StopBtnHdl,'Enable','Off');
    set(GUI_Data.Controls.StopBtnAxes,'BackGroundColor',[0.7 0 0]);
    set(GUI_Data.AnimData.LineHdls,'EraseMode','normal');
    set(GUI_Data.StatusText,'String','Simulation has been stopped');
    set_param(GUI_Data.Simulink.Model,'SimulationCommand','Stop');
end


%%%%%%%%%%%%%%%%%%%%%%%%
% localUpDateStructure %
%%%%%%%%%%%%%%%%%%%%%%%%
function localUpDateStructure(figHdl)
% Updates the graphics and popup menu when the control structure is changed
% via MATLAB or Simulink
GUI_Data = get(figHdl,'UserData');
StatusBarText = { ...
        'No control system selected, the plant will run open-loop', ...
        'Only Feedback control is being used', ...
        'Only Feedforward control is being used', ...
        'Both Feedback and Feedforward control are being used'};
GraphTitleText = { ...
        'Open-Loop Response Without Any Controller', ...
        'Response of Feedback Control System', ...
        'Response of Feedforward Control System', ...
        'Response of a Joint Feedback and Feedforward Control System'};
TitleHdl = get(GUI_Data.AnimData.GraphHdl,'Title');

n = 2*(GUI_Data.CtrlStrct(1)) + (GUI_Data.CtrlStrct(2)) + 1;
set_param(GUI_Data.Simulink.FFSwitch, 'sw',num2str(GUI_Data.CtrlStrct(1)));
set_param(GUI_Data.Simulink.FBSwitch, 'sw',num2str(GUI_Data.CtrlStrct(2)));
set(GUI_Data.Controls.CtrlPopUpHdl,'Value',n);
set(GUI_Data.StatusText,'String',StatusBarText(n));
set(TitleHdl,'String',GraphTitleText(n));
localDrawLoop(figHdl);
localDrawCSTR(figHdl);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localUpDateGainAndDelayValues %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localUpDateGainAndDelayValues(figHdl)
% Updates FF Gain and Delay values when changed via MATLAB and Simulink
% Note there are no Simulink callbacks for gain or delay blocks therefore
% if they are changed during simulation they will not be updated in the figure
GUI_Data = get(figHdl,'UserData');

% Update the FeedForward Delay Gain
CurrentGain = localEvalNumGain(get_param(GUI_Data.Simulink.FFGain,'Gain'));
if isempty(CurrentGain)
    CurrentGain = str2num(get_param(GUI_Data.Simulink.FFGain,'UserData'));
end
OldGain = str2num(get_param(GUI_Data.Simulink.FFGain,'UserData'));

if CurrentGain ~= OldGain
    % Then value has been changed via Simulink since last update
    NewGain = CurrentGain;
elseif CurrentGain == OldGain
    % Then value has been set by a callback
    NewGain = GUI_Data.FFGainValue;
end
GUI_Data.FFGainValue = NewGain;

% Update Simulink
set_param(GUI_Data.Simulink.FFGain,'Gain',num2str(NewGain));
set_param(GUI_Data.Simulink.FFGain,'Userdata',num2str(NewGain));

% Update MATLAB figure displays
set(GUI_Data.Controls.FFGainTxtHdl,'String',num2str(NewGain));
% Check the value is within limits for slider
MinGain = get(GUI_Data.Controls.FFGainSldHdl,'Min');
MaxGain = get(GUI_Data.Controls.FFGainSldHdl,'Max');
NewGain = min(max(NewGain,MinGain),MaxGain);
set(GUI_Data.Controls.FFGainSldHdl,'Value',NewGain);

% Update the FeedForward Delay Time
CurrentDelay = localEvalNumDelay(get_param(GUI_Data.Simulink.FFDelay,'DelayTime'));
if isempty(CurrentDelay)
    CurrentDelay = str2num(get_param(GUI_Data.Simulink.FFDelay,'UserData'));
end
OldDelay = str2num(get_param(GUI_Data.Simulink.FFDelay,'UserData'));

if CurrentDelay ~= OldDelay
    % Then value has been changed via Simulink since last update
    NewDelay = CurrentDelay;
elseif CurrentDelay == OldDelay
    % Then value has been set by a callback
    NewDelay = GUI_Data.FFDelayValue;
end
GUI_Data.FFDelayValue = NewDelay;

% Update Simulink
set_param(GUI_Data.Simulink.FFDelay,'DelayTime',num2str(NewDelay));
set_param(GUI_Data.Simulink.FFDelay,'Userdata',num2str(NewDelay));
set_param(GUI_Data.Simulink.Model,'Dirty','off');

% Update MATLAB figure displays
set(GUI_Data.Controls.FFDelayTxtHdl,'String',num2str(NewDelay));
% Check the value is within limits for slider
MinDelay = get(GUI_Data.Controls.FFDelaySldHdl,'Min');
MaxDelay = get(GUI_Data.Controls.FFDelaySldHdl,'Max');
NewDelay = min(max(NewDelay,MinDelay),MaxDelay);
set(GUI_Data.Controls.FFDelaySldHdl,'Value',NewDelay);
set(figHdl,'Userdata',GUI_Data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localCreateGraphDisplay %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localCreateGraphDisplay(figHdl)
% Creates the initial GRAPH DISPLAY further changes to
% this display are then carried out by localUpDateDisplays
GUI_Data = get(figHdl,'UserData');

GUI_Data.AnimData.GraphHdl = axes( ...
    'Parent',GUI_Data.Figure, ...
    'Units','normalized', ...
    'XLim',[0 200], ...
    'YLim',[-1.1 1.5], ...
    'XTick',[0:50:200], ...
    'YTick',[-1.0 -0.5 0 0.5 1.0 1.5], ...
    'XGrid','on', ...
    'YGrid','on', ...        
    'Box','on',...
    'FontSize',8);

XLabelHdl = get(GUI_Data.AnimData.GraphHdl,'XLabel');
set(XLabelHdl,'String','Time (seconds)','FontSize',7);
YLabelHdl = get(GUI_Data.AnimData.GraphHdl,'YLabel');
set(YLabelHdl,'String','Normalised Magnitude','FontSize',7)
TitleHdl = get(GUI_Data.AnimData.GraphHdl,'Title');
set(TitleHdl,'String','Heat Exchanger Temperature Control','FontSize',7)

GUI_Data.AnimData.LineData = struct(...
    'Parent',GUI_Data.AnimData.GraphHdl,...
    'LineWidth',2,...
    'LineStyle','-',...
    'Color','m');
% Create the lines that will plot the output from the simulation
dist_val = [0];
con_val  = [0];
mag_val  = [0];
time_val = [0];

GUI_Data.AnimData.LineHdls(1) = line(...
    'Parent',GUI_Data.AnimData.GraphHdl,...
    'YData',dist_val,...
    'XData',time_val,...
    'LineStyle',':',...
    'LineWidth',GUI_Data.AnimData.LineData.LineWidth,...
    'Color',[0.7 0 0],...
    'EraseMode','normal');

GUI_Data.AnimData.LineHdls(2) = line(...
    'Parent',GUI_Data.AnimData.GraphHdl,...
    'YData',mag_val,...
    'XData',time_val,...
    'LineWidth',GUI_Data.AnimData.LineData.LineWidth,...
    'LineStyle',GUI_Data.AnimData.LineData.LineStyle,...
    'Color',[0.7 0 0],...
    'EraseMode','normal');    

GUI_Data.AnimData.LineHdls(3) = line(...
    'Parent',GUI_Data.AnimData.GraphHdl,...
    'YData',con_val,...
    'XData',time_val,...
    'LineStyle','--',...
    'LineWidth',GUI_Data.AnimData.LineData.LineWidth,...
    'Color','r',...
    'EraseMode','normal');    

% Create a legend and handles to the line colors
[Lgd,LgdL1,LgdL1C1,Lgdtext] = legend(GUI_Data.AnimData.GraphHdl,'d','y','u',4);
GUI_Data.AnimData.LegendHdls = LgdL1C1;

% Set the user data field of the figure with the new GUI data
set(figHdl,'Userdata',GUI_Data);
%==================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localCreateMimicDisplay %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localCreateMimicDisplay(figHdl)
% Set up the MIMIC display
GUI_Data = get(figHdl,'UserData');
frmPos=[0.03 0.078 0.6 0.45];

GUI_Data.AnimData.MimicHdl = axes( ...
    'Parent',figHdl, ...
    'Position',frmPos, ...
    'Color',[1 1 1], ...
    'Visible','off');
% Ensure that the dx and dy of the axis are square so that mimics keep their correct ratio
axis(GUI_Data.AnimData.MimicHdl,'equal')
% Set the user data field of the figure with the new GUI data
set(figHdl,'Userdata',GUI_Data);
%==================================

%%%%%%%%%%%%%%%%%%%%%%%
% localUpDateDisplays %
%%%%%%%%%%%%%%%%%%%%%%%
function localUpDateDisplays(figHdl,t,u)
% This function is called from Simulink when flag = 2 in heatex_getdata.m
% It is passed the GUI data and the Simulation time t, and outputs u
GUI_Data = get(figHdl,'UserData');

% Read in the stored data values from the lines already drawn
dist_val = get(GUI_Data.AnimData.LineHdls(1),'YData');
mag_val  = get(GUI_Data.AnimData.LineHdls(2),'YData');
con_val  = get(GUI_Data.AnimData.LineHdls(3),'YData');    
time     = get(GUI_Data.AnimData.LineHdls(1),'XData');    

% Read in the values from Simulink and store them in the data storage array
dist_val = [u(1) dist_val];    % Plant Input Disturbance
mag_val  = [u(2) mag_val];    % Plant Output Temperature 
con_val  = [u(3) con_val];    % Control Signal 
time_val = [t(1) time];        % Simulation Time

% Update the animation counter
GUI_Data.AnimData.Counter = 1 + GUI_Data.AnimData.Counter;

% Create a variable small time delay so the animation is slowed down
timeA = clock;
timeB = clock;
timedelay = etime(timeB,timeA);

if t(1) >= 20 & t(1) <= 50
    desired_delay = 0.2;
elseif t(1) > 50 & t(1) <= 70
    desired_delay = 0.3;
elseif t(1) > 70 & t(1) <= 110
    desired_delay = 0.15;
else 
    desired_delay = 0;
end

while timedelay <= desired_delay
    timeB = clock;
    timedelay = etime(timeB,timeA);
end

% Simulate the changing temperature of the MIMIC display objects by changing their color
if u(1) == 0
    LiquidInColor = GUI_Data.AnimData.MimicObjtHdls.InitialColor;
    SplashColor = LiquidInColor;
    set(GUI_Data.AnimData.MimicObjtHdls.LiquidInA,'FaceColor',LiquidInColor);
    set(GUI_Data.AnimData.MimicObjtHdls.LiquidInB,'FaceColor',LiquidInColor);    
    set(GUI_Data.AnimData.MimicObjtHdls.LiquidInC,'FaceColor',LiquidInColor);        
    set(GUI_Data.AnimData.MimicObjtHdls.Splash1,'FaceColor',SplashColor);
    set(GUI_Data.AnimData.MimicObjtHdls.Splash2,'FaceColor',SplashColor);
    
elseif u(1) ~= 0
    if u(1) > 0
        LiquidInColor = [1 0 0];
    elseif u(1) < 0
        LiquidInColor = [0 0 1];
    end
    SplashColor = GUI_Data.AnimData.MimicObjtHdls.InitialColor;
    AX = get(GUI_Data.AnimData.MimicObjtHdls.LiquidInA,'XData');
    pipe_delay = str2num(get_param(GUI_Data.Simulink.DisturbanceDelay,'DelayTime'));
    pipe_length  = 0.4275 + 0.1215;
    flow_rate = pipe_length/pipe_delay;
    dt = t(1) - time(1);
    dp = flow_rate*dt;
    
    if AX(4) < 0.1215
        new_XData = [AX(1) AX(2) max(min(AX(3)+dp,0.1215),-0.4275) max(min(AX(4)+dp,0.1215),-0.4275)]';
        set(GUI_Data.AnimData.MimicObjtHdls.LiquidInA,'FaceColor',LiquidInColor);
        set(GUI_Data.AnimData.MimicObjtHdls.LiquidInA,'XData',new_XData);
        BX = get(GUI_Data.AnimData.MimicObjtHdls.LiquidInB,'XData');
        new_XData = [max(min(BX(1)+dp,0.1215),-0.3915) max(min(BX(2)+dp,0.1215),-0.3915) BX(3) BX(4)]';
        set(GUI_Data.AnimData.MimicObjtHdls.LiquidInB,'XData',new_XData);
    elseif AX(4) >= 0.1215
        SplashColor = LiquidInColor;
        set(GUI_Data.AnimData.MimicObjtHdls.LiquidInB,'FaceColor',LiquidInColor);    
        set(GUI_Data.AnimData.MimicObjtHdls.LiquidInC,'FaceColor',LiquidInColor);        
        set(GUI_Data.AnimData.MimicObjtHdls.Splash1,'FaceColor',SplashColor);
        set(GUI_Data.AnimData.MimicObjtHdls.Splash2,'FaceColor',SplashColor);        
    end
end

u_min = -1;
u_max =  1;
delta_u = u_max - u_min;
delta_c = 1 - 0;

u_act = u(2) - u_min;
u_act = 1.2*u_act*delta_c/delta_u;
u_actr = u_act+0.1;
u_actb = u_act+0.1;
rfu2 = max(min(u_actr,1),0);
bfu2 = max(min(1 - u_actb,1),0);
set(GUI_Data.AnimData.MimicObjtHdls.TankLiquid,'FaceColor',[rfu2 0 bfu2]);

u_act = u(3) - u_min;
u_act = u_act*delta_c/delta_u;
rfu3 = max(min(u_act+0.0,1),0);
% Set bfu3 so it never goes fully blue, bfu3 <= 0.5
bfu3 = min(max(min(1 - u_act-0.0,1),0),0.5);
if u(3) == 0, rfu3 = 0.5;gfu3 = 0.5;bfu3 = 0.5;else gfu3 = 0;end

if u(3) ~= 0
    AX = get(GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB,'XData');
    pipe_delay = 1*25;
    pipe_length  = 2.95;
    flow_rate = pipe_length/pipe_delay;
    dt = t(1) - time(1);
    dp = GUI_Data.AnimData.dp + flow_rate*dt;
    % Scaling factor in the x direction
    q = 2;
    AX = get(GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB,'XData');
    % Rescale the x value p.Size*(p.Position(1)+x)
    if max(AX) < q*0.09*( -0.2 + 0.65) &  max(AX) < q*(0.09*( -0.2 + 0.65))
        newx = min(max(max(AX)+dp,-0.75),0.65);
        x = q*[-0.75 newx newx -0.75 -0.75];
        y =   [-2.2  -2.2      -2.45   -2.45 -2.2];
    elseif max(AX) >= q*0.09*( -0.2 + 0.65) & max(AX) <= q*0.09*( -0.2 + 0.75)
        newx = min(max(max(AX)+dp,-0.75),0.75);
        x = q*[-0.75 0.65 0.65 newx newx -0.75 -0.75];
        y =   [-2.2 -2.2 -0.5  -0.5     -2.45    -2.45 -2.2];
    elseif max(AX) > q*0.09*( -0.2 + 0.75)  & max(AX) <= q*0.09*( -0.2 + 1.2)
        newx = min(max(max(AX)+dp,-0.75),1.2);
        x = q*[-0.75 0.65 0.65 newx newx 0.75  0.75 -0.75 -0.75];
        y =   [-2.2 -2.2 -0.5  -0.5     -0.75   -0.75 -2.45 -2.45 -2.2];
    elseif max(AX)>= q*0.09*( -0.2 + 1.2)& max(AX) < q*0.09*( -0.2 + 1.3)
        newx = min(max(max(AX)+dp,-0.75),1.3);
        x = q*[-0.75 0.65 0.65 newx  newx 1.2   1.2   0.75  0.75 -0.75 -0.75];
        y =   [-2.2 -2.2 -0.5  -0.5     -2.45   -2.45 -0.75 -0.75 -2.45 -2.45 -2.2];
    elseif max(AX)>= q*0.09*( -0.2 + 1.3) & max(AX)<= q*0.09*( -0.2 + 2.2)
        newx = min(max(max(AX)+dp,-0.75),2.2);
        x = q*[-0.75 0.65 0.65 1.3  1.3 newx newx 1.2   1.2   0.75  0.75 -0.75 -0.75];
        y =   [-2.2 -2.2 -0.5 -0.5 -2.2 -2.2     -2.45   -2.45 -0.75 -0.75 -2.45 -2.45 -2.2];
    end
    % Update patch XData if it has been changed
    if exist('x')
        set(GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB,'XData',0.09*( -0.2 + x));
        set(GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB,'YData',0.09*(  0.0 + y));
    end
    set(GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB,'FaceColor',[rfu3 gfu3 bfu3]);
    GUI_Data.AnimData.dp = dp;
end

% Plot the lines by setting their XData and YData fields to the values from Simulink
set(GUI_Data.AnimData.LineHdls(1),'YData',dist_val,'XData',time_val,'Color',LiquidInColor);
set(GUI_Data.AnimData.LineHdls(2),'YData',mag_val,'XData',time_val,'Color',[rfu2 0 bfu2]);
set(GUI_Data.AnimData.LineHdls(3),'YData',con_val,'XData',time_val,'Color',[rfu3 0 bfu3]);

% When the disturbance in the inlet flow occurs update the status bar text
if u(1)~=0 & GUI_Data.AnimData.DisplayFlag == 1
    set(GUI_Data.StatusText,'String','A disturbance in the inlet flow temperature has occured');
end

% Update the Status bar when the correct temperature has been reached
if u(2) >= -0.02 & u(2) <= 0.02 & u(3) ~= 0
    set(GUI_Data.StatusText,'String','The tank is at the correct temperature');    
    GUI_Data.AnimData.DisplayFlag = 2;
elseif  u(1) ~= 0 
    GUI_Data.AnimData.DisplayFlag = 1;
else
    GUI_Data.AnimData.DisplayFlag = 0;
end

% Set the control valve color
if u(3) == 0
    set(GUI_Data.AnimData.ValveObjtHdls,'FaceColor',[0 0 0]);    
    set(GUI_Data.StatusText,'String','Simulation is running');
    GUI_Data.AnimData.DisplayFlag = 1;
elseif u(3) ~= 0
    set(GUI_Data.AnimData.ValveObjtHdls,'FaceColor',[0 0 0]);    
end

% Simulate the stirrer rotating and the liquid entering the tank
if GUI_Data.AnimData.Counter >= 3
    set(GUI_Data.AnimData.MimicObjtHdls.LStirrer,'FaceColor',[0 0 0]);
    set(GUI_Data.AnimData.MimicObjtHdls.RStirrer,'FaceColor',[1 1 1]*0.7);
    set(GUI_Data.AnimData.MimicObjtHdls.Splash1,'FaceColor',[1 1 1]*0.8);    
    set(GUI_Data.AnimData.MimicObjtHdls.Splash2,'FaceColor',SplashColor);
    GUI_Data.AnimData.Counter = 0;
end
if GUI_Data.AnimData.Counter >= 2
    set(GUI_Data.AnimData.MimicObjtHdls.Splash1,'FaceColor',SplashColor);
    set(GUI_Data.AnimData.MimicObjtHdls.Splash2,'FaceColor',[1 1 1]*0.8);
    set(GUI_Data.AnimData.MimicObjtHdls.LStirrer,'FaceColor',[1 1 1]*0.7);
    set(GUI_Data.AnimData.MimicObjtHdls.RStirrer,'FaceColor',[0 0 0]);
end

% Update the line colors in the legend
set(GUI_Data.AnimData.LegendHdls(1),'Color',LiquidInColor);
set(GUI_Data.AnimData.LegendHdls(2),'Color',[rfu2 0 bfu2]);
set(GUI_Data.AnimData.LegendHdls(3),'Color',[rfu3 0 bfu3]);

% Set the user data field of the figure with the new GUI data
set(figHdl,'UserData',GUI_Data);


%%%%%%%%%%%%%%%%%%%%%
% localEvalNumDelay %
%%%%%%%%%%%%%%%%%%%%%
function val = localEvalNumDelay(val)
% Checks validity of user entered data
%---Evaluate string val
if ~isempty(val)
    val = evalin('base',val,'[]');
    if ~isnumeric(val) | ~(isreal(val) & isfinite(val)) | length(val)~=1 | val < 1 
        val = [];
    end
end


%%%%%%%%%%%%%%%%%%%%
% localEvalNumGain %
%%%%%%%%%%%%%%%%%%%%
function val = localEvalNumGain(val)
% Checks validity of user entered data
%---Evaluate string val
if ~isempty(val)
    val = evalin('base',val,'[]');
    if ~isnumeric(val) | ~(isreal(val) & isfinite(val)) | length(val)~=1 %| val < 0.1 
        val = [];
    end
end


%%%%%%%%%%%%%%%%%
% localDrawLoop %
%%%%%%%%%%%%%%%%%
function localDrawLoop(figHdl)
% Draws a schematic of the control loop
GUI_Data = get(figHdl,'UserData');

% Initialise plot
frmPos = get(GUI_Data.DgrmAxesHdl,'Position');
ax = GUI_Data.DgrmAxesHdl;
delete(allchild(ax));
y0 = 5.5;  x0 = -3.5;

% Customise the plot depending on the type of control used
n = 2*GUI_Data.CtrlStrct(1) + GUI_Data.CtrlStrct(2) + 1;
switch n
    
case 1
    % No Control (Open-Loop)    
    wire('x',x0+[-3 11.2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    text(x0-3,y0,'r  ','horiz','right','fontweight','normal','fontsize',8+2*isunix,'parent',ax);
    % The Plant
    sysblock('position',[x0+11.4 y0-1.5 4.5 3.5],'name','Gp',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 17.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    text(x0+20.5,y0,'  y','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    text(x0+9.7,y0+1,'u','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[18 20.5],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    % The Disturbance
    wire('x',x0+[-3.2 11.2],'y',y0+[7 7],'parent',ax,'arrow',0.5,'parent',ax);
    sysblock('position',[x0+11.4 y0+5.5 4.5 3.5],'name','Gd',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 18],'y',y0+[7 7],'parent',ax,'parent',ax);
    text(x0-4.5,y0+7,'d  ','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    sumblock('position',[x0+18,y0],'label',{'+210','+40'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    wire('x',x0+[18 18],'y',y0+[7 0.5],'parent',ax,'arrow',0.5,'parent',ax);
    
case 2
    % FeedBack
    wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    sumblock('position',[x0-0.5,y0],'label',{'+140','-235'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    text(x0-3,y0,'r  ','horiz','right','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    % The Plant
    sysblock('position',[x0+11.4 y0-1.5 4.5 3.5],'name','Gp',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 17.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    text(x0+20.5,y0,'  y','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    text(x0+9.7,y0+1,'u','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[18 20.5],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    % The Disturbance
    wire('x',x0+[-3.2 11.2],'y',y0+[7 7],'parent',ax,'arrow',0.5,'parent',ax);
    sysblock('position',[x0+11.4 y0+5.5 4.5 3.5],'name','Gd',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 18],'y',y0+[7 7],'parent',ax,'parent',ax);
    text(x0-4.5,y0+7,'d  ','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[19.5 19.5 -0.5 -0.5],'y',y0+[0 -5 -5 -0.5],'parent',ax,'arrow',0.5);
    sumblock('position',[x0+18,y0],'label',{'+210','+40'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    wire('x',x0+[0 1.9],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    wire('x',x0+[18 18],'y',y0+[7 0.5],'parent',ax,'arrow',0.5,'parent',ax);
    % The FeedBack Controller
    sysblock('position',[x0+2 y0-1.5 4.5 3.5],'name','Gc',...
        'fontweight','normal','facecolor','c','fontsize',8,'parent',ax);
    wire('x',x0+[6.4 11.2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    
case 3
    % FeedForward
    text(x0-3,y0,'r  ','horiz','right','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    % The Plant
    sysblock('position',[x0+11.4 y0-1.5 4.5 3.5],'name','Gp',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 17.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    text(x0+20.5,y0,'  y','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    text(x0+9.7,y0+1,'u','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[18 20.5],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    % The Disturbance
    wire('x',x0+[-3.2 11.2],'y',y0+[7 7],'parent',ax,'arrow',0.5,'parent',ax);
    sysblock('position',[x0+11.4 y0+5.5 4.5 3.5],'name','Gd',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 18],'y',y0+[7 7],'parent',ax,'parent',ax);
    text(x0-4.5,y0+7,'d  ','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    sumblock('position',[x0+18,y0],'label',{'+210','+40'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    wire('x',x0+[18 18],'y',y0+[7 0.5],'parent',ax,'arrow',0.5,'parent',ax);
    wire('x',x0+[-3 8.4],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    wire('x',x0+[9 11.2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    % The FeedForward Controller
    sysblock('position',[x0+2 y0+2.6 4.5 3.5],'name','Gff',...
        'fontweight','normal','facecolor','c','fontsize',8,'parent',ax);
    wire('x',x0+[0 0 NaN 6.5 9],'y',y0+[4.3 7.0 NaN 4.3 4.3],'parent',ax);
    wire('x',x0+[9 9],'y',y0+[4.3 0.5],'parent',ax,'arrow',0.5);
    wire('x',x0+[0 1.8],'y',y0+[4.3 4.3],'parent',ax,'arrow',0.5);
    sumblock('position',[x0+9,y0+0],'label',{'+210','-140'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    
case 4
    % FeedBack & FeedForward
    wire('x',x0+[-3 -1],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    sumblock('position',[x0-0.5,y0],'label',{'+140','-240'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    text(x0-3,y0,'r  ','horiz','right','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    % The Plant
    sysblock('position',[x0+11.4 y0-1.5 4.5 3.5],'name','Gp',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 17.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    text(x0+20.5,y0,'  y','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    text(x0+9.7,y0+1,'u','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[18 20.5],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    % The Disturbance
    wire('x',x0+[-3.2 11.2],'y',y0+[7 7],'parent',ax,'arrow',0.5,'parent',ax);
    sysblock('position',[x0+11.4 y0+5.5 4.5 3.5],'name','Gd',...
        'fontweight','normal','facecolor','y','fontsize',8,'parent',ax);
    wire('x',x0+[16 18],'y',y0+[7 7],'parent',ax,'parent',ax);
    text(x0-4.5,y0+7,'d  ','horiz','left','fontweight','normal','fontsize',8+0*isunix,'parent',ax);
    wire('x',x0+[19.5 19.5 -0.5 -0.5],'y',y0+[0 -5 -5 -0.5],'parent',ax,'arrow',0.5);
    sumblock('position',[x0+18,y0],'label',{'+210','+40'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    wire('x',x0+[0 1.9],'y',y0+[0 0],'parent',ax,'arrow',0.5,'parent',ax);
    wire('x',x0+[18 18],'y',y0+[7 0.5],'parent',ax,'arrow',0.5,'parent',ax);
    % The FeedBack Controller
    sysblock('position',[x0+2 y0-1.5 4.5 3.5],'name','Gc',...
        'fontweight','normal','facecolor','c','fontsize',8,'parent',ax);
    wire('x',x0+[6.4 8.4],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    wire('x',x0+[9 11.2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
    % The FeedForward Controller
    sysblock('position',[x0+2 y0+2.6 4.5 3.5],'name','Gff',...
        'fontweight','normal','facecolor','c','fontsize',8,'parent',ax);
    wire('x',x0+[0 0 NaN 6.5 9],'y',y0+[4.3 7.0 NaN 4.3 4.3],'parent',ax);
    wire('x',x0+[9 9],'y',y0+[4.3 0.5],'parent',ax,'arrow',0.5);
    wire('x',x0+[0 1.8],'y',y0+[4.3 4.3],'parent',ax,'arrow',0.5);
    sumblock('position',[x0+9,y0+0],'label',{'+210','-140'},'radius',.5,...
        'LabelRadius',1.5,'fontsize',10,'parent',ax);
    
end


%%%%%%%%%%%%%%%%%
% localDrawCSTR %
%%%%%%%%%%%%%%%%%
function localDrawCSTR(figHdl)
GUI_Data = get(figHdl,'UserData');

if GUI_Data.AnimData.RefreshMimic == 1
    Parent = GUI_Data.AnimData.MimicHdl;
    delete(allchild(Parent));
    
    %---Default properties
    p = struct(...
        'Parent',Parent,...
        'Position',[-0.2 0 0],...
        'Size',0.09,...
        'Angle',0,...
        'LineWidth',2,...
        'LineStyle','-',...
        'Color','k',...
        'Clipping','off', ...
        'FaceColor','r', ...
        'InitialColor',[0.7 0 0], ...
        'HeatInAColor','r', ...
        'HeatInBColor',[0.5 0.5 0.5]);
    
    % Create a structure to hold the handles of the objects in the mimic display
    GUI_Data.AnimData.MimicObjtHdls = struct( ...
        'LStirrer',[], ...
        'RStirrer',[], ...        
        'LiquidIn',[], ...
        'HeatPipeIn',[], ...
        'HeatPipeOut',[], ...
        'Splash1',[], ...
        'Splash2',[], ...
        'TankLiquid',[], ...
        'InitialColor',p.InitialColor);
    
    % Scaling factor in the x direction
    q = 2;
    
    %***************************************************************************************************
    % Start to plot a mimic display of the CSTR
    x = q*[.2 .2 .4 .4 1.6 1.6 1.8 1.8 .2];
    y =   [-2 1.5 1.5 -1.5 -1.5 1.5 1.5 -2 -2];
    patch_Hdl = patch('Parent',p.Parent,...
        'XData',p.Size*(p.Position(1)+x),'YData',p.Size*(p.Position(2)+y),...
        'FaceColor',[.6 .6 .6],'EdgeColor','k','LineWidth',p.LineWidth);
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the liquid input pipe
    dx = 0.35;
    
    % Fill in the liquid input pipe draw it as 3 patches to show disturbance moving along pipe
    x_lin_pipe_patch = (dx + p.Position(1) + q*[-2.45 -2.45 -2.25 -2.25])';
    y_lin_pipe_patch = (p.Position(2) +        [ 2.0   2.25  2.25 2.0])';
    
    all_patches = p.Size*[x_lin_pipe_patch y_lin_pipe_patch];
    faces_matrix = [1 2 3 4];
    GUI_Data.AnimData.MimicObjtHdls.LiquidInA = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',p.InitialColor,'EdgeColor','none');
    
    x_lin_pipe_patch = (dx + p.Position(1) + q*[ -2.25  -2.25  0.6  0.6])';
    y_lin_pipe_patch = (p.Position(2) +        [ 2.0 2.25 2.25 2.0])';
    
    all_patches = p.Size*[x_lin_pipe_patch y_lin_pipe_patch];
    faces_matrix = [1 2 3 4];
    GUI_Data.AnimData.MimicObjtHdls.LiquidInB = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',p.InitialColor,'EdgeColor','none');
    
    x_lin_pipe_patch = (dx + p.Position(1) + q*[0.5  0.5  0.6  0.6])';
    y_lin_pipe_patch = (p.Position(2) +   [1.75 2.25 2.25 1.75])';
    
    all_patches = p.Size*[x_lin_pipe_patch y_lin_pipe_patch];
    faces_matrix = [1 2 3 4];
    GUI_Data.AnimData.MimicObjtHdls.LiquidInC = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',p.InitialColor,'EdgeColor','none');
    
    % And the "splash" as it enters the tank
    x_lin_pipe_splash_patch = (dx + p.Position(1) + q*[ 0.5  0.6  0.55])';
    y_lin_pipe_splash_patch = (p.Position(2) +   [ 1.75 1.75 1.3])';
    
    all_patches = p.Size*[x_lin_pipe_splash_patch y_lin_pipe_splash_patch];
    faces_matrix = [1 2 3];
    GUI_Data.AnimData.MimicObjtHdls.Splash1 = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',[1 1 1]*0.8,'EdgeColor','none');
    
    x_lin_pipe_splash_patch = (dx + p.Position(1) + q*[0.5  0.4 0.6  0.7])';
    y_lin_pipe_splash_patch = (p.Position(2) +   [1.75 1.3 1.75 1.3])';
    
    all_patches = p.Size*[x_lin_pipe_splash_patch y_lin_pipe_splash_patch];
    faces_matrix = [1 2 3 4];
    GUI_Data.AnimData.MimicObjtHdls.Splash2 = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',[1 1 1]*0.8,'EdgeColor','none');
    
    % Draw the liquid draw off pipe
    x_lin_pipe = dx+q*[-2.1-dx 0.5 NaN -2.1-dx 0.6  NaN 0.6  0.6  NaN 0.5 0.5 NaN];
    y_lin_pipe =      [ 2.0    2.0 NaN  2.25   2.25 NaN 2.25 1.75 NaN 2.0 1.75 NaN];
    x_doff_pipe = q*[1.6  2.2  NaN 1.6 2.2 NaN 2.21 2.21 NaN 2.25 2.25 NaN];
    y_doff_pipe =   [0.75 0.75 NaN 1.0 1.0 NaN 0.6  1.2  NaN 0.6  1.2 NaN];
    x = [x_lin_pipe x_doff_pipe];
    y = [y_lin_pipe y_doff_pipe];
    line_Hdl = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + x), ...
        'YData',p.Size*(p.Position(2) + y), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle',p.LineStyle,...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the liquid in the tank
    x_liquid_patch = (p.Position(1) + q*[ 0.4 0.4 1.6  1.6, 1.6  1.6 2.2 2.2])';
    y_liquid_patch = (p.Position(2) +   [-1.5 1.3 1.3 -1.5, 0.75 1.0 1.0 0.75])';
    all_patches = p.Size*[x_liquid_patch y_liquid_patch];
    faces_matrix = [1 2 3 4; 5 6 7 8];
    GUI_Data.AnimData.MimicObjtHdls.TankLiquid = patch('Parent',p.Parent,...
        'Vertices',all_patches,'Faces',faces_matrix,...
        'FaceColor',p.InitialColor,'EdgeColor','none');
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the heat output pipe i.e. after the valve
    x = q*[-0.75 0.65 0.65 1.3 1.3 2.2 2.2 1.2 1.2 0.75 0.75 -0.75 -0.75];
    y =   [-2.2  -2.2 -0.5 -0.5 -2.2 -2.2 -2.45 -2.45 -0.75 -0.75 -2.45 -2.45 -2.2];
    GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutA = patch('Parent',p.Parent,...
        'XData',p.Size*(p.Position(1)+x),'YData',p.Size*(p.Position(2)+y),...
        'FaceColor',p.HeatInBColor,'EdgeColor','k','LineWidth',p.LineWidth);
    % draw another patch ontop which increases when valve is open
    dp = 0;
    GUI_Data.AnimData.dp = dp;
    x = q*[-0.75 -0.75+dp -0.75+dp -0.75 -0.75];
    y =   [-2.2  -2.2     -2.45    -2.45 -2.2];
    GUI_Data.AnimData.MimicObjtHdls.HeatPipeOutB = patch('Parent',p.Parent,...
        'XData',p.Size*(p.Position(1)+x),'YData',p.Size*(p.Position(2)+y),...
        'FaceColor',p.HeatInBColor,'EdgeColor','k','LineWidth',p.LineWidth);

    x = p.Size*(p.Position(1) + q*[2.21 2.21 NaN 2.25 2.25]);
    y = p.Size*(p.Position(2) + -2.325+[-.3 .3 NaN -.3 .3]);
    line_Hdl = line(...
        'Parent',p.Parent,...
        'XData',x, ...
        'YData',y, ...   
        'LineWidth',p.LineWidth,...
        'LineStyle',p.LineStyle,...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the heat input pipe before the valve
    w = 0.25;    % y pipe diameter
    x = p.Size*(p.Position(1)+q*[-2.3 -1.28 -1.28 -2.3]);
    y = p.Size*(p.Position(2)+  [-2.2 -2.2 -2.2-w -2.2-w]);
    GUI_Data.AnimData.MimicObjtHdls.HeatPipeIn = patch('Parent',p.Parent,...
        'XData',x,'YData',y,...
        'FaceColor',p.HeatInAColor,'EdgeColor','none');
    line('Parent',p.Parent,...
        'XData',[x(1:2) NaN x(3:4)],'YData',[y(1:2) NaN y(3:4)],...
        'Color','k','LineWidth',p.LineWidth);
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the stirrer
    line_Hdl = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1)+q*[1 1]), ...
        'YData',p.Size*(p.Position(2)+[.5 2.5]), ...   
        'LineWidth',p.LineWidth,...
        'Clipping',p.Clipping);
    % Right paddle
    x = p.Size*(p.Position(1) + q*[1.1 1 1.1 1.1]);
    y = p.Size*(p.Position(2) +   [.3 .5 .7 .3]);
    GUI_Data.AnimData.MimicObjtHdls.LStirrer = patch('Parent',p.Parent,...
        'XData',x,'YData',y,...
        'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'LineWidth',p.LineWidth);
    % Left paddle
    x = p.Size*(p.Position(1) + q*[.9 1 .9 .9]);
    y = p.Size*(p.Position(2) +   [.3 .5 .7 .3]);
    GUI_Data.AnimData.MimicObjtHdls.RStirrer = patch('Parent',p.Parent,...
        'XData',x,'YData',y,...
        'FaceColor',[0 0 0],'EdgeColor',[0 0 0],'LineWidth',p.LineWidth);
    %***************************************************************************************************
    
    %***************************************************************************************************
    % Draw the tank temperature probe
    x_probe = q*[0.5 0.5  NaN 0.5 -0.25  NaN -0.25 -0.25 NaN];
    y_probe =   [0.0 1.75 NaN 1.75 1.75 NaN  1.75 0.9 NaN];
    
    line_Hdl = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + x_probe), ...
        'YData',p.Size*(p.Position(2) + y_probe), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle',p.LineStyle,...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    
    % Draw the probe round end
    probe_radius = 0.05;
    x_probe_centre = p.Position(1) + 1.0;
    y_probe_bottom = p.Position(2);
    
    x_probe_end = x_probe_centre + (cos((0:5:360)*pi/180))*probe_radius;
    y_probe_end = y_probe_bottom +  (sin((0:5:360)*pi/180))*probe_radius;
    
    % Fill in the probe end
    probe_end = patch( ...
        'Parent',p.Parent, ...
        'XData',p.Size*x_probe_end, ...
        'YData',p.Size*y_probe_end, ...
        'FaceColor',p.Color, ...
        'EdgeColor',p.Color);
    
    % Draw the tank temperature sensor ( T sphere)
    sensor_radius = 0.35;
    x_sensor_centre = p.Position(1) - 0.55;
    y_sensor_bottom = p.Position(2) + 0.9-sensor_radius;
    
    x_sensor_end = x_sensor_centre + (cos((0:5:360)*pi/180))*sensor_radius;
    y_sensor_end = y_sensor_bottom +  (sin((0:5:360)*pi/180))*sensor_radius;
    
    % Fill in the tank temperature sensor
    sensor_end = patch( ...
        'Parent',p.Parent, ...
        'XData',p.Size*x_sensor_end, ...
        'YData',p.Size*y_sensor_end, ...
        'FaceColor',[0.7 0.7 0.7], ...
        'EdgeColor',p.Color);
    
    sensor_text = text('Parent',p.Parent,'String','T','Position',p.Size*[x_sensor_centre y_sensor_bottom],...
        'FontWeight','bold','Hor','center','Ver','middle');
    
    %***************************************************************************************************
    % Draw the inlet pipe temperature probe
    x_probe = q*[-2.1 -2.1];
    y_probe =   [ 2.0   0.9];
    
    LHdlA = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + x_probe), ...
        'YData',p.Size*(p.Position(2) + y_probe), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle',p.LineStyle,...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    
    LHdlB = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + [-3.8 -2.35]), ...
        'YData',p.Size*(p.Position(2) + [ 0.6  0.6]), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle','--',...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    
    % Draw the inlet pipe temperature sensor ( T sphere)
    sensor_radius = 0.35;
    x_sensor_centre = p.Position(1) - 4.2;
    y_sensor_bottom = p.Position(2) + 0.9-sensor_radius;
    
    x_sensor_end = x_sensor_centre + (cos((0:5:360)*pi/180))*sensor_radius;
    y_sensor_end = y_sensor_bottom +  (sin((0:5:360)*pi/180))*sensor_radius;
    
    % Fill in the inlet pipe temperature sensor
    PHdl = patch( ...
        'Parent',p.Parent, ...
        'XData',p.Size*x_sensor_end, ...
        'YData',p.Size*y_sensor_end, ...
        'FaceColor',[0.7 0.7 0.7], ...
        'EdgeColor',p.Color);
    
    THdl = text('Parent',p.Parent,'String','T','Position',p.Size*[x_sensor_centre y_sensor_bottom],...
        'FontWeight','bold','Hor','center','Ver','middle');
    
    % Store the handles to be deleted when FeedForward control is deselected
    GUI_Data.AnimData.MimicObjtHdls.DelFF = [LHdlA LHdlB PHdl THdl];
    
    LHdlA = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + [-2.0  -2.0]), ...
        'YData',p.Size*(p.Position(2) + [ 0.15 -1.5]), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle','--',...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    
    % Draw the temperature controller ( TC sphere)
    sensor_radius = 0.35;
    x_sensor_centre = p.Position(1) - 2;
    y_sensor_bottom = p.Position(2) + 0.9-sensor_radius;
    
    x_sensor_end = x_sensor_centre + (cos((0:5:360)*pi/180))*sensor_radius;
    y_sensor_end = y_sensor_bottom +  (sin((0:5:360)*pi/180))*sensor_radius;
    
    % Fill in the temperature controller
    PHdl = patch( ...
        'Parent',p.Parent, ...
        'XData',p.Size*x_sensor_end, ...
        'YData',p.Size*y_sensor_end, ...
        'FaceColor','c', ...
        'EdgeColor',p.Color);
    
    THdl = text('Parent',p.Parent,'String','TC','Position',p.Size*[x_sensor_centre y_sensor_bottom],...
        'FontWeight','bold','Hor','center','Ver','middle');
    
    % Store the handles to be deleted when FeedBack and FeedForward control are deselected
    GUI_Data.AnimData.MimicObjtHdls.DelCtrl = [LHdlA PHdl THdl];
    
    LHdlA = line(...
        'Parent',p.Parent,...
        'XData',p.Size*(p.Position(1) + [-1.6  -0.9]), ...
        'YData',p.Size*(p.Position(2) + [ 0.6 0.6]), ...   
        'LineWidth',p.LineWidth,...
        'LineStyle','--',...
        'Color',p.Color,...
        'Clipping',p.Clipping);
    
    % Store the handles to be deleted when FeedBack and FeedForward control are deselected
    GUI_Data.AnimData.MimicObjtHdls.DelFB = [LHdlA];
    
    %***************************************************************************************************
    % Draw the valve in position
    valve_position = [-2.5 -2.05];
    GUI_Data.AnimData.ValveObjtHdls = valve('Parent',GUI_Data.AnimData.MimicHdl,...
        'Position',valve_position,'Size',0.1,'FaceColor',[0 0 0]);
    %***************************************************************************************************
    
end % of GUI_Data.AnimData.RefreshMimic == 1

% Add the extra temperature and control components if required
n = 2*(GUI_Data.CtrlStrct(1)) + (GUI_Data.CtrlStrct(2)) + 1;
switch n
case 1
    % No Control
    set(GUI_Data.AnimData.MimicObjtHdls.DelCtrl,'vis','off');    
    set(GUI_Data.AnimData.MimicObjtHdls.DelFF,'vis','off');
    set(GUI_Data.AnimData.MimicObjtHdls.DelFB,'vis','off');    
case 2
    % FeedBack Control
    set(GUI_Data.AnimData.MimicObjtHdls.DelCtrl,'vis','on');    
    set(GUI_Data.AnimData.MimicObjtHdls.DelFB,'vis','on');    
    set(GUI_Data.AnimData.MimicObjtHdls.DelFF,'vis','off');    
case 3
    % FeedForward Control
    set(GUI_Data.AnimData.MimicObjtHdls.DelCtrl,'vis','on');    
    set(GUI_Data.AnimData.MimicObjtHdls.DelFF,'vis','on');
    set(GUI_Data.AnimData.MimicObjtHdls.DelFB,'vis','off');    
case 4 
    % FeedBack and FeedForward Control
    set(GUI_Data.AnimData.MimicObjtHdls.DelCtrl,'vis','on');    
    set(GUI_Data.AnimData.MimicObjtHdls.DelFF,'vis','on');
    set(GUI_Data.AnimData.MimicObjtHdls.DelFB,'vis','on');    
end

GUI_Data.AnimData.RefreshMimic = 0;
% Set the user data field of the figure with the new GUI data
set(figHdl,'UserData',GUI_Data);
%***************************************************************************************************

% end of heatex.m
