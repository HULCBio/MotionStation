function varargout = slblkpropdlg(varargin)
% Simulink Block Properties dialog.
% 
%   This function creates a Handle Graphics dialog to display and edit
%   Simulink block's block properties. This is an internal Simulink
%   function. 
%

%   Jun Wu, 1/01/2002
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18.4.6 $ $Date: 2004/04/13 00:35:54 $

hdl = -1;
switch(nargin) 
  
 case 1,
  %------------------------------------------%
  % Simulink is asking us to open the dialog %
  %------------------------------------------%
  blkHdl = varargin{1};
  hdl    = openDialog(blkHdl);
  
 case 2,
  %--------------------------------------------------------------%
  % Simulink is telling us the block changed name or was deleted %
  %--------------------------------------------------------------%
  blkHdl = varargin{2};
  blkType = get_param(blkHdl, 'BlockType');
  switch lower(varargin{1})
   case 'delete'
    doClose(blkHdl);
   case 'namechange'
    doUpdateName(blkHdl);
   otherwise
    error(sprintf(['Invalid command "' varargin{1} ...
		   '" for Block Properties dialog.']));
  end
  
 case 3,
  switch lower(varargin{1}) 
   case 'switchtab'                     % command line interface
    blkHdl    = varargin{2};
    newTabNum = varargin{3};
    
    hdl = get_param(blkHdl, 'PropertiesDialogFigure');
    ud  = get(hdl, 'UserData');
    
    tabdlg('tabpress', ud.hdl, get(ud.tab(newTabNum),'String'), newTabNum);
    
   otherwise
    error(sprintf(['Invalid command "' varargin{1} ...
		   '" for Block Properties dialog.']));
  end
  
 case 6 % tabcallbk
  doTabSwitch(varargin{2:6});
  
 otherwise,
  error(['Invalid number of arguments ', num2str(nargin)]);
end

if nargout
  varargout{1} = hdl;			% output bogus handle
end

% end sldatastoredlg


% Function: createDialog =======================================================
% Abstract:
%   This function constructs the graphical objects for the dialog.
%
function hdl = createDialog(blkHdl)

% keep the background color consistent for each uicontrol objects
objBGColor = get(0, 'defaultuicontrolbackgroundcolor');
fontsize   = get(0, 'FactoryUicontrolFontSize');
fontname   = get(0, 'FactoryUicontrolFontName');

%
% Create constants based on current computer.
%
thisComputer = computer;

fontsize = get(0, 'FactoryUicontrolFontSize');
fontname = get(0, 'FactoryUicontrolFontName');

switch(thisComputer)
  case 'PCWIN',
    ud.popupBackGroundColor = 'w';
    ud.tabHoffset           = 1;
    ud.tabVoffset           = 2;
    dialogPos = [1 1 400 450];
    
  otherwise,  % X
    ud.popupBackGroundColor = get(0, 'FactoryUicontrolBackgroundColor');
    ud.tabHoffset           = 0;
    ud.tabVoffset           = 2;
    dialogPos = [1 1 500 450];
end

hdl = figure( ...
    'Name',             sprintf('Block Properties: %s', get_param(blkHdl, 'name')), ...
    'Numbertitle',                     'off',...
    'Menubar',                         'none', ...
    'Visible',                         'off', ...
    'HandleVisibility',                'callback', ...
    'IntegerHandle',                   'off', ...
    'DefaultUicontrolHorizontalAlign', 'left', ...
    'DefaultUicontrolFontname',        fontname, ...
    'DefaultUicontrolFontsize',        fontsize, ...
    'DefaultUicontrolUnits',           'pixels', ...
    'Color',                           objBGColor, ...
    'Position',                        dialogPos, ...
    'Resize',                          'on', ...
    'KeyPressFcn',                     {@returnKeyOK}, ...
    'DeleteFcn',                       {@deleteFcn});

tmpText = uicontrol(hdl, 'style', 'text', ...
                    'fontunit', 'pixel', ...
		    'visible', 'off', ...
		    'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
dialogPos(3:4) = dialogPos(3:4)*pixelRatio;
set(hdl, 'Position', dialogPos);

% create a text object for text size calliboration on different platforms
textExtent = uicontrol( ...
    'Parent',     hdl, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'FontSize',   fontsize, ...
    'FontName',   fontname ...
    );

commonGeom = createCommonGeom(textExtent);

% Set callback and offsets for tabdlg.
callback = 'slblkpropdlg';
offsets  = [commonGeom.figSideEdgeBuffer
            commonGeom.figTopEdgeBuffer
            commonGeom.figSideEdgeBuffer
            commonGeom.bottomSheetOffset
           ];

% have a fixed sheetDims by default
sheetDims = [dialogPos(3)-2*commonGeom.figSideEdgeBuffer
             dialogPos(4)-commonGeom.figTopEdgeBuffer-...
             commonGeom.bottomSheetOffset];

% create the tab dialog
tabStrings = {'General', 'Block Annotation', 'Callbacks'};
try
  defaultTabNum  = get_param(blkHdl, 'PropertiesDialogTabNum');
catch
  % error occurs, using default page
  defaultTabNum  = 1;
end
defaultTabName = tabStrings{defaultTabNum};
numTabs = length(tabStrings);

% calculate each tabs' dimension
widths(numTabs) = 0;
for i=1:numTabs,
  set(textExtent, 'String', tabStrings{i});
  ext = get(textExtent, 'Extent');
  widths(i) = ext(3) + 6;
end
height  = ext(4) + 4;
tabDims = {widths, height};

% now, creating the tab dialog
[hdl, sheetPos] = tabdlg('create', ...
                         tabStrings, ...
                         tabDims, ...
                         callback, ...
                         sheetDims, ...
                         offsets, ...
                         defaultTabNum, ...
                         {}, ...
                         hdl ...
                         );

% get these buttons' handles that simulated tab dialog
ud.tab(1) = findobj(hdl, 'Style', 'pushbutton', 'String', tabStrings{1});
ud.tab(2) = findobj(hdl, 'Style', 'pushbutton', 'String', tabStrings{2});
ud.tab(3) = findobj(hdl, 'Style', 'pushbutton', 'String', tabStrings{3});
ud.tab(4) = findobj(hdl, 'Style', 'pushbutton', 'String', '');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       General properties tab                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud.gen.infoFrame = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.gen.infoTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Usage');

infoStr = ...
    sprintf(['Description: Text saved with the block in the model file.\n' ...
	     'Priority: Specifies the block''s order of execution ' ...
             'relative to other blocks in the same model.\n'...
             'Tag: Text that appears in the block label that Simulink ' ...
             'generates.']);
ud.gen.infoText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              infoStr);

ud.gen.frame =  uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'enable',          'inactive',...
    'foregroundcolor', [255 251 240]/255);

ud.gen.descPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Description: ');

ud.gen.descEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'Max',                 2, ...
    'Min',                 0, ...
    'Tooltip',             'Enter text here', ...
    'string',              get_param(blkHdl,'Description'), ...
    'callback',            {@doEnableApply});

ud.gen.prioPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Priority: ');

ud.gen.prioEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'Tooltip',             'Enter integer value or leave it empty', ...
    'string',              get_param(blkHdl,'Priority'), ...
    'callback',            {@doEnableApply});

ud.gen.tagPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Tag: ');

ud.gen.tagEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'Tooltip',             'Enter text here', ...
    'string',              get_param(blkHdl,'Tag'), ...
    'callback',            {@doEnableApply});

ud.genHdls = [ud.gen.infoFrame ud.gen.infoTitle ud.gen.infoText ...
              ud.gen.frame ud.gen.descPrompt ud.gen.descEdit ...
              ud.gen.prioPrompt ud.gen.prioEdit ...
              ud.gen.tagPrompt ud.gen.tagEdit];
set(ud.genHdls, 'Visible', onoff(defaultTabNum==1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Attributes properties tab                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud.att.infoFrame = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.att.infoTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Usage');

infoStr = sprintf(...
    ['Text that appears below the block''s label. Enter the text in the ' ...
     'annotation field. The text may include any of the block property ' ...
     'tokens in the Block property tokens list. Simulink replaces each ' ...
     'token with the value of the corresponding property in the generated ' ...
     'annotation. Click the >> button to enter the selected token in ' ...
     'the annotation field. Text can be edited on the ' ...
     'right side edit field. See example syntax on the bottom.']);
ud.att.infoText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              infoStr);

ud.att.frame =  uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'enable',          'inactive',...
    'foregroundcolor', [255 251 240]/255);

ud.att.blkPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Block property tokens: ');

paramsStr = getDynamicBlkParamStr(blkHdl); 
ud.att.blkList = uicontrol(...
    hdl, ...
    'style',               'listbox', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'Tooltip',             ...
    sprintf(['Select tokens from the list to append by \n' ...
	     'double click mouse or using Append button.']), ...
    'string',              paramsStr.att, ...
    'callback',            {@doAttListGetFocus});

ud.att.appendButton = uicontrol(...
    hdl, ...
    'style',               'pushbutton', ...
    'Tooltip',   ...
    sprintf(['Click to append selected tokens \n' ...
	     'from left side to the right side']), ...
    'string',              ' >> ', ...
    'callback',            {@doAttAppend});

ud.att.fmtstrPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Enter text and tokens for annotation: ');

ud.att.fmtstrList = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     'white', ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'Tooltip', ...
    'Edit annotation strings. Click Apply to see the change on block.', ...
    'string',              retrieveAttributesFormatStr(blkHdl), ...
    'callback',            {@doEnableApply}); 

ud.att.example = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'horizontalalignment', 'left', ...
    'string',              ...
    [sprintf('Example syntax: \n') '    Name=%<Name>']);

ud.attHdls = [ud.att.infoFrame ud.att.infoTitle ud.att.infoText ...
              ud.att.frame ud.att.blkPrompt ud.att.blkList ...
              ud.att.appendButton ud.att.fmtstrPrompt ud.att.fmtstrList ...
              ud.att.example];
set(ud.attHdls, 'Visible', onoff(defaultTabNum==2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Callbacks properties tab                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud.cbk.infoFrame = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.cbk.infoTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Usage');

descStr = ...
    sprintf(['To create or edit a callback function for this block, select ' ...
             'it in the callback list (below, left). Then enter MATLAB code ' ...
             'that implements the function in the content pane (below, right). '...
             'The callback name''s suffix indicates its status: ' ...
	     '*(has saved content).']);
ud.cbk.infoText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              descStr);

ud.cbk.frame =  uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'enable',          'inactive',...
    'foregroundcolor', [255 251 240]/255);

ud.cbk.fcnPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Callback functions list: ');

ud.cbk.fcnList = uicontrol(...
    hdl, ...
    'style',               'listbox', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 1, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'Tooltip',             ...
    ['Select callback function.' sprintf('\n'), ...
     'Functions with asterisk(*) are non-empty.'], ...
    'string',              paramsStr.cbk.fcns, ...
    'callback',            {@doCbkSelection});
% create a cell-array that will store the callback function data
ud.cbk.cbData = paramsStr.cbk.cbData;

ud.cbk.fcnEditPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor);
doCbkEditPromptUpdate(ud.cbk.fcnList, ud.cbk.fcnEditPrompt);

ud.cbk.fcnEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     'white', ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'Tooltip',             'Editing selected callback function here.', ...
    'value',               [], ...
    'string',              {''}, ...
    'callback',            {@doCbkEditFocusLost}); 
set(ud.cbk.fcnEdit, 'String', ...
    doCbkFcnSelect(ud.cbk.fcnList, ud.cbk.cbData));

ud.cbkHdls = [ud.cbk.infoFrame ud.cbk.infoTitle ud.cbk.infoText ...
              ud.cbk.frame ud.cbk.fcnPrompt ud.cbk.fcnList ...
              ud.cbk.fcnEditPrompt ud.cbk.fcnEdit ...
             ];
set(ud.cbkHdls, 'Visible', onoff(defaultTabNum==3));

if slfeature('JavaFigures') == 1
  set(ud.gen.descEdit, 'KeyPressFcn', {@doEnableApply});
  set(ud.gen.prioEdit, 'KeyPressFcn', {@doEnableApply});
  set(ud.gen.tagEdit, 'KeyPressFcn', {@doEnableApply});
  set(ud.att.fmtstrList, 'KeyPressFcn', {@doEnableApply});
  set(ud.cbk.fcnEdit, 'KeyPressFcn', {@doEnableApply});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    standard dialog buttons                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ud.okButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalign', 'center', ...
    'String',          'OK', ...
    'Callback',        {@doOK});

ud.cancelButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'horizontalalign', 'center', ...
    'String',          'Cancel', ...
    'Callback',        {@doCancel});

ud.helpButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'horizontalalign', 'center', ...
    'Enable',          'on', ...
    'String',          'Help', ...
    'Callback',        {@doHelp});

ud.applyButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalign', 'center', ...
    'Enable',          'off', ...
    'String',          'Apply', ...
    'Callback',        {@doApply});

% register block handle and this figure handle in figure handle's UserData
ud.blkHdl = blkHdl;
ud.hdl    = hdl;

% store these objects information in dialog handle's userdata
ud.origSize = [0 0];
set(hdl, 'UserData', ud);

% setting up the proper size for this dialog
doResize(hdl, []);

% adjust the dialog's position according to block's position
set(hdl, 'Units', 'pixels');
dialogPos = get(hdl,'Position');
bdPos     = get_param(get_param(blkHdl,'Parent'), 'Location');
blkPos    = get_param(blkHdl, 'Position');
bdPos     = [bdPos(1:2)+blkPos(1:2) bdPos(1:2)+blkPos(1:2)+blkPos(3:4)];

hgPos        = rectconv(bdPos,'hg');
dialogPos(1) = hgPos(1)+(hgPos(3)-dialogPos(3));
dialogPos(2) = hgPos(2)+(hgPos(4)-dialogPos(4));

% make sure the dialog is not off the screen
units = get(0, 'Units');
set(0, 'Units', 'pixel');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', units);
if dialogPos(1)<0
  dialogPos(1) = 1;
elseif dialogPos(1)> screenSize(3)-dialogPos(3) 
  dialogPos(1) = screenSize(3)-dialogPos(3);
end
if dialogPos(2)<0
  dialogPos(2) = 1;
elseif dialogPos(2)> screenSize(4)-dialogPos(4) 
  dialogPos(2) = screenSize(4)-dialogPos(4);
end

ud.origSize=dialogPos(3:4);
set(hdl, ...
    'Position',  dialogPos, ...
    'Units',     'normalized', ...
    'UserData',  ud, ...
    'ResizeFcn', {@doResize});

%
% Update the userdata only if it is a changeable block
% else show a disabled version of the gui.
%
UiControls = [ud.attHdls'; ud.genHdls'; ud.cbkHdls'; ...
              ud.okButton; ud.applyButton];
if     ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set_param(blkHdl, 'PropertiesDialogFigure', hdl);
else
  set(UiControls, 'enable', 'off');
end

% end createDialog


% Function: createCommonGeom ===================================================
% Abstract:
%   Create common geometry constants so we don't have to deal with the
%   platform dependency issue.
%
function commonGeom = createCommonGeom(textExtent)

sysOffsets = sluigeom;

% Define generic font characterists.
calibrationStr = '_Revert_';

set(textExtent, 'String', calibrationStr);
ext = get(textExtent, 'Extent');

sysButtonWidth = ext(3);
charHeight     = ext(4);

commonGeom.textHeight            = charHeight;
commonGeom.editHeight            = charHeight + sysOffsets.edit(4);
commonGeom.checkboxHeight        = charHeight + sysOffsets.checkbox(4);
commonGeom.radiobuttonHeight     = charHeight + sysOffsets.radiobutton(4);
commonGeom.popupHeight           = charHeight + sysOffsets.popupmenu(4);
commonGeom.sysButtonHeight       = (charHeight*1.3) + sysOffsets.pushbutton(4);
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

commonGeom.bottomSheetOffset = ...
    commonGeom.figBottomEdgeBuffer    + ...
    commonGeom.sysButtonHeight        + ...
    commonGeom.sysButton_SheetDelta;

commonGeom.sysOffsets = sysOffsets;

% end createCommonGeom


% Function: doApply ============================================================
% Abstract:
%   This function will apply all the current settings appeared on the dialog.
%
function doApply(applyButton, evd)

hdl = get(applyButton, 'Parent');
ud  = get(hdl, 'UserData');

try
  paramVal = deblankall(get(ud.gen.descEdit, 'String'));
  if ~isempty(paramVal) | ...
	~isempty(get_param(ud.blkHdl, 'Description'))
    set_param(ud.blkHdl, 'Description', paramVal);
  end
  
  paramVal = deblankall(get(ud.gen.prioEdit, 'String'));
  if ~isempty(paramVal) | ...
	~isempty(get_param(ud.blkHdl, 'Priority'))
    set_param(ud.blkHdl, 'Priority', paramVal);
  end
  
  paramVal = deblankall(get(ud.gen.tagEdit, 'String'));
  if ~isempty(paramVal) | ...
	~isempty(get_param(ud.blkHdl, 'Tag'))
    set_param(ud.blkHdl, 'Tag', paramVal);
  end
  
  paramVal = createAttributesFormatStr(get(ud.att.fmtstrList, ...
					    'String'));
  if ~isempty(paramVal) | ...
	~isempty(get_param(ud.blkHdl, 'AttributesFormatString'))
    set_param(ud.blkHdl, 'AttributesFormatString', paramVal);
  end
  
  % save all callback functions
  doCbkSave(ud.cbk.fcnList);
catch
  errordlg(lasterr);
end
set_param(ud.blkHdl, 'PropertiesDialogFigure', hdl);

% switch applyButton
toggleApply(applyButton, 'off');

set(hdl, 'UserData', ud);

% end doApply


% Function: doAttAppend ========================================================
% Abstract: 
%   This function will append user selected block annotation token(s) into
%   the Block annotation edit field.
%
function doAttAppend(obj, evd)

hdl = get(obj, 'Parent');
ud = get(hdl, 'UserData');

attBlksStr = get(ud.att.blkList, 'String');
val        = get(ud.att.blkList, 'Value');

if ~isempty(attBlksStr) & val > 0
  appendedStr = [{deblank(attBlksStr{val(1)})}];
  if length(val) > 1
    for i=2:length(val)
      appendedStr = [appendedStr; {deblank(attBlksStr{val(i)})}];
    end
  end
  
  if isempty(deblank(get(ud.att.fmtstrList, 'string')))
    set(ud.att.fmtstrList, 'string', appendedStr);
  else
    if iscell(get(ud.att.fmtstrList, 'string'))
      existStr = get(ud.att.fmtstrList, 'string');
    else
      existStr = {deblankall(get(ud.att.fmtstrList, 'string'))};
    end
    set(ud.att.fmtstrList, ...
        'string', [existStr; appendedStr]);
  end
end

toggleApply(ud.applyButton);

% end doAttAppend


% Function: doAttListGetFocus ==================================================
% Abstract: 
%   Deal with the mouse double click on block annotation tokens list.
%
function doAttListGetFocus(obj, evd)

hdl = get(obj, 'Parent');
ud = get(hdl, 'UserData');

if strcmp(lower(get(hdl, 'SelectionType')), 'open')
  doAttAppend(ud.att.appendButton, []);
end

% end doAttListGetFocus


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change in it.
%
function doCancel(cancelButton, evd)

hdl = get(cancelButton, 'Parent');
ud  = get(hdl, 'UserData');

set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

if ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  set(ud.gen.descEdit, 'String', get_param(ud.blkHdl, 'Description'));
  set_param(ud.blkHdl, 'PropertiesDialogFigure', hdl);
  warning(warningState);
end

% end doCancel


% Function: doClose ============================================================
% Abstract:
%   This function will be called when the block is vanished.
%
function doClose(blkHdl)

if get_param(blkHdl, 'PropertiesDialogFigure') ~= -1
  hdl = get_param(blkHdl, 'PropertiesDialogFigure');
  if ~isempty(hdl) & ishandle(hdl)
    ud  = get(hdl, 'UserData');
    
    delete(hdl);
    try
      set_param(blkHdl, 'PropertiesDialogFigure', -1);
    catch
      % it will be error out if it's a library
    end
  end
end

% end doClose


% Function: doCbkSelection =====================================================
% Abstract: 
%   This function will be called when user selects callback functions.
% 
function doCbkSelection(fcnList, evd)
  
hdl = get(fcnList, 'Parent');
ud = get(hdl, 'UserData');
  
% update prompt
doCbkEditPromptUpdate(ud.cbk.fcnList, ud.cbk.fcnEditPrompt);

% get the selected callback fcn's string and display it in the edit field
cbkFcnStr = doCbkFcnSelect(ud.cbk.fcnList, ud.cbk.cbData);
set(ud.cbk.fcnEdit, 'String', cbkFcnStr);

% end doCbkSelection


% Function: doCbkEditFocusLost =================================================
% Abstract:
%   This function will be called when callback function's edit field lost its
%   editing focus.
%   
function doCbkEditFocusLost(fcnEdit, evd)
  
hdl = get(fcnEdit, 'Parent');
ud = get(hdl, 'UserData');

% update the callback function list to reflect the change
list = get(ud.cbk.fcnList, 'String');
val  = get(ud.cbk.fcnList, 'Value');

cbkData = deblank(get(fcnEdit, 'String'));

if ~strcmp(cbkData, ud.cbk.cbData{val})
  set(ud.cbk.fcnList, 'String', list);
  % update the callback function cache data
  ud.cbk.cbData{val} = cbkData;
  
  set(hdl, 'UserData', ud);
end
toggleApply(ud.applyButton);
  
% end doCbkEditFocusLost


% Function: doCbkEditPromptUpdate ==============================================
% Abstract:
%   Update callback edit field's prompt to reflect the selected callback
%   function's name.
%
function doCbkEditPromptUpdate(fcnList, fcnEditPrompt);
  
list = get(fcnList, 'String');
val  = get(fcnList, 'Value');

if ~isempty(list)
  list{val} = strrep(list{val}, '*', '');
  set(fcnEditPrompt, 'String', ...
                    sprintf('Content of callback function: "%s"', ...
                            deblank(list{val})));
else
  set(fcnEditPrompt, 'String', 'Content of callback function: ');
end

% end doCbkEditPromptUpdate


% Function: doCbkFcnSelect =====================================================
% Abstract:
%   Select callback function and get its content.
% 
function cbkFcnStr = doCbkFcnSelect(fcnList, cbData)

cbkFcnStr = {''};

list = get(fcnList, 'String');
val  = get(fcnList, 'Value');

if ~isempty(list) & val > 0
  if ~isempty(cbData{val})
    cbkFcnStr = cbData{val};
  end 
end

% end doCbkFcnSelect


% Function: doCbkSave ==========================================================
% Abstract:
%   Save all callback functions for this block.
%
function doCbkSave(fcnList, evd)

hdl = get(fcnList, 'Parent');
ud = get(hdl, 'UserData');

list = get(fcnList, 'String');
val  = get(fcnList, 'value');

setprmStr = {};
for i=1:length(ud.cbk.cbData)
  localListStr = strrep(list{i}, '*', '');
  if iscell(ud.cbk.cbData{i})
    setprmStr([end+1 end+2]) = {localListStr, ud.cbk.cbData{i}{:}};
  else
    setprmStr([end+1 end+2]) = {localListStr, ud.cbk.cbData{i}};
  end
  if ~isempty(ud.cbk.cbData{i})
    % if the cbData is not empty, we have to add the "*"
    list{i} = [localListStr '*'];
  else
    % if the cbData is empty, we have to remove the "*"
    list{i} = [localListStr];
  end
end
if ~isempty(setprmStr)
  set_param(ud.blkHdl, setprmStr{:});
end
set(fcnList, 'String', list);

% end doCbkSave


% Function: doEnableApply ======================================================
% Abstract:
%   Enable Apply button on the dialog.
%
function doEnableApply(obj, evd)

hdl = get(obj, 'Parent');
ud = get(hdl, 'UserData');

toggleApply(ud.applyButton);

% end doEnableApply


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for Bus Creator block.
%
function doHelp(helpButton, evd)

hdl = get(helpButton, 'Parent');
ud  = get(hdl, 'UserData');
helpview([docroot '/mapfiles/simulink.map'], 'blockpropertiesdialog');

% end doHelp


% Function: doOK ===============================================================
% Abstract:
%   This function is the callback function for OK button. It will apply all
%   current selection and close the dialog.
%
function doOK(okButton, evd)

hdl = get(okButton, 'Parent');
ud  = get(hdl, 'UserData');

doApply(ud.applyButton, evd);
set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

% end doOK


% Function: doResize ===========================================================
% Abstract:
%   This function will set/reset the sizes and positions for each object and
%   the main frame. This is a hand-made HG layout manager.
%   When the size is bigger than default size, extend the listbox's width and
%   height, popup menu and edit field's width, and frame's size; keep rest of
%   items' size unchanged (buttons, etc).
%   When it's smaller than its default size, resize everything.
%
function doResize(hdl, evd)

% retrieve userdata from this figure handle
ud = get(hdl, 'UserData');

set(hdl, 'Units', 'pixels');
figPos = get(hdl, 'Position');
% if the figure size is smaller than its default size, set the figure to be
% 'normalized' resize units
tmpText = uicontrol(hdl, 'style', 'text', ...
                    'fontunit', 'pixel', ...
		    'visible', 'off', ...
		    'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);

if ud.origSize ~= [0 0]
  if figPos(3) < ud.origSize(1) | figPos(4) < 450*pixelRatio
    set(hdl, 'Units', 'normalized');
    return;
  end
end

allHdls = [hdl ud.tab(4) ...
           ud.genHdls ud.attHdls ud.cbkHdls ...
           ud.okButton ud.cancelButton ud.helpButton ud.applyButton];
set(allHdls, 'Units', 'characters');

offset    = 1;
btnWidth  = 12;
btnHeight = 1.75;
txtMove   = .5;

figPos=get(hdl, 'Position');
sheetPos = get(ud.tab(4), 'Position');

% start from bottom row to top
posApply     = [figPos(3)-offset-btnWidth ...
                (sheetPos(2)-btnHeight)/2 ...
                btnWidth btnHeight];
posHelp      = posApply;
posHelp(1)   = [posApply(1)-2*offset-btnWidth]; 
posCancel    = posHelp;
posCancel(1) = [posHelp(1)-2*offset-btnWidth]; 
posOK        = posCancel;
posOK(1)     = [posCancel(1)-2*offset-btnWidth]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%
% general properties tab %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% position for infoFrame/Title/Text
posGenInfoFrame = [sheetPos(1)+offset sheetPos(2)+sheetPos(4)-7*offset ...
                sheetPos(3)-2*offset 5.5*offset];
strExt = get(ud.gen.infoTitle, 'Extent');
posGenInfoTitle = [posGenInfoFrame(1)+2*offset ...
                   posGenInfoFrame(2)+posGenInfoFrame(4)-strExt(4)/2 ...
                   strExt(3:4)];
posGenInfoText = [posGenInfoFrame(1)+offset posGenInfoFrame(2)+.2 ...
                  posGenInfoFrame(3)-2*offset posGenInfoFrame(4)-offset];

% field frame
posGenFrame = [posGenInfoFrame(1) sheetPos(2)+offset ...
               posGenInfoFrame(3) posGenInfoFrame(2)-sheetPos(2)-2*offset];

% description prompt and its edit field
strExt = get(ud.gen.descPrompt, 'extent');
posDescPrompt = [posGenFrame(1)+offset ...
                 posGenFrame(4)+posGenFrame(2)-txtMove-strExt(4) ...
                 strExt(3:4)];

strExt = get(ud.gen.descEdit, 'extent');
posDescEdit = [posDescPrompt(1) ...
               posDescPrompt(2)-3*btnHeight ...
               posGenFrame(3)-2*offset 3*btnHeight];

% priority prompt and edit field
strExt = get(ud.gen.prioPrompt, 'extent');
posPrioPrompt = [posGenFrame(1)+offset ...
                 posDescEdit(2)-txtMove-strExt(4) ...
                 strExt(3:4)];

strExt = get(ud.gen.prioEdit, 'extent');
posPrioEdit = [posPrioPrompt(1) ...
               posPrioPrompt(2)-btnHeight ...
               posGenFrame(3)-2*offset btnHeight];

% tag prompt and edit field
strExt = get(ud.gen.tagPrompt, 'extent');
posTagPrompt = [posGenFrame(1)+offset ...
                posPrioEdit(2)-txtMove-strExt(4) ...
                strExt(3:4)];

strExt = get(ud.gen.tagEdit, 'extent');
posTagEdit = [posTagPrompt(1) ...
              posTagPrompt(2)-btnHeight ...
              posGenFrame(3)-2*offset btnHeight];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% attributes properties tab %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
posAttInfoFrame = [sheetPos(1)+offset sheetPos(2)+sheetPos(4)-9*offset ...
                   sheetPos(3)-2*offset 7.5*offset];
strExt = get(ud.gen.infoTitle, 'Extent');
posAttInfoTitle = [posAttInfoFrame(1)+2*offset ...
                   posAttInfoFrame(2)+posAttInfoFrame(4)-strExt(4)/2 ...
                   strExt(3:4)];
posAttInfoText = [posAttInfoFrame(1)+offset posAttInfoFrame(2)+.2 ...
                  posAttInfoFrame(3)-2*offset posAttInfoFrame(4)-offset];

% field frame
posAttFrame = [posAttInfoFrame(1) sheetPos(2)+offset ...
               posAttInfoFrame(3) posAttInfoFrame(2)-sheetPos(2)-2*offset];

% attributes block prompt 
strExt = get(ud.att.blkPrompt, 'extent');
posBlkPrompt = [posAttFrame(1)+offset ...
                posAttFrame(4)+posAttFrame(2)-txtMove-strExt(4) ...
                strExt(3:4)];

% attributes block listbox
posBlkList = [posBlkPrompt(1) ...
              posAttFrame(2)+offset ...
              posAttFrame(3)/3 ...
              posAttFrame(4)-3*offset];

% append button
strExt = get(ud.att.appendButton, 'extent');
posAppendButton = [posBlkList(1)+posBlkList(3)+offset ...
                   posBlkList(2)+posBlkList(4)-strExt(4) ...
                   strExt(3:4)];

% atributes format string prompt and field
strExt = get(ud.att.fmtstrPrompt, 'extent');
posFmtStrPrompt = [posAppendButton(1)+posAppendButton(3)+offset ...
                   posBlkPrompt(2) ...
                   strExt(3:4)];

posFmtStrList = [posFmtStrPrompt(1) ...
                 posBlkList(2) ...
                 posAttFrame(3)-4*offset-posBlkList(3)-posAppendButton(3) ...
                 posBlkList(4)];

% example text area
strExt = get(ud.att.example, 'extent');
posExample = [posFmtStrList(1) ...
              posBlkList(2) ...
              strExt(3:4)];

posFmtStrList(2) = posExample(2)+posExample(4)+txtMove;
posFmtStrList(4) = posFmtStrList(4)-posExample(4)-txtMove;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% callback properties tab %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
posCbkInfoFrame = [sheetPos(1)+offset sheetPos(2)+sheetPos(4)-7*offset ...
                   sheetPos(3)-2*offset 5.5*offset];
strExt = get(ud.gen.infoTitle, 'Extent');
posCbkInfoTitle = [posCbkInfoFrame(1)+2*offset ...
                   posCbkInfoFrame(2)+posCbkInfoFrame(4)-strExt(4)/2 ...
                   strExt(3:4)];
posCbkInfoText = [posCbkInfoFrame(1)+offset posCbkInfoFrame(2)+.2 ...
                  posCbkInfoFrame(3)-2*offset posCbkInfoFrame(4)-offset];

% field frame
posCbkFrame = [posCbkInfoFrame(1) sheetPos(2)+offset ...
               posCbkInfoFrame(3) posCbkInfoFrame(2)-sheetPos(2)-2*offset];

% callback function prompt and list
strExt = get(ud.cbk.fcnPrompt, 'extent');
posFcnPrompt = [posCbkFrame(1)+offset ...
                posCbkFrame(4)+posCbkFrame(2)-txtMove-strExt(4) ...
                strExt(3:4)];
posFcnList = [posFcnPrompt(1) ...
              posCbkFrame(2)+offset ...
              posCbkFrame(3)/3 ...
              posCbkFrame(4)-3*offset];

% callback function edit prompt and field
strExt = get(ud.cbk.fcnEditPrompt, 'extent');
posFcnEditPrompt = [posFcnList(1)+posFcnList(3)+offset ...
                    posFcnPrompt(2) ...
                    posCbkFrame(3)-3*offset-posFcnList(3) ...
                    strExt(4)];

posFcnEdit = [posFcnEditPrompt(1) ...
              posFcnList(2) ...
              posCbkFrame(3)-3*offset-posFcnList(3) ...
              posFcnList(4)];

% set the calculated position
set(ud.gen.infoFrame,    'Position', posGenInfoFrame);
set(ud.gen.infoTitle,    'Position', posGenInfoTitle);
set(ud.gen.infoText,     'Position', posGenInfoText);
set(ud.gen.frame,        'Position', posGenFrame);
set(ud.gen.descPrompt,   'Position', posDescPrompt);
set(ud.gen.descEdit,     'Position', posDescEdit);
set(ud.gen.prioPrompt,   'Position', posPrioPrompt);
set(ud.gen.prioEdit,     'Position', posPrioEdit);
set(ud.gen.tagPrompt,    'Position', posTagPrompt);
set(ud.gen.tagEdit,      'Position', posTagEdit);
set(ud.att.infoFrame,    'Position', posAttInfoFrame);
set(ud.att.infoTitle,    'Position', posAttInfoTitle);
set(ud.att.infoText,     'Position', posAttInfoText);
set(ud.att.frame,        'Position', posAttFrame);
set(ud.att.blkPrompt,    'Position', posBlkPrompt);
set(ud.att.blkList,      'Position', posBlkList);
set(ud.att.appendButton, 'Position', posAppendButton);
set(ud.att.fmtstrPrompt, 'Position', posFmtStrPrompt);
set(ud.att.fmtstrList,   'Position', posFmtStrList);
set(ud.att.example,      'Position', posExample);
set(ud.cbk.infoFrame,    'Position', posCbkInfoFrame);
set(ud.cbk.infoTitle,    'Position', posCbkInfoTitle);
set(ud.cbk.infoText,     'Position', posCbkInfoText);
set(ud.cbk.frame,        'Position', posCbkFrame);
set(ud.cbk.fcnPrompt,    'Position', posFcnPrompt);
set(ud.cbk.fcnList,      'Position', posFcnList);
set(ud.cbk.fcnEditPrompt,'Position', posFcnEditPrompt);
set(ud.cbk.fcnEdit,      'Position', posFcnEdit);
set(ud.okButton,         'Position', posOK);
set(ud.cancelButton,     'Position', posCancel);
set(ud.helpButton,       'Position', posHelp);
set(ud.applyButton,      'Position', posApply);

set(allHdls, 'Units', 'normalized');

% end doResize


% Fucntion: doTabSwitch ========================================================
% Abstract:
%   Callback function to switch tab.
%
function doTabSwitch(varargin)
if nargin == 5  
  newTabName = varargin{1};
  newTabNum  = varargin{2};
  oldTabName = varargin{3};
  oldTabNum  = varargin{4};
  hdl        = varargin{5};

  ud = get(hdl, 'UserData');
  blkHdl = ud.blkHdl;
  
elseif nargin == 2
  blkHdl    = varargin{1};
  newTabNum = varargin{2};
  
  hdl = get_param(blkHdl, 'PropertiesDialogFigure');
  ud = get(hdl, 'UserData');
  
  if strcmp(get(ud.gen.infoFrame, 'Visible'), 'on')
    oldTabNum = 1;
  elseif strcmp(get(ud.att.infoFrame, 'Visible'), 'on')
    oldTabNum = 2;
  elseif strcmp(get(ud.cbk.infoFrame, 'Visible'), 'on')
    oldTabNum = 3;
  else
    oldTabNum = 1;
  end
end
  
if newTabNum == oldTabNum
  return;
end

if newTabNum > 3
  error('Internal error: no such tab panel on this dialog.');
  return;
end

set(ud.genHdls, 'visible', onoff(newTabNum==1));
set(ud.attHdls, 'visible', onoff(newTabNum==2));
set(ud.cbkHdls, 'visible', onoff(newTabNum==3));

if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set_param(ud.blkHdl, 'PropertiesDialogTabNum', newTabNum);
end

% end doTabSwitch


% Function: doUpdateName =======================================================
% Abstract:
%   This function will update block dialog's title name according to block's
%   name change.
%
function doUpdateName(blkHdl)

hdl = get_param(blkHdl, 'PropertiesDialogFigure');

if hdl ~= -1
  ud  = get(hdl, 'UserData');
  set(hdl, 'Name', ['Block Properties: ' get_param(blkHdl, 'name')]);
  ud.blkHdl = blkHdl;
  set(hdl, 'UserData', ud);
  if strcmp(get_param(blkHdl, 'LinkStatus'), 'none')
    set_param(blkHdl, 'PropertiesDialogFigure', hdl);
  end
end

% end doUpdateName


% Function: deleteFcn ==========================================================
% Abstract: 
%   Called when the dialog figure is deleted.
%
function deleteFcn(fig, evd)

ud = get(fig, 'UserData');
try
  doClose(ud.blkHdl);
catch
  close(fig);
end

% end deleteFcn


% Function: getDynamicBlkParamStr ==============================================
% Abstract:
%   This function will return a list of block callback functions and useful 
%   parameters used by block annotation strings.
%
function paramsStr = getDynamicBlkParamStr(blkHdl)

prm       = get_param(blkHdl, 'ObjectParameters');
prmfields = fieldnames(prm);

paramsStr.cbk.fcns   = '';
paramsStr.cbk.temp   = '';
paramsStr.cbk.cbData = {};
paramsStr.att = '';

for i=1:length(prmfields)
  if length(prmfields{i}) > 3 & ...
        ~isempty(findstr(prmfields{i}(end-2:end), 'Fcn')) & ...
        strcmp(prmfields{i}, 'ErrorFcn') == 0
    if ~isempty(get_param(blkHdl, prmfields{i}))
      paramsStr.cbk.fcns = [paramsStr.cbk.fcns; {[prmfields{i} '*']}];
    else
      paramsStr.cbk.fcns = [paramsStr.cbk.fcns; {[prmfields{i}]}];
    end
    paramsStr.cbk.temp   = [paramsStr.cbk.temp; {[prmfields{i}]}];
    paramsStr.cbk.cbData = ...
        [paramsStr.cbk.cbData; {get_param(blkHdl, prmfields{i})}];
  else
    if (length(prmfields{i})>4 & ...
        ((strcmp(prmfields{i}(1:4), 'Mask') & ...
          ~strcmp(prmfields{i}, 'MaskType')) | ...
         strcmp(prmfields{i}(1:4), 'Port') | ...
         strcmp(prmfields{i}(1:4), 'Font')) ...
        ) | ...
          (length(prmfields{i})>3 & strcmp(prmfields{i}(1:3), 'RTW')) | ...
          (length(prmfields{i})>7 & strcmp(prmfields{i}(1:7), 'ExtMode')) | ...
          (length(prmfields{i})>5 & strcmp(prmfields{i}(1:5), 'Paper')) | ...
          (length(prmfields{i})>7 & strcmp(prmfields{i}(1:7), 'Current')) | ...
          (length(prmfields{i})>12 & ...
           strcmp(prmfields{i}(1:12), 'CompiledPort')) | ...
          (length(prmfields{i})>12 & ...
           strcmp(prmfields{i}(1:12), 'ModelBrowser') ...
           ) | ...
          strcmp(prmfields{i}, 'Position') | ...
          strcmp(prmfields{i}, 'AttributesFormatString') | ...
          strcmp(prmfields{i}, 'UserData') | ...
          strcmp(prmfields{i}, 'DialogParameters') | ...
          strcmp(prmfields{i}, 'CompiledSampleTime') | ...
          strcmp(prmfields{i}, 'Blocks') | ...
          strcmp(prmfields{i}, 'Lines') | ...
          strcmp(prmfields{i}, 'ModelParamTableInfo') | ...
          strcmp(prmfields{i}, 'Location') | ...
          strcmp(prmfields{i}, 'Open') | ...
          strcmp(prmfields{i}, 'ReferencedWSVars') | ...
          strcmp(prmfields{i}, 'ScrollbarOffset') | ...
          strcmp(prmfields{i}, 'ScreenColor') | ...
          strcmp(prmfields{i}, 'ZoomFactor') | ...
          strcmp(prmfields{i}, 'ReportName') | ...
          strcmp(prmfields{i}, 'InputSignalNames') | ...
          strcmp(prmfields{i}, 'OutputSignalNames') | ...
          strcmp(prmfields{i}, 'Selected')

      % do nothing
      continue;
    else
      paramsStr.att = [paramsStr.att; {['%<' prmfields{i} '>']}];
    end
  end
end

% sort callback functions string
[paramsStr.cbk.temp, idx] = sort(paramsStr.cbk.temp);
paramsStr.cbk.fcns   = paramsStr.cbk.fcns(idx);
paramsStr.cbk.cbData = paramsStr.cbk.cbData(idx);

% sort attributes tokens
paramsStr.att = sort(paramsStr.att);

% end getDynamicBlkParamStr


% Function: openDialog =========================================================
% Abstract:
%   Function to create the block dialog for the selected Data Store
%   Read/Write block if doesn't have one, or refresh the associated block
%   dialog and make it visible if it does.
%
function hdl = openDialog(blkHdl)

% Check to see if block has a dialog
updateDataOnly = 0;
hdl = get_param(blkHdl, 'PropertiesDialogFigure');
if ~isempty(hdl) & ishandle(hdl) & hdl ~= -1
  % we need to update the dialog with most recent data, i.e., do get_param on 
  % all fields
  updateParamFields(blkHdl, hdl);
  
  % show the dialog now
  figure(hdl);
  
  updateDataOnly = 1;
end

% If there is no dialog associated with this block, we have to create one
if ~updateDataOnly
  hdl = createDialog(blkHdl);
end

ud = get(hdl, 'UserData');
UiControls = [ud.attHdls'; ud.genHdls'; ud.cbkHdls'; ud.okButton];
if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set(UiControls, 'enable', 'on');
  set_param(blkHdl, 'PropertiesDialogFigure', hdl);
else
  set(UiControls, 'enable', 'off');
end

% Show the dialog
set(hdl, 'visible', 'on');

% end openDialog


% Function: updateParamFields ==================================================
% Abstract:
%   This function will be called when the dialog is re-opened.
%
function updateParamFields(blkHdl, hdl)
  
ud = get(hdl, 'UserData');
  
% General Tab
set(ud.gen.descEdit, 'string',  ...
                  get_param(blkHdl,'Description'));
set(ud.gen.prioEdit, 'string', get_param(blkHdl,'Priority'));
set(ud.gen.tagEdit, 'string', get_param(blkHdl,'Tag'));

% Block Annotation Tab
set(ud.att.fmtstrList, 'string', retrieveAttributesFormatStr(blkHdl));

% Callbacks Tab
list = get(ud.cbk.fcnList, 'string');
for i=1:length(ud.cbk.cbData)
  localListStr = strrep(list{i}, '*', '');
  fcn = get_param(blkHdl, localListStr);
  if ~isempty(fcn)
    % if the cbData is not empty, we have to add the "*"
    list{i} = [localListStr '*'];
  else
    % if the cbData is empty, we have to remove the "*"
    list{i} = [localListStr];
  end
  ud.cbk.cbData{i} = fcn;
end
set(ud.cbk.fcnList, 'string', list);
set(ud.cbk.fcnEdit, 'string', doCbkFcnSelect(ud.cbk.fcnList, ud.cbk.cbData));

% update user data
set(hdl, 'UserData', ud);

% end updateParamFields
  
  
% Function: returnKeyOK ========================================================
% Abstract:
%   This function will be called when user use keyboard to enter command. Now
%   it only does one thing: when it's from Enter key, call doOK function.
%
function returnKeyOK(fig, evd)

ud = get(fig, 'UserData');

if ~isempty(get(fig, 'CurrentChar')) 	% unix keyboard has an empty key
  if (abs(get(fig, 'CurrentChar')) == 13)
    if strcmp(get(ud.okButton, 'Enable'), 'on')
      doOK(ud.okButton, []);
    end
  end
end

% end returnKeyOK


% Function: toggleApply ========================================================
% Abstract:
%   This function toggles the Apply button between ENABLE ON/OFF.
%
function toggleApply(varargin)

if nargin == 1
  set(varargin{1}, 'Enable', 'on');
elseif nargin == 2
  set(varargin{1}, 'Enable', varargin{2});
end
  
% end toggleApply


% Function: createAttributesFormatStr ==========================================
% Abstract:
%   This function creates the correct format for user entered attributes format 
%   string.
%
function formattedStr = createAttributesFormatStr(str)

[row, col] = size(str);

formattedStr = '';
for i=1:row
  if ~isempty(deblankall(str(i,:)))
    formattedStr = [formattedStr, deblankall(str(i,:))];
    if i ~= row 
      formattedStr = [formattedStr, '\n'];
    end
  end
end

% end createAttributesFormatStr


% Function: retrieveAttributesFormatStr ========================================
% Abstract:
%   This function process the block's attributes format string so it will be 
%   displayed in the listbox in a nice format.
%
function formattedStr = retrieveAttributesFormatStr(blkHdl)

str = strrep(get_param(blkHdl, 'AttributesFormatString'), '%', '%%');

formattedStr = sprintf(str);

% end retrieveAttributesFormatStr


% [EOF]
