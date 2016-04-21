function fig = spdialog(varargin)
%SPDIALOG Signal properties dialog.
%   SPDIALOG(varargin) displays the dialog for editing signal properties.

%   Nikita Visnevski
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.32 $

if nargin < 1,
  error('Not enough input arguments');
end

guiAction = varargin{1};

% Attribute format string feature
AttrFormatStrEnabled  = 0;

ArgErrorStr = ['Invalid arguments for ''',mfilename,''' ', ...
    'to perform ''',guiAction,''' action'];

switch guiAction,

case 'Open',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Opens the dialog and sets its components to
  % values of corresponding port parameters.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 2 error(ArgErrorStr); end,
  fig = LocalProcessOpenRequest(varargin{2});

case 'OK',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Applies changes to port parameters and closes the dialog.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 2 error(ArgErrorStr); end,
  LocalProcessOKRequest(varargin{2});

case 'Apply',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Applies changes to port parameters.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 2 error(ArgErrorStr); end,
  LocalProcessApplyRequest(varargin{2});

case 'Finalize',
  if nargin ~= 2 error(ArgErrorStr); end,
  LocalFinalize(varargin{2});

case 'New',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creates a new GUI for dialog session.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 1 error(ArgErrorStr); end,
  fig = LocalCreateNewSPDialogWindow(AttrFormatStrEnabled);

case 'Resize',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Process the GUI resize action.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch nargin,
  case 1,
    LocalProcessResizeAction;
  case 2,
    LocalProcessResizeAction(varargin{2});
  otherwise,
    error(ArgErrorStr);
  end,

case 'UpdateTPStatus',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Test Point checkbox callback.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch nargin,
  case 1,
    LocalProcessTPChangeRequest;
  case 2,
    LocalProcessTPChangeRequest(varargin{2});
  otherwise,
    error(ArgErrorStr);
  end,

case 'UpdateStorageClassStatus',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % RTW Storage Class popup menu calback.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch nargin,
  case 1,
    LocalProcessStorageClassChangeRequest;
  case {2,3}
    LocalProcessStorageClassChangeRequest(varargin{2:end});
  otherwise
    error(ArgErrorStr);
  end,

case 'DocLinkCall',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Document Link field callback.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 1 error(ArgErrorStr); end,
  LocalProcessDocumentLinkCall;

case 'EnableOKApplyButtons',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Enable OK and Apply buttons.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 1 error(ArgErrorStr); end,
  LocalEnableOKApplyButton(gcbf);

otherwise,
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Default case - Invalid action command.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  error(['Invalid action command: ' guiAction]);

end,


%******************************************************************
%                  Start Local Functions
%******************************************************************


%= FUNCTION == LocalCreateNewSPDialogWindow =======================
%   - creates a new signal properties dialog and returns its handle.
%==================================================================
function h0 = LocalCreateNewSPDialogWindow(AttrFormatStrEnabled),

%
%~~ Dialog Settings ~~
%

% Set colormap
if (get(0,'ScreenDepth')==1)
  ColorMap = [0 0 0; 1 1 1];
else
  ColorMap = [1 0 0; 1 1 1]; % GUI parameter
end

% Determine common color array
FontName  = get(0,'FactoryUIControlFontName');
FontSize  = get(0,'FactoryUIControlFontSize');
Color     = get(0,'FactoryUIControlBackgroundColor');

% Default window size settings
if strcmp(computer,'PCWIN'),
  Width = 75; 
  PopUpColor          = 'white';
  PopUpTextCorrection = 0.215;
  sigPropFudge        = 0.0;
else 
  Width = 58;
  PopUpColor = Color;
  PopUpTextCorrection = 0;
  sigPropFudge        = 0.1;
end,
Height  = 40;
Offset  = 0;

% Create User Data
UD = struct( ...
  ... %~~~~~~~~~ DATA MONITORING AND CODE GENERATION CONTROL GROUP ~~~~~~~~~~~~~~~~
  'Frame1',                    -1,      'Frame1Text',                  -1,      ...
  'TPCheckBox',                -1,      ...
  'StorageClassText',          -1,      'StorageClassPopUp',           -1,      ...
  'TypeQualifierText',         -1,      'TypeQualifierEdit',           -1,      ...
  ... %~~~~~~~~~~~~~~~~~~ DOCUMENENTATION CONTROL GROUP  ~~~~~~~~~~~~~~~~~~~~~~~~~~
  'Frame2',                    -1,      'Frame2Text',                  -1,      ...
  'SigNameText',               -1,      'SigNameEdit',                 -1,      ...
  'PropSigText',               -1,      ...
  'PropSigPopup',              -1,      ...
  'DescText',                  -1,      'DescEdit',                    -1,      ...
  'DocLinkUnderline',          -1,      'DocLinkText',                 -1,      ...
  'DocLinkEdit',               -1,      ...
  'AttributeText',             -1,      'AttributeEdit',               -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~~~~~ CONTROL BUTTONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'OKButton',                  -1,      'CancelButton',                -1,      ...
  'ApplyButton',               -1,      'HelpButton',                  -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~ MAIN WINDOW PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'DefaultWidth',               Width,  'DefaultHeight',                Height, ...
  'SpaceFromBorderToFrame',     3,      'SpaceFromBorderToComponents',  5,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~~~~~~  SOURCE PORT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'SignalPort',                -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~~ ADDITIONAL GUI PARAMETERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'sysOffsets',                 sluigeom('character'),...
  'AttrFormStrFeature',         AttrFormatStrEnabled,...
  'PopUpTextCorrection',        PopUpTextCorrection,...
  'sigPropFudge',               sigPropFudge);

TextHeight  = 1 + UD.sysOffsets.text(4);

%
%~~ MAIN SIGNAL PROPERTIES DIALOG WINDOW  ~~
%

% Positioning the dialog in the middle of the screen
defUnits = get(0, 'Units');
set(0,'Units','characters');
ScreenSize = get(0,'ScreenSize');
WindowPosition = [ScreenSize(3)/2-Width/2 ScreenSize(4)/2-Height/2 Width Height];

h0 = figure( ...
  'DefaultUIControlHorizontalAlign',    'left', ...
  'DefaultUIControlFontname',           FontName, ...
  'DefaultUIControlFontsize',           FontSize, ...
  'DefaultUIControlUnits',              'characters', ...
  'DefaultUIControlBackgroundColor',    Color, ...
  'Color',                              Color, ...
  'ColorMap',                           ColorMap,...
  'HandleVisibility',                   'off', ...
  'MenuBar',                            'none', ...
  'NumberTitle',                        'off', ...
  'Units',                              'characters',...
  'Position',                           WindowPosition, ...
  'IntegerHandle',                      'off',...
  'DoubleBuffer',                       'on',...
  'ResizeFcn',                          'spdialog(''Resize'')',...
  'CloseRequestFcn',                    'spdialog(''Finalize'',gcbf)',...
  'Visible',                            'off');

%
%~~ DOCUMENTATION CONTROL GROUP ~~
%

%++++ Documentation Control Frame ++++

% Adjusting the frame based on the Attribute
% format string feature.
FrameWidth = Width - 2*UD.SpaceFromBorderToFrame;
if AttrFormatStrEnabled,
  FrameHeight = 19;
else,
  FrameHeight = 15.75;
end,
FrameX0 = UD.SpaceFromBorderToFrame;
FrameY0 = Height-Offset-FrameHeight-1;
Offset  = Height - FrameY0;
UD.Frame2 = uicontrol(                                              ...
  'Parent',               h0,                                       ...
  'Position',             [FrameX0 FrameY0 FrameWidth FrameHeight], ...
  'Enable',               'inactive',                               ...
  'Style',                'frame',                                  ...
  'Visible',              'on');
String = 'Documentation';
UD.Frame2Text = uicontrol(          ...
  'Parent',               h0,       ...
  'String',               String,   ...
  'Style',                'text',   ...
  'Visible',              'on');
text_extent   = get(UD.Frame2Text,'Extent');
ObjectWidth   = text_extent(3) + UD.sysOffsets.text(3);
ObjectHeight  = TextHeight;
X0 = UD.SpaceFromBorderToFrame + 1;
Y0 = FrameY0 + FrameHeight - ObjectHeight*0.6;
set(UD.Frame2Text,'Position',[X0 Y0 ObjectWidth ObjectHeight]);

%++++ Signal Name Edit Box ++++
String = 'Signal name:';
ObjectWidth = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight = TextHeight;
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + FrameHeight - 2.2;
UD.SigNameText = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               String, ...
  'Style',                'text',...
  'Visible',              'on');
X0tmp = X0;
Y0tmp = Y0;

ObjectWidth   = Width - 2*UD.SpaceFromBorderToComponents;
ObjectHeight  = TextHeight + UD.sysOffsets.edit(4);
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + FrameHeight - 4;
UD.SigNameEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Max',                  2, ...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Visible',              'on');

%++++ Show Propagated Signals popup ++++
String       = 'Show propagated signals:';
%ObjectWidth  = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight = TextHeight;

UD.PropSigText = uicontrol('parent',h0,'style','text','string',String);
ext=get(UD.PropSigText,'Extent');
ObjectWidth = ext(3);

Stringtmp      = 'all';
ObjectWidthTmp = length(Stringtmp) + 2 + UD.sysOffsets.popupmenu(3);

X0 = ...
  X0tmp										 + ...
  (Width - 2*UD.SpaceFromBorderToComponents) - ...
  ObjectWidth - ObjectWidthTmp;
Y0 = Y0tmp;

set(UD.PropSigText, ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Position',             [X0 Y0+UD.PopUpTextCorrection ObjectWidth ObjectHeight],...
  'String',               String, ...
  'Style',                'text',...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Visible',              'off');

String       = Stringtmp;
ObjectWidth  =  ObjectWidthTmp;
if ispc,
ObjectHeight = TextHeight + UD.sysOffsets.popupmenu(4);
else,
  ObjectHeight = TextHeight+0.4;
end
X0 = (Width - UD.SpaceFromBorderToComponents) - ObjectWidth;
UD.PropSigPopup = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               {'off','on','all'}, ...
  'Style',                'popupmenu',...
  'BackgroundColor',      PopUpColor, ...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Visible',              'off');

%++++ Description Text Edit Box ++++
String = 'Description:';
ObjectWidth   = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight  = TextHeight;
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + FrameHeight - 5.75;
UD.DescText = uicontrol( ...
  'Parent',               h0, ...
  'ListboxTop',           0, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight], ...
  'String',               String, ...
  'Style',                'text', ...
  'Visible',              'on');
ObjectWidth   = Width - 2*UD.SpaceFromBorderToComponents;
ObjectHeight  = 5.25 + UD.sysOffsets.text(4);
Y0 = FrameY0 + FrameHeight - 11.25;
UD.DescEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'Max',                  2, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Visible',              'on');

%++++ Document Link Text Edit Box ++++
String = '_____________________';
ObjectWidth   = 1; %text_extent(3) + 4 + UD.sysOffsets.text(3);
ObjectHeight  = 1;
Y0 = FrameY0 + FrameHeight - 12.6;
UD.DocLinkUnderline = uicontrol( ...
  'Parent',               h0, ...
  'ForegroundColor',      [0 0 1],...
  'FontWeight',           'bold',...
  'BusyAction',           'cancel', ...
  'Enable',               'inactive',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               String, ...
  'Style',                'text', ...
  'Visible',              'on');
String = 'Document link:';
ObjectWidth = 1; %length(String) + 5 + UD.sysOffsets.text(3);
ObjectHeight = 1;
Y0 = FrameY0 + FrameHeight - 12.5;
UD.DocLinkText = uicontrol( ...
  'Parent',               h0, ...
  'ForegroundColor',      [0 0 1],...
  'FontWeight',           'bold',...
  'BusyAction',           'cancel', ...
  'Enable',               'inactive',...
  'ButtonDownFcn',        'spdialog(''DocLinkCall'')',...
  'TooltipString',        'Click to go to the document',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               String, ...
  'Style',                'text', ...
  'Visible',              'on');
text_extent = get(UD.DocLinkText,'Extent');
position = get(UD.DocLinkText,'Position');
set(UD.DocLinkText,'Position',[position(1) position(2) text_extent(3) position(4)]);
position = get(UD.DocLinkUnderline,'Position');
if strcmp(computer,'PCWIN'),
  text_extent(3) = text_extent(3) - 1;
end
set(UD.DocLinkUnderline,'Position',[position(1) position(2) text_extent(3) position(4)]);

ObjectWidth   = Width - 2*UD.SpaceFromBorderToComponents;
ObjectHeight  = TextHeight + UD.sysOffsets.edit(4);
Y0 = FrameY0 + FrameHeight - 14.75;
UD.DocLinkEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'TooltipString',        'Click on the text label on the top to go to the document',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Visible',              'on');

%++++ Attribute Format String Edit Box ++++
String = 'Signal attribute format string:';
ObjectWidth = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight = TextHeight;
Y0 = FrameY0 + FrameHeight - 16.25;
UD.AttributeText = uicontrol( ...
  'Parent',               h0,...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               String,...
  'Style',                'text', ...
  'Enable',               'on',...
  'Visible',              'on');
ObjectWidth = Width - 2*UD.SpaceFromBorderToComponents;
ObjectHeight = TextHeight + UD.sysOffsets.edit(4);
Y0 = FrameY0 + FrameHeight - 18;
UD.AttributeEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'TooltipString',        'Enter the attribute format string here',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Enable',               'on',...
  'Visible',              'on');
if ~AttrFormatStrEnabled,
  set(UD.AttributeText,'Enable','off','Visible','off');
  set(UD.AttributeEdit,'Enable','off','Visible','off');
end,


%
%~~ DATA MONITORING AND CODE GENERATION CONTROL GROUP ~~
%

%++++ Data Monitoring and Code Generation Control Frame ++++
FrameWidth = Width-2*UD.SpaceFromBorderToFrame;
FrameHeight = 9;
FrameTitle = 'Signal monitoring and code generation options';

FrameX0 = UD.SpaceFromBorderToFrame;
FrameY0 = Height-Offset-FrameHeight-1;
Offset = Height - FrameY0;
UD.Frame1 = uicontrol( ...
  'Parent',               h0,...
  'Position',             [FrameX0 FrameY0 FrameWidth FrameHeight],...
  'Style',                'frame', ...
  'Visible',              'on');
UD.Frame1Text = uicontrol( ...
  'Parent',               h0,...
  'String',               FrameTitle,...
  'Style',                'text', ...
  'Visible',              'on');
text_extent = get(UD.Frame1Text,'Extent');
ObjectWidth   = text_extent(3) + UD.sysOffsets.text(3);
ObjectHeight  = TextHeight;
X0 = UD.SpaceFromBorderToFrame + 1;
Y0 = FrameY0 + FrameHeight - ObjectHeight*0.6;
set(UD.Frame1Text,'Position',[X0 Y0 ObjectWidth ObjectHeight]);

%++++ Test Point Checkbox ++++
String = 'SimulinkGlobal (Test Point)';
UD.TPCheckBox = uicontrol( ...
  'Parent',               h0, ...
  'String',               String, ...
  'Style',                'checkbox', ...
  'Tag',                  'Test Point Checkbox', ...
  'TooltipString',        'When ON, this signal persists during the simulation', ...
  'Value',                0,...
  'Callback',             'spdialog UpdateTPStatus;');
text_extent = get(UD.TPCheckBox,'Extent');
ObjectWidth   = text_extent(3) + UD.sysOffsets.checkbox(3);
if ispc,
ObjectHeight  = TextHeight + UD.sysOffsets.checkbox(4);
else
  ObjectHeight = TextHeight+0.55;    
end
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + FrameHeight - 2.5;
set(UD.TPCheckBox,'Position',[X0 Y0 ObjectWidth ObjectHeight]);

%++++ RTW Storage Class Pop Up Menu ++++
String = 'RTW storage class:';
UD.StorageClassText = uicontrol( ...
  'Parent',               h0,...
  'String',               String,...
  'Style',                'text', ...
  'Visible',              'on');
text_extent = get(UD.StorageClassText,'Extent');
ObjectWidth   = text_extent(3) + UD.sysOffsets.text(3);
ObjectHeight  = TextHeight;
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + 4.55;
set(UD.StorageClassText,'Position',[X0 Y0 ObjectWidth ObjectHeight]);

String = strvcat('Auto','ExportedGlobal','ImportedExtern','ImportedExternPointer');
X0 = UD.SpaceFromBorderToComponents + 1 + ObjectWidth;
Y0 = FrameY0 + 4.45;
ObjectWidth   = length(String) + 1 + UD.sysOffsets.popupmenu(3);
if ispc,
ObjectHeight  = TextHeight + UD.sysOffsets.popupmenu(4);
else,
  ObjectHeight = TextHeight+0.5;
end
UD.StorageClassPopUp = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      PopUpColor, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight], ...
  'String',               String,...
  'Max',                  4, ...
  'Style',                'popupmenu', ...
  'UserData',             1,...
  'Tag',                  'RTW Storage Class PopUp Menu', ...
  'TooltipString',        'Storage class for code generation', ...
  'Value',                1,...
  'Callback',             'spdialog UpdateStorageClassStatus;');

%++++ RTW Storage Class Type Qualifier Edit Field ++++
String = 'RTW storage type qualifier:';
ObjectWidth   = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight  = TextHeight;
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + 2.8;
UD.TypeQualifierText = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Enable',               'off',...
  'UserData',             'off',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'String',               String, ...
  'Style',                'text');
ObjectWidth = Width - 2*UD.SpaceFromBorderToComponents;
ObjectHeight = TextHeight + UD.sysOffsets.edit(4);
Y0 = FrameY0 + 1;
temp.Enable = 'off';
temp.String = '';
UD.TypeQualifierEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'String',               '',...
  'UserData',             temp,...
  'Enable',               'off',...
  'TooltipString',        'Language specific type qualifier such as "volatile" for C',...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Callback',             'spdialog EnableOKApplyButtons',...
  'Tag',                  'Storage Type Qualifier Edit Text');

%
%~~ CONTROL BUTTONS ~~
%

%++++ Apply Button ++++
%
% Making dialog buttons size match those on the
% simulation parameters dialog.
%
ObjectWidth = 10.4;
ObjectHeight = 2.0077;

X0 = Width-ObjectWidth-3; Y0 = Height-Offset-ObjectHeight-1;
UD.ApplyButton = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Callback',             'spdialog(''Apply'',gcbf)',...
  'ListboxTop',           0, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'HorizontalAlignment',  'center',...
  'String',               'Apply', ...  %'TooltipString',        'Apply your changes',...
  'Tag',                  'Pushbutton1', ...
  'Enable',               'off');

%++++ Help Button ++++
X0 = X0-ObjectWidth-2;
UD.HelpButton = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Callback',             'slprophelp(''signal'')',...
  'ListboxTop',           0, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'HorizontalAlignment',  'center',...
  'String',               'Help', ...  %'TooltipString',        'Sorry!!!  Help not available for this application',...
  'Tag',                  'Pushbutton1');

%++++ Cancel Button ++++
X0 = X0-ObjectWidth-2;
UD.CancelButton = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Callback',             'spdialog(''Finalize'',gcbf)', ...
  'ListboxTop',           0, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'HorizontalAlignment',  'center',...
  'String',               'Cancel', ...  %'TooltipString',        'Discard your changes',...
  'Tag',                  'Pushbutton1');

%++++ OK Button ++++
X0 = X0-ObjectWidth-2;
UD.OKButton = uicontrol( ...
  'Parent',               h0, ...
  'BusyAction',           'cancel', ...
  'Callback',             'spdialog(''OK'',gcbf)', ...
  'ListboxTop',           0, ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'HorizontalAlignment',  'center',...
  'String',               'OK', ...  %'TooltipString',        'Apply your changes and finish',...
  'Tag',                  'Pushbutton1');

Offset = Height - Y0;

% Finalization of the drawing
Height = Offset + 1;
UD.DefaultHeight = Height;
set(h0,'UserData',UD);
pos = get(h0,'Position');
set(h0,'Position',[pos(1) pos(2) Width Height]);
set(h0,'Visible','on');

% Reset units property
set(0,'Units',defUnits);

%= FUNCTION == LocalProcessResizeAction ===========================
%   - manages window resize action.
%==================================================================
function LocalProcessResizeAction(figHandle),

defUnits = get(0, 'Units');
set(0,'Units','characters');

if nargin < 1, figHandle = gcbf; end
UD        = get(figHandle,'UserData');
Position  = get(figHandle,'Position');

Width     = Position(3);
Height    = Position(4);

if isempty(UD) return, end,

% Attribute format string feature
AttrFormatStrEnabled  = UD.AttrFormStrFeature;

% HG objects may not be set smaller that their default size
if UD.DefaultWidth > Width,   Width   = UD.DefaultWidth;  end,
if UD.DefaultHeight > Height, Height  = UD.DefaultHeight; end,

% Calculating initial offsets
Position  = get(UD.Frame1,'Position') + 1;
Offset    = Position(4);

%
%~~ DOCUMENENTATION CONTROL GROUP ~~
%

%++++ Documentation Control Frame ++++
FramePosition = get(UD.Frame2,'Position');
FrameWidth    = Width - 2*UD.SpaceFromBorderToFrame;
FrameHeight   = Height-Offset-5;
FrameX0       = FramePosition(1);
FrameY0       = Height-FrameHeight-1;
Offset        = Height-FrameY0;
set(UD.Frame2,'Position',[FrameX0 FrameY0 FrameWidth FrameHeight]);

ObjectPosition = get(UD.Frame2Text,'Position');
Y0 = FrameY0+FrameHeight - ObjectPosition(4)*0.6;
set(UD.Frame2Text,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ Propagated signal text ++++
ObjectPosition = get(UD.PropSigText,'Position');
Y0 = FrameY0 + FrameHeight - 2.2 + UD.sigPropFudge;
set(UD.PropSigText,'Position',[ObjectPosition(1) Y0+UD.PopUpTextCorrection ObjectPosition(3) ObjectPosition(4)]);

%++++ Propagated signal popup ++++
ObjectPosition = get(UD.PropSigPopup,'Position');
Y0 = FrameY0 + FrameHeight - 2.2 + UD.sigPropFudge;
set(UD.PropSigPopup,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ Signal Name Edit Box ++++
ObjectPosition = get(UD.SigNameText,'Position');
Y0 = FrameY0 + FrameHeight - 2.2;
set(UD.SigNameText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.SigNameEdit,'Position');
Y0 = Y0 - 1.8;
set(UD.SigNameEdit,'Position',[ObjectPosition(1) Y0 Width-10 ObjectPosition(4)]);

%++++ Description Text Edit Box ++++
ObjectPosition = get(UD.DescText,'Position');
Y0 = Y0 - 1.75;
set(UD.DescText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.DescEdit,'Position');
DescEditWidth = Width - 2*UD.SpaceFromBorderToComponents;
DescEditHeight = FrameHeight - 10.5;
if AttrFormatStrEnabled,
  DescEditHeight = DescEditHeight - 3.25;
end,
Y0 = FrameY0 + FrameHeight - DescEditHeight - 5.75;
set(UD.DescEdit,'Position',[ObjectPosition(1) Y0 DescEditWidth DescEditHeight]);

%++++ Document Link Text Edit Box ++++
ObjectPosition = get(UD.DocLinkUnderline,'Position');
Y0 = Y0 - 1.35;
set(UD.DocLinkUnderline,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.DocLinkText,'Position');
Y0 = Y0 + 0.1;
set(UD.DocLinkText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.DocLinkEdit,'Position');
Y0 = Y0 - 2.25;
set(UD.DocLinkEdit,'Position',[ObjectPosition(1) Y0 Width-10 ObjectPosition(4)]);

%++++ Attribute Format String Edit Box ++++
ObjectPosition = get(UD.AttributeText,'Position');
Y0 = Y0 - 1.5;
set(UD.AttributeText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.AttributeEdit,'Position');
Y0 = Y0 - 1.75;
set(UD.AttributeEdit,'Position',[ObjectPosition(1) Y0 Width-10 ObjectPosition(4)]);

%
%~~ DATA MONITORING AND CODE GENERATION CONTROL GROUP ~~
%

%++++ Data Monitoring Control Frame ++++
FramePosition = get(UD.Frame1,'Position');
FrameWidth    = Width - 2*UD.SpaceFromBorderToFrame;
FrameHeight   = FramePosition(4);
FrameX0       = FramePosition(1);
FrameY0       = Height-Offset-FrameHeight-1;
Offset        = Height-FrameY0;
set(UD.Frame1,'Position',[FrameX0 FrameY0 FrameWidth FrameHeight]);

ObjectPosition  = get(UD.Frame1Text,'Position');
Y0 = FrameY0+FrameHeight - ObjectPosition(4)*0.6;
set(UD.Frame1Text,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ Test Point Checkbox ++++
ObjectPosition  = get(UD.TPCheckBox,'Position');
Y0 = FrameY0 + FrameHeight - 2.5;
set(UD.TPCheckBox,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ RTW Storage Class Pop Up Menu ++++
ObjectPosition  = get(UD.StorageClassText,'Position');
Y0 = FrameY0 + 4.55;
set(UD.StorageClassText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition  = get(UD.StorageClassPopUp,'Position');
Y0 = FrameY0 + 4.45;
set(UD.StorageClassPopUp,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ RTW Storage Type Qualifier Edid Field ++++
ObjectPosition  = get(UD.TypeQualifierText,'Position');
Y0 = FrameY0 + 2.8;
set(UD.TypeQualifierText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition  = get(UD.TypeQualifierEdit,'Position');
Y0 = FrameY0 + 1;
set(UD.TypeQualifierEdit,'Position',[ObjectPosition(1) Y0 Width-10 ObjectPosition(4)]);

%
%~~ CONTROL BUTTONS ~~
%

%++++ Apply Button ++++
ObjectPosition = get(UD.ApplyButton,'Position');
X0 = Width-ObjectPosition(3)-4;
Y0 = Height-Offset-ObjectPosition(4)-1;
set(UD.ApplyButton,'Position',[X0 Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ Help Button ++++
ObjectPosition = get(UD.HelpButton,'Position');
X0 = X0-ObjectPosition(3)-2;
set(UD.HelpButton,'Position',[X0 Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ Cancel Button ++++
ObjectPosition = get(UD.CancelButton,'Position');
X0 = X0-ObjectPosition(3)-2;
set(UD.CancelButton,'Position',[X0 Y0 ObjectPosition(3) ObjectPosition(4)]);

%++++ OK Button ++++
ObjectPosition = get(UD.OKButton,'Position');
X0 = X0-ObjectPosition(3)-2;
set(UD.OKButton,'Position',[X0 Y0 ObjectPosition(3) ObjectPosition(4)]);

% Reset units property
set(0,'Units',defUnits);

%= FUNCTION == LocalProcessDocumentLinkCall =======================
%   - calls the html viewer and passes to it the string
%     from the Document Link text edit box.
%==================================================================
function LocalProcessDocumentLinkCall,

fig       = gcbf;
UD        = get(fig,'UserData');

document  = get(UD.DocLinkEdit,'String');
if ~isempty(document),
  if ~isempty(findstr(document,'http:'))  |...
      ~isempty(findstr(document,'ftp:'))  |...
      ~isempty(findstr(document,'www.')),
    web(document);
  else,
    eval(document);
  end
else,
  warndlg('Cannot launch HTML viewer since Document link field is empty.','Signal Properties Warning','modal');
end,


%= FUNCTION == LocalProcessTPChangeRequest ========================
%   - Handles dependencies of the StorageClass of the
%     signal and test point.
%==================================================================
function LocalProcessTPChangeRequest(fig),

if nargin < 1, fig = gcbf; end
UD = get(fig,'UserData');

% Enable OK and Apply buttons if TP Checkbox is
% modified by the user
if strcmp(get_param(UD.SignalPort,'TestPoint'),'on'),
  ActualTestPoint = 1;
else,
  ActualTestPoint = 0;
end,
if get(UD.TPCheckBox,'Value') ~= ActualTestPoint,
  LocalEnableOKApplyButton(fig);
end,

if get(UD.TPCheckBox,'Value') == 1,
  set(UD.StorageClassText,'Enable','off');
  set(UD.StorageClassPopUp,...
    'UserData',         get(UD.StorageClassPopUp,'Value'),...
    'Value',            1,...
    'Enable',           'off');

  if strcmp(get(UD.TypeQualifierEdit,'Enable'),'on'),
    LocalProcessStorageClassChangeRequest(fig);
  end,

else,
  set(UD.StorageClassText,'Enable','on');
  set(UD.StorageClassPopUp,...
    'Value',            get(UD.StorageClassPopUp,'UserData'),...
    'Enable',           'on');

  if get(UD.StorageClassPopUp,'UserData') > 1,
    LocalProcessStorageClassChangeRequest(fig);
  end,

end,


%= FUNCTION == LocalProcessStorageClassChangeRequest ==============
%   - sets code generation parameters.
%==================================================================
function LocalProcessStorageClassChangeRequest(varargin),

switch nargin,
case 0,
  fig     = gcbf;
case 1,
  fig     = varargin{1};
otherwise,
  error(ArgErrorStr);
end,
UD = get(fig,'UserData');


% Enable OK and Apply buttons if TP Checkbox is
% modified by the user
switch get_param(UD.SignalPort,'RTWStorageClass'),
case 'Auto',
  ActualStorageClassParameter = 1;
case 'ExportedGlobal',
  ActualStorageClassParameter = 2;
case 'ImportedExtern',
  ActualStorageClassParameter = 3;
case 'ImportedExternPointer',
  ActualStorageClassParameter = 4;
case 'DefinedInTLC',
  ActualStorageClassParameter = 5;
end,
if get(UD.StorageClassPopUp,'Value') ~= ActualStorageClassParameter,
  LocalEnableOKApplyButton(fig);
end,

if get(UD.StorageClassPopUp,'Value') > 1,
  set(UD.TypeQualifierText,'Enable','on');
  temp = get(UD.TypeQualifierEdit,'UserData');
  if ~strcmp(temp.String,''),
    set(UD.TypeQualifierEdit,'String',temp.String);
  end,
  set(UD.TypeQualifierEdit,'Enable','on');

else,
  set(UD.TypeQualifierText,'Enable','off');
  temp.Enable = get(UD.TypeQualifierEdit,'Enable');
  temp.String = get(UD.TypeQualifierEdit,'String');
  set(UD.TypeQualifierEdit,...
    'UserData',       temp,...
    'Enable',         'off',...
    'String',         '');
end,


%= FUNCTION == LocalProcessOpenRequest ============================
%   - opens (or brings to front if already active)
%     the signal properties dialog.
%==================================================================
function fig = LocalProcessOpenRequest(PortHandle),

%
% Checking if this dialog window is already open
% If it's open, bring it to front, otherwise
% start a new one
%
fig = findobj(allchild(0),'Tag',...
  strcat('Properties for the port: ',...
  num2str(PortHandle,16)));

if isempty(fig),
  % If the dialog does not exist, create one
  fig   = spdialog('New');
  set(fig,'Tag',...
    strcat('Properties for the port: ',...
    num2str(PortHandle,16)));
  UD = get(fig,'UserData');
  UD.SignalPort = PortHandle;
  set(fig,'UserData',UD)
  % Update the title for the dialog based on the signal name
  title = get_param(PortHandle,'Name');
  if isempty(title), title = ' '; end,
  LocalUpdateFigureTitle(fig,title);
else,
  % If the dialog is already open, bring it to front
  figure(fig);
  UD = get(fig,'UserData');
end;

% Setting the Test Point Checkbox
if strcmp(get_param(PortHandle,'TestPoint'),'on'),
  set(UD.TPCheckBox,'Value',1);
  spdialog('UpdateTPStatus',fig);
else
  set(UD.TPCheckBox,'Value',0);
  spdialog('UpdateTPStatus',fig);
  %Setting the RTWStorageClass parameters
  TypeQualifier = get_param(PortHandle,'RTWStorageTypeQualifier');
  if isempty(TypeQualifier),
    TypeQualifier = '';
  end,

  switch get_param(PortHandle,'RTWStorageClass'),

  case {'Auto', 'DefinedInTLC'},
    set(UD.StorageClassPopUp,'Value',1);
    spdialog('UpdateStorageClassStatus',fig);

  case 'ExportedGlobal',
    set(UD.StorageClassPopUp,'Value',2);
    spdialog('UpdateStorageClassStatus',fig);
    set(UD.TypeQualifierEdit,'String',TypeQualifier);

  case 'ImportedExtern',
    set(UD.StorageClassPopUp,'Value',3);
    spdialog('UpdateStorageClassStatus',fig);
    set(UD.TypeQualifierEdit,'String',TypeQualifier);

  case 'ImportedExternPointer',
    set(UD.StorageClassPopUp,'Value',4);
    spdialog('UpdateStorageClassStatus',fig);
    set(UD.TypeQualifierEdit,'String',TypeQualifier);

  end,

end,

%
% Setting up the show prop sig popup
%
visVal = get_param(PortHandle,'EnableSigPropUI');

set([UD.PropSigText UD.PropSigPopup], 'Visible', visVal);
if (onoff(visVal)),
  showSetting = get_param(PortHandle,'ShowPropagatedSignals');
  str         = get(UD.PropSigPopup, 'String');
  val         = find(strcmp(showSetting, str));

  set(UD.PropSigPopup, 'Value', val);
end

% Setting the Name Edit Text
set(UD.SigNameEdit,'String',{get_param(PortHandle,'Name')});

% Setting the Description Edit Text
set(UD.DescEdit,'String',{get_param(PortHandle,'Description')});

% Setting the Document Link Edit Text
set(UD.DocLinkEdit,'String',get_param(PortHandle,'DocumentLink'));

ParentBlock   = get_param(PortHandle,'Parent');
BlockDiagram  = get_param(ParentBlock,'Parent');

Locked_flag = strcmp(get_param(bdroot(BlockDiagram),'Lock'),'on');
Linked_flag = strcmp(get_param(ParentBlock,'LinkStatus'),'implicit');

if ( Locked_flag | Linked_flag),
  LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks(fig);
end,

% 
% Setting the figure handle via the set_param is necessary because
% the pointer of the port inside of the C code could be garbage 
% by the time we leave this function.  This is the case if the
% block owning the port is linked, and the library it is in is 
% unlocked.  In this case the pointer to the port is invalid after
% the get_param(ParentBlock,'LinkStatus') call - block is being
% updated at this time.
%
set_param(PortHandle,'SigPropDialogHandle',fig);


%= FUNCTION == LocalProcessApplyRequest ===========================
%   - finalizes the dialog session applies all the new
%     settings to the port.
%==================================================================
function  Success = LocalProcessApplyRequest(fig),

UD = get(fig,'UserData');
Success = 1;

% Setting the Signal Name for the port and the dialog window
new_name = LocalParseCellArrayToMultilineString(get(UD.SigNameEdit, 'String'));
set_param(UD.SignalPort, 'Name', new_name);
LocalUpdateFigureTitle(fig, new_name);

%
% Show signal property setting.
%
if onoff(get_param(UD.SignalPort,'EnableSigPropUI')),
   val = get(UD.PropSigPopup, 'Value');
   str = get(UD.PropSigPopup, 'String');
   set_param(UD.SignalPort, 'ShowPropagatedSignals', str{val});
end

% Setting the Description and Document Link parameters
new_description = LocalParseCellArrayToMultilineString(get(UD.DescEdit, 'String'));
set_param(UD.SignalPort,...
  'Description',  new_description,...
  'DocumentLink', get(UD.DocLinkEdit, 'String'));

% Setting the Test Point Checkbox
if get(UD.TPCheckBox,'Value') == 1,
  try
    set_param(UD.SignalPort,...
	      'RTWStorageTypeQualifier','',...
	      'RTWStorageClass','auto',...
	      'TestPoint','on');
  catch
    % Fails when ResolveTo ~= ''
    errordlg(lasterr, 'Error','modal');
    lasterr('');
    Success = 0;
  end
else
  set_param(UD.SignalPort,'TestPoint','off'),

  if isempty(get(UD.TypeQualifierEdit,'String')),
    set(UD.TypeQualifierEdit,'String','');
  end,

  %Setting the RTWStorageClass parameter
  try
    switch get(UD.StorageClassPopUp,'Value');,
      case 1,
        set_param(UD.SignalPort,...
            'RTWStorageTypeQualifier','',...
            'RTWStorageClass','Auto');
      case 2,
        set_param(UD.SignalPort,...
            'RTWStorageClass','ExportedGlobal',...
            'RTWStorageTypeQualifier',get(UD.TypeQualifierEdit,'String'));
      case 3,
        set_param(UD.SignalPort,...
            'RTWStorageClass','ImportedExtern',...
            'RTWStorageTypeQualifier',get(UD.TypeQualifierEdit,'String'));
      case 4,
        set_param(UD.SignalPort,...
            'RTWStorageClass','ImportedExternPointer',...
            'RTWStorageTypeQualifier',get(UD.TypeQualifierEdit,'String'));
    end,
    set(UD.ApplyButton, 'Enable', 'off');
  catch
    errordlg(lasterr, 'Error','modal');
    lasterr('');
    Success = 0;
  end
end

%
% Reset the name string from the model.  If the ShowPropagatedSignals
% setting changed from off to !off, and the existing name had '<'
% characters in it, then the name will have been changed by Simulink
% such that all characters inside the <> are disregared.
%
set(UD.SigNameEdit,'String',{get_param(UD.SignalPort,'Name')});

if nargout < 1,
  clear Success;
end,


%= FUNCTION == LocalProcessOKRequest ==============================
%   - finalizes the dialog session applies all the new
%     settings to the port.
%==================================================================
function LocalProcessOKRequest(fig),

if LocalProcessApplyRequest(fig),
  LocalFinalize(fig);
end,


%= FUNCTION == LocalFinalize ======================================
%   - removes the handle of the dialog from the port and
%     closes the dialog.
%==================================================================
function LocalFinalize(fig),

UD = get(fig,'UserData');
%
% Setting 'SigPropDialogHandle' parameter of the signal port
% to an invalid handle will automatically dispose the signal
% properties dialog window.
%
set_param(UD.SignalPort,'SigPropDialogHandle',-1.0);


%= FUNCTION == LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks
%   - disables all the GUI components except for Help and
%     Cancel buttons.
%==================================================================
function LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks(fig),

UD = get(fig,'UserData');

set(UD.Frame1Text,'Enable','off');
set(UD.SigNameText,'Enable','off');
set(UD.PropSigText,'Enable','off');
set(UD.PropSigPopup,'Enable','off');
set(UD.SigNameEdit,'Enable','off');
set(UD.TPCheckBox,'Enable','off');
set(UD.StorageClassText,'Enable','off');
set(UD.StorageClassPopUp,'Enable','off');
set(UD.TypeQualifierText,'Enable','off');
set(UD.TypeQualifierEdit,'Enable','off');
set(UD.Frame2Text,'Enable','off');
set(UD.DescText,'Enable','off');
set(UD.DescEdit,'Enable','off');
set(UD.DocLinkUnderline,'Enable','off');
set(UD.DocLinkText,'Enable','off');
set(UD.DocLinkEdit,'Enable','off');
set(UD.AttributeText,'Enable','off');
set(UD.AttributeEdit,'Enable','off');
set(UD.OKButton,'Enable','off');
set(UD.ApplyButton,'Enable','off');


%= FUNCTION == LocalEnableOKApplyButton ===========================
%   - enables OK and Apply buttons if any changes were
%     made to signal parameters.
%==================================================================
function LocalEnableOKApplyButton(fig),

UD = get(fig,'UserData');

if strcmp(get(UD.OKButton,'Enable'),'off'),
  set(UD.OKButton,'Enable','on');
end,

if strcmp(get(UD.ApplyButton,'Enable'),'off'),
  set(UD.ApplyButton,'Enable','on');
end,

%= FUNCTION == LocalUpdateFigureTitle =============================
%   - updates the figure title string.
%==================================================================
function LocalUpdateFigureTitle(fig,title),

set(fig,'Name',['Signal Properties: ' title]);

%= FUNCTION == LocalParseCellArrayToMultilineString ===============
%   - takes a cell array as an argument and transforms it into
%     a multiline string containing '\n'.
%==================================================================
function str = LocalParseCellArrayToMultilineString(cell_array),

if ~iscell(cell_array),
  error('Wrong arguments passed');
end;

if ~isempty(cell_array),
  [str{1:length(cell_array)}] = deal(sprintf('\n'));
  str{length(str)} = '';
  str = strcat(cell_array, str');
  str = [str{:}];
else,
   str = '';
end   

% [EOF] spdialog.m
