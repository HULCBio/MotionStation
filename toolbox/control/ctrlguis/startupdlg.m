function Handles = startupdlg(FigHndl, FigureType, Preferences)

%STARTUPDLG  Opens and manages the start-up dialog.
% FigHndl is the handle of the main figure window
% FigureType is either SISOtool or LTIviewer
% Preferences is the handle to the Toolbox Preferences
% Handles is a structure containing handles of objects 

%   Author(s): N. Hickey
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/10 23:14:51 $

% Parameters
StdColor = get(0,'DefaultUIControlBackground');
StdUnit = 'character';
StdFontSize = Preferences.UIFontSize;
FigW = 75;
FigH = 10;
hBorder = 1.5;
vBorder = 0.5;
EditH = 1.5;
TextH = 1.1;
Toffset = 2;
BW = (FigW-5*hBorder)/4;
BH = 1.5;

% Create figure
STARTMSGFig = figure('Color',StdColor, ...
    'IntegerHandle','off', ...
    'Units',StdUnit,...
    'Resize','off',...
    'MenuBar','none', ...
    'NumberTitle','off', ...
    'HandleVisibility','callback',...
    'Visible','off',...
    'Position',[10 10 FigW FigH],...
    'DockControls', 'off');

Handles.Figure = STARTMSGFig;
centerfig(STARTMSGFig,FigHndl);

% Create the don't show again checkbox
X0 = hBorder;
Y0 = vBorder;
nBW = BW*1.8;
chkboxHndl = uicontrol('Parent',STARTMSGFig, ...
    'Style','checkbox', ...
    'Units',StdUnit, ...
    'FontSize', StdFontSize, ...
    'Position',[X0 Y0 nBW BH], ...
    'String','Do not show me this again', ...
    'HorizontalAlignment', 'left');

% Button group
X0 = FigW - 2*hBorder-2*BW;
Y0 = vBorder;
uicontrol('Parent',STARTMSGFig, ...
    'Units',StdUnit, ...
    'FontSize', StdFontSize, ...
    'Position',[X0 Y0 BW BH], ...
    'String','Close', ...
    'Callback', {@LocalCloseBtnCB chkboxHndl FigureType} );
X0 = X0+hBorder+BW;
Handles.HelpBtn = uicontrol('Parent',STARTMSGFig, ...
    'Units',StdUnit, ...
    'FontSize', StdFontSize, ...
    'Position',[X0 Y0 BW BH], ...
    'String','Help');

% Create the text message
X0 = hBorder;
Y0 = 5*vBorder;
BW = FigW - 2*hBorder;
BH = 12*vBorder;
Handles.TextMsg = uicontrol('Parent',STARTMSGFig, ...
    'Style','text', ...
    'Units',StdUnit, ...
    'FontSize', StdFontSize, ...
    'Position',[X0 Y0 BW BH], ...
    'HorizontalAlignment', 'left');

% Create and store, a listener to delete the message box when the sisotool is closed
listener = handle.listener(FigHndl, 'ObjectBeingDestroyed', {@localDeleteMsgBox STARTMSGFig});
set(STARTMSGFig, 'UserData', listener);

% Make the figure visible
set(STARTMSGFig,'Visible','on');


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCloseBtnCB %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalCloseBtnCB(eventSrc, eventData, chkboxHndl, FigureType)
% Writes the state of the don't show me box to the ctrlprefs.mat file
on_or_off = { 'on' 'off' };
% Get the sisotool preferences
h = cstprefs.tbxprefs;
htemp = h.StartUpMsgBox;
htemp.(FigureType) = on_or_off{get(chkboxHndl,'Value')+1};
h.StartUpMsgBox = htemp;
% Save the preferences in ctrlprefs.mat file
save(h)
delete(get(chkboxHndl,'Parent'));


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeleteMsgBox %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteMsgBox(eventSrc, eventData, STARTMSGFig)
% Deletes the start-up message box when the main window is deleted

delete(STARTMSGFig);
