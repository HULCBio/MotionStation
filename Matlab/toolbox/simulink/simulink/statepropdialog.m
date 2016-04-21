function fig = statepropdialog(varargin)
%STATEPROPDIALOG State properties dialog.
%   STATEPROPDIALOG(varargin) displays the dialog for editing state properties.

%   Paul Jackson
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $

if nargin < 1,
  error('Not enough input arguments');
end

guiAction = varargin{1};

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

case 'Delete',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Delete dialog window when block is destroyed
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 2, error(ArgErrorStr); end
  LocalBlockDeleted(varargin{2});

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
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Closes dialog window.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 2 error(ArgErrorStr); end,
  LocalFinalize(varargin{2});

case 'New',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Creates a new GUI for dialog session.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin ~= 1 error(ArgErrorStr); end,
  fig = LocalCreateNewSPDialogWindow;

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
%   - creates a new state properties dialog and returns its handle.
%==================================================================
function h0 = LocalCreateNewSPDialogWindow,

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
else 
  Width = 58;
  PopUpColor = Color;
end,
Height  = 15;
Offset  = 0;

% Create User Data
UD = struct( ...
  ... %~~~~~~~~~ DATA MONITORING AND CODE GENERATION CONTROL GROUP ~~~~~~~~~~~~~~~~
  'Frame1',                    -1,      'Frame1Text',                  -1,      ...
  'StateNameText',             -1,      'StateNameEdit',               -1,      ...
  'StorageClassText',          -1,      'StorageClassPopUp',           -1,      ...
  'TypeQualifierText',         -1,      'TypeQualifierEdit',           -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~~~~~ CONTROL BUTTONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'OKButton',                  -1,      'CancelButton',                -1,      ...
  'ApplyButton',               -1,      'HelpButton',                  -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~ MAIN WINDOW PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'DefaultWidth',               Width,  'DefaultHeight',                Height, ...
  'SpaceFromBorderToFrame',     3,      'SpaceFromBorderToComponents',  5,      ...
  ... %~~~~~~~~~~~~~~~~~~~ ASSOCIATED SIMULINK OBJECT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'BlockHandle',                -1,      ...
  ... %~~~~~~~~~~~~~~~~~~~~~~ ADDITIONAL GUI PARAMETERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  'sysOffsets',                 sluigeom('character'));

TextHeight  = 1 + UD.sysOffsets.text(4);

%
%~~ MAIN STATE PROPERTIES DIALOG WINDOW  ~~
%

% Positioning the dialog in the middle of the screen
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
  'ResizeFcn',                          'statepropdialog(''Resize'')',...
  'CloseRequestFcn',                    'statepropdialog(''Finalize'',gcbf)',...
  'Visible',                            'off');

%
%~~ STATE CODE GENERATION CONTROL GROUP ~~
%

%++++ State Code Generation Control Frame ++++
FrameWidth = Width-2*UD.SpaceFromBorderToFrame;
FrameHeight = 11;
FrameTitle = 'State code generation options';
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

%++++ State Name Edit Box ++++
String = 'State name:';
ObjectWidth = length(String) + 1 + UD.sysOffsets.text(3);
ObjectHeight = TextHeight;
X0 = UD.SpaceFromBorderToComponents;
Y0 = FrameY0 + FrameHeight - 2.2;
UD.StateNameText = uicontrol( ...
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
UD.StateNameEdit = uicontrol( ...
  'Parent',               h0, ...
  'BackgroundColor',      'white', ...
  'BusyAction',           'cancel', ...
  'Position',             [X0 Y0 ObjectWidth ObjectHeight],...
  'Style',                'edit', ...
  'Max',                  1, ...
  'Callback',             'statepropdialog EnableOKApplyButtons',...
  'Visible',              'on');

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
ObjectHeight  = TextHeight + UD.sysOffsets.popupmenu(4);
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
  'Callback',             'statepropdialog UpdateStorageClassStatus;');

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
  'Callback',             'statepropdialog EnableOKApplyButtons',...
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
  'Callback',             'statepropdialog(''Apply'',gcbf)',...
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
  'Callback',             'slprophelp(''state'')',...
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
  'Callback',             'statepropdialog(''Finalize'',gcbf)', ...
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
  'Callback',             'statepropdialog(''OK'',gcbf)', ...
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


%= FUNCTION == LocalProcessResizeAction ===========================
%   - manages window resize action.
%==================================================================
function LocalProcessResizeAction(figHandle),

if nargin < 1, figHandle = gcbf; end
UD        = get(figHandle,'UserData');
Position  = get(figHandle,'Position');

Width     = Position(3);
Height    = Position(4);

if isempty(UD) return, end,

% HG objects may not be set smaller that their default size
if UD.DefaultWidth > Width,   Width   = UD.DefaultWidth;  end,
if UD.DefaultHeight > Height, Height  = UD.DefaultHeight; end,

% Calculating initial offsets
Position  = get(UD.Frame1,'Position') + 1;
Offset    = 0;

%
%~~ STATE CODE GENERATION CONTROL GROUP ~~
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

%++++ State Name Edit Box ++++
ObjectPosition = get(UD.StateNameText,'Position');
Y0 = FrameY0 + FrameHeight - 2.2;
set(UD.StateNameText,'Position',[ObjectPosition(1) Y0 ObjectPosition(3) ObjectPosition(4)]);

ObjectPosition = get(UD.StateNameEdit,'Position');
Y0 = FrameY0 + FrameHeight - 4;
set(UD.StateNameEdit,'Position',[ObjectPosition(1) Y0 Width-10 ObjectPosition(4)]);

%   %++++ RTW Storage Class Pop Up Menu ++++
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

% Enable OK and Apply buttons if RTWStorageClass is
% modified by the user
switch get_param(UD.BlockHandle,'RTWStateStorageClass'),
case 'Auto',
  ActualStorageClassParameter = 1;
case 'ExportedGlobal',
  ActualStorageClassParameter = 2;
case 'ImportedExtern',
  ActualStorageClassParameter = 3;
case 'ImportedExternPointer',
  ActualStorageClassParameter = 4;
end,
if get(UD.StorageClassPopUp,'Value') ~= ActualStorageClassParameter,
  LocalEnableOKApplyButton(fig);
end,

switch get(UD.StorageClassPopUp,'Value')
case 1,
  % Record TypeQualifier string for future use (if it is enabled)
  % Clear & disable TypeQualifier text & string
  if strcmp(get(UD.TypeQualifierEdit,'Enable'), 'on')
    temp.Enable = get(UD.TypeQualifierEdit,'Enable');
    temp.String = get(UD.TypeQualifierEdit,'String');
    set(UD.TypeQualifierText,'Enable','off');
    set(UD.TypeQualifierEdit,...
      'UserData',       temp,...
      'Enable',         'off',...
      'String',         '');
  end
otherwise, 
  % Set TypeQualifier string from information in UserData
  % Enable TypeQualifier text & string
  temp = get(UD.TypeQualifierEdit,'UserData');
  set(UD.TypeQualifierText,'Enable','on');
  set(UD.TypeQualifierEdit,'Enable','on');
  if ~strcmp(temp.String,''),
    set(UD.TypeQualifierEdit,'String',temp.String);
  end,
end,


%= FUNCTION == LocalProcessOpenRequest ============================
%   - opens (or brings to front if already active)
%     the state properties dialog.
%==================================================================
function fig = LocalProcessOpenRequest(hBlock),

%
% Checking if this dialog window is already open
% If it's open, bring it to front, otherwise
% start a new one
%
fig = findobj(allchild(0),'Tag',...
  ['Properties for the state: ', num2str(hBlock,16)]);

if isempty(fig),
  % If the dialog does not exist, create one
  fig   = statepropdialog('New');
  set(fig,'Tag',...
    ['Properties for the state: ', num2str(hBlock,16)]);
  UD = get(fig,'UserData');
  UD.BlockHandle = hBlock;
  set(fig,'UserData',UD)
  % Update the title for the dialog based on the state name
  title = get_param(hBlock,'StateIdentifier');
  if isempty(title), title = ' '; end,
  LocalUpdateFigureTitle(fig,title);
else,
  % If the dialog is already open, bring it to front
  figure(fig);
  UD = get(fig,'UserData');
end;

%Setting the RTWStorageClass parameters
TypeQualifier = get_param(hBlock,'RTWStateStorageTypeQualifier');
if isempty(TypeQualifier),
  TypeQualifier = '';
end,

switch get_param(hBlock,'RTWStateStorageClass'),
  
case {'Auto', 'DefinedInTLC'},
  set(UD.StorageClassPopUp,'Value',1);
  statepropdialog('UpdateStorageClassStatus',fig);
case 'ExportedGlobal',
  set(UD.StorageClassPopUp,'Value',2);
  statepropdialog('UpdateStorageClassStatus',fig);
  set(UD.TypeQualifierEdit,'String',TypeQualifier);
case 'ImportedExtern',
  set(UD.StorageClassPopUp,'Value',3);
  statepropdialog('UpdateStorageClassStatus',fig);
  set(UD.TypeQualifierEdit,'String',TypeQualifier);
case 'ImportedExternPointer',
  set(UD.StorageClassPopUp,'Value',4);
  statepropdialog('UpdateStorageClassStatus',fig);
  set(UD.TypeQualifierEdit,'String',TypeQualifier);
end

% Setting the Name Edit Text
set(UD.StateNameEdit,'String',get_param(hBlock,'StateIdentifier'));

% Deal with blocks from linked/locked libraries
BlockDiagram  = get_param(hBlock,'Parent');

Locked_flag = strcmp(get_param(bdroot(BlockDiagram),'Lock'),'on');
Linked_flag = strcmp(get_param(hBlock,'LinkStatus'),'implicit');

if ( Locked_flag | Linked_flag),
  LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks(fig);
end,

%= FUNCTION == LocalProcessApplyRequest ===========================
%   - finalizes the dialog session applies all the new
%     settings to the port.
%==================================================================
function  Success = LocalProcessApplyRequest(fig),

UD = get(fig,'UserData');
Success = 1;

try
  % Get values from dialog window
  newStateName = get(UD.StateNameEdit, 'String');
  storageClassPopUpValue = get(UD.StorageClassPopUp,'Value');
  newTypeQualifier = get(UD.TypeQualifierEdit,'String');
  
  % Special case: 
  % (StateIdentifier == '') & (RTWStateStorageClass ~= 'Auto')
  if ((isempty(newStateName)) & ...
      (storageClassPopUpValue ~= 1))
    % NOTE: Can not rely on Simulink's internal error checking
    % because this only happens after the set_param has been applied
    errTxt = 'Must specify StateIdentifier when RTWStateStorageClass is not ''Auto''.';
    errordlg(errTxt, 'Error', 'modal');
    Success = 0;
  else
    % Get new values for RTWStateStorageClass & RTWStateStorageTypeQualifier
    switch storageClassPopUpValue
    case 1
      newStorageClass = 'Auto';
      newTypeQualifier = '';
    case 2
      newStorageClass = 'ExportedGlobal';
    case 3
      newStorageClass = 'ImportedExtern';
    case 4
      newStorageClass = 'ImportedExternPointer';
    end
    
    % Set new values
    % NOTE: Order is important to prevent internal Simulink errors
    set_param(UD.BlockHandle,...
      'RTWStateStorageTypeQualifier',newTypeQualifier,...
      'RTWStateStorageClass',newStorageClass,...
      'StateIdentifier', newStateName);

    % Update dialog window
    LocalUpdateFigureTitle(fig, newStateName);
    set(UD.ApplyButton, 'Enable', 'off');
  end
  catch
  errordlg(lasterr, 'Error','modal');
  lasterr('');
  Success = 0;
end


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
delete(fig);

%= FUNCTION == LocalBlockDeleted =========================
%   - deletes dialog window when Simulink model is destroyed.
%==================================================================
function LocalBlockDeleted(hBlock),
fig = findobj(allchild(0),'Tag',...
  ['Properties for the state: ', num2str(hBlock,16)]);
if ~isempty(fig)
  delete(fig);
end

%= FUNCTION == LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks
%   - disables all the GUI components except for Help and
%     Cancel buttons.
%==================================================================
function LocalDisableGUIComponentsForLockedLibraryOrLinkedBlocks(fig),

UD = get(fig,'UserData');

set(UD.Frame1Text,'Enable','off');
set(UD.StateNameText,'Enable','off');
set(UD.StateNameEdit,'Enable','off');
set(UD.StorageClassText,'Enable','off');
set(UD.StorageClassPopUp,'Enable','off');
set(UD.TypeQualifierText,'Enable','off');
set(UD.TypeQualifierEdit,'Enable','off');
set(UD.Frame2Text,'Enable','off');
set(UD.OKButton,'Enable','off');
set(UD.ApplyButton,'Enable','off');


%= FUNCTION == LocalEnableOKApplyButton ===========================
%   - enables OK and Apply buttons if any changes were
%     made to state properties.
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

set(fig,'Name',['State Properties: ' title]);

% [EOF] statepropdialog.m
