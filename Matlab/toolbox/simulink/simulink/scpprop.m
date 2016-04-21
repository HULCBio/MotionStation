function varargout = scpprop(varargin),
%SCPPROP Simulink scope properties dialog
%   SCPPROP manages the property interface for the Simulink scope.
%
%   See also SIMSCOPE, SCOPEBAR.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.50.4.2 $

Action = varargin{1};

switch(Action),

case 'create',
    %
    % Create the dialog.
    %
    scopePropDlg = varargin{2};
    scopeUserData = get(scopePropDlg, 'UserData');

    if scopeUserData.scopePropDlg == -1,
      dialog = i_Create(scopePropDlg, scopeUserData);

      scopeUserData.scopePropDlg = dialog;
      set(scopePropDlg, 'UserData', scopeUserData);
    else,
      dialogFig = scopeUserData.scopePropDlg;
      dialogUserData = get(dialogFig, 'UserData');
      i_ReShowDialog(dialogFig, dialogUserData);  
    end

case 'GeneralPage',
    %
    % Pass request to Settings Page manager.
    %
    dialogFig = varargin{3};
    dialogUserData = get(dialogFig, 'UserData');
    i_ManageGeneralPage(dialogFig, dialogUserData, varargin{2});

case 'DataPage',
    %
    % Pass request to Settings Page manager.
    %
    dialogFig = varargin{3};
    dialogUserData = get(dialogFig, 'UserData');

    [dialogUserData, bModified] = ...
      i_ManageDataPage(dialogFig, dialogUserData, varargin{2});

    if bModified == 1,
      set(dialogFig, 'UserData', dialogUserData);
    end

case 'SystemButtons',
    %
    % Pass request to System buttons(apply...) manager function.
    %
    dialogFig = varargin{3};
    dialogUserData = get(dialogFig, 'UserData');

    [dialogUserData, bModified] = ...
      i_ManageSystemButtons(dialogFig, dialogUserData, varargin{2});

    if bModified == 1,
      set(dialogFig, 'UserData', dialogUserData);
    end

case 'tabcallbk',
    %
    % Request to change page.
    %
    dialogFig = gcbf;
    dialogUserData = get(dialogFig, 'UserData');

    [dialogUserData, bModified] = i_ChangePage( ...
      varargin{2:end}, dialogUserData ...
    );

    if bModified == 1,
      set(dialogFig, 'UserData', dialogUserData);
    end

case 'BlockStart',
    %
    % Simulation is initializing.
    %
    dialogFig = varargin{2};
    dialogUserData = get(dialogFig, 'UserData');

    [dialogUserData, bModified] = ...
      i_SimulationInitialize(dialogFig, dialogUserData);

    if bModified == 1,
      set(dialogFig, 'UserData', dialogUserData);
    end

case 'BlockTerminate',
    %
    % Simulation is terminating.
    %
    dialogFig = varargin{2};
    dialogUserData = get(dialogFig, 'UserData');

    [dialogUserData, bModified] = ...
      i_SimulationTerminate(dialogFig, dialogUserData);

    if bModified == 1,
      set(dialogFig, 'UserData', dialogUserData);
    end

case 'BlockNameChange',
    %
    % Name of the block has changed, update scpprop dialog name.
    %
    dialogFig      = varargin{2};
    dialogUserData = get(dialogFig, 'UserData');

    set(dialogFig, 'Name', i_DialogName(dialogUserData.parent));

case {'FindCallBack', 'SyncCallBack'},
    %
    % A 'find' operation has occured that has required some action
    % on the part of the scope dialog.
    %
    dialogFig      = varargin{2};
    dialogUserData = get(dialogFig, 'UserData');

    i_SyncGeneralPage(dialogFig, dialogUserData);
  
otherwise,
    %
    % Programming error.
    %
    error('M Assert: unknown action');
end


% Function =====================================================================
% Create the dialog box.

function dialogFig = i_Create(scopePropDlg, scopeUserData),

%
% Create constants based on current computer.
%
dialogUserData.thisComputer = computer;

dialogUserData.fontsize = get(0, 'FactoryUicontrolFontSize');
dialogUserData.fontname = get(0, 'FactoryUicontrolFontName');

switch(dialogUserData.thisComputer),

case 'PCWIN',
    dialogUserData.popupBackGroundColor = 'w';

case 'MAC2',
    dialogUserData.popupBackGroundColor = 'w';

otherwise,  % X
    dialogUserData.popupBackGroundColor = ...
      get(0, 'FactoryUicontrolBackgroundColor');
end

%
% Create an empty figure (we need it now for text extents)..
%
closeReqFcn = 'scpprop(''SystemButtons'', ''CloseReq'',  gcbf)';
deleteFcn   = 'scpprop(''SystemButtons'', ''DeleteFcn'', gcbf)';

dialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           dialogUserData.fontname, ...
    'DefaultUicontrolFontsize',           dialogUserData.fontsize, ...
    'DefaultUicontrolUnits',              'pixels', ...
    'HandleVisibility',                   'off', ...
    'Colormap',                           [], ...
    'Name',                               i_DialogName(scopePropDlg), ...
    'IntegerHandle',                      'off', ...
    'CloseRequestFcn',                    closeReqFcn, ...
    'DeleteFcn',                          deleteFcn);

%
% Create a text object for text sizing.
%
textExtent = uicontrol( ...
    'Parent',     dialogFig, ...
    'Visible',    'off', ...
    'Style',      'text');

%
% Construct common geometry constants.
%
commonGeom  = i_CommonGeom(textExtent);
generalGeom = i_GeneralGeom(commonGeom);
dataGeom    = i_DataGeom(commonGeom);


%
% Create tabbed dialog.
%
tabStrings = {'General', 'Data history'};
sheetDims  = i_SheetDims(commonGeom, generalGeom, dataGeom);

callback  = 'scpprop';
offsets   = [
  commonGeom.figSideEdgeBuffer
  commonGeom.figTopEdgeBuffer
  commonGeom.figSideEdgeBuffer
  commonGeom.bottomSheetOffset];

defaultPageNum  = 1;
defaultPageName = tabStrings{defaultPageNum};

%
% ... calculate tab dimenstions 
%
nTabs = length(tabStrings);
widths(nTabs) = 0; %alloc

for i=1:nTabs,
  set(textExtent, 'String', tabStrings{i});
  ext = get(textExtent, 'Extent');
  widths(i) = ext(3) + 6;
end

height  = ext(4) + 3;
tabDims = {widths, height};

[dialogFig, sheetPos] = tabdlg('create', ...
    tabStrings, ...
    tabDims, ...
    callback, ...
    sheetDims, ...
    offsets, ...
    defaultPageNum, ...
    {}, ...
    dialogFig);
commonGeom.sheetPos = sheetPos;

%
% Finish creating initial user data.
%
dialogUserData.parent                = scopePropDlg;
dialogUserData.block                 = scopeUserData.block;
dialogUserData.block_diagram         = scopeUserData.block_diagram;
dialogUserData.commonGeom            = commonGeom;
dialogUserData.generalGeom           = generalGeom;
dialogUserData.dataGeom              = dataGeom;
dialogUserData.generalPage.children  = [];
dialogUserData.dataPage.children     = [];

%
% Create default page and system buttons.
%
dialogUserData = i_CreatePage(defaultPageName, dialogFig, dialogUserData);
dialogUserData = i_CreateSysButtons(dialogFig, dialogUserData);

%
% Add "hint" to try right clicking on axis.
%
dialogPos = get(dialogFig, 'Position');

str1 = 'Tip:';
set(textExtent, 'String', str1);
ext  = get(textExtent, 'Extent');
w1   = ext(3);

str2 = 'try right clicking on axes';
set(textExtent, 'String', str2);
ext  = get(textExtent, 'Extent');
w2   = ext(3);

width = w1 + w2 + 1;

dialogUserData.rightClickHint(2) = 0; %alloc

height = ext(4);
left   = dialogPos(3) - commonGeom.figSideEdgeBuffer - width;
bottom = dialogPos(4) - commonGeom.figTopEdgeBuffer - tabDims{2} - 3;
dialogUserData.rightClickHint(1) = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'text', ...
    'String',           str1, ...
    'ForegroundColor',  'k', ...
    'Position',         [left bottom w1 height]);

left = left + w1;
dialogUserData.rightClickHint(2) = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'text', ...
    'String',           str2, ...
    'ForegroundColor',  'k', ...
    'Position',         [left bottom w2 height]);

%
% Visible stuff is done.  Set user data and show figure.
%
scopePos     = get(scopePropDlg, 'Position');
deltaY       = scopePos(4) - dialogPos(4);
dialogBottom = scopePos(2) + deltaY - 10;
dialogLeft   = scopePos(1) + 10;

dialogPos([1 2]) = [dialogLeft dialogBottom];

set(dialogFig, ...
    'Visible',        'on', ...
    'Position',       dialogPos, ...
    'UserData',       dialogUserData);

%
% Install callbacks.
%
i_InstallCallbacks(defaultPageName, dialogFig, dialogUserData);
i_InstallCallbacks('System', dialogFig, dialogUserData);


% Function =====================================================================
% Create common geometry structure.

function commonGeom = i_CommonGeom(textExtent),

sysOffsets = sluigeom;

calibrationStr = '_Cancel_';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

sysButtonWidth = ext(3);
charHeight     = ext(4);

commonGeom.textHeight            = charHeight;
commonGeom.editHeight            = charHeight + sysOffsets.edit(4);
commonGeom.checkboxHeight        = charHeight + sysOffsets.checkbox(4);
commonGeom.popupHeight           = charHeight + sysOffsets.popupmenu(4);
commonGeom.sysButtonHeight       = (charHeight * 1.3) + sysOffsets.pushbutton(4);
commonGeom.sysButtonWidth        = sysButtonWidth + sysOffsets.pushbutton(3);
commonGeom.sysButtonDelta        = 8;
commonGeom.sheetSideEdgeBuffer   = 8;
commonGeom.sheetTopEdgeBuffer    = (commonGeom.textHeight/1.3);
commonGeom.sheetBottomEdgeBuffer = 8;
commonGeom.frameBottomEdgeBuffer = 6;
commonGeom.frameTopEdgeBuffer    = (commonGeom.textHeight/2) + 2;
commonGeom.frameSideEdgeBuffer   = 8;
commonGeom.frameDelta            = (commonGeom.textHeight/1.3);
commonGeom.figBottomEdgeBuffer   = 5;
commonGeom.figTopEdgeBuffer      = 5;
commonGeom.figSideEdgeBuffer     = 5;
commonGeom.sysButton_SheetDelta  = 5;
commonGeom.rowSpace              = 5; 

commonGeom.bottomSheetOffset = ...
  commonGeom.figBottomEdgeBuffer    + ...
  commonGeom.sysButtonHeight        + ...
  commonGeom.sysButton_SheetDelta; 

commonGeom.sysOffsets = sysOffsets;
commonGeom.textExtent = textExtent;

set(textExtent, 'String', '12345678901');
ext = get(textExtent, 'Extent');
commonGeom.stdEditWidth = ext(3) + sysOffsets.edit(3);

commonGeom.checkboxEditDelta = 5;

commonGeom.checkboxEditPairHeight = ...
  max(commonGeom.checkboxHeight, commonGeom.editHeight);


% Function =====================================================================
% Create specified tab page.                                     

function dialogUserData = i_CreatePage(page, dialogFig, dialogUserData),

if strcmp(get(dialogFig, 'Visible'), 'on'),
    set(dialogFig, 'DefaultUicontrolVisible', 'off');
end

switch(page),
  
case 'General',
    dialogUserData = i_CreateGeneralPage(dialogFig, dialogUserData);
    i_SyncGeneralPage(dialogFig, dialogUserData);

    dialogUserData.generalGeom = [];

case 'Data',
    dialogUserData = i_CreateDataPage(dialogFig, dialogUserData);
    i_SyncDataPage(dialogFig, dialogUserData);

    dialogUserData.dataGeom = [];

otherwise,
    error('M Assert: Invalid page');

end

set(dialogFig, 'DefaultUicontrolVisible', 'on');


%
% If all pages are created, free up some memory.
%

if ((~isempty(dialogUserData.generalPage.children)) & ...
    (~isempty(dialogUserData.dataPage.children))),

  delete(dialogUserData.commonGeom.textExtent);
  dialogUserData.commonGeom = [];

end


% Function =====================================================================
% Create geometry constants for axes page.
%
% NOTE: Some of these dimensions are actually "minimum allowed" dimensions
%       that are used only to figure out how big to make the figure.  Once
%       a figure size is picked some controls will be made large enough to
%       fill any extra space.

function geom = i_GeneralGeom(commonGeom),

textExtent = commonGeom.textExtent;
sysOffsets = commonGeom.sysOffsets;

geom.colDelta  = 18;
geom.editWidth = commonGeom.stdEditWidth - 4;

set(textExtent, 'String', 'Number of axes: ');
ext = get(textExtent, 'Extent');
geom.numAxesLabelWidth = ext(3) + sysOffsets.text(3);

set(textExtent, 'String', 'floating scope ');
ext = get(textExtent, 'Extent');
geom.floatCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Time range: ');
ext = get(textExtent, 'Extent');
geom.timeRangeLabelWidth = ext(3) + sysOffsets.text(3);

set(textExtent, 'String', 'Tick labels: ');
ext = get(textExtent, 'Extent');
geom.tickLabelLabelWidth = ext(3) + sysOffsets.text(3);

set(textExtent, 'String', 'bottom axis only ');
ext = get(textExtent, 'Extent');
geom.tickLabelPopupWidth = ext(3) + sysOffsets.popupmenu(3);

set(textExtent, 'String', 'Sample time  ');
ext = get(textExtent, 'Extent');
geom.sampleTimePopupWidth = ext(3) + sysOffsets.popupmenu(3);

col1LabelWidths = ...
    [geom.numAxesLabelWidth
     geom.timeRangeLabelWidth
     geom.tickLabelLabelWidth];
geom.maxCol1LabelWidth = max(col1LabelWidths);

geom.AxesGroupBoxWidth = ...
    (commonGeom.frameSideEdgeBuffer * 2)  + ...
    geom.maxCol1LabelWidth         + ...
    geom.editWidth                 + ...
    geom.colDelta                  + ...
    geom.floatCheckboxWidth;

geom.AxesGroupBoxHeight = ...
    commonGeom.frameTopEdgeBuffer     + ...
    commonGeom.editHeight             + ...
    commonGeom.rowSpace               + ...
    commonGeom.editHeight             + ...
    commonGeom.rowSpace               + ...
    commonGeom.popupHeight            + ...
    commonGeom.frameBottomEdgeBuffer;

geom.SamplingGroupBoxWidth  = geom.AxesGroupBoxWidth;
geom.SamplingGroupBoxHeight = ...
    commonGeom.frameTopEdgeBuffer     + ...
    commonGeom.popupHeight            + ...
    commonGeom.frameBottomEdgeBuffer;


% Function =====================================================================
% Determine ctrl positions for general page.

function ctrlPos = i_GeneralCtrlPositions(commonGeom, generalGeom),

%
% Axes groupbox.
%

%
% ...frame
%

frameLeft = commonGeom.figSideEdgeBuffer + commonGeom.sheetSideEdgeBuffer;

frameTop  = ... 
    (commonGeom.sheetPos(2) + commonGeom.sheetPos(4)) - ...
    commonGeom.sheetTopEdgeBuffer;

frameHeight = generalGeom.AxesGroupBoxHeight;
frameWidth  = generalGeom.AxesGroupBoxWidth;
frameBottom = frameTop - frameHeight;

ctrlPos.axesGroupBox = [frameLeft frameBottom frameWidth frameHeight];

%
% ...Number of axes.
%

cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = frameTop - commonGeom.frameTopEdgeBuffer - commonGeom.editHeight;


ctrlPos.numAxesLabel = ...
    [cxCur cyCur generalGeom.numAxesLabelWidth commonGeom.textHeight];

rightTickLabelPopup = ...
    cxCur +  generalGeom.tickLabelLabelWidth + generalGeom.tickLabelPopupWidth;

cxCur     = cxCur + generalGeom.numAxesLabelWidth;
editWidth = rightTickLabelPopup - cxCur;
ctrlPos.numAxesEdit = ...
    [cxCur cyCur editWidth commonGeom.editHeight];


%
% ...Floating scope.
%
cxCur = cxCur + generalGeom.editWidth + generalGeom.colDelta;

ctrlPos.floatCheckbox = ...
    [cxCur cyCur generalGeom.floatCheckboxWidth commonGeom.checkboxHeight];

%
% ...Time range;
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - commonGeom.rowSpace - commonGeom.editHeight;

labelWidth = max(generalGeom.timeRangeLabelWidth,...
                 generalGeom.tickLabelLabelWidth);

ctrlPos.timeRangeLabel = ...
    [cxCur cyCur generalGeom.timeRangeLabelWidth commonGeom.textHeight];



cxCur     = cxCur + labelWidth;
editWidth = rightTickLabelPopup - cxCur;
ctrlPos.timeRangeEdit = [cxCur cyCur editWidth commonGeom.editHeight];

%
% ...Tick labels
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = cyCur - commonGeom.rowSpace - commonGeom.editHeight;
ctrlPos.tickLabelLabel = ...
    [cxCur cyCur generalGeom.tickLabelLabelWidth commonGeom.textHeight];

cxCur = cxCur + labelWidth;
ctrlPos.tickLabelPopup = ...
    [cxCur cyCur generalGeom.tickLabelPopupWidth commonGeom.popupHeight];


%
% Sampling.
%

%
% ...frame
%

frameTop    = frameBottom - commonGeom.frameDelta;
frameLeft   = commonGeom.figSideEdgeBuffer + commonGeom.sheetSideEdgeBuffer;
frameWidth  = generalGeom.SamplingGroupBoxWidth;
frameHeight = generalGeom.SamplingGroupBoxHeight;
frameBottom = frameTop - frameHeight;

ctrlPos.samplingGroupBox = [frameLeft frameBottom frameWidth frameHeight];

%
% Decimation/Sample Time popup
%
cxCur = frameLeft + commonGeom.frameSideEdgeBuffer;
cyCur = frameTop - commonGeom.frameTopEdgeBuffer - commonGeom.editHeight;

ctrlPos.sampleTimePopup = ...
    [cxCur cyCur generalGeom.sampleTimePopupWidth commonGeom.popupHeight];

cxCur = ...
    cxCur + generalGeom.sampleTimePopupWidth + commonGeom.checkboxEditDelta;

ctrlPos.sampleTimeEdit = ...
    [cxCur cyCur generalGeom.editWidth commonGeom.editHeight];


% Function =====================================================================
% Create General page.

function dialogUserData = i_CreateGeneralPage(dialogFig, dialogUserData),

commonGeom      = dialogUserData.commonGeom;
generalGeom     = dialogUserData.generalGeom;
popupBackground = dialogUserData.popupBackGroundColor;
textExtent      = commonGeom.textExtent;
block           = dialogUserData.block;

if isempty(dialogUserData.generalPage.children),
    generalCtrlPos = i_GeneralCtrlPositions(commonGeom, generalGeom);
end

%
% Axes group box.
%
children.axesGroupBox = groupbox( ...
    dialogFig, ...
    generalCtrlPos.axesGroupBox, ...
    ' Axes', ...
    textExtent);

children.numAxesLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Number of axes:', ...
    'Position',           generalCtrlPos.numAxesLabel);

children.numAxesEdit = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'edit', ...
    'Position',           generalCtrlPos.numAxesEdit, ...
    'BackGroundColor',    'w');


if ~onoff(get_param(block,'ModelBased'))
    children.floatCheckbox = uicontrol( ...
        'Parent',             dialogFig, ...
        'Style',              'checkbox', ...
        'String',             'floating scope', ...
        'Position',           generalCtrlPos.floatCheckbox);
else
    children.floatCheckbox = -1;
end

children.timeRangeLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Time range:', ...
    'Position',           generalCtrlPos.timeRangeLabel);

children.timeRangeEdit = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'edit', ...
    'Position',           generalCtrlPos.timeRangeEdit, ...
    'BackGroundColor',    'w');

children.tickLabelLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Tick labels:', ...
    'Position',           generalCtrlPos.tickLabelLabel);

string = {'all', 'none', 'bottom axis only'};
children.tickLabelPopup = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'Position',           generalCtrlPos.tickLabelPopup, ...
    'BackGroundColor',    popupBackground);

%
% Sampling group box.
%
children.samplingGroupBox = groupbox( ...
    dialogFig, ...
    generalCtrlPos.samplingGroupBox, ...
    ' Sampling', ...
    textExtent);

if ~onoff(get_param(block,'ModelBased'))
    string = {'Decimation', 'Sample time'};
    children.sampleTimePopup = uicontrol( ...
        'Parent',             dialogFig, ...
        'Style',              'popupmenu', ...
        'String',             string, ...
        'Position',           generalCtrlPos.sampleTimePopup, ...
        'BackGroundColor',    popupBackground);
else
    children.sampleTimePopup = uicontrol( ...
        'Parent',             dialogFig, ...
        'Style',              'text', ...
        'String',             'Decimation', ...
        'Position',           generalCtrlPos.sampleTimePopup, ...
        'BackGroundColor',    popupBackground);
end

children.sampleTimeEdit = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'edit', ...
    'Position',           generalCtrlPos.sampleTimeEdit, ...
    'BackGroundColor',    'w');

%
% Update the user data.
%
dialogUserData.generalPage.children = children;


% Function =====================================================================
% Create geometry constants for data history page.
% NOTE: Some of these dimensions are actually "minimum allowed" dimensions
%       that are used only to figure out how big to make the figure.  Once
%       a figure size is picked some controls will be made large enough to
%       fill any extra space.

function geom = i_DataGeom(commonGeom),

textExtent     = commonGeom.textExtent;
sysOffsets     = commonGeom.sysOffsets;
geom.editWidth = commonGeom.stdEditWidth + 16;
geom.vSpacer   = commonGeom.textHeight;

set(textExtent, 'String', 'Limit data points to last:');
ext = get(textExtent, 'Extent');
geom.LimitDataToLastCheckboxWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Save data to workspace');
ext = get(textExtent, 'Extent');
geom.saveToWorkspaceWidth = ext(3) + sysOffsets.checkbox(3);

set(textExtent, 'String', 'Variable name:');
ext = get(textExtent, 'Extent');
geom.variableNameLabelWidth = ext(3);

set(textExtent, 'String', 'Format: ');
ext = get(textExtent, 'Extent');
geom.formatLabelWidth = ext(3) + sysOffsets.text(3);
if geom.formatLabelWidth < geom.variableNameLabelWidth
  geom.formatLabelWidth = geom.variableNameLabelWidth;
end

set(textExtent, 'String', 'Structure with time ');
ext = get(textExtent, 'Extent');
geom.formatLabelPopupWidth = ext(3) + sysOffsets.popupmenu(3);


% Function =====================================================================
% Determine ctrl positions for data history page.

function ctrlPos = i_DataCtrlPositions(commonGeom, dataGeom),

% formatLabelPopupWidth is a base size for several uiControls in the Data
% history page. Since sheetPos is not available in i_DataGeom when 
% formatLabelPopupWidth is initialized, we update it here.
% (Note: this is a work a round and can be updated in future.)
%
sheetPos   = commonGeom.sheetPos;
sysOffsets = commonGeom.sysOffsets;
dataGeom.formatLabelPopupWidth = (sheetPos(3)- ...
                                  dataGeom.variableNameLabelWidth - ...
                                  2*commonGeom.sheetSideEdgeBuffer);  
%
left = commonGeom.figSideEdgeBuffer + commonGeom.sheetSideEdgeBuffer;


rightFormatPopup = ...
    left                           +...
    dataGeom.formatLabelWidth      +...
    dataGeom.formatLabelPopupWidth;

%
% Limit data checkbox and edit.
%
cxCur = left;
cyCur = ...
    (commonGeom.sheetPos(2) + commonGeom.sheetPos(4)) - ...
    commonGeom.sheetTopEdgeBuffer                     - ...
    commonGeom.checkboxHeight;

ctrlPos.limitDataCheck = [cxCur cyCur ...
    dataGeom.LimitDataToLastCheckboxWidth commonGeom.checkboxHeight];

cxCur = ...
    cxCur + dataGeom.LimitDataToLastCheckboxWidth + commonGeom.checkboxEditDelta;

editWidth = rightFormatPopup - cxCur - 1;
ctrlPos.limitDataEdit = ...
    [cxCur cyCur editWidth commonGeom.editHeight];

%
% Save data to workspace checkbox.
%
cyCur = cyCur - commonGeom.editHeight - dataGeom.vSpacer;
cxCur = left;

ctrlPos.saveToWorkspaceCheckbox = [cxCur cyCur ...
    dataGeom.saveToWorkspaceWidth commonGeom.checkboxHeight];

%
% Variable name label and edit.
%
cyCur = cyCur - commonGeom.rowSpace - commonGeom.editHeight;

ctrlPos.variableNameLabel = [cxCur cyCur ...
    dataGeom.variableNameLabelWidth commonGeom.textHeight];

cxCur = cxCur + dataGeom.variableNameLabelWidth;
editWidth = rightFormatPopup - cxCur - 1;
ctrlPos.variableNameEdit = [cxCur cyCur editWidth commonGeom.editHeight];

%
% Format label and popup.
%
cxCur = left;
cyCur = cyCur - commonGeom.rowSpace - commonGeom.popupHeight;

ctrlPos.formatLabel = ...
    [cxCur cyCur dataGeom.formatLabelWidth commonGeom.textHeight];

cxCur = cxCur + dataGeom.formatLabelWidth;
ctrlPos.formatPopup = ...
    [cxCur cyCur dataGeom.formatLabelPopupWidth commonGeom.popupHeight];


% Function =====================================================================
% Create Settings page.

function dialogUserData = i_CreateDataPage(dialogFig, dialogUserData),

commonGeom             = dialogUserData.commonGeom;
dataGeom               = dialogUserData.dataGeom;
textExtent             = commonGeom.textExtent;
popupBackground        = dialogUserData.popupBackGroundColor;
block_diagram          = dialogUserData.block_diagram;
simStatus              = get_param(block_diagram, 'SimulationStatus');
defaultUicontrolEnable = get(dialogFig, 'DefaultUicontrolEnable');

if strcmp(simStatus, 'running'),
    set(dialogFig, 'DefaultUicontrolEnable', 'off');
end

if isempty(dialogUserData.dataPage.children),
    dataCtrlPos = i_DataCtrlPositions(commonGeom, dataGeom);
end

children.limitDataCheck = uicontrol(...
    'Parent',             dialogFig,...
    'Style',              'checkbox',...
    'String',             'Limit data points to last:',...
    'Position',           dataCtrlPos.limitDataCheck);

children.limitDataEdit = uicontrol(...
    'Parent',             dialogFig,...
    'Style',              'edit',...
    'HorizontalAlign',    'left',...
    'BackgroundColor',    'w',...
    'Position',           dataCtrlPos.limitDataEdit);

children.saveToWorkspaceCheckbox = uicontrol(...
    'Parent',             dialogFig,...
    'Style',              'checkbox',...
    'String',             'Save data to workspace',...
    'Position',           dataCtrlPos.saveToWorkspaceCheckbox);

children.variableNameLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Variable name:', ...
    'Position',           dataCtrlPos.variableNameLabel);

children.variableNameEdit = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'edit', ...
    'Position',           dataCtrlPos.variableNameEdit, ...
    'BackgroundColor',    'w');

children.formatLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Format:', ...
    'Position',           dataCtrlPos.formatLabel);

string = ...
    {'Structure with time', 'Structure', 'Array'};
children.formatPopup = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'popupmenu', ...
    'String',             string, ...
    'Position',           dataCtrlPos.formatPopup, ...
    'BackGroundColor',    popupBackground);

%
% Update the user data.
%
dialogUserData.dataPage.children = children;


% Function =====================================================================
% Determine sheet dimensions.  For each sheet, an expression defining it's
% width and height is used.  The max width and height across all sheets is
% used to compute the sizes.

function sheetDims = i_SheetDims(commonGeom, generalGeom, dataGeom),

numPages = 3;   % 1 for the system buttons
widths(numPages)  = 0;
heights(numPages) = 0;

%
% General sheet dims.
%
widths(1) = ...
    (commonGeom.sheetSideEdgeBuffer * 2) + ...
    generalGeom.AxesGroupBoxWidth;

heights(1) = ...
    commonGeom.sheetTopEdgeBuffer      + ...
    generalGeom.AxesGroupBoxHeight     + ...
    commonGeom.frameDelta              + ...
    generalGeom.SamplingGroupBoxHeight + ...
    commonGeom.sheetBottomEdgeBuffer;

%
% Settings page sheet dims.
%
widths(2) = ...
    (commonGeom.sheetSideEdgeBuffer * 2)    + ...
    (commonGeom.frameSideEdgeBuffer * 2)    + ...
    dataGeom.LimitDataToLastCheckboxWidth   + ...
    commonGeom.checkboxEditDelta            + ...
    dataGeom.editWidth;

heights(2) = ...
    commonGeom.sheetTopEdgeBuffer                        + ...
    max(commonGeom.checkboxHeight,commonGeom.editHeight) + ...
    dataGeom.vSpacer                                     + ...
    commonGeom.checkboxHeight                            + ...
    commonGeom.rowSpace                                  + ...
    commonGeom.editHeight                                + ...
    commonGeom.popupHeight                               + ...
    commonGeom.sheetBottomEdgeBuffer;

%
% System buttons.
%

heights(3) = 0;
widths(3)  = (commonGeom.sysButtonWidth * 4) + (commonGeom.sysButtonDelta * 3);

sheetDims = [max(widths), max(heights)];


% Function =====================================================================
% Return the state of the 'Number of axes' label and edit box.  Note that the
% floating status must be known (set on the object) before calling this function.

function state = i_NumberOfAxesState(dialogUserData, simStatus),

children = dialogUserData.generalPage.children;

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
        state = 'on';
    end


% Function =====================================================================
% Return the state of the floating checkbox.

function state = i_FloatingState(dialogUserData, simStatus),

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    state = 'on';
end


% Function =====================================================================
% Return the state of the Sampling controls.

function state = i_SamplingState(dialogUserData, simStatus),

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    state = 'on';
end


% Function =====================================================================
% Sync axes page with model.

function i_SyncGeneralPage(dialogFig, dialogUserData),

changed       = 0;
children      = dialogUserData.generalPage.children;
block         = dialogUserData.block;
block_diagram = dialogUserData.block_diagram;
simStatus     = get_param(block_diagram, 'SimulationStatus');


%
% Floating (done before number of axes due to dependency).
%
h              = children.floatCheckbox;
if h ~= -1
    val            = onoff(get_param(block, 'Floating'));
    enabStr        = i_FloatingState(dialogUserData, simStatus);
    User.enableFcn = 'i_FloatingState';
    if val ~= get(h, 'Value'),
        changed = 1;
    end
    set(h, ...
        'Value',          val,  ...
        'Enable',         enabStr, ...
        'UserData',       User);
end

%
% Number of axes.
%
h              = children.numAxesEdit;
string         = get_param(block, 'NumInputPorts');
enabStr        = i_NumberOfAxesState(dialogUserData, simStatus);
User.enableFcn = 'i_NumberOfAxesState';
if ~strcmp(string, get(h, 'String')),
    changed = 1;
end
set(h, ...
    'String',         string, ...
    'Enable',         enabStr, ...
    'UserData',       User);

%
% Time range
%
h              = children.timeRangeEdit;
string         = get_param(block, 'TimeRange');
User.enableFcn = '';
if ~strcmp(string, get(h, 'String')),
    changed = 1;
end
set(h, ...
    'String',         string, ...
    'UserData',       User);

%
% Tick labels.
%
switch get_param(block, 'TickLabels'),
case 'on',
    val = 1;
case 'off',
    val = 2;
case 'OneTimeTick',
    val = 3;
end

h              = children.tickLabelPopup;
User.enableFcn = '';
if val ~= get(h, 'Value'),
    changed = 1;
end
set(h, ...
    'Value',          val, ...
    'UserData',       User);

%
% Sample time/decimation popup and edit.
%
val = 1;
if strcmp(get_param(block, 'SampleInput'), 'on'),
    val = 2;
end

strs    = {get_param(block, 'Decimation'), get_param(block, 'SampleTime')};
enabStr = i_SamplingState(dialogUserData, simStatus);

User.enableFcn = 'i_SamplingState';
User.strings   = strs;

h = children.sampleTimePopup;
if val ~= get(h, 'Value'),
    changed = 1;
end
set(h, ...
    'Value',          val, ...
    'Enable',         enabStr, ...
    'UserData',       User);

User = [];
User.enableFcn = 'i_SamplingState';

string = strs{val};
h      = children.sampleTimeEdit;
if ~strcmp(string, get(h, 'String')),
    changed = 1;
end

set(h, ...
    'String',         string, ...
    'Enable',         enabStr, ...
    'UserData',       User);


% Function =====================================================================
% Return the state of the 'Limit data points to last' checkbox.

function state = i_LimitDataCheckboxState(dialogUserData, simStatus),

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    state = 'on';
end


% Function =====================================================================
% Return the state of the 'Limit data points to last' edit box.

function state = i_LimitDataEditState(dialogUserData, simStatus),

children = dialogUserData.dataPage.children;

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    hLimitData = children.limitDataCheck;
    if get(hLimitData, 'Value') == 1,
        state = 'on';
    else,
        state = 'off';
    end
end


% Function =====================================================================
% Return the state of the 'Save data to workspace' checkbox.

function state = i_SaveDataToWSState(dialogUserData, simStatus),

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    floatCheckbox = dialogUserData.generalPage.children.floatCheckbox;
    if floatCheckbox ~= -1
       if get(floatCheckbox,'Value')
           state = 'off';
       else
           state = 'on';
       end
    else
        state = 'on';
    end
end


% Function =====================================================================
% Return the state of the 'Variable Name' label and edit.

function state = i_VariableNameState(dialogUserData, simStatus),

children = dialogUserData.dataPage.children;

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    hSave = children.saveToWorkspaceCheckbox;
    if get(hSave, 'Value') == 1,
        state = 'on';
    else,
        state = 'off';
    end
end


% Function =====================================================================
% Return the state of the 'Format' label and checkbox.

function state = i_FormatState(dialogUserData, simStatus),

state = i_VariableNameState(dialogUserData, simStatus);


% Function =====================================================================
% Return the state of the 'Use signal label for field names' checkbox.

function state = i_SigLabelForFieldState(dialogUserData, simStatus),

children = dialogUserData.dataPage.children;

if ~strcmp(simStatus, 'stopped'),
    state = 'off';
else,
    hSave = children.saveToWorkspaceCheckbox;
    if get(hSave,'Value') == 1,
        hFormat = children.formatPopup;
        if (get(hFormat, 'Value') ~= 2),
            state = 'on';
        else,
            state = 'off';
        end
    else,
        state = 'off';
    end
end


% Function =====================================================================
% Sync 'Data history' page with model.

function i_SyncDataPage(dialogFig, dialogUserData),

children      = dialogUserData.dataPage.children;
block         = dialogUserData.block;
block_diagram = dialogUserData.block_diagram;
simStatus     = get_param(block_diagram, 'SimulationStatus');

%
% Limit data points to last.
%
enabStr        = i_LimitDataCheckboxState(dialogUserData, simStatus);
val            = onoff(get_param(block, 'LimitDataPoints'));
User.enableFcn = 'i_LimitDataCheckboxState';

set(children.limitDataCheck, ...
    'Value',          val,  ...
    'UserData',       User, ...
    'Enable',         enabStr);

string         = get_param(block, 'MaxDataPoints');
enabStr        = i_LimitDataEditState(dialogUserData, simStatus);
User.enableFcn = 'i_LimitDataEditState';
set(children.limitDataEdit, ...
    'Enable',         enabStr, ...
    'String',         string, ...
    'UserData',       User);

% ...append the edit handle to the checkbox's userdata
ud      = get(children.limitDataCheck, 'UserData');
ud.edit = children.limitDataEdit;
set(children.limitDataCheck, 'UserData', ud);

%
% Save data to workspace checkbox.
%
val            = onoff(get_param(block, 'SaveToWorkspace'));
enabStr        = i_SaveDataToWSState(dialogUserData, simStatus);
User.enableFcn = 'i_SaveDataToWSState';

set(children.saveToWorkspaceCheckbox, ...
    'Value',          val,  ...
    'Enable',         enabStr, ...
    'UserData',       User);

%
% Variable name label and edit.
%
User           = [];
enabStr        = i_VariableNameState(dialogUserData, simStatus);
User.enableFcn = 'i_VariableNameState';
set(children.variableNameLabel, ...
    'Enable',         enabStr, ...
    'UserData',       User);

string         = get_param(block, 'SaveName');
User.enableFcn = 'i_VariableNameState';
set(children.variableNameEdit, ...
    'Enable',         enabStr, ...
    'String',         string, ...
    'UserData',       User);

%
% ... Data format label and popup.
%
User           = [];
enabStr        = i_FormatState(dialogUserData, simStatus);
User.enableFcn = 'i_FormatState';
set(children.formatLabel, ...
    'Enable',         enabStr, ...
    'UserData',       User);

switch get_param(block, 'DataFormat'),
case 'StructureWithTime',
    val = 1;
case 'Structure',
    val = 2;
case 'Array',
    val = 3;
end

set(children.formatPopup, ...
    'Value',          val, ...
    'Enable',         enabStr, ...
    'UserData',       User);


% Function =====================================================================
% Create "system" buttons.                                       

function dialogUserData = i_CreateSysButtons(dialogFig, dialogUserData),

figPos      = get(dialogFig, 'Position');
commonGeom  = dialogUserData.commonGeom;
sheetPos    = commonGeom.sheetPos;
width       = commonGeom.sysButtonWidth;
height      = commonGeom.sysButtonHeight;
buttonDelta = commonGeom.sysButtonDelta;

totalButtonWidth = (width * 4) + (buttonDelta * 3);
sheetEdge = sheetPos(1) + sheetPos(3);

cxCur = sheetEdge - totalButtonWidth;
cyCur = commonGeom.figBottomEdgeBuffer;


%
% Place apply button.
%
children.OK = uicontrol( ...
  'Parent',             dialogFig, ...
  'String',             'OK', ...
  'Horizontalalign',    'center', ...
  'Position',           [cxCur cyCur width height] ...
);

%
% Place Cancel button.
%
cxCur = cxCur + width + buttonDelta;
children.Cancel = uicontrol( ...
  'Parent',             dialogFig, ...
  'String',             'Cancel', ...
  'Horizontalalign',    'center', ...
  'Enable',             'on', ...
  'Position',           [cxCur cyCur width height] ...
);

%
% Place help button.
%
cxCur = cxCur + width + buttonDelta;
children.Help = uicontrol( ...
  'Parent',             dialogFig, ...
  'String',             'Help', ...
  'Horizontalalign',    'center', ...
  'Position',           [cxCur cyCur width height] ...
);

%
% Place apply button.
%
cxCur = cxCur + width + buttonDelta;
children.Apply = uicontrol( ...
  'Parent',             dialogFig, ...
  'String',             'Apply', ...
  'Horizontalalign',    'center', ...
  'Position',           [cxCur cyCur width height] ...
);

%
% Update user data.
%
dialogUserData.SystemButtons = children;


% Function =====================================================================
% Install callbacks for specified page.                          

function i_InstallCallbacks(page, dialogFig, dialogUserData),

switch(page),
    
case 'General',
    i_InstallGeneralCallbacks(dialogFig, dialogUserData);
    
case 'Data',
    i_InstallDataCallbacks(dialogFig, dialogUserData);
    
case 'System',
    i_InstallSystemButtonCallbacks(dialogFig, dialogUserData);
    
otherwise,
    error('M Assert: Invalid page');
    
end


% Function =====================================================================
% Install callbacks for 'General' page.

function i_InstallGeneralCallbacks(dialogFig, dialogUserData),

children = dialogUserData.generalPage.children;
block    = dialogUserData.block;

%
% Floating checkbox.
%
if children.floatCheckbox ~= -1
    set(children.floatCheckbox, ...
        'Callback', 'scpprop(''GeneralPage'', ''FloatCheckbox'', gcbf)');
end


%
% Sampling controls.
%
set(children.sampleTimeEdit, ...
    'Callback', 'scpprop(''GeneralPage'', ''SampleTimeEdit'', gcbf)');

if ~onoff(get_param(block,'ModelBased'))
    set(children.sampleTimePopup, ...
        'Callback', 'scpprop(''GeneralPage'', ''SampleTimePopup'', gcbf)');
end

% Function =====================================================================
% Install callbacks for 'Data history' page.

function i_InstallDataCallbacks(dialogFig, dialogUserData),

children = dialogUserData.dataPage.children;

%
% Set callbacks for other controls.
%

set(children.limitDataCheck, ...
    'Callback', 'scpprop(''DataPage'', ''DefCheckEdit'', gcbf)');

set(children.saveToWorkspaceCheckbox, ...
    'Callback', 'scpprop(''DataPage'', ''SaveDataCheckbox'', gcbf)');


% Function =====================================================================
% Install callbacks for system buttons.                          

function i_InstallSystemButtonCallbacks(dialogFig, dialogUserData),

set(dialogUserData.SystemButtons.OK, ...
    'Callback',           'scpprop(''SystemButtons'', ''OK'', gcbf)');

set(dialogUserData.SystemButtons.Cancel, ...
    'Callback',           'scpprop(''SystemButtons'', ''Cancel'', gcbf)');

set(dialogUserData.SystemButtons.Help, ...
    'Callback',           'scpprop(''SystemButtons'', ''Help'', gcbf)');

set(dialogUserData.SystemButtons.Apply, ...
    'Callback',           'scpprop(''SystemButtons'', ''Apply'', gcbf)');


% Function =====================================================================
% Handle call back on the 'floating scope' checkbox.

function i_FloatCheckboxFcn(dialogFig),

dialogUserData = get(dialogFig, 'UserData');
children       = dialogUserData.generalPage.children;
ud             = get(children.numAxesEdit, 'UserData');
enableFcn      = ud.enableFcn;
simStatus      = get_param(dialogUserData.block_diagram, 'SimulationStatus');

handles = [children.numAxesLabel children.numAxesEdit];
set(handles, 'Enable', feval(enableFcn, dialogUserData, simStatus));

% Enable/disable "save to workspace" based on "Floating" button
dataChildren = dialogUserData.dataPage.children;
if (~isempty(dataChildren)) & (children.floatCheckbox ~= -1)
  saveHandle  = dataChildren.saveToWorkspaceCheckbox;
  savingData  = get (saveHandle,'Value');
  floating    = get(children.floatCheckbox,'Value');
  
  if floating
    if savingData
      set(saveHandle, 'Value', 0);
      i_SaveDataCheckboxFcn(dialogFig);  % Update related controls
    end
    set(saveHandle, 'Enable', 'off');
  else
    set(saveHandle, 'Enable', 'on');
  end
end

% Function =====================================================================
% Manage callbacks for general page.

function [dialogUserData, bModified] = i_ManageGeneralPage( ...
    dialogFig, dialogUserData, Action),

bModified = 0;

switch(Action),
    
case 'FloatCheckbox',
    i_FloatCheckboxFcn(dialogFig);
    
case 'SampleTimeEdit',
    i_SampleTimeEditFcn(dialogFig);
    
case 'SampleTimePopup',
    i_SampleTimePopupFcn(dialogFig);
    
otherwise,
    error('M Assert: invalid action');
end


% Function =====================================================================
% Handle callback for the 'Save data to workspace' checkbox.

function i_SaveDataCheckboxFcn(dialogFig),

dialogUserData = get(dialogFig, 'UserData');
children       = dialogUserData.dataPage.children;
simStatus      = get_param(dialogUserData.block_diagram, 'SimulationStatus');

%
% Set enabledness of 'Variable name' label and edit.
%
h  = children.variableNameEdit;
ud = get(h,'UserData');

handles = [h children.variableNameLabel];
set(handles, 'Enable', feval(ud.enableFcn, dialogUserData, simStatus));

%
% Set enabledness of format label and popup.
%
h  = children.formatPopup;
ud = get(h, 'UserData');

handles = [h children.formatLabel];
set(handles, 'Enable', feval(ud.enableFcn, dialogUserData, simStatus));


% Function =====================================================================
% Manage callbacks for 'Data history' page.

function [dialogUserData, bModified] = i_ManageDataPage( ...
    dialogFig, dialogUserData, Action),

bModified = 0;

switch(Action),
    
case 'DefCheckEdit',
    checkbox         = gcbo;
    checkBoxUserData = get(checkbox, 'UserData');
    
    i_CheckEditPair_DefCheckCallbk(checkbox, checkBoxUserData.edit);
    
case 'SaveDataCheckbox',
    i_SaveDataCheckboxFcn(dialogFig);
    
otherwise,
    error('M Assert: invalid action');
end


% Function =====================================================================
% Manage callbacks for system buttons.                           

function [dialogUserData, bModified] = i_ManageSystemButtons( ...
    dialogFig, dialogUserData, Action ...
),

bModified = 0;

switch(Action),
    
case { 'OK', 'CloseReq' },
    success = i_ApplyParams(dialogFig, dialogUserData);
    if success,
        set(dialogFig, 'Visible', 'off');
    end
    
case 'Cancel',
    set(dialogFig, 'Visible', 'off');
    
case 'Help',
    slhelp(dialogUserData.block);
    
case 'Apply',
    success = i_ApplyParams(dialogFig, dialogUserData);
    
case 'DeleteFcn',
    scopePropDlg = dialogUserData.parent;
    if ishandle(scopePropDlg),
        scopeUserData = get(scopePropDlg, 'UserData');
        
        scopeUserData.scopePropDlg = -1;
        set(scopePropDlg, 'UserData', scopeUserData);
    end
    
otherwise,
    error('M Assert: Invalid action');
    
end


% Function =====================================================================
% Apply params to block.

function success = i_ApplyParams(dialogFig, dialogUserData),

block               = dialogUserData.block;
generalPropValPairs = {};
dataPropValPairs    = {};
propValPairs        = {};
success             = 1;

%
% General page property value pairs.
%

if ~isempty(dialogUserData.generalPage.children),
    [error, generalPropValPairs] = i_GeneralPropValPairs(dialogUserData);
    if error,
        success = 0;
        return;
    end
end

if ~isempty(dialogUserData.dataPage.children),
    [error, dataPropValPairs] = i_DataPropValPairs(dialogUserData);
    if error,
        success = 0;
        return;
    end
end

propValPairs = [propValPairs generalPropValPairs dataPropValPairs];

%
% Set all propval pairs.
%
cmd      = 'set_param(block, propValPairs{:})';
catchStr = 'errordlg(lasterr, ''Error'',''modal'')'; 
eval(cmd, catchStr);

%
% Call simscope.m to let it know that an apply occurred.
%
simscope('PropDialogApply', dialogUserData.parent);


% Function =====================================================================
% Build prop/val pairs for general page.

function [error, propValPairs] = i_GeneralPropValPairs(dialogUserData),

children      = dialogUserData.generalPage.children;
block         = dialogUserData.block;
block_diagram = dialogUserData.block_diagram;
simStatus     = get_param(block_diagram, 'SimulationStatus');
compiled      = ~strcmp(simStatus, 'stopped');

scopePropDlg  = dialogUserData.parent;
scopeUserData = get(scopePropDlg, 'UserData');

error        = 0;
propValPairs = {};

%
% Number of axes.
%
if ~compiled,
    h = children.numAxesEdit;
    userstr   = deblank(get(h, 'String'));

    prop   = 'NumInputPorts';
    
    propValPairs([end+1 end+2]) = {prop, userstr};
end

%
% Floating checkbox.
%
if ~compiled,
    h = children.floatCheckbox;
    if h ~= -1
        string = onoff(get(h, 'Value'));
        prop   = 'floating';
        
        propValPairs([end+1 end+2]) = {prop, string};
    end
end

%
% Time range.
%
h = children.timeRangeEdit;
userstr = deblank(get(h, 'String'));
errmsg  = 'Invalid setting for ''Time range''';

if ~strcmp(lower(userstr), 'auto'),
    
    % do this first, check if userstr is valid variable name
    evalin('base', [userstr,';'], 'error = 1;');
    if (error | isempty(userstr)),  
        beep;
        errordlg(errmsg, 'Error', 'modal');
        error = 1;
        return;
    else
      % userstr is valid variable name, get its value
      % ~(evalValue < inf) will filter out inf and nan
      evalValue = evalin('base', userstr);
      if (isempty(userstr) | (evalValue < 0) | ...
            ~isnumeric(evalValue) | (length(evalValue) ~= 1) | ...
            (evalValue <= 0) | isnan(evalValue) | isinf(evalValue)),
        beep;
        errordlg(errmsg, 'Error', 'modal');
        error = 1;
        return;
      end;
    end
    
    tRange = evalValue;    
    propValPairs([end+1 end+2]) = ...
        {'TimeRange', sprintf('%0.16g', evalValue)};
else,
    block_diagram = scopeUserData.block_diagram;
    simStatus = get_param(block_diagram, 'SimulationStatus');
    
    tRange = simscope('SimTimeSpan', block, block_diagram, simStatus);
    propValPairs([end+1 end+2]) = {'TimeRange', 'auto'};
end


%
% Tick labels popup.
%
h    = children.tickLabelPopup;
prop = 'TickLabels';

switch(get(h, 'Value')),
case 1,
    string = 'on';
case 2,
    string = 'off';
case 3,
    string = 'OneTimeTick';
end
propValPairs([end+1 end+2]) = {prop, string};

%
% Sampling controls.
%
if ~compiled,
    hPop     = children.sampleTimePopup;
    hEdit    = children.sampleTimeEdit;
    if ~onoff(get_param(block,'ModelBased'))
        value = get(hPop,  'Value');
    else
        % Edit box is always for decimation in Model-based scope.
        value = 1;
    end
    propStrs = get(hPop,  'String');
    string   = get(hEdit, 'String');
    
    bStr = {'off', 'on'};
    
    propValPairs(end+1:end+2) = {'SampleInput', bStr{value}};
    % Replace spaces by none since the parameter name 'Sample time'
    % has now been replaced by 'SampleTime'
    if ~onoff(get_param(block, 'ModelBased'))
        propValPairs(end+1:end+2) = {strrep(propStrs{value}, ' ', ''), string};
    else
        propValPairs(end+1:end+2) = {propStrs, string};
    end
    
end


% Function =====================================================================
% Build prop/val pairs for 'Data history' page.

function [error, propValPairs] = i_DataPropValPairs(dialogUserData),

block_diagram = dialogUserData.block_diagram;
simStatus     = get_param(block_diagram, 'SimulationStatus');
compiled      = ~strcmp(simStatus, 'stopped');
children     = dialogUserData.dataPage.children;
error        = 0;
propValPairs = {};

%
% Set properties associated w/ limiting data rows.
%
if ~compiled,
    h = children.limitDataCheck;
    bLimitDataPoints = onoff(get(h, 'Value'));
    propValPairs(end+1:end+2) = {'limitDataPoints', bLimitDataPoints};
end

if ~compiled,
    h = children.limitDataEdit;
    MaxDataPoints = get(h, 'String');
    propValPairs(end+1:end+2) = {'MaxDataPoints', MaxDataPoints};

    if strcmp(MaxDataPoints,'inf')
      error = 1;
      beep;
      errordlg(['Invalid setting for ''MaxDataPoints''']);
      return;
    end

end

%
% Set SaveToWorkspace property.
%
if ~compiled,
    h = children.saveToWorkspaceCheckbox;
    bSaveToWorkspace = onoff(get(h, 'Value'));
    propValPairs(end+1:end+2) = {'SaveToWorkspace', bSaveToWorkspace};
end

%
% Set variable name.
%
if ~compiled,
    h = children.variableNameEdit;
    saveName = get(h, 'String');
    if ~isvarname(saveName)
        error = 1;
        beep;
        errordlg(['Invalid setting for ''Variable Name''.  ''' saveName ...
                  ''' is not a valid MATLAB variable name.'], 'Error','modal');
        return;
    end
    propValPairs(end+1:end+2) = {'SaveName', saveName};
end

%
% Data format popup.
%
if ~compiled,
    h = children.formatPopup;
    prop = 'DataFormat';

    switch(get(h, 'Value')),
    case 1,
        string = 'StructureWithTime';
    case 2,
        string = 'Structure';
    case 3,
        string = 'Array';
    end
    propValPairs([end+1 end+2]) = {prop, string};
end


% Function =====================================================================
% Handle callback for sampleTime/decimation popup.               

function i_SampleTimePopupFcn(dialogFig),

dialogUserData = get(dialogFig, 'UserData');
children       = dialogUserData.generalPage.children;
value          = get(children.sampleTimePopup, 'Value');

popupUserData = get(children.sampleTimePopup, 'UserData');
strings       = popupUserData.strings;

str = strings{value};
set(children.sampleTimeEdit, 'String', str);


% Function =====================================================================
% Handle callback for sampleTime/decimation edit box.               
%
% Update the stored strings for decimation and sample settings.

function i_SampleTimeEditFcn(dialogFig),

dialogUserData = get(dialogFig, 'UserData');
children       = dialogUserData.generalPage.children;
if ~onoff(get_param(dialogUserData.block, 'ModelBased'))
  value = get(children.sampleTimePopup, 'Value');
else
  value = 1;
end

popupUserData = get(children.sampleTimePopup, 'UserData');
popupUserData.strings{value} = get(children.sampleTimeEdit, 'String');
set(children.sampleTimePopup, 'UserData', popupUserData);


% Function =====================================================================
% Handle default callback behavior for checkbox in a checkbox/edit pair.

function i_CheckEditPair_DefCheckCallbk(checkbox, edit, text),

if nargin > 2,
    handles = [edit, text];
else,
    handles = edit;
end

bState = get(checkbox, 'Value');
set(handles, 'Enable', onoff(bState));


% Function =====================================================================
% Initialize checkbox/edit pair.                                 

function i_InitCheckEditPair(checkbox, edit, onoffState, string),

bState = onoff(onoffState);

User.edit   = edit;
set(checkbox, ...
    'Value',          bState, ...
    'UserData',       User);

set(edit, ...
    'Enable',         onoffState, ...
    'String',         string, ...
    'UserData',       User);


% Function =====================================================================
% handle changing of pages.

function [dialogUserData, bModified] = i_ChangePage( ...
    pressedTabString, ...
    pressedTabNum, ...
    oldTabString, ...
    oldTabNum, ...
    dialogFig, ...
    dialogUserData),

bModified = 0;


%
% Determine which controls to make visible base on page number.
%
switch(pressedTabNum),

case 1,
    if isempty(dialogUserData.generalPage.children),
      page = 'General';

      dialogUserData = i_CreatePage(page, dialogFig, dialogUserData);
      i_InstallCallbacks(page, dialogFig, dialogUserData);
      bModified = 1;
    end

    childrenCell   = struct2cell(dialogUserData.generalPage.children);
    childrenVector = [childrenCell{:}];

case 2,
    if isempty(dialogUserData.dataPage.children),
      page = 'Data';

      dialogUserData = i_CreatePage(page, dialogFig, dialogUserData);
      i_InstallCallbacks(page, dialogFig, dialogUserData);
      bModified = 1;
    end

    childrenCell   = struct2cell(dialogUserData.dataPage.children);
    childrenVector = [childrenCell{:}];

otherwise,
    error('M Assert: invalid tab');
end


%
% Determine which controls to make invisible base on page number.
%
switch(oldTabNum),

case 1,
    oldchildrenCell   = struct2cell(dialogUserData.generalPage.children);
    oldchildrenVector = [oldchildrenCell{:}];

case 2,
    oldchildrenCell   = struct2cell(dialogUserData.dataPage.children);
    oldchildrenVector = [oldchildrenCell{:}];

otherwise,
    error('M Assert: invalid tab');
end

%
% Get rid of undefined elements (handle == -1)
%
oldchildrenVector(oldchildrenVector == -1) = [];
childrenVector(childrenVector == -1) = [];

%
% Toggle page visiblity (default behavior).
%
set(oldchildrenVector, 'Visible', 'off');
set(childrenVector, 'Visible', 'on');


% Function =====================================================================
% Show an already existing dialog box and if it is invisible, re-sync the
% existing pages.                                             ***

function i_ReShowDialog(dialogFig, dialogUserData),

bVisible = onoff(get(dialogFig, 'Visible'));

if ~bVisible & ~isempty(dialogUserData.generalPage.children),
    i_SyncGeneralPage(dialogFig, dialogUserData);
end

if ~bVisible & ~isempty(dialogUserData.dataPage.children), 
    i_SyncDataPage(dialogFig, dialogUserData);
end

figure(dialogFig);


% Function =====================================================================
% Update the enabled states of all controls.
function i_UpdateAllEnableStates(dialogUserData, simStatus),

generalChildren     = dialogUserData.generalPage.children;
dataChildren        = dialogUserData.dataPage.children;
generalCellchildren = {};
dataCellChildren    = {};

if ~isempty(generalChildren),
    generalCellchildren = struct2cell(generalChildren);
end
if ~isempty(dataChildren),
    dataCellChildren = struct2cell(dataChildren);
end
allChildren = [generalCellchildren{:} dataCellChildren{:}];

%
% Get rid of undefined elements (handle == -1)
%
allChildren(allChildren == -1) = [];

for i=1:length(allChildren),
    h  = allChildren(i);
    ud = get(h, 'UserData');
    if isfield(ud, 'enableFcn') & ~isempty(ud.enableFcn),
        set(h, 'Enable', feval(ud.enableFcn, dialogUserData, simStatus));
    end
end


% Function =====================================================================
% Handle simulation initialization tasks.

function [dialogUserData, bModified] = i_SimulationInitialize( ...
    dialogFig, dialogUserData),

bModified = 0;
simStatus = 'running'; %not exactly true!
i_UpdateAllEnableStates(dialogUserData, simStatus);


% Function =====================================================================
% Handle simulation termination tasks.

function [dialogUserData, bModified] = i_SimulationTerminate( ...
    dialogFig, dialogUserData),

bModified = 0;
simStatus = 'stopped'; % not exactly true!
i_UpdateAllEnableStates(dialogUserData, simStatus);


% Function =====================================================================
% Get the name for the dialog box.

function figName = i_DialogName(scopePropDlg),

namescopePropDlg  = get(scopePropDlg, 'Name');
figName = ['''' namescopePropDlg ''' parameters'];


% [EOF] scpprop.m

