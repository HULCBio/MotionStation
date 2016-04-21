function siglogdialog(varargin),
%SIGLOGDIALOG Signal logging properties dialog.
%   SIGLOGDIALOG(varargin) displays the dialog for editing signal properties.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.3 $

  action = varargin{1};

  switch action,

    case 'Open',
      ph = varargin{2};

      i_Open(ph);

    case 'EnableApply',
      fig = varargin{2};
      i_EnableApply(fig);

    case {'SigNamePopup'
          'LimitDataCheckbox'
          'DecimationCheckbox'
          'LoggingCheckbox'},

      fig = varargin{2};
      ud  = get(fig,'UserData');

      i_UpdateState(ud);
      i_EnableApply(fig);

    case 'LogNameEdit',
      fig = varargin{2};

      i_LogNameEdit(fig);
      
    case {'SimStart', 'SimStop'},
      ph  = varargin{2};
      fig = get_param(ph,'LogPropDialogHandle');
      ud  = get(fig,'UserData');

      i_UpdateState(ud);

    case 'Apply',
      fig = varargin{2};

      i_Apply(fig);

    case 'Cancel',
      INVALID_HANDLE = -1;
      fig            = varargin{2};
      ud             = get(fig,'UserData');
      ph             = ud.ph;

      set_param(ph,'LogPropDialogHandle',INVALID_HANDLE); %forces close

    case 'OK'
      INVALID_HANDLE = -1;
      fig            = varargin{2};
      ud             = get(fig,'UserData');
      ph             = ud.ph;

      i_Apply(fig);
      set_param(ph,'LogPropDialogHandle',INVALID_HANDLE); %forces close

    otherwise,
      error('M Assert: unhandled action');
  end
%endfunction siglogdialog


% Function: i_Open =============================================================
% Process the dialog open request.
%
function i_Open(ph),
  INVALID_HANDLE = -1;

  if ~ishandle(get_param(ph,'LogPropDialogHandle')),
    i_CreateDlg(ph);
  else,
    i_ShowDlg(ph);
  end
%endfunction i_Open


% Function: i_CalcFigPos =======================================================
% Currently puts dialog in the middle of the screen (same as signal properties
% dialog.  This is lame.  Should offset each one in some semi-smart way. (xxx)
%
function figPos = i_CalcFigPos(w,h),
  try,
    origUnits = get(0,'Units');
    set(0,'Units','characters');

    screenPos = get(0,'ScreenSize');
    sw = screenPos(3);
    sh = screenPos(4);

    figPos = [(sw/2)-(w/2) (sh/2)-(h/2) w h];
  end
  set(0,'Units',origUnits);

%endfunction i_CalcFigPos


% Function: i_CreateDlg ========================================================
% Create the dialog box.
%
function i_CreateDlg(ph),
  INVALID_HANDLE = -1;
  fig            = INVALID_HANDLE;

  ud.bd = get_param(bdroot,'handle');
  ud.ph = ph;

  try,
    special             = i_PlatformSpecific;
    fig                 = i_CreateDefaultFig(ph,special);
    ud                  = i_CreateTextExtent(fig,ud);
    geom                = i_CreateGeom(special);
    ctrlPos             = i_CreateCtrlDims(special,geom);
    [figX,figY,ctrlPos] = i_CreateCtrlPos(geom,ctrlPos);
    figPos              = i_CalcFigPos(figX,figY);
    ud                  = i_CreateControls(special,ctrlPos,fig,ud);

    i_Sync(ud);
    i_UpdateState(ud);

    set(fig, ...
      'UserData',   ud, ...
      'Position',   figPos, ...
      'Visible',    'on');

    set_param(ph,'LogPropDialogHandle', fig);
    
  catch,
    if ishandle(fig), delete(fig), end
    set_param(ph,'LogPropDialogHandle', INVALID_HANDLE);
    error(lasterr);
  end

%endfunction i_CreateDlg


% Function: i_ShowDlg ==========================================================
% Pop an already existing dialog to the foreground.
%
function i_ShowDlg(ph),
  fig = get_param(ph,'LogPropDialogHandle');
  figure(fig);

%endfunction i_ShowDlg


% Function: i_CreateDefaultFig =================================================
% Create the dialog box.
%
function fig = i_CreateDefaultFig(ph,special),

  color = get(0,'FactoryUIControlBackgroundColor');
  name  = i_FigName(ph);

  fig = figure(...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           special.ctrlFontName, ...
    'DefaultUicontrolFontsize',           special.ctrlFontSize, ...
    'DefaultUicontrolUnits',              'characters', ...
    'Units',                              'characters', ...
    'HandleVisibility',                   'off', ...
    'Colormap',                           [], ...
    'Name',                               name, ...
    'IntegerHandle',                      'off', ...
    'Color',                              color, ...
    'DefaultUIControlBackgroundColor',    color, ...
    'MenuBar',                            'none', ...
    'NumberTitle',                        'off');

%endfunction i_CreateDefaultFig


% Function: i_CreateTextExtent =================================================
% Create the hidden textExtent object used for control sizing.

function ud = i_CreateTextExtent(fig,ud),

  textExtent = uicontrol( ...
    'Parent',     fig, ...
    'Visible',    'off', ...
    'Style',      'text');

  ud.textExtent = textExtent;
%endfunction i_CreateTextExtent


% Function: i_NewLine2Space ====================================================
% Replace new lines with spaces.
%
function newName = i_NewLine2Space(name),
  newLine = abs(sprintf('\n'));
  space   = abs(sprintf(' '));

  newName = name;
  newName(newName == newLine) = space; %remove newLines
  
%endfunction i_NewLine2Space


% Function: i_FigName ==========================================================
% Figure out the figure name.
%
function figName = i_FigName(ph),

  sigName  = get_param(ph,'name');
  baseName = 'Logging properties: ';

  if ~isempty(sigName),
    %
    % Create name of form => Logging properties: foo
    %
    sigName = i_NewLine2Space(get_param(ph,'name'));
    figName = [baseName sigName];
  else
    %
    % Create name of form => Logging propeties: blockName:port
    %
    newLine = abs(sprintf('\n'));
    space   = abs(sprintf(' '));

    blockName  = i_NewLine2Space(get_param(ph,'Parent'));
    portNumStr = num2str(get_param(ph,'PortNumber'));

    figName = [baseName blockName ':' portNumStr];
  end 
%endfunction i_FigName


% Function: i_PlatformSpecific =================================================
% Compute properties that are platform dependent.
%
function special = i_PlatformSpecific(),

  special.sysOffsets   = sluigeom('character');
  special.ctrlFontSize = get(0, 'FactoryUicontrolFontSize');
  special.ctrlFontName = get(0, 'FactoryUicontrolFontName');

  switch(computer),

    case 'PCWIN',
      special.popupBackGroundColor = 'w';

    otherwise,  % X
      special.popupBackGroundColor = ...
        get(0, 'FactoryUicontrolBackgroundColor');
  end
%endfunction i_PlatformSpecific


% Function: i_CreateGeom =======================================================
% Create geometry constants for control positioning.
%
function geom = i_CreateGeom(special),

  sysOffsets = special.sysOffsets;

  geom.figYDeltaTop    = 1.4;
  geom.figYDeltaBottom = 0.8;
  geom.figXDelta       = 1.5;
  geom.groupYDelta     = 1.6; %distance between group boxes
  geom.groupBoxYDelta  = 0.8; %space between group border and 1st item
  geom.groupBoxXDelta  = 0.8; %space between group border and 1st item
  geom.rowDelta        = 0.5; %space between 2 rows of controls.
  
  geom.sysButtonY     = 1.5 + sysOffsets.pushbutton(4);
  geom.sysButtonX     = length('Cancel ') + sysOffsets.pushbutton(3);
  geom.sysButtonDelta = 1.5;

  geom.labelEditXDelta = 1.5; %dist between a label and corresponding edit box

  %
  % Lots of controls all share the same height
  %
  geom.editY     = 1 + sysOffsets.edit(4);
  geom.checkboxY = 1 + sysOffsets.checkbox(4);
  geom.popupY    = 1 + sysOffsets.popupmenu(4);


%endfunction i_CreateGeom


% Function: i_CreateCtrlDims ===================================================
% Calculate width and height of uicontrols.  Returns a posion vector for 
% each control with only the last 2 elements (width & height) filled in.
%
function ctrlPos = i_CreateCtrlDims(special,geom),

  sysOffsets = special.sysOffsets;

  %
  % Assume edits have same width.
  %
  editX = 35 + sysOffsets.edit(3);

  %
  % Log data checkbox
  %
  w = length('Log signal data ') + sysOffsets.checkbox(3);
  ctrlPos.logDataCheckbox = [0 0 w geom.checkboxY];

  %
  % Logging name popup.
  %
  % NOTE:
  %  Width overridden below.  Using width of 'Limit data points...' checkbox
  %  for alignment.
  %
  w = length('Use signal name  ') + sysOffsets.popupmenu(3);
  ctrlPos.logNamePopup = [0 0 w geom.popupY];

  %
  % Logging name edit.
  %
  ctrlPos.logNameEdit = [0 0 editX geom.editY];

  %
  % Limit data points checkbox
  %
  if (ispc),
    fudge = 4; %checkbox sys correction seems off
  else,
    fudge = 0;
  end
  w = length('Limit data points to last: ') + sysOffsets.checkbox(3) - fudge;
  ctrlPos.limitDataCheckbox = [0 0 w geom.checkboxY];
  ctrlPos.logNamePopup(3) = w; %override popup width for alignment

  %
  % Limit data points edit.
  %
  ctrlPos.limitDataEdit = [0 0 editX geom.editY]; 

  %
  % Decimation checkbox.
  %
  w = length('Decimation: ') + sysOffsets.checkbox(3);
  ctrlPos.decimationCheckbox = [0 0 w geom.checkboxY];

  %
  % Decimation edit.
  %
  ctrlPos.decimationEdit = [0 0 editX geom.editY]; 

  %
  % Assume that groupboxes have same width (controlled by the
  % 'Limit data points' row of the Data groupbox.
  %
  w = ...
    geom.groupBoxXDelta          + ...
    ctrlPos.limitDataCheckbox(3) + ...
    geom.labelEditXDelta         + ...
    editX                        + ...
    geom.groupBoxXDelta;

  %
  % Variable name group box.
  %
  rowHeight = max(geom.popupY, geom.editY);

  h = ...
    geom.groupBoxYDelta + ...
    rowHeight           + ...
    geom.groupBoxYDelta;

  ctrlPos.varNameGroupbox = [0 0 w h];

  %
  % Data groupbox.
  %
  rowHeight = max(geom.checkboxY, geom.editY);

  h = ...
    geom.groupBoxYDelta + ...
    rowHeight           + ...
    geom.rowDelta       + ...
    rowHeight           + ...
    geom.groupBoxYDelta;

  ctrlPos.dataGroupbox = [0 0 w h];

  %
  % Sys buttons.
  %
  ctrlPos.OK     = [0 0 geom.sysButtonX geom.sysButtonY];
  ctrlPos.cancel = [0 0 geom.sysButtonX geom.sysButtonY];
  ctrlPos.help   = [0 0 geom.sysButtonX geom.sysButtonY];
  ctrlPos.apply  = [0 0 geom.sysButtonX geom.sysButtonY];

%endfunction i_CreateCtrlDims


% Function: i_CreateCtrlPos ====================================================
% Calculate:
%   o figure height and width based on the control heights and widths
%     (elements 3 and 4 of ctrlPos vects).
%   o fill in the  the X,Y coordinates of the controls (elements 0 and 1 of the
%     ctrlPos vects - they assumed to be 0 when passed into this function).
%
function [figX,figY,ctrlPos] = i_CreateCtrlPos(geom,ctrlPos),

  %
  % Figure height.
  %
  figY = ...
    geom.figYDeltaBottom       + ...
    geom.sysButtonY            + ...
    geom.groupYDelta           + ...
    ctrlPos.dataGroupbox(4)    + ...
    geom.groupYDelta           + ...
    ctrlPos.varNameGroupbox(4) + ...
    geom.groupYDelta           + ...
    geom.checkboxY             + ...
    geom.figYDeltaTop;

  %
  % Figure width (assuming that 'Limit data points to last is widest control).
  %
  figX = ...
    geom.figXDelta               + ...
    ctrlPos.dataGroupbox(3)      + ...
    geom.figXDelta;

  %
  % sysButton control positions.
  %
  cX = figX - geom.figXDelta - ctrlPos.apply(3);
  cY = geom.figYDeltaBottom;

  ctrlPos.apply(1) = cX;
  ctrlPos.apply(2) = cY;

  cX = cX - geom.sysButtonDelta - ctrlPos.help(3);

  ctrlPos.help(1) = cX;
  ctrlPos.help(2) = cY;

  cX = cX - geom.sysButtonDelta - ctrlPos.cancel(3);

  ctrlPos.cancel(1) = cX;
  ctrlPos.cancel(2) = cY;
    
  cX = cX - geom.sysButtonDelta - ctrlPos.OK(3);

  ctrlPos.OK(1) = cX;
  ctrlPos.OK(2) = cY;

  %
  % Data groupbox position.
  %
  cX = geom.figXDelta;
  cY = cY + ctrlPos.OK(4) + geom.groupYDelta;

  ctrlPos.dataGroupbox(1) = cX;
  ctrlPos.dataGroupbox(2) = cY;

  %
  % Calculate y fixups for decimation row
  %  (due to different control heights in the row - see i_YFixUp)
  %
  [yFixCheckbox, yFixEdit] = ...
    i_YFixUp(ctrlPos.decimationCheckbox(4),ctrlPos.decimationEdit(4));

  %
  % Decimation controls.
  %
  cX = cX + geom.groupBoxXDelta;
  cY = cY + geom.groupBoxYDelta;

  ctrlPos.decimationCheckbox(1) = cX;
  ctrlPos.decimationCheckbox(2) = cY + yFixCheckbox;

  cX = cX + ctrlPos.limitDataCheckbox(3) + geom.labelEditXDelta;

  ctrlPos.decimationEdit(1) = cX;
  ctrlPos.decimationEdit(2) = cY + yFixEdit;

  %
  % Calculate y fixups for limit data row
  %  (due to different control heights in the row - see i_YFixUp)
  %
  [yFixCheckbox, yFixEdit] = ...
    i_YFixUp(ctrlPos.limitDataCheckbox(4),ctrlPos.limitDataEdit(4));

  %
  % Limit data controls.
  %
  rowHeight = max(geom.checkboxY, geom.editY);
  
  cX = ctrlPos.decimationCheckbox(1);
  cY = cY + rowHeight + geom.rowDelta;

  ctrlPos.limitDataCheckbox(1) = cX;
  ctrlPos.limitDataCheckbox(2) = cY + yFixCheckbox;

  cX = cX + ctrlPos.limitDataCheckbox(3) + geom.labelEditXDelta;

  ctrlPos.limitDataEdit(1) = cX;
  ctrlPos.limitDataEdit(2) = cY + yFixEdit;

  %
  % Variable name groupbox position.
  %
  cX = geom.figXDelta;

  cY = ...
    ctrlPos.dataGroupbox(2)    + ...
    ctrlPos.dataGroupbox(4)    + ...
    geom.groupYDelta;

  ctrlPos.varNameGroupbox(1) = cX;
  ctrlPos.varNameGroupbox(2) = cY;

  %
  % Variable name controls.
  %
  cX = ctrlPos.decimationCheckbox(1);
  cY = cY + geom.groupBoxYDelta;

  ctrlPos.logNamePopup(1) = cX;
  ctrlPos.logNamePopup(2) = cY;

  cX = cX + ctrlPos.logNamePopup(3) + geom.labelEditXDelta;

  ctrlPos.logNameEdit(1) = cX;
  ctrlPos.logNameEdit(2) = cY;

  %
  % Log data checkbox position.
  %
  cX = geom.figXDelta;

  cY = ...
    ctrlPos.varNameGroupbox(2)  + ...
    ctrlPos.varNameGroupbox(4)  + ...
    geom.groupYDelta;

  ctrlPos.logDataCheckbox(1) = cX;
  ctrlPos.logDataCheckbox(2) = cY;

%endfunction i_CreateCtrlPos


% Function: i_CreateControls ===================================================
%
function ud = i_CreateControls(special,ctrlPos,fig,ud),

  textExtent = ud.textExtent;

  %
  % Log data checkbox
  %
  children.logDataCheckbox = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'checkbox', ...
    'String',             'Log signal data', ...
    'Callback',           'siglogdialog(''LoggingCheckbox'',gcbf)', ...
    'Position',           ctrlPos.logDataCheckbox);

  %
  % Variable name group box.
  %
  children.varNameGroupbox = groupbox( ...
    fig, ...
    ctrlPos.varNameGroupbox, ...
    ' Variable name', ...
    textExtent);

  %
  % Logging name popup.
  %
  children.logNamePopup = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'popupmenu', ...
    'String',             {'Use signal name','Custom'}, ...
    'Position',           ctrlPos.logNamePopup, ...
    'Callback',           'siglogdialog(''SigNamePopup'',gcbf)', ...
    'BackGroundColor',    special.popupBackGroundColor);

  %
  % Logging name edit.
  %
  children.logNameEdit = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.logNameEdit, ...
    'Callback',           'siglogdialog(''LogNameEdit'',gcbf)', ...
    'BackGroundColor',    'w');

  %
  % Data groupbox.
  %
  children.dataGroupbox = groupbox( ...
    fig, ...
    ctrlPos.dataGroupbox, ...
    ' Data', ...
    textExtent);

  %
  % Limit data points checkbox
  %
  children.limitDataCheckbox = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'checkbox', ...
    'String',             'Limit data points to last:', ...
    'Callback',           'siglogdialog(''LimitDataCheckbox'',gcbf)', ...
    'Position',           ctrlPos.limitDataCheckbox);

  %
  % Limit data points edit.
  %
  children.limitDataEdit = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.limitDataEdit, ...
    'Callback',           'siglogdialog(''EnableApply'',gcbf)', ...
    'BackGroundColor',    'w');

  %
  % Decimation checkbox.
  %
  children.decimationCheckbox = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'checkbox', ...
    'String',             'Decimation:', ...
    'Callback',           'siglogdialog(''DecimationCheckbox'',gcbf)', ...
    'Position',           ctrlPos.decimationCheckbox);

  %
  % Decimation edit.
  %
  children.decimationEdit = uicontrol( ...
    'Parent',             fig, ...
    'Style',              'edit', ...
    'Position',           ctrlPos.decimationEdit, ...
    'Callback',           'siglogdialog(''EnableApply'',gcbf)', ...
    'BackGroundColor',    'w');

  %
  % Sys buttons.
  %
  children.OK = uicontrol( ...
    'Parent',             fig, ...
    'String',             'OK', ...
    'Horizontalalign',    'center', ...
    'Callback',           'siglogdialog(''OK'',gcbf)', ...
    'Position',           ctrlPos.OK);

  children.cancel = uicontrol( ...
    'Parent',             fig, ...
    'String',             'Cancel', ...
    'Horizontalalign',    'center', ...
    'Callback',           'siglogdialog(''Cancel'',gcbf)', ...
    'Position',           ctrlPos.cancel);

  children.help = uicontrol( ...
    'Parent',             fig, ...
    'String',             'Help', ...
    'Horizontalalign',    'center', ...
    'Position',           ctrlPos.help);

  children.apply = uicontrol( ...
    'Parent',             fig, ...
    'String',             'Apply', ...
    'Horizontalalign',    'center', ...
    'Callback',           'siglogdialog(''Apply'',gcbf)', ...
    'Position',           ctrlPos.apply);

  ud.children = children;

%endfunction i_CreateControls


% Function: i_YFixUp ===========================================================
% If two rows on the same row have different heights, the smaller one needs
% to be bumped up so that it's position is not low relative to the larger
% control.
%
function [fixA, fixB] = i_YFixUp(heightA, heightB),

  fixA = 0;
  fixB = 0;

  if (heightA < heightB),
    fixA = (heightB - heightA)/2;
  elseif (heightB < heightA),
    fixB = (heightA - heightB)/2;
  end

%endfunction i_YFixUp


% Function: i_Sync =============================================================
% Synchronize with param values stored on model.
%
function i_Sync(ud)
  children  = ud.children;
  ph        = ud.ph;

  %
  % Log checkbox.
  %
  val = get_param(ph,'DataLogging');
  set(children.logDataCheckbox, 'Value', onoff(val));

  %
  % Variable name popup
  % NOTE:
  %  o The variable name checkbox is slaved to the variable name popup
  %    It's state is handled in i_UpdateState.  The custom string is
  %    always stored in the user data of the popup.  The slaved edit
  %    control retrieves the custom string from the popup when needed.
  %
  nameMode   = get_param(ph,'DataLoggingNameMode');
  customName = get_param(ph,'DataLoggingName');

  switch(nameMode),
    case 'SignalName',
      val = 1;
    case 'Custom',
      val = 2;
    otherwise,
      error('M Assert: unexpected nameMode');
  end

  popupUd = customName;
  set(children.logNamePopup, ...
    'Value',        val, ...
    'UserData',     popupUd);
  
  %
  % Limit data points checkbox
  %
  val = get_param(ph,'DataLoggingLimitDataPoints');
  set(children.limitDataCheckbox,'Value',onoff(val));

  %
  % Limit data points edit
  %
  val = get_param(ph,'DataLoggingMaxPoints');
  set(children.limitDataEdit,'String',val);

  %
  % Decimation checkbox.
  %
  val = get_param(ph,'DataLoggingDecimateData');
  set(children.decimationCheckbox,'Value',onoff(val));

  %
  % Decimation edit
  %
  val = get_param(ph,'DataLoggingDecimation');
  set(children.decimationEdit,'String',val);

%endfunction i_Sync


% Function: i_StateForRunTime ==================================================
% Abstract:
%
function i_StateForRunTime(children),
  offCtrls = [
    children.logDataCheckbox
    children.varNameGroupbox(1)
    children.varNameGroupbox(2)
    children.logNamePopup
    children.logNameEdit
    children.dataGroupbox(1)
    children.dataGroupbox(2)
    children.limitDataCheckbox
    children.limitDataEdit
    children.decimationCheckbox
    children.decimationEdit
    children.OK
    children.apply];

  onCtrls = [
    children.cancel
    children.help];

  set(offCtrls,'Enable','off');
  set(onCtrls, 'Enable','on');

%endfunction i_StateForRunTime


% Function: i_EnableAll ==================================================
% Abstract:
%
function i_EnableAll(children),
  childCell = struct2cell(children);
  childVec  = [childCell{:}];

  set(childVec,'Enable','on');

%endfunction i_EnableAll


% Function: i_UpdateState ======================================================
%
function i_UpdateState(ud),

  children  = ud.children;
  ph        = ud.ph;
  bd        = ud.bd;
  simStatus = get_param(bd, 'SimulationStatus');
  editMode  = strcmp(simStatus,'stopped') | strcmp(simStatus,'terminating');

  if ~editMode
    i_StateForRunTime(children);
  else,
    i_EnableAll(children);

    %
    % Special handing for variable name popup/edit
    %
    signal = 1;
    custom = 2;
    val     = get(children.logNamePopup,'Value');
    popupUd = get(children.logNamePopup,'UserData');

    if val == signal,
      set(children.logNameEdit, ...
        'Enable',       'off', ...
        'String',       i_NewLine2Space(get_param(ph,'Name')));
    else,
      customString = get(children.logNamePopup,'UserData');
      set(children.logNameEdit, ...
        'Enable',       'on', ...
        'String',       customString);
    end

    %
    % Handle items in the 'Data' groupbox
    %
    loggingEnabled = get(children.logDataCheckbox, 'Value');

    if (loggingEnabled),
      %
      % Special handling for limit data checkbox/edit.
      %
      val       = get(children.limitDataCheckbox,'Value');
      editState = onoff(val);

      set(children.limitDataEdit,'Enable',editState);

      %
      % Special handling for decimation data checkbox/edit.
      %
      val       = get(children.decimationCheckbox,'Value');
      editState = onoff(val);

      set(children.decimationEdit,'Enable',editState);
    else,
      handles = [
        children.dataGroupbox(:)
        children.limitDataCheckbox
        children.limitDataEdit
        children.decimationCheckbox
        children.decimationEdit
      ];

      set(handles,'Enable','off');    
    end
  end

%endfunction i_UpdateState


% Function: i_EnableApply ======================================================
%
function i_EnableApply(fig),
  ud       = get(fig,'UserData');
  children = ud.children;

  set(children.apply, 'Enable', 'on');

%endfunction i_EnableApply


% Function: i_LogNameEdit ======================================================
%
function i_LogNameEdit(fig),
  ud       = get(fig,'UserData');
  children = ud.children;
  signal   = 1;
  custom   = 2;
  popupVal = get(children.logNamePopup,'Value');

  if (popupVal == custom),
    str = get(children.logNameEdit,'String');
    set(children.logNamePopup, 'UserData', str);
  end

  i_EnableApply(fig);

%endfunction i_LogNameEdit


% Function: i_Apply ============================================================
%
%
function i_Apply(fig),
  ud           = get(fig,'UserData');
  children     = ud.children;
  propValPairs = {};

  try,
    %
    % Data logging checkbox
    %
    h    = children.logDataCheckbox;
    prop = 'DataLogging';
    val  = onoff(get(h,'Value'));

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Variable name popup
    %
    h        = children.logNamePopup;
    prop     = 'DataLoggingNameMode';
    popupVal = get(h,'Value');

    switch(popupVal),
      case 1,
        val = 'SignalName';
      case 2,
        val = 'Custom';
      otherwise,
        error('M Assert: unexpected nameMode');
    end

    propValPairs([end+1 end+2]) = {prop, val};

    prop = 'DataLoggingName'; %the custom name
    val  = get(h, 'UserData');

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Variable name edit.
    %
    % Work handle by popupmenu.

    %
    % Limit data points checkbox
    %
    h    = children.limitDataCheckbox;
    prop = 'DataLoggingLimitDataPoints';
    val  = onoff(get(h,'Value'));

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Limit data points edit
    %
    h    = children.limitDataEdit;
    prop = 'DataLoggingMaxPoints';
    val  = get(h,'String');

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Decimation checkbox.
    %
    h    = children.decimationCheckbox;
    prop = 'DataLoggingDecimateData';
    val  = onoff(get(h,'Value'));

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Decimation edit
    %
    h    = children.decimationEdit;
    prop = 'DataLoggingDecimation';
    val  = get(h,'String');

    propValPairs([end+1 end+2]) = {prop, val};

    %
    % Apply the changes.
    %
    set_param(ud.ph, propValPairs{:});

    set(children.apply,'Enable','off');

  catch,
    errordlg(lasterr, 'Error','modal');
  end

%endfunction i_Apply


%[EOF] siglogdialog.m
