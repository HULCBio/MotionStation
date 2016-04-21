function varargout = watchsigsdlg(varargin)
%WATCHSIGSDLG Simulink Watch Signals Dialog Box
%   WATCHSIGSDLG is a dialog box that allows the user to manage 
%   the creation, destruction, and manipulation of Signal Viewers.
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/15 00:49:56 $

Action = varargin{1};
args   = varargin(2:end);

switch(Action)

 case 'create',
  [dialogFig, dialogUserData] = i_Create(args{1});

  set(dialogFig, 'UserData', dialogUserData);
  varargout = {dialogFig};

 case 'GeneralPage'
  dialogFig = args{2};
  dialogUserData = get(dialogFig, 'UserData');
  dialogUserData = i_ManageGeneralPage(dialogFig, dialogUserData, args{1});

  set(dialogFig, 'UserData', dialogUserData);
  
 case 'PerfPage',
  dialogFig = args{2};
  dialogUserData = get(dialogFig, 'UserData');
  dialogUserData = i_ManagePerformancePage(dialogFig, dialogUserData, args{1});
  
 case 'SystemButtons',
  dialogFig = args{2};
  dialogUserData = get(dialogFig, 'UserData');
  dialogUserData = i_ManageSystemButtons(dialogFig, dialogUserData, args{1});

  set(dialogFig, 'UserData', dialogUserData);
  
 case 'tabcallbk',
  dialogFig = gcbf;
  dialogUserData = get(dialogFig, 'UserData');
  
  dialogUserData = i_ChangePage(args{:}, dialogUserData);
  set(dialogFig, 'UserData', dialogUserData);
  
 case 'show',
  dialogFig = args{1};
  dialogUserData = get(dialogFig, 'UserData');
  
  dialogUserData = i_ReShowDialog(dialogFig, dialogUserData);
  
  set(dialogFig, 'UserData', dialogUserData);

 case {'SimStart','SimStop'},
  dialogFig = args{1};

  if ~ishandle(dialogFig) | ~onoff(get(dialogFig,'Visible')),
    return
  end

  dialogUserData = get(dialogFig, 'UserData');
  dialogUserData = i_UpdateEnables(dialogFig, dialogUserData);
  
  set(dialogFig, 'UserData', dialogUserData);
  
 case 'ChangeName',
  dialogFig      = args{1};
  dialogUserData = get(dialogFig, 'UserData');
  bdName         = get_param(dialogUserData.model,'Name');
  
  set(dialogFig, 'Name', i_DlgName(bdName));
  
 case 'ModelBasedPrefix',
  varargout = {PREFIX_STR};
  
 case 'GetSigViewerDisplayName',
  block = args{1};
  varargout = {i_BlockNameToDisplayName(block)};
  
 case 'GetSigViewerDisplayPath',
  block = args{1};
  varargout = {i_BlockPathToDisplayPath(block)};
  
 otherwise,
  error('Invalid action');
  
end

% end function watchsigsdlg

% Function ======================================================================
%

function [dialogFig, dialogUserData] = i_Create(hModel)

%
% Create constants based on current computer.
%
dialogUserData.thisComputer = computer;

dialogUserData.fontsize = get(0, 'FactoryUicontrolFontSize');
dialogUserData.fontname = get(0, 'FactoryUicontrolFontName');

switch(dialogUserData.thisComputer),
  
 case 'PCWIN',
  dialogUserData.popupBackGroundColor   = 'w';
  dialogUserData.listboxBackGroundcolor = 'w';
  
 case 'MAC2',
  dialogUserData.popupBackGroundColor = 'w';
  dialogUserData.listboxBackGroundcolor = 'w';
  
 otherwise,  % X
  dialogUserData.popupBackGroundColor = ...
      get(0, 'FactoryUicontrolBackgroundColor');
  dialogUserData.listboxBackGroundcolor = 'w';
end

%
% Create an empty figure (we need it now for text extents)..
%
closeReqFcn = 'watchsigsdlg(''SystemButtons'', ''Close'', gcbf)';


dialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           dialogUserData.fontname, ...
    'DefaultUicontrolFontsize',           dialogUserData.fontsize, ...
    'DefaultUicontrolUnits',              'pixels', ...
    'HandleVisibility',                   'off', ...
    'Colormap',                           [], ...
    'Name',                               i_DlgName(hModel), ...
    'IntegerHandle',                      'off', ...
    'CloseRequestFcn',                    closeReqFcn);

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
commonGeom = i_CommonGeom(textExtent);

%
% Create tabbed dialog.
%
tabStrings = {'General', 'Performance'};
sheetDims  = [300 250];

callback  = 'watchsigsdlg';
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
dialogUserData.model                    = hModel;
dialogUserData.commonGeom               = commonGeom;
dialogUserData.errorTitle               = 'Signal viewer error';
dialogUserData.generalPage.children     = [];
dialogUserData.performancePage.children = [];

%
% *** If you change this table, change same in scppropsv.m ***
%
dialogUserData.performancePage.secSliderRefreshVals = [0 0.035 0.07 0.2  1.5];
dialogUserData.performancePage.secSliderSliderVals  = [0 2.500 5.00 7.5 10.0];

dialogUserData.performancePage.frameSliderRefreshVals = [1 10];
dialogUserData.performancePage.frameSliderSliderVals  = [0 10];


%
% Create default page and system buttons.
%
dialogUserData = i_CreatePage(defaultPageName, dialogFig, dialogUserData);
dialogUserData = i_CreateSysButtons(dialogFig, dialogUserData);
i_InstallSystemButtonCallbacks(dialogFig, dialogUserData);

set(dialogFig, ...
    'Visible',        'on', ...
    'UserData',       dialogUserData);

% end i_Create()


% Function ======================================================================
%

function commonGeom = i_CommonGeom(textExtent)

sysOffsets = sluigeom;

%
% Define generic font characterists.
%
calibrationStr = '_Revert_';
nameLabel = 'Name:';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

sysButtonWidth = ext(3);
charHeight     = ext(4);

commonGeom.textHeight            = charHeight;
commonGeom.editHeight            = charHeight + sysOffsets.edit(4);
commonGeom.checkboxHeight        = charHeight + sysOffsets.checkbox(4);
commonGeom.popupHeight           = charHeight + sysOffsets.popupmenu(4);
commonGeom.buttonHeight          = charHeight + sysOffsets.pushbutton(4);
commonGeom.hSliderHeight         = commonGeom.editHeight;
commonGeom.sysButtonHeight       = (charHeight*1.3) + sysOffsets.pushbutton(4);
commonGeom.sysButtonWidth        = sysButtonWidth + sysOffsets.pushbutton(3);
commonGeom.sysButtonDelta        = 8;
commonGeom.sheetSideEdgeBuffer   = 8;
commonGeom.sheetTopEdgeBuffer    = (commonGeom.textHeight/1.3);
commonGeom.sheetBottomEdgeBuffer = 8;
commonGeom.figBottomEdgeBuffer   = 5;
commonGeom.figTopEdgeBuffer      = 5;
commonGeom.figSideEdgeBuffer     = 5;
commonGeom.sysButton_SheetDelta  = 5;
commonGeom.toolButtonHeight      = 24;
commonGeom.toolButtonWidth       = 24;
commonGeom.toolButtonDelta       = 5;

commonGeom.bottomSheetOffset = ...
  commonGeom.figBottomEdgeBuffer    + ...
  commonGeom.sysButtonHeight        + ...
  commonGeom.sysButton_SheetDelta; 

commonGeom.standardDeltaSmall = 5;
commonGeom.standardDeltaLarge = 8;

commonGeom.sysOffsets = sysOffsets;
commonGeom.textExtent = textExtent;

% end i_CommonGeom()


% Function ======================================================================
% Create specified tab page.                                     

function i_SyncGeneralPage(dialogFig, dialogUserData, selectedViewer),
  children = dialogUserData.generalPage.children;
  viewers  = i_GetViewers(dialogUserData);
  val      = []; %assume
  str      = ''; %assume

  if ~isempty(selectedViewer),
    idx = strmatch(selectedViewer, viewers, 'exact');
    if ~isempty(idx),
      if length(idx) ~= 1,
        error('M Assert: non-unique names in viewer list');
      end
      val = idx;
      str = viewers{idx};
    end
  end
  
  set(children.viewerList, ...
      'String',          viewers, ...
      'Value',           val);
  
  set(children.nameEdit, 'String', str);
  
%end i_SyncGeneralPage


% Function ======================================================================
% 
function string = i_SliderText(frameMode,val),
  if ~frameMode,
    string = [num2str(val) ' seconds'];
  else,
    string = [num2str(-val) ' frames'];
  end
%endfunction


% Function ======================================================================
% 
function i_SyncSlider(dialogUserData),
  bd       = dialogUserData.model;
  children = dialogUserData.performancePage.children;
  
  val = get_param(bd,'ScopeRefreshTime');
  frameMode = 0;
  if val >= 0,
    x = dialogUserData.performancePage.secSliderRefreshVals;
    y = dialogUserData.performancePage.secSliderSliderVals;
  else,
    x = dialogUserData.performancePage.frameSliderRefreshVals;
    y = dialogUserData.performancePage.frameSliderSliderVals;
    
    frameMode = 1;    
  end

  sliderVal = interp1(x,y,val);
  sliderMin = get(children.slider,'Min');
  sliderMax = get(children.slider,'Max');
  
  if (sliderVal < sliderMin),
    sliderVal = sliderMin;
  end
  if (sliderVal > sliderMax),
    sliderVal = sliderMax;
  end
  
  set(children.slider, ...
      'Value',          sliderVal);  
  
  %
  % Slider text
  %
  string = i_SliderText(frameMode,val);
  set(children.sliderText,'String',string);
%endfunction
  

% Function ======================================================================
% Create specified tab page.                                     

function i_SyncPerformancePage(dialogFig, dialogUserData),
  bd       = dialogUserData.model;
  children = dialogUserData.performancePage.children;
  
  %
  % Override checkbox
  %
  val = onoff(get_param(bd,'OverrideScopeRefreshTime'));
  set(children.overrideCheckbox,'Value',val);
  
  %
  % Slider and slider text.
  %
  i_SyncSlider(dialogUserData);
  
  %
  % Freeze button
  %
  val = onoff(get_param(bd,'DisableAllScopes'));
  set(children.freezeButton,'Value',val);
  
%end i_SyncPerformancePage


% Function ======================================================================
% Create specified tab page.                                     

function dialogUserData = i_CreatePage(page, dialogFig, dialogUserData),
  
if onoff(get(dialogFig, 'Visible')),
  set(dialogFig, 'DefaultUicontrolVisible', 'off');
end

switch(page),
  
 case 'General',
  dialogUserData = i_CreateGeneralPage(dialogFig, dialogUserData);
  i_SyncGeneralPage(dialogFig, dialogUserData,'');
  
  dialogUserData = i_UpdateGeneralPage(dialogFig,dialogUserData);
  dialogUserData = i_UpdateGeneralPageEnables(dialogFig,dialogUserData);
  
  i_InstallGeneralCallbacks(dialogFig, dialogUserData);
 
 case 'Performance',
  dialogUserData = i_CreatePerformancePage(dialogFig, dialogUserData);
  i_SyncPerformancePage(dialogFig,dialogUserData);
  
  dialogUserData = i_UpdatePerformancePage(dialogFig,dialogUserData);
  dialogUserData = i_UpdatePerformancePageEnables(dialogFig,dialogUserData);  
  
  i_InstallPerformanceCallbacks(dialogFig, dialogUserData);
  
 otherwise,
  error('M Assert: Invalid page');
  
end

set(dialogFig, 'DefaultUicontrolVisible', 'on');


%
% If all pages are created, free up some memory.
%

if ((~isempty(dialogUserData.generalPage.children)) & ...
    (~isempty(dialogUserData.performancePage.children))),
  
  delete(dialogUserData.commonGeom.textExtent);
  dialogUserData.commonGeom = [];
end

%end i_CreatePage


% Function ======================================================================
% Create specified tab page.                                     

function dialogUserData = i_CreateSysButtons(dialogFig, dialogUserData),

  commonGeom = dialogUserData.commonGeom;
  sheetPos   = commonGeom.sheetPos;
  
  cxCur = sheetPos(1) + sheetPos(3) - commonGeom.sysButtonWidth;
  cyCur = commonGeom.figBottomEdgeBuffer;
  
  pos = [cxCur cyCur commonGeom.sysButtonWidth commonGeom.sysButtonHeight];
  
  children.close = uicontrol( ...
    'Parent',            dialogFig, ...
    'String',             'Close', ...
    'Horizontalalign',    'center', ...
    'Enable',             'on', ...
    'Position',           pos);

  dialogUserData.systemButtons = children;
  
%end i_CreateSysButtons


% Function ======================================================================
% Create specified tab page.                                     

function dialogUserData = i_CreateGeneralPage(dialogFig, dialogUserData)

cr = sprintf('\n');

commonGeom     = dialogUserData.commonGeom;
generalCtrlPos = i_GeneralCtrlPositions(commonGeom);

children.viewerList = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'listbox', ...
    'String',             {}, ...
    'Max',                3, ...
    'Min',                1, ...
    'Position',           generalCtrlPos.viewerList, ...
    'BackgroundColor',    dialogUserData.listboxBackGroundcolor, ...
    'Interruptible',      'off', ...
    'BusyAction',         'queue');

children.nameLabel = uicontrol( ...
    'Parent',             dialogFig, ...
    'Style',              'text', ...
    'String',             'Name:', ...
    'Position',           generalCtrlPos.nameLabel);

children.nameEdit = uicontrol( ...
    'Parent',             dialogFig, ...
    'BackgroundColor',    'w', ...
    'Style',              'edit', ...
    'Position',           generalCtrlPos.nameEdit);

children.insertButton = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'pushbutton', ...
    'Position',         generalCtrlPos.insertButton, ...
    'Tooltip',          'Add signal viewer', ...
    'CData',            i_LoadGifIcon('add.gif'));

children.deleteButton = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'pushbutton', ...
    'Position',         generalCtrlPos.deleteButton, ...
    'Tooltip',          'Delete selected signal viewer(s)', ...
    'CData',            i_LoadGifIcon('delete.gif'));

children.openButton = uicontrol( ...
    'Parent',           dialogFig, ...
    'Style',            'pushbutton', ...
    'Position',         generalCtrlPos.openButton, ...
    'Tooltip',          'Open selected signal viewer(s)', ...
    'CData',            []);
    
dialogUserData.generalPage.children = children;

% end i_CreateGeneralPage()


% Function ======================================================================
% Create specified tab page.                                     

function pageCtrlPos = i_GeneralCtrlPositions(commonGeom),
  
  sheetPos   = commonGeom.sheetPos;
  sysOffsets = commonGeom.sysOffsets;
  
  sheetW = sheetPos(3);
  sheetH = sheetPos(4);
  
  listboxW = sheetW - ...
      (commonGeom.sheetSideEdgeBuffer * 2) - ...
      commonGeom.toolButtonWidth - ...
      commonGeom.toolButtonDelta;

  listBoxBottomFromSheet = ...
      commonGeom.sheetBottomEdgeBuffer + ...
      commonGeom.editHeight + ...
      commonGeom.standardDeltaSmall;
  
  listBoxBottom = sheetPos(2) + listBoxBottomFromSheet;
  
  listboxH = sheetH - ...
      commonGeom.sheetTopEdgeBuffer - ...
      listBoxBottomFromSheet;
  
  cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
  cyCur = listBoxBottom;
  
  pageCtrlPos.viewerList = [cxCur cyCur listboxW listboxH];
  
  set(commonGeom.textExtent, 'String', 'Name: ');
  ext            = get(commonGeom.textExtent, 'Extent');
  nameLabelWidth = ext(3);
  nameEditWidth  = listboxW - nameLabelWidth;
  
  cyCur = cyCur - commonGeom.standardDeltaSmall - commonGeom.editHeight;
  pageCtrlPos.nameLabel = [cxCur cyCur nameLabelWidth commonGeom.textHeight];
  
  cxCur = cxCur + nameLabelWidth;
  pageCtrlPos.nameEdit = [cxCur cyCur nameEditWidth commonGeom.editHeight];
  
  cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer + listboxW + commonGeom.toolButtonDelta;
  cyCur = listBoxBottom + listboxH - commonGeom.toolButtonHeight;
  
  pageCtrlPos.insertButton = ...
      [cxCur cyCur commonGeom.toolButtonWidth commonGeom.toolButtonHeight];
  
  cyCur = cyCur - commonGeom.toolButtonDelta - commonGeom.toolButtonHeight;
  pageCtrlPos.deleteButton = ...
      [cxCur cyCur commonGeom.toolButtonWidth commonGeom.toolButtonHeight];
  
  cyCur = cyCur - commonGeom.toolButtonDelta - commonGeom.toolButtonHeight;
  pageCtrlPos.openButton = ...
      [cxCur cyCur commonGeom.toolButtonWidth commonGeom.toolButtonHeight];  
  
% end i_GeneralCtrlPositions()


% Function ======================================================================
% Create specified tab page.                                     

function pageCtrlPos = i_PerformanceCtrlPositions(commonGeom),
  sheetPos   = commonGeom.sheetPos;
  sysOffsets = commonGeom.sysOffsets;
  
  set(commonGeom.textExtent, 'String', 'Override signal viewer refresh periods');
  ext               = get(commonGeom.textExtent, 'Extent');
  overrideCheckboxW = ext(3) + sysOffsets.checkbox(3);
  
  cxCur = sheetPos(1) + commonGeom.sheetSideEdgeBuffer;
  cyCur = ...
      sheetPos(2) + sheetPos(4) - ...
      commonGeom.sheetTopEdgeBuffer - ...
      commonGeom.checkboxHeight;
  
  pageCtrlPos.overrideCheckbox = ...
      [cxCur cyCur overrideCheckboxW commonGeom.checkboxHeight];
  
  cyCur = cyCur - commonGeom.standardDeltaSmall - commonGeom.hSliderHeight;
  
  set(commonGeom.textExtent,'String','Refresh period (frames): ');
  ext             = get(commonGeom.textExtent, 'Extent');
  unitsPopupWidth = ext(3) + sysOffsets.popupmenu(3);
  hSpace           = 0;
  
  sliderWidth = ...
      sheetPos(3)                          - ...
      (commonGeom.sheetSideEdgeBuffer * 4);
  
  cxCur = sheetPos(1) + (commonGeom.sheetSideEdgeBuffer * 2);
  pageCtrlPos.unitsPopup = ...
      [cxCur cyCur unitsPopupWidth commonGeom.popupHeight];
  
  cyCur = cyCur - commonGeom.hSliderHeight;
  pageCtrlPos.slider = [cxCur cyCur sliderWidth commonGeom.hSliderHeight];
  leftSlider = cxCur;
  
  cxCur = leftSlider;
  cyCur = cyCur-commonGeom.textHeight;
  pageCtrlPos.sliderText = [cxCur cyCur sliderWidth commonGeom.textHeight];
  
  set(commonGeom.textExtent,'String','Freeze all signal viewer graphics ');
  ext             = get(commonGeom.textExtent, 'Extent');
  freezeWidth     = ext(3) + sysOffsets.pushbutton(3);
  
  cxCur = sheetPos(1) + ((sheetPos(3) - freezeWidth)/2);
  cyCur = cyCur - (2*commonGeom.standardDeltaSmall) - commonGeom.buttonHeight;
  pageCtrlPos.freezeButton = [cxCur cyCur freezeWidth commonGeom.buttonHeight];
  
%end i_PerformanceCtrlPositions

  
% Function ======================================================================
% Create specified tab page.                                     

function dialogUserData = i_CreatePerformancePage(dialogFig, dialogUserData),

  commonGeom         = dialogUserData.commonGeom;
  performanceCtrlPos = i_PerformanceCtrlPositions(commonGeom);
  
  children.overrideCheckbox = uicontrol( ...
      'Parent',           dialogFig, ...
      'Style',            'checkbox', ...
      'String',           'Override signal viewer refresh periods', ...
      'Position',         performanceCtrlPos.overrideCheckbox);
  
  string = {
      'Refresh period (sec)'
      'Refresh period (frames)'};
  
  children.unitsPopup = uicontrol(...
      'Parent',                  dialogFig, ...
      'Style',                   'popupmenu', ...
      'Position',                performanceCtrlPos.unitsPopup, ...
      'BackgroundColor',         dialogUserData.popupBackGroundColor, ...
      'String',                  string);
  
  children.slider = uicontrol(...
      'Parent',           dialogFig, ...
      'Style',            'slider', ...
      'Position',         performanceCtrlPos.slider, ...
      'Min',              0, ...
      'Max',              10);

  children.sliderText = uicontrol(...
      'Parent',               dialogFig, ...
      'Style',                'text', ...
      'Position',             performanceCtrlPos.sliderText, ...
      'String',               'Test string', ...
      'HorizontalAlignment',  'center');
  
  children.freezeButton = uicontrol( ...
      'Parent',               dialogFig, ...
      'Style',                'ToggleButton', ...
      'Position',             performanceCtrlPos.freezeButton, ...
      'String',               'Freeze all signal viewer graphics', ...
      'HorizontalAlignment',  'center');
  
  dialogUserData.performancePage.children = children;
  
%end i_CreatePerformancePage
  
  
% Function ======================================================================
% Install callbacks for specified page.                          

function i_InstallCallbacks(page, dialogFig, dialogUserData),

switch(page),
    
case 'General',
    i_InstallGeneralCallbacks(dialogFig, dialogUserData);
    
case 'Performance',
    i_InstallPerformanceCallbacks(dialogFig, dialogUserData);
    
case 'System',
    i_InstallSystemButtonCallbacks(dialogFig, dialogUserData);
    
otherwise,
    error('M Assert: Invalid page');
    
end

%end i_InstallCallbacks


% Function ======================================================================
% Install callbacks for specified page.                          

function i_InstallGeneralCallbacks(dialogFig, dialogUserData),
  children = dialogUserData.generalPage.children;

  set(children.viewerList, ...
    'Callback',  'watchsigsdlg(''GeneralPage'', ''ViewerList'', gcbf)');
  
  set(children.nameEdit, ...
    'Callback',  'watchsigsdlg(''GeneralPage'', ''NameEdit'', gcbf)');
  
  set(children.insertButton, ...
    'Callback',   'watchsigsdlg(''GeneralPage'', ''Insert'', gcbf)');
  
  set(children.deleteButton, ...
    'Callback',  'watchsigsdlg(''GeneralPage'', ''Delete'', gcbf)');
  
  set(children.openButton, ...
    'Callback',  'watchsigsdlg(''GeneralPage'', ''Open'', gcbf)');
  
%end i_InstallGeneralCallbacks


% Function ======================================================================
% Install callbacks for specified page.                          

function i_InstallPerformanceCallbacks(dialogFig, dialogUserData),
  children = dialogUserData.performancePage.children;
  
  set(children.overrideCheckbox, ...
      'Callback',    'watchsigsdlg(''PerfPage'', ''Override'', gcbf)');

  set(children.unitsPopup, ...
      'Callback',    'watchsigsdlg(''PerfPage'', ''UnitsPopup'', gcbf)');
  
  set(children.slider, ...
      'Callback',    'watchsigsdlg(''PerfPage'', ''Slider'', gcbf)');
  
  set(children.freezeButton, ...
      'Callback',    'watchsigsdlg(''PerfPage'', ''Freeze'', gcbf)');

%end i_InstallPerformanceCallbacks


% Function ======================================================================
% Install callbacks for specified page.                          

function i_InstallSystemButtonCallbacks(dialogFig, dialogUserData),

  children = dialogUserData.systemButtons;
  
  set(children.close, ...
    'Callback',  'watchsigsdlg(''SystemButtons'', ''Close'', gcbf)');

%end i_InstallSystemButtonCallbacks


% Function ======================================================================
% Return 1 for single click, 2 for double click.

function clickType = i_GetClickType(dialogFig),
  clickType = 1;
  if strcmp(get(dialogFig,'SelectionType'),'open'),
    clickType = 2;
  end
  
%end i_GetClickType


% Function ======================================================================
%

function dialogUserData =  i_UpdatePage( ...
  dialogFig, dialogUserData, page),
  
  switch(page),
    
   case 'General',
    dialogUserData = i_UpdateGeneralPage(dialogFig, dialogUserData);
  
   case 'Performance',
    dialogUserData = i_UpdatePerformancePage(dialogFig, dialogUserData);
  end
  
%end i_UpdatePage


% Function ======================================================================
%

function dialogUserData = i_UpdateEnables(dialogFig, dialogUserData)

  if  ~isempty(dialogUserData.generalPage.children),
    dialogUserData = i_UpdateGeneralPageEnables(dialogFig, dialogUserData);
  end

  if ~isempty(dialogUserData.performancePage.children), 
    dialogUserData = i_UpdatePerformancePageEnables(dialogFig, dialogUserData);
  end  
  
  figure(dialogFig);
% end i_ReShowDialog

% Function ======================================================================
%

function dialogUserData =  i_UpdatePageEnables( ...
  dialogFig, dialogUserData, page),
  
  switch(page),
    
   case 'General',
    dialogUserData = i_UpdateGeneralPageEnables(dialogFig, dialogUserData);
  
   case 'Performance',
    dialogUserData = i_UpdatePerformancePageEnables(dialogFig, dialogUserData);
  end
  
%end i_UpdatePage


% Function ======================================================================
%

function dialogUserData = ...
      i_UpdateGeneralPageEnables(dialogFig, dialogUserData),
  
  children  = dialogUserData.generalPage.children;
  simStatus = get_param(dialogUserData.model, 'SimulationStatus');
  
  if strcmp(simStatus,'stopped'),
    viewerIndices = get(children.viewerList, 'Value');
    if length(viewerIndices) == 1,
      set(children.nameEdit, ...
          'Enable',          'on', ...
          'BackgroundColor', 'w');
    else,
      set(children.nameEdit, ...
          'Enable',    'off', ...
          'BackgroundColor', get(0,'FactoryUicontrolBackgroundColor'));
    end
    
    set([children.insertButton children.deleteButton], 'Enable','on');
  else,
    handles = [
        children.nameEdit];
    set(handles, ...
        'Enable',           'off', ...
        'BackgroundColor',  get(0,'FactoryUicontrolBackgroundColor'));
    
    set([children.insertButton children.deleteButton], 'Enable','off');
  end
  
%end i_UpdateGeneralPageEnables


% Function ======================================================================
%

function dialogUserData = ...
      i_UpdatePerformancePageEnables(dialogFig, dialogUserData),
  
  children  = dialogUserData.performancePage.children;
  bd        = dialogUserData.model;
  
  val = get_param(bd, 'OverrideScopeRefreshTime');
  h   = [children.unitsPopup children.slider];
  set(h,'Enable',val);
  
%end dialogUserData


% Function ======================================================================
%

function dialogUserData =  i_UpdateGeneralPage(...
    dialogFig, dialogUserData),
  
  children  = dialogUserData.generalPage.children;
  
  viewerListStr = get(children.viewerList, 'String');
  viewerIndices = get(children.viewerList, 'Value');
  if length(viewerIndices) == 1,
    selectedStr = viewerListStr{viewerIndices};
    set(children.nameEdit, ...
        'String',          selectedStr);
  else,
    set(children.nameEdit, ...
        'String',    '');
  end
  
%end i_UpdateGeneralPage


% Function ======================================================================
%

function dialogUserData =  i_UpdatePerformancePage(...
    dialogFig, dialogUserData),
  
%end i_UpdatePerformancePage


% Function ======================================================================
% Given a string from the viewer list box, return a block handle.

function valid = i_IsValidBlockPath(blockPath),
  valid = 1;
  
  try,
    get_param(blockPath,'tag');
  catch,
    valid = 0;
  end
%end i_IsValidBlockPath


% Function ======================================================================
% Given a string from the viewer list box, return a block handle.  Returns
% -1 if no corresponding block exists.

function handle = i_GetBlockHandleFromListBoxString(bd,displayStr),
  handle = -1;
  
  modelName = get_param(bd,'Name');
  
  blockPath = [modelName '/' i_DisplayNameToBlockName(displayStr)];
  if i_IsValidBlockPath(blockPath),
    handle = get_param(blockPath,'Handle');
  end
  
%end i_GetBlockHandleFromListBoxString

  
% Function ======================================================================
%

function i_OpenSelectedViewers(dialogUserData),
  
  children        = dialogUserData.generalPage.children;
  viewerListStr   = get(children.viewerList, 'String');
  selectedIndices = get(children.viewerList, 'Value');
  bd              = dialogUserData.model;
  
  for i=1:length(selectedIndices),
    idx        = selectedIndices(i);
    viewerName = viewerListStr{idx};
    block      = i_GetBlockHandleFromListBoxString(bd, viewerName);
    if block ~= -1,
      open_system(block);
    else,
      warning(['Unable to open: '' ' displayString]);
    end
  end
  
%end i_OpenSelectedViewers
  

% Function ======================================================================
%

function dialogUserData = ...
      i_ManageGeneralPage(dialogFig, dialogUserData, action)
  
  switch(action)
    
   case 'ViewerList',
    if i_GetClickType(dialogFig) == 1,
      % Single-click
      dialogUserData = i_UpdateGeneralPage(dialogFig, dialogUserData);
      dialogUserData = i_UpdateGeneralPageEnables(dialogFig, dialogUserData);
    else
      % Double-click
      i_OpenSelectedViewers(dialogUserData);
    end    
    
   case 'NameEdit',
    dialogUserData = i_RenameViewer(dialogFig, dialogUserData);
    
   case 'Insert',
    dialogUserData = i_AddViewer(dialogFig, dialogUserData);
    
   case 'Delete',
    dialogUserData = i_DeleteViewer(dialogFig, dialogUserData);
    
   case 'Open',
    i_OpenSelectedViewers(dialogUserData);
    
   otherwise,
    
    error('Invalid action');
    
  end %switch
  
% end i_ManageGeneralPage


% Function ======================================================================
%

function dialogUserData = ...
      i_ManagePerformancePage(dialogFig, dialogUserData, action),
  
  children = dialogUserData.performancePage.children;
  bd       = dialogUserData.model;
  
  switch(action),
    
   case 'Override',
    val = get(children.overrideCheckbox,'Value');
    set_param(bd,'OverrideScopeRefreshTime',onoff(val));
    
    dialogUserData = i_UpdatePerformancePageEnables(dialogFig,dialogUserData);
    
   case 'UnitsPopup',
    unitsPopup    = children.unitsPopup;
    unitsPopupVal = get(unitsPopup,'Value');
    slider        = children.slider;
    
    switch(unitsPopupVal),
     case 1,
      %seconds mode
      refreshVal = 0.035;
     
     case 2,
      %frame mode
      refreshVal = -1;
      
     otherwise,
      error('M Assert: unexpected units for slider');
    end
    
    set_param(bd,'ScopeRefreshTime',refreshVal);
    i_SyncSlider(dialogUserData);      
      
   case 'Slider',
    slider        = children.slider;
    unitsPopup    = children.unitsPopup;
    unitsPopupVal = get(unitsPopup,'Value');
    sliderVal     = get(slider,'Value');
    frameMode     = 0;
    
    switch(unitsPopupVal),
     case 1,
      %seconds mode
      x = dialogUserData.performancePage.secSliderSliderVals;
      y = dialogUserData.performancePage.secSliderRefreshVals;
     case 2,
      %frame mode
      x = dialogUserData.performancePage.frameSliderSliderVals;
      y = dialogUserData.performancePage.frameSliderRefreshVals;
      
      frameMode = 1;
     otherwise,
      error('M Assert: unexpected units for slider');
    end
   
    val = interp1(x,y,sliderVal);
    if frameMode,
      % round down to nearest int and negate.  Simulink uses the - to figure out
      % that we're in frame mode
      val = -floor(val);
    end
    
    try,
      set_param(bd,'ScopeRefreshTime',val);
    catch,
      warning('Error adjusting scope performance');
    end      
    
    string = i_SliderText(frameMode,val);
    set(children.sliderText,'String',string);
    
   case 'Freeze',
    val = get(children.freezeButton, 'Value');
    set_param(bd,'DisableAllScopes',onoff(val));
    
    if (val),
      set(children.freezeButton,'ForeGroundColor','r');
    else,
      set(children.freezeButton,'ForeGroundColor','k');
    end    
    
   otherwise,
    error('Invalid action');
  end
%end i_ManagePerformancePage


% Function ======================================================================
%

function dialogUserData = ...
      i_ManageSystemButtons(dialogFig, dialogUserData, action),

  switch(action),
   case 'Close',
    set(dialogFig,'Visible','off');
    
   otherwise,
    error('M Assert: Invalid action');
  end
%end i_ManagePerformancePage


% Function ======================================================================
%

function dialogUserData = i_AddViewer(dialogFig, dialogUserData),
  bd            = dialogUserData.model;
  bdName        = get_param(bd,'Name');
  newViewerName = i_NewViewerName(bd);
  
  block = [bdName '/' i_DisplayNameToBlockName(newViewerName)];
  
  try,
    add_block('built-in/SignalViewerScope', block, ...
              'ShowName', 'off', ...
              'Position', [0 0 0 0]);
  catch,
    error(['M Assert: Error adding block: ''' block 'to model']);
  end

  i_SyncGeneralPage(dialogFig, dialogUserData, newViewerName);
  
%end i_AddViewer()


% Function ======================================================================
%

function dialogUserData = i_DeleteViewer(dialogFig, dialogUserData),
  children        = dialogUserData.generalPage.children;
  viewerListStr   = get(children.viewerList, 'String');
  selectedIndices = get(children.viewerList, 'Value');
  bd              = dialogUserData.model;
  
  for i=1:length(selectedIndices),
    idx        = selectedIndices(i);
    viewerName = viewerListStr{idx};
    block      = i_GetBlockHandleFromListBoxString(bd, viewerName);
    if block ~= -1,
      delete_block(block);
    else,
      warning(['Unable to delete: '' ' displayString]);
    end
  end
  
  i_SyncGeneralPage(dialogFig, dialogUserData, '');

%end i_DeleteViewer()


% Function ======================================================================
%

function dialogUserData = i_RenameViewer(dialogFig, dialogUserData),
  
  blockRenamed = 0;
  
  children  = dialogUserData.generalPage.children;
  newName   = get(children.nameEdit,   'String');
  viewerStr = get(children.viewerList, 'String');
  viewerIdx = get(children.viewerList, 'Value');
  
  if (length(viewerIdx) ~= 1),
    error('M Assert: single selection expected');
  end
  
  bd         = dialogUserData.model;
  displayStr = viewerStr{viewerIdx};
  block      = i_GetBlockHandleFromListBoxString(bd, displayStr);

  if block == -1,
    error('M_Assert: Invalid block');
  end


  try,
    set_param(block, 'Name', i_DisplayNameToBlockName(newName));
  catch,
    errordlg(['Invalid viewer name: ' sllasterror], ...
             dialogUserData.errorTitle, 'modal');
  end
  blockRenamed = 1;
  
  % Update the controls.
  % 
  if blockRenamed
    viewerStr{viewerIdx} = newName;
    set(children.viewerList,'String',viewerStr);
  end
  
%end i_RenameViewer()


% Function ======================================================================
%

function name = i_DlgName(bd),

name = ['Signal viewers for: ' get_param(bd,'name')];

% end i_DlgName


% Function ======================================================================
%

function dialogUserData = i_ReShowDialog(dialogFig, dialogUserData)

  bVisible = onoff(get(dialogFig, 'Visible'));

  if ~bVisible & ~isempty(dialogUserData.generalPage.children),
    i_SyncGeneralPage(dialogFig, dialogUserData, '');
    dialogUserData = i_UpdatePage(dialogFig,dialogUserData,'General');
    dialogUserData = i_UpdatePageEnables(dialogFig,dialogUserData,'General');
  end

  if ~bVisible & ~isempty(dialogUserData.performancePage.children), 
    i_SyncPerformancePage(dialogFig, dialogUserData);
    dialogUserData = i_UpdatePage(dialogFig,dialogUserData,'Performance');
    dialogUserData = i_UpdatePageEnables(dialogFig,dialogUserData,'Performance');
  end  
  
  figure(dialogFig);
% end i_ReShowDialog

% Function ======================================================================
%

function str = PREFIX_STR
  str = 'SignalViewer_';
  
%end PREFIX_STR

% Function ======================================================================
%

function blockName = i_DisplayNameToBlockName(displayName)
    
  blockName = [PREFIX_STR displayName];
    
%end i_DisplayNameToBlockName

    
% Function ======================================================================
%

function displayName = i_BlockNameToDisplayName(blockName)
  
  prefixLen = length(PREFIX_STR);
  
  if ~strncmp(blockName,PREFIX_STR,prefixLen)
    error('SIMULINK:watchsigsdlg',['Invalid Signal Viewer name. ' ...
                        'Contact MathWorks']);
  end
  
  displayName = blockName(prefixLen+1:end);
  
%end i_BlockNameToDisplayName


% Function ======================================================================
%

function displayPath = i_BlockPathToDisplayPath(blockPath)
    
  prefixLen = length(PREFIX_STR);
  
  if isempty(findstr(blockPath, PREFIX_STR)),
    error('SIMULINK:watchsigsdlg',['Invalid Signal Viewer name. ' ...
                        'Contact MathWorks']);
  end
  
  displayPath = strrep(blockPath, PREFIX_STR, '');
  
%end i_BlockPathToDisplayPath


% Function ======================================================================
%

function viewers = i_GetViewers(dialogUserData)                              
  
  modelName = get_param(dialogUserData.model,'Name');
  viewerPaths = find_system(modelName, 'AllBlocks', 'on','SearchDepth', 1, ...
			   'BlockType', 'SignalViewerScope');

  viewers = strrep(viewerPaths, [modelName '/' PREFIX_STR], '');
  
%end i_GetViewers
 

% Function ======================================================================
%

function name = i_NewViewerName(bd),

  baseName  = 'Viewer';
  modelName = get_param(bd,'Name');
  name      = baseName;
  hBd       = get_param(bd,'Handle');

  i = 0;
  while(1),
    if isempty(find_system(hBd,'AllBlocks','on','SearchDepth',1, ...
                           'Name', i_DisplayNameToBlockName(name))),
      break;
    end
    i = i + 1;
    name = sprintf('%s%d', baseName, i);
  end
%end i_NewViewerName


% Function ======================================================================
%  

function icon = i_LoadGifIcon(fileName)
    
    bgNew = get(0,'DefaultUIControlBackground');
    [img,cm] = imread(fileName,'gif');
    
    % Convert Add
    img = double(img)+1;
    
    % Overwrite the background color with the UI Background color.
    % (Assume the top, left corner is a background color.)
    cm(img(1,1),:) = bgNew;
    
    % This converts the gif to rgb.  It does not use ind2rgb, because 
    % the user may not have purchased the Image Processing Toolbox.
    icon = reshape(cm(img,:),[size(img) 3]);
    
%end i_LoadGifIcon(fileName)


% Function ======================================================================
%

function dialogUserData = i_ChangePage( ...
    pressedTabString, ...
    pressedTabNum, ...
    oldTabString, ...
    oldTabNum, ...
    dialogFig, ...
    dialogUserData),

%
% Determine which controls to make visible base on page number.
%
switch(pressedTabNum),

case 1,
    if isempty(dialogUserData.generalPage.children),
      page = 'General';

      dialogUserData = i_CreatePage(page, dialogFig, dialogUserData);
      i_InstallCallbacks(page, dialogFig, dialogUserData);
    end

    childrenCell   = struct2cell(dialogUserData.generalPage.children);
    childrenVector = [childrenCell{:}];

case 2,
 if isempty(dialogUserData.performancePage.children),
   page = 'Performance';
   
   dialogUserData = i_CreatePage(page, dialogFig, dialogUserData);
   i_InstallCallbacks(page, dialogFig, dialogUserData);
 end
 
 childrenCell   = struct2cell(dialogUserData.performancePage.children);
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
    oldchildrenCell   = struct2cell(dialogUserData.performancePage.children);
    oldchildrenVector = [oldchildrenCell{:}];

otherwise,
    error('M Assert: invalid tab');
end


%
% Toggle page visiblity (default behavior).
%
set(oldchildrenVector, 'Visible', 'off');
set(childrenVector, 'Visible', 'on');

%end i_ChangePage
