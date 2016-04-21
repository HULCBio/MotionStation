function varargout = sldsmemdlg(varargin)
% Data Store Memory block   Creates block dialog for Data Store Memory block.
% 
%   It provides the following functionalities for user:
%     - view and set the Data Store name;
%     - set initial value;
%     - list all corresponding Data Store Write and Data Store Read blocks;
%     - set RTW storage class and type qualifier;
%
%   This is an internal Simulink function.
%
%   See also sldatastoredlg.
  
%   Jun Wu, 10/30/2001
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2004/04/15 00:32:33 $

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
    error('Simulink:Dialog', ...
          sprintf(['Invalid command "' varargin{1} ...
                   '" for Data Store ', blkType(10:end), ...
                   ' block parameter dialog.']));
  end

 case 3,
  if strcmp(varargin{1}, 'get')
    blkHdl = varargin{2};
    hdl    = get_param(blkHdl, 'Figure');
    ud     = get(hdl, 'UserData');
    varargout = {};
    switch varargin{3}
     case 0 % DataStoreName
      varargout{1} = sl('deblankall', get(ud.dsNameEdit, 'String'));
     case 1 % initial value
      varargout{1} = sl('deblankall', get(ud.initValEdit, 'String'));
     case 2 % RTW storage class
      varargout{1} = get(ud.rtwStorageClassPopup, 'Value')-1;
     case 3 % RTW type qualifier
      if strcmp(get(ud.rtwTypeQualifierEdit, 'Enable'), 'on')
        varargout{1} = sl('deblankall', get(ud.rtwTypeQualifierEdit, 'String'));
      else
        varargout{1} = '';
      end
     case 4 % vector param checkbox
      varargout{1} = get(ud.vecParam1DChkbx, 'Value');
    end
    return;
  end
  
 case 4
  if strcmp(varargin{1}, 'set')
    blkHdl = varargin{2};
    hdl    = get_param(blkHdl, 'Figure');
    ud     = get(hdl, 'UserData');
    switch varargin{4}
     case 0 % DataStoreName
      set(ud.dsNameEdit, 'String', sl('deblankall', varargin{3}));
      doEnableApplyButton(ud.dsNameEdit, []);
     case 1 % initial value
      set(ud.initValEdit, 'String', sl('deblankall', varargin{3}));
      doEnableApplyButton(ud.initValEdit, []);
     case 2 % RTW storage class
      set(ud.rtwStorageClassPopup, 'Value', varargin{3}+1);
      doRTWStorageClass(ud.rtwStorageClassPopup, []);
     case 3 % RTW type qualifier
      if strcmp(get(ud.rtwTypeQualifierEdit, 'Enable'), 'on')
        set(ud.rtwTypeQualifierEdit, 'String', sl('deblankall', varargin{3}));
        doEnableApplyButton(ud.rtwTypeQualifierEdit, []);
      else
        set_param(blkHdl, 'Figure', -1);
        try
          set_param(blkHdl, 'RTWStateStorageTypeQualifier', varargin{3});
        catch
          errordlg(lasterr);
        end
        set_param(blkHdl, 'Figure', hdl);
      end
     case 4 % vector param checkbox
      set(ud.vecParam1DChkbx, 'Value', varargin{3});
      doEnableApplyButton(ud.vecParam1DChkbx, []);
    end
    return;
  end
  
 otherwise,
  error(['Invalid number of arguments ', num2str(nargin)]);
end

if nargout
  varargout{1} = hdl;			% output bogus handle
end

% end sldsmemdlg


% Function: createDialog =======================================================
% Abstract:
%   This function constructs the graphical objects for the dialog.
%
function hdl = createDialog(blkHdl)

% keep the background color consistent for each uicontrol objects
objBGColor = get(0,'defaultuicontrolbackgroundcolor');

%
% create the figure for the block dialog
%
dialogPos = [1 1 440 550];
hdl = figure( ...
    'numbertitle',      'off',...
    'name',             ['Block Parameters: ' get_param(blkHdl, 'name')], ...
    'menubar',          'none', ...
    'visible',          'off', ...
    'HandleVisibility', 'callback', ...
    'IntegerHandle',    'off', ...
    'color',            objBGColor, ...
    'Units',            'pixels', ...
    'Position',         dialogPos, ...
    'DoubleBuffer',     'on', ...
    'Resize',           'on' ...
    );

tmpText = uicontrol(hdl, 'style', 'text', ...
                    'fontunit', 'pixel', ...
		    'visible', 'off', ...
		    'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
dialogPos(3:4) = dialogPos(3:4)*pixelRatio;
set(hdl, 'Position', dialogPos);

% 'Enter' key will be same as clicking on 'OK' button
set(hdl, 'KeyPressFcn', {@returnKeyOK});
set(hdl, 'DeleteFcn',   {@deleteFcn});

% register block handle and this figure handle in figure handle's UserData
ud.blkHdl = blkHdl;
ud.hdl = hdl;

ud.showAdditionalParams = strcmp(get_param(blkHdl, 'ShowAdditionalParam'), ...
                                 'on');
ud.datatypeViaDialog = ~isempty(findstr(get_param(blkHdl, 'DataType'), ...
                                        'Specify'));
% create description frame
ud.desc = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.descTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'string',          'Data Store Memory');

descStr = get_param(blkHdl, 'BlockDescription');
ud.descText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              sprintf(descStr));

% create Parameters frame and the tile
ud.param = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.paramTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'string',          'Parameters');

% create "Data store name" field
ud.dsNamePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'string',          'Data store name: ');

ud.dsNameEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              'A', ...
    'callback',            {@doEnableApplyButton});

% Data store Read/Write blocks list and prompt
ud.dsListPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'horizontalalignment', 'left', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Data store write(W) and read(R) blocks: ');

ud.cmenu = uicontextmenu('Parent', hdl);
uiItem = uimenu(ud.cmenu, ...
                'Label',     'Refresh list ', ...
                'callback',  {@doRefreshSrcList});
uiItem = uimenu(ud.cmenu, ...
                'Label',     'Remove highlighting ', ...
                'callback',  {@doUnHiliteBlocks});
ud.dsList = uicontrol(...
    hdl, ...
    'style',           'listbox', ...
    'backgroundcolor', objBGColor, ...
    'String',          '', ...
    'Tooltip', ...
    sprintf(['Double click to locate the selected block.\n'...
            'Right-click to refresh this list.']), ...
    'uicontextmenu',   ud.cmenu, ...
    'callback',        {@doDSSrcSelection});

% create 'Initial value' field
ud.initValPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'horizontalalignment', 'left', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Initial value: ');

ud.initValEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'String',              '0', ...
    'callback',            {@doEnableApplyButton});

% create RTW storage class popup and its prompt
ud.rtwStorageClassPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'horizontalalignment', 'left', ...
    'backgroundcolor', objBGColor, ...
    'string',          'RTW storage class: ');

ud.rtwStorageClassPopup = uicontrol(...
    hdl, ...
    'style',               'Popup', ...
    'horizontalalignment', 'left', ...
    'string',              ...
    'Auto|ExportedGlobal|ImportedExtern|ImportedExternPointer', ...
    'callback',            {@doRTWStorageClass});
if strcmp(computer, 'PCWIN')
  set(ud.rtwStorageClassPopup, 'backgroundcolor', 'white');
end

% create RTW type qualifier edit field and prompt
ud.rtwTypeQualifierPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'Enable',          'off', ...
    'string',          'RTW type qualifier: ');

ud.rtwTypeQualifierEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'string',              '', ...
    'Enable',              'off', ...
    'horizontalalignment', 'left', ...
    'callback',            {@doEnableApplyButton});

% 1-D vector switch checkbox
ud.vecParam1DChkbx = uicontrol(...
    hdl, ...
    'style',               'checkbox', ...
    'horizontalalignment', 'left', ...
    'String',              'Interpret vector parameters as 1-D', ...
    'callback',            {@doEnableApplyButton});

% Create "Show additional parameter" dialog checkbox
ud.showAdditionalParamsChx = uicontrol(...
    hdl, ...
    'Style',           'checkbox', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'center', ...
    'String',          ...
    '---------------- Show additional parameters ---------------', ...
    'Value',           ud.showAdditionalParams, ...
    'Callback',        {@doShowAdditionalParams, blkHdl});

% Data type prompt and popup menu
dataTypeList = ['auto|double|single|int8|uint8|int16|uint16' ...
                '|int32|uint32|boolean|Specify via dialog'];
ud.dataTypePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'Visible',          sl('onoff',ud.showAdditionalParams), ...
    'string',          'Data store data type mode: ');
ud.dataTypePopup = uicontrol(...
    hdl, ...
    'style',               'Popup', ...
    'horizontalalignment', 'left', ...
    'string',              dataTypeList, ...
    'Visible',             sl('onoff',ud.showAdditionalParams), ...
    'callback',            {@doDataTypeSelection});
if strcmp(computer, 'PCWIN')
  set(ud.dataTypePopup, 'backgroundcolor', 'white');
end

% Output data type edit field and prompt
if ud.showAdditionalParams && ud.datatypeViaDialog
  dtVisible = 'on';
else
  dtVisible = 'off';
end
ud.outputDTPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'Enable',          'on', ...
    'horizontalalignment', 'left', ...
    'Visible',         dtVisible, ...
    'string',          ...
    'Data store data type (e.g., sfix(16), uint(8), float(''single'')): ');
ud.outputDTEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'string',              'sfix(16)', ...
    'Enable',              'on', ...
    'Visible',             dtVisible, ...
    'horizontalalignment', 'left', ...
    'callback',            {@doOutputDataTypeInput});

% Output scaling value prompt and edit field
str = get_param(blkHdl, 'OutDataType');
le = lasterr;
try
  val = eval(str);
catch
  val = [];
  lasterr(le);
end
if ~isempty(val) && isfield(val, 'Class') && strcmp(val.Class, 'FIX')
  ud.showOutputScale = true;
else
  ud.showOutputScale = false;
end
if ~ud.showOutputScale
  dtVisible = 'off';
end
ud.outputScalePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'horizontalalignment', 'left', ...
    'Enable',          'on', ...
    'Visible',         dtVisible, ...
    'string',          ...
    'Data store scaling value (Slope, e.g. 2^-9 or [Slope Bias], e.g. [1.25 3]): ');
ud.outputScaleEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'string',              '2^0', ...
    'horizontalalignment', 'left', ...
    'Enable',              'on', ...
    'Visible',             dtVisible, ...   ...
    'callback',            {@doEnableApplyButton});

% signal type prompt and popup
ud.signalTypePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'horizontalalignment', 'left', ...
    'backgroundcolor', objBGColor, ...
    'Enable',          'on', ...
    'Visible',         sl('onoff',ud.showAdditionalParams), ...
    'string',          'Signal type: ');
ud.signalTypePopup = uicontrol(...
    hdl, ...
    'style',               'Popup', ...
    'horizontalalignment', 'left', ...
    'string',              'auto|real|complex', ...
    'Visible',             sl('onoff',ud.showAdditionalParams), ...
    'callback',            {@doEnableApplyButton});
if strcmp(computer, 'PCWIN')
  set(ud.signalTypePopup, 'backgroundcolor', 'white');
end

% Create the "standard" dialog buttons 
ud.okButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'String',          'OK', ...
    'Callback',        {@doOK});

ud.cancelButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'String',          'Cancel', ...
    'Callback',        {@doCancel});

ud.helpButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'Backgroundcolor', objBGColor, ...
    'Enable',          'on', ...
    'String',          'Help', ...
    'Callback',        {@doHelp});

ud.applyButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'Enable',          'off', ...
    'String',          'Apply', ...
    'Callback',        {@doApply});

% store these objects information in dialog handle's userdata
ud.origSize   = [0 0];
ud.hilitedBlk.blkHdl = -1;              % block handle of hilited block
ud.hilitedBlk.origHL = 'none';          % cache its hilited theme

set(hdl, 'UserData', ud);

% setting up the proper size for this dialog
doResize(hdl, []);

% adjust the dialog's position according to block's position
set(hdl, 'Units', 'pixels');
dialogPos = get(hdl,'Position');
bdPos     = get_param(get_param(blkHdl,'Parent'), 'Location');
blkPos    = get_param(blkHdl, 'Position');
bdPos     = [bdPos(1:2)+blkPos(1:2) bdPos(1:2)+blkPos(1:2)+blkPos(3:4)];

hgPos        = sl('rectconv', bdPos,'hg');
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
    'UserData',  ud);

% update its parameters fields
set(ud.dsNameEdit, 'String', get_param(blkHdl, 'DataStoreName'));
set(ud.initValEdit, 'String', get_param(blkHdl, 'InitialValue'));
set(ud.rtwStorageClassPopup, ...
    'Value', getPopupMatchingValue(ud.rtwStorageClassPopup, ...
                                   get_param(blkHdl, ...
                                             'RTWStateStorageClass')));
if get(ud.rtwStorageClassPopup, 'Value') > 1
  set(ud.rtwTypeQualifierEdit, 'String', ...
                    get_param(blkHdl, 'RTWStateStorageTypeQualifier'));
  set(ud.rtwTypeQualifierPrompt, 'Enable', 'on');
  set(ud.rtwTypeQualifierEdit, 'Enable', 'on');
end
set(ud.vecParam1DChkbx, 'Value',  ...
                  sl('onoff', get_param(blkHdl, 'VectorParams1D')));
set(ud.dataTypePopup, 'Value', ...
                  getPopupMatchingValue(ud.dataTypePopup, ...
                                        get_param(blkHdl, 'DataType')));
set(ud.outputDTEdit, 'String', get_param(blkHdl, 'OutDataType'));
set(ud.outputScaleEdit, 'String', get_param(blkHdl, 'OutScaling'));
set(ud.signalTypePopup, 'Value', ...
                  getPopupMatchingValue(ud.signalTypePopup, ...
                                        get_param(blkHdl, 'SignalType')));

%
% Update the userdata only if it is a changeable block
% else show a disabled version of the gui.
%
if strcmp(get_param(blkHdl, 'LinkStatus'), 'none') && ...
      ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set_param(blkHdl, 'Figure', hdl)
else
  UiControls = [ud.dsNamePrompt; ud.dsNameEdit; ud.dsListPrompt; ud.dsList; ...
                ud.initValPrompt; ud.initValEdit; ud.rtwStorageClassPrompt; ...
                ud.rtwStorageClassPopup; ud.rtwTypeQualifierPrompt; ...
                ud.rtwTypeQualifierEdit; ud.vecParam1DChkbx; ...
                ud.showAdditionalParamsChx; ud.dataTypePrompt; ud.dataTypePopup; ...
                ud.outputDTPrompt; ud.outputDTEdit; ud.outputScalePrompt; ...
                ud.outputScaleEdit; ud.signalTypePrompt; ud.signalTypePopup; ...
                ud.okButton; ud.applyButton];
  set(UiControls, 'enable', 'off');
end

% end createDialog


% Function: doApply ============================================================
% Abstract:
%   This function will apply all the current settings appeared on the dialog.
%
function applyNoError = doApply(applyButton, evd)

hdl = get(applyButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
ud.hilitedBlk  = doUnHiliteBlocks(ud.hilitedBlk, []);
errmsg = '';
lasterr('');

applyNoError = 1;
set_param(ud.blkHdl, 'Figure', -1);
prevParamOpt = {'DataStoreName', get_param(ud.blkHdl, 'DataStoreName'), ...
                'InitialValue', get_param(ud.blkHdl, 'InitialValue'), ...
                'VectorParams1D', get_param(ud.blkHdl, 'VectorParams1D'), ...
                'RTWStateStorageClass', ...
                get_param(ud.blkHdl, 'RTWStateStorageClass'), ...
                'RTWStateStorageTypeQualifier', ...
                get_param(ud.blkHdl, 'RTWStateStorageTypeQualifier'), ...
                'ShowAdditionalParam', ...
                get_param(ud.blkHdl, 'ShowAdditionalParam'), ...
                'DataType', get_param(ud.blkHdl, 'DataType'), ...
                'OutDataType', get_param(ud.blkHdl, 'OutDataType'), ...
                'OutScaling', get_param(ud.blkHdl, 'OutScaling'), ...
                'SignalType', get_param(ud.blkHdl, 'SignalType') };

paramOpt = {'DataStoreName', sl('deblankall', get(ud.dsNameEdit, 'String')), ...
            'InitialValue', sl('deblankall', get(ud.initValEdit, 'String')), ...
            'VectorParams1D', sl('onoff', get(ud.vecParam1DChkbx, 'Value')), ...
            'RTWStateStorageClass', ...
            getPopupCurrentSelectionStr(ud.rtwStorageClassPopup), ...
            'ShowAdditionalParam', ...
            sl('onoff', get(ud.showAdditionalParamsChx, 'Value')), ...
            'DataType', getPopupCurrentSelectionStr(ud.dataTypePopup), ...
            'OutDataType', sl('deblankall', get(ud.outputDTEdit, 'String')), ...
            'OutScaling', sl('deblankall', get(ud.outputScaleEdit,'String')), ...
            'SignalType', getPopupCurrentSelectionStr(ud.signalTypePopup)};

if isempty(findstr(lower(...
    getPopupCurrentSelectionStr(ud.rtwStorageClassPopup)), 'auto'))
  paramOpt = [paramOpt, ...
              {'RTWStateStorageTypeQualifier'}, ...
              {sl('deblankall', get(ud.rtwTypeQualifierEdit, 'String'))}];
else
  paramOpt = [paramOpt, {'RTWStateStorageTypeQualifier'}, {''}];
end

try
  % apply set_param
  set_param(ud.blkHdl, paramOpt{:});
catch
  applyNoError = 0;
  try
    % recover the parameter
    set_param(ud.blkHdl, prevParamOpt{:});
  catch
  end
  errmsg = [errmsg; {lasterr}];
end
  
% recover the Figure handle setting
set_param(ud.blkHdl, 'Figure', hdl);

if applyNoError
  try
    % update Data Store Read/Write blocks list
    doRefreshSrcList(ud.dsNameEdit, []);
  catch
    errordlg(lasterr);
  end

  % switch applyButton
  toggleApply(applyButton, 'off');
end

set(hdl, 'UserData', ud);
if ~isempty(errmsg)
  errordlg(errmsg, 'Error message: Data Store Memory Block', 'modal');
end

% end doApply


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change on it.
%
function doCancel(cancelButton, evd)

hdl = get(cancelButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk, []);

set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

if ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  set_param(ud.blkHdl, 'Figure', -1);
  set(ud.dsNameEdit, 'String', get_param(ud.blkHdl, 'DataStoreName'));
  set(ud.initValEdit, 'String', get_param(ud.blkHdl, 'InitialValue'));
  set(ud.vecParam1DChkbx, 'Value',  ...
                    sl('onoff', get_param(ud.blkHdl, 'VectorParams1D')));
  set(ud.rtwStorageClassPopup, 'Value', ...
                    getPopupMatchingValue(ud.rtwStorageClassPopup, ...
                                          get_param(ud.blkHdl, ...
                                                    'RTWStateStorageClass')));
  set(ud.rtwTypeQualifierEdit, 'String', ...
                    get_param(ud.blkHdl, 'RTWStateStorageTypeQualifier'));
  set(ud.showAdditionalParamsChx, 'Value', ...
                    sl('onoff', get_param(ud.blkHdl, 'ShowAdditionalParam')));
  set(ud.dataTypePopup, 'Value', ...
                    getPopupMatchingValue(ud.dataTypePopup, ...
                                          get_param(ud.blkHdl, 'DataType')));
  set(ud.outputDTEdit, 'String', get_param(ud.blkHdl, 'OutDataType'));
  set(ud.outputScaleEdit, 'String', get_param(ud.blkHdl, 'OutScaling'));
  set(ud.signalTypePopup, 'Value', ...
                    getPopupMatchingValue(ud.signalTypePopup, ...
                                          get_param(ud.blkHdl, 'SignalType')));
  set_param(ud.blkHdl, 'Figure', hdl);
  warning(warningState);
end

% end doCancel


% Function: doClose ============================================================
% Abstract:
%   This function will be called when the DS MEMORY block is vanished.
%
function doClose(blkHdl)

if get_param(blkHdl, 'Figure') ~= -1
  hdl = get_param(blkHdl, 'Figure');
  if ~isempty(hdl) && ishandle(hdl)
    ud  = get(hdl, 'UserData');
    
    % un-hilite_system
    ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk, []);
    
    if ~strcmp(get_param(bdroot(blkHdl), 'Lock'), 'on')
      delete(hdl);
      try
        set_param(blkHdl, 'Figure', -1);
      catch
      end
    end
  end
end
  
% end doClose


% Function: doDSSrcSelection ===================================================
% Abstract:
%   - Toggle the apply button when any item is selected
%   - Double-click will find selected READ or WRITE block
%
function doDSSrcSelection(dsList, evd)

hdl = get(dsList, 'Parent');
ud  = get(hdl, 'UserData');

if strcmp(lower(get(hdl, 'SelectionType')), 'normal')
  % normal selection callback
  listStr = get(ud.dsList, 'String');

  if ~isempty(listStr)
    % toggle apply button
    toggleApply(ud.applyButton);
  end
elseif strcmp(lower(get(hdl, 'SelectionType')), 'open')
  % double-click action, will call doFind
  doFind(dsList, []);
end

% end doDSSrcSelection


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for Data Store Memory block.
%
function doHelp(helpButton, evd)

hdl = get(helpButton, 'Parent');
ud  = get(hdl, 'UserData');
slhelp(ud.blkHdl);

% end doHelp


% Function: doFind =============================================================
% Abstract:
%   This function will find the selected Data Store block in the mode by using
%   hilite_system.
%
function doFind(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk, []);

listStr = get(ud.dsList, 'String');
% if the listbox is not empty, try to find the selected From block
if ~isempty(listStr)
  listSrc = listStr{get(ud.dsList, 'Value')};
  if ~isempty(listSrc)
    try
      % use 'find' scheme in hilite_system
      ud.hilitedBlk.origHL = get_param(listSrc(4:end), 'HiliteAncestors');
      hilite_system(listSrc(4:end), 'find');
      ud.hilitedBlk.blkHdl = listSrc(4:end);
    catch
      msg = ['Unable to find Data Store block named: "' listSrc(4:end) ...
             '". ' lasterr];
      msgbox(msg, 'Data Store Source Locating Message', 'modal');
    end
  end
end
set(hdl, 'UserData', ud);

% end doFind


% Function: doOK ===============================================================
% Abstract:
%   This function is the callback function for OK button. It will apply all
%   current selection and close the dialog.
%
function doOK(okButton, evd)

hdl = get(okButton, 'Parent');
ud  = get(hdl, 'UserData');

if doApply(ud.applyButton, evd);
  % un-hilite_system
  ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk, []);
  
  set(hdl, 'Visible', 'off');
  set(hdl, 'UserData', ud);
end

% end doOK


% Function: doRefreshSrcList ===================================================
% Abstract:
%   Refresh Data store source filed according to selected data store name.
%
function doRefreshSrcList(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');
if isempty(ud)
  % called from uimenu
  hdl = get(get(obj, 'Parent'), 'Parent');
  ud  = get(hdl, 'UserData');
end

srcName = getDSSrcBlocks(ud.blkHdl);
if get(ud.dsList, 'Value') > size(srcName, 1)
  set(ud.dsList, 'Value', 1);
end
set(ud.dsList, 'String', srcName);

% end doRefreshSrcList
  
  
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
                    'fontunit', 'pixel', 'string', 'www');
strExt = get(tmpText, 'extent');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
if ud.origSize ~= [0 0]
  if figPos(3) < ud.origSize(1) || figPos(4) < 550*pixelRatio
    %set(hdl, 'Units', 'normalized');
    %return;
  end
end

allHdls = [hdl ud.desc ud.descTitle ud.descText ud.param ud.paramTitle ...
	   ud.dsNamePrompt ud.dsNameEdit ud.dsListPrompt ud.dsList ...
           ud.initValPrompt ud.initValEdit ud.rtwStorageClassPrompt ...
           ud.rtwStorageClassPopup ud.rtwTypeQualifierPrompt ...
           ud.rtwTypeQualifierEdit ud.vecParam1DChkbx ... 
           ud.showAdditionalParamsChx, ud.dataTypePrompt, ud.dataTypePopup, ...
           ud.outputDTPrompt, ud.outputDTEdit, ud.outputScalePrompt, ...
           ud.outputScaleEdit, ud.signalTypePrompt, ud.signalTypePopup, ...
           ud.okButton ud.cancelButton ud.helpButton ud.applyButton];
set(allHdls, 'Units', 'characters');

offset    = 1;
btnWidth  = 12;
btnHeight = 1.75;
txtMove   = .5;

figPos=get(hdl, 'Position');

% start from bottom row to top
posApply     = [figPos(3)-offset-btnWidth offset btnWidth btnHeight];
posHelp      = posApply;
posHelp(1)   = posApply(1)-2*offset-btnWidth; 
posCancel    = posHelp;
posCancel(1) = posHelp(1)-2*offset-btnWidth; 
posOK        = posCancel;
posOK(1)     = posCancel(1)-2*offset-btnWidth; 

% Parameters frame
posParam      = [offset posOK(2)+posOK(4)+offset ...
		 figPos(3)-2*offset ...
		 figPos(4)+figPos(2)-posOK(4)-3*offset];

additionalHeight = 0;  
tmpText = uicontrol(hdl,'style','text', ...
                    'units','char','string','wwwwwwwwwww');
strExt = get(tmpText, 'extent');

% need to add space for two popup entries (Signal type and Data type)
addHeight1 = 2*(additionalHeight+btnHeight+offset);

% signal type prompt and popup
strExt = get(ud.signalTypePrompt, 'extent');
posSignalTypePrompt = ...
    [posParam(1)+offset ...
     posParam(2)+offset ...
     strExt(3:4)];
posSignalTypePopup = ...
    [posSignalTypePrompt(1)+posSignalTypePrompt(3)+offset ...
     posSignalTypePrompt(2) strExt(3) btnHeight];
ruler = posSignalTypePopup(2)+posSignalTypePopup(4)+txtMove;
  
if ud.datatypeViaDialog
  if ud.showOutputScale
    % need to add at least on prompt and one edit field for output scaling value
    strExt = get(ud.outputScaleEdit, 'extent');
    posOutputScaleEdit = ...
        [posParam(1)+offset ...
         ruler ...
         posParam(3)-2*offset btnHeight];
    
    strExt = get(ud.outputScalePrompt, 'extent');
    posOutputScalePrompt = ...
        [posParam(1)+offset ...
         posOutputScaleEdit(2)+posOutputScaleEdit(4) ...
         posParam(3)-2*offset strExt(4)];
    
    % compensate vertical space
    addHeight2 = posOutputScaleEdit(4) + posOutputScalePrompt(4) + txtMove;
    ruler = posOutputScalePrompt(2)+posOutputScalePrompt(4)+txtMove;
  else
    posOutputScalePrompt = [1 1 1 1];
    posOutputScaleEdit = [1 1 1 1];
    if strcmp(get(ud.outputDTEdit, 'Visible'), 'on')
      posOutputDTEdit = get(ud.outputDTEdit, 'Position');
      addHeight2 = ruler-posOutputDTEdit(2);
    else
      addHeight2 = 0;
    end
  end

  % output data type
  posOutputDTEdit = ...
      [posParam(1)+offset ...
       ruler ...
       posParam(3)-2*offset btnHeight];
  strExt = get(ud.outputDTPrompt, 'extent');
  posOutputDTPrompt = ...
      [posParam(1)+offset ...
       posOutputDTEdit(2)+posOutputDTEdit(4) ...
       posParam(3)-2*offset strExt(4)];
  
  % compensate vertical space if needed
  prevPosDTEdit = get(ud.outputDTEdit,'position');
  if posSignalTypePopup(2)+posSignalTypePopup(4)+txtMove < prevPosDTEdit(2)
    addHeight3 = 0;
  else
    addHeight3 = posOutputDTPrompt(4) + posOutputDTEdit(4) + txtMove;
  end
  ruler = posOutputDTPrompt(2)+posOutputDTPrompt(4)+txtMove;
  
  prevPosDTPopup = get(ud.dataTypePrompt, 'position');
  if ( posSignalTypePopup(2)+posSignalTypePopup(4)+...
       txtMove-prevPosDTPopup(2)<0.0001 ) ...
        || ...
        (strcmp(get(ud.dataTypePopup, 'Visible'), 'on') && ...
         strcmp(get(hdl, 'Visible'), 'on') && ...
         ud.showAdditionalParams == 0)
    addHeight1 = 0;
  end
else
  posOutputDTPrompt = [1 1 1 1];
  posOutputDTEdit = [1 1 1 1];
  posOutputScalePrompt = [1 1 1 1];
  posOutputScaleEdit = [1 1 1 1];
  if strcmp(get(ud.dataTypePopup, 'Visible'), 'on')
    posDataTypePopup = get(ud.dataTypePopup, 'Position');
    addHeight1 = 0;
    addHeight2 = 0;
    addHeight3 = ruler - posDataTypePopup(2);
  else
    addHeight2 = 0;
    addHeight3 = 0;
  end
end

% data type popup and prompt
strExt = get(ud.dataTypePrompt, 'extent');
posDataTypePrompt = ...
    [posParam(1)+offset ...
     ruler ...
     strExt(3:4)];
set(tmpText,'string','wwwwwwwwwwwwwwwwww');
strExt = get(tmpText, 'extent');
posDataTypePopup = ...
    [posDataTypePrompt(1)+posDataTypePrompt(3)+offset ...
     posDataTypePrompt(2) strExt(3) btnHeight];
ruler = posDataTypePopup(2)+posDataTypePopup(4)+txtMove;

if ud.showAdditionalParams
  additionalHeight = addHeight1;
  additionalHeight = additionalHeight+addHeight2+addHeight3;
else
  posSignalTypePrompt = [1 1 1 1];
  posSignalTypePopup = [1 1 1 1];
  posDataTypePrompt = [1 1 1 1];
  posDataTypePopup = [1 1 1 1];
  posOutputScalePrompt = [1 1 1 1];
  posOutputScaleEdit = [1 1 1 1];
  posOutputDTPrompt = [1 1 1 1];
  posOutputDTEdit = [1 1 1 1];

  ruler = posParam(2)+offset;
  
  if strcmp(get(hdl, 'Visible'), 'on')
    currentPosShowChx = get(ud.showAdditionalParamsChx,'position');
    additionalHeight = -(currentPosShowChx(2)-posParam(2));
  end
end
figPos = [figPos(1) figPos(2)-additionalHeight ...
          figPos(3) figPos(4)+additionalHeight];

% description frame
posDesc      = [offset figPos(4)-6.5*offset figPos(3)-2*offset 5.5*offset];
strExt       = get(ud.descTitle, 'extent');
posDescTitle = [3*offset posDesc(2)+posDesc(4)-strExt(4)/2 ...
		strExt(3:4)];
posDescText  = [posDesc(1)+offset posDesc(2)+.2 ...
		posDesc(3)-2*offset posDesc(4)-offset];

posParam(4) = posDesc(2)-posOK(2)-posOK(4)-3*offset;

% Parameter frame title
strExt        = get(ud.paramTitle, 'extent');
posParamTitle = [3*offset posParam(2)+posParam(4)-strExt(4)/2 strExt(3:4)];

% data store name prompt and edit field
strExt = get(ud.dsNamePrompt, 'extent');
posDSNamePrompt = [posParam(1)+offset ...
                   posParam(4)+posParam(2)-offset-strExt(4) ...
                   posParam(3)-2*offset strExt(4)];

strExt = get(ud.dsNameEdit, 'extent');
posDSNameEdit = [posDSNamePrompt(1) ...
                 posDSNamePrompt(2)-btnHeight ...
                 posParam(3)-2*offset btnHeight];

%            --------------- show additional parameters ---------------
% checkbox use up all dialog width
set(tmpText,'string',...
            'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww');
strExt = get(tmpText, 'extent');
posShowAdditionalParams = ...
    [posParam(1)+offset ...
     ruler ...
     posParam(3)-2*offset btnHeight];

% vector parameter as 1-D checkbox
strExt = get(ud.vecParam1DChkbx, 'extent');
posVecParam1DChkbx = ...
    [posParam(1)+offset ...
     posShowAdditionalParams(2)+posShowAdditionalParams(4)+txtMove ...
     posParam(3)-2*offset btnHeight];

% RTW type qualifier prompt and edit field
posRTWTypeQualifierEdit = ...
    [posVecParam1DChkbx(1) ...
     posVecParam1DChkbx(2)+txtMove+posVecParam1DChkbx(4) ...
     posParam(3)-2*offset btnHeight];
strExt = get(ud.rtwTypeQualifierPrompt, 'extent');
posRTWTypeQualifierPrompt = ...
    [posVecParam1DChkbx(1) ...
     posRTWTypeQualifierEdit(2)+posRTWTypeQualifierEdit(4) ...
     posParam(3)-2*offset strExt(4)];

% RTW Storage class prompt and popup.
strExt = get(ud.rtwStorageClassPrompt, 'extent');
posRTWStorageClassPrompt = ...
    [posRTWTypeQualifierPrompt(1) ...
     posRTWTypeQualifierPrompt(2)+btnHeight ...
     strExt(3:4) ];

set(tmpText,'string','wwwwwwwwwwwwwwwwwwww');
strExt = get(tmpText, 'extent');
posRTWStorageClassPopup = ...
    [posRTWStorageClassPrompt(1)+posRTWStorageClassPrompt(3)+offset ...
     posRTWStorageClassPrompt(2) ...
     strExt(3) btnHeight];
delete(tmpText);

% initial value 
strExt = get(ud.initValEdit, 'extent');
posInitValEdit = [posParam(1)+offset ...
                  posRTWStorageClassPrompt(2)+txtMove+btnHeight ...
                  posParam(3)-2*offset btnHeight];
	
strExt = get(ud.initValPrompt, 'extent');
posInitValPrompt = [posParam(1)+offset ...
                    posInitValEdit(2)+posInitValEdit(4) ...
                    posParam(3)-2*offset strExt(4)];

% read/write blocks list 
strExt = get(ud.dsListPrompt, 'extent');
posDSListPrompt = [posParam(1)+offset ...
                   posDSNameEdit(2)-txtMove-strExt(4) ...
                   posParam(3)-2*offset strExt(4)];

dsListHeight = posDSListPrompt(2) - posInitValPrompt(2) - ...
    posInitValPrompt(4)-txtMove;
posDSList = [posDSListPrompt(1) ...
             posInitValPrompt(2)+posInitValPrompt(4)+txtMove ...
             posParam(3)-2*offset ...
	     dsListHeight];

% set objects' positions
set(hdl,                       'Position', figPos);
set(ud.desc,                   'Position', posDesc);
set(ud.descTitle,              'Position', posDescTitle);
set(ud.descText,               'Position', posDescText); 
set(ud.param,                  'Position', posParam);
set(ud.paramTitle,             'Position', posParamTitle);
set(ud.dsNamePrompt,           'Position', posDSNamePrompt);
set(ud.dsNameEdit,             'Position', posDSNameEdit);
set(ud.dsListPrompt,           'Position', posDSListPrompt);
set(ud.dsList,                 'Position', posDSList);
set(ud.initValPrompt,          'Position', posInitValPrompt);
set(ud.initValEdit,            'Position', posInitValEdit);
set(ud.rtwStorageClassPrompt,  'Position', posRTWStorageClassPrompt);
set(ud.rtwStorageClassPopup,   'Position', posRTWStorageClassPopup);
set(ud.rtwTypeQualifierPrompt, 'Position', posRTWTypeQualifierPrompt);
set(ud.rtwTypeQualifierEdit,   'Position', posRTWTypeQualifierEdit);
set(ud.vecParam1DChkbx,        'Position', posVecParam1DChkbx);
set(ud.signalTypePrompt,       'Position', posSignalTypePrompt);
set(ud.signalTypePopup,        'Position', posSignalTypePopup);
set(ud.outputScalePrompt,      'Position', posOutputScalePrompt);
set(ud.outputScaleEdit,        'Position', posOutputScaleEdit);
set(ud.outputDTPrompt,         'Position', posOutputDTPrompt);
set(ud.outputDTEdit,           'Position', posOutputDTEdit);
set(ud.dataTypePrompt,         'Position', posDataTypePrompt);
set(ud.dataTypePopup,          'Position', posDataTypePopup);
set(ud.showAdditionalParamsChx,'Position', posShowAdditionalParams);
set(ud.okButton,               'Position', posOK);
set(ud.cancelButton,           'Position', posCancel);
set(ud.helpButton,             'Position', posHelp);
set(ud.applyButton,            'Position', posApply);

set(allHdls, 'Units', 'normalized');
set(hdl, 'UserData', ud);

% end doResize


% Function: doRTWStorageClass ==================================================
% Abstract:
%   Enable Apply button when RTW storage class popup called.
%
function doRTWStorageClass(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

if get(ud.rtwStorageClassPopup, 'Value') > 1
  set(ud.rtwTypeQualifierPrompt, 'Enable', 'on');
  set(ud.rtwTypeQualifierEdit, 'Enable', 'on');
else
  set(ud.rtwTypeQualifierPrompt, 'Enable', 'off');
  set(ud.rtwTypeQualifierEdit, 'Enable', 'off');
end

% toggle apply button
toggleApply(ud.applyButton);

set(hdl, 'UserData', ud);
% end doRTWStorageClass


% Function: doEnableApplyButton ================================================
% Abstract:
%   Enable Apply button when these edit fields all called
%
function doEnableApplyButton(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

% toggle apply button
toggleApply(ud.applyButton);

set(hdl, 'UserData', ud);

% end doEnableApplyButton


% Function: doUpdateName =======================================================
% Abstract:
%   This function will update block dialog's title name according to block's
%   name change.
%
function doUpdateName(blkHdl)

hdl = get_param(blkHdl, 'Figure');

if hdl ~= -1
  ud  = get(hdl, 'UserData');
  set(hdl, 'Name', ['Block Parameters: ' get_param(blkHdl, 'name')]);
  ud.blkHdl = blkHdl;
  set(hdl, 'UserData', ud);
  if strcmp(get_param(blkHdl, 'LinkStatus'), 'none')
    set_param(blkHdl, 'Figure', hdl);
  end
end

% end doUpdateName


% Function: doUnHiliteBlocks ===================================================
% Abstract:
%   Set hilited block to its previous hilite_system theme.
%
function hilitedBlk = doUnHiliteBlocks(obj, evd)

if ~isstruct(obj)
  hdl = get(obj, 'Parent');
  ud  = get(hdl, 'UserData');
  if isempty(ud)
    % called from uimenu
    hdl = get(get(obj, 'Parent'), 'Parent');
    ud  = get(hdl, 'UserData');
  end
  hilitedBlk = ud.hilitedBlk;
else
  hilitedBlk = obj;
end

% un-hilite_system
if hilitedBlk.blkHdl ~= -1
  try
    set_param(hilitedBlk.blkHdl, 'HiliteAncestors', hilitedBlk.origHL);
  catch
    % do nothing is pre-hilited block has already gone
  end
  hilitedBlk.blkHdl = -1;
  hilitedBlk.origHL = 'none';
end
  
% end doUnHiliteBlocks
  
  
% Function: doShowAdditionalParams =============================================
% Abstract: 
%   Toggle data type section.
%
function doShowAdditionalParams(obj, evd, blkHdl)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

currentStatus = get(ud.dataTypePopup, 'Visible');
specialParamsHdl = ...
    [ud.outputDTPrompt, ud.outputDTEdit, ...
     ud.outputScalePrompt, ud.outputScaleEdit];
additionalParamsHdl = ...
    [ud.dataTypePrompt, ud.dataTypePopup, ...
     ud.signalTypePrompt, ud.signalTypePopup];

if ~isempty(findstr(getPopupCurrentSelectionStr(ud.dataTypePopup), 'Specify'))
  ud.datatypeViaDialog = true;
  
  str = get(ud.outputDTEdit, 'String');
  le = lasterr;
  try
    val = eval(str);
  catch
    val = [];
    lasterr(le);
  end

  if ~isempty(val) && isfield(val, 'Class') && strcmp(val.Class, 'FIX')
    % show Output scaling edit field
    ud.showOutputScale = true;
  else
    ud.showOutputScale = false;
  end
else
  ud.datatypeViaDialog = false;
  ud.showOutputScale = false;
end
ud.showAdditionalParams = get(ud.showAdditionalParamsChx, 'Value');

if ud.showAdditionalParams
  set(additionalParamsHdl, 'Visible', 'on');
  if ~ud.datatypeViaDialog
    set(specialParamsHdl, 'Visible', 'off');
  else
    if ~ud.showOutputScale
      set([ud.outputScalePrompt, ud.outputScaleEdit], 'Visible', 'off');
      set([ud.outputDTPrompt, ud.outputDTEdit], 'Visible', 'on');
    else
      set(specialParamsHdl, 'Visible', 'on');
    end
  end
else
  set([additionalParamsHdl,specialParamsHdl], 'Visible', 'off');
end
set(hdl, 'UserData', ud);

doResize(hdl, []);

% toggle apply button
toggleApply(ud.applyButton);

% end doShowAdditionalParams
    

% Function: doDataTypeSelection ================================================
% Abstract: 
%   Toggle apply button and display more info. fields for output setting.
%
function doDataTypeSelection(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

specialParamsHdl = ...
    [ud.outputDTPrompt, ud.outputDTEdit, ...
     ud.outputScalePrompt, ud.outputScaleEdit];

currentStatus = get(ud.outputDTPrompt, 'Visible');
if get(ud.dataTypePopup, 'Value') == size(get(ud.dataTypePopup, 'String'), 1)
  ud.datatypeViaDialog = true;
  str = get(ud.outputDTEdit, 'String');
  le = lasterr;
  try
    val = eval(str);
  catch
    val = [];
    lasterr(le);
  end

  if ~isempty(val) && isfield(val, 'Class') && strcmp(val.Class, 'FIX')
    % show Output scaling edit field
    ud.showOutputScale = true;
  else
    ud.showOutputScale = false;
  end

  if ~ud.showOutputScale
    set([ud.outputDTPrompt, ud.outputDTEdit], 'Visible', 'on');
    set([ud.outputScalePrompt, ud.outputScaleEdit], 'Visible', 'off');
  else
    set(specialParamsHdl, 'Visible', 'on');  
  end
else
  ud.datatypeViaDialog = false;
  ud.showOutputScale = false;
  set(specialParamsHdl, 'Visible', 'off');
end
set(hdl, 'UserData', ud);

if ~strcmp(get(ud.outputDTPrompt, 'Visible'), currentStatus)
  doResize(hdl, []);
end

% toggle apply button
toggleApply(ud.applyButton);

% end doDataTypeSelection
  

% Function: doOutputDataTypeInput ==============================================
% Abstract: 
%   Check if the input entry is FIXEDPOINT class object. If it is, enable 
%   Output scaling value field; otherwise, disable them.
%
function doOutputDataTypeInput(obj, evd)
  
hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

% toggle apply button
toggleApply(ud.applyButton);

str = get(ud.outputDTEdit, 'String');
le = lasterr;
try
  val = eval(str);
catch
  val = [];
  lasterr(le);
end
toggleField = false;
if ~isempty(val) && isfield(val, 'Class') && strcmp(val.Class, 'FIX')
  % show Output scaling edit field
  if strcmp(get(ud.outputScalePrompt, 'Visible'), 'off')
    ud.showOutputScale = true;
    toggleField = true;
  end
else
  % hide Output scaling edit field
  if strcmp(get(ud.outputScalePrompt, 'Visible'), 'on')
    ud.showOutputScale = false;
    toggleField = true;
  end
end
set([ud.outputScalePrompt, ud.outputScaleEdit], 'Visible', ...
                  sl('onoff', ud.showOutputScale));
set(hdl, 'UserData', ud);
if toggleField
  doResize(hdl, []);
end

% doOutputDataTypeInput


% Function: deleteFcn ==========================================================
% Abstract: 
%   Get called when the dialog figure is deleted.
%
function deleteFcn(fig, evd)

ud = get(fig, 'UserData');
doClose(ud.blkHdl);

% end deleteFcn


% Function: getDSSrcBlocks =====================================================
% Abstract:
%   This function will return a list of Read/Write blocks that are 
%   corresponding to current Write/Read block.
%
function srcName = getDSSrcBlocks(blkHdl)

dsSrc = get_param(blkHdl, 'DSReadWriteBlocks');

srcName = '';
if length(dsSrc) > 0
  for i=1:length(dsSrc)
    if ~isempty(findstr(get_param(dsSrc(i).name, 'BlockType'), 'Write'))
      preFix = '(W)';
    else
      preFix ='(R)';
    end
    srcName = [srcName; {[preFix dsSrc(i).name]}];
  end
end

% end getDSSrcBlocks


% Function: getPopupMatchingValue ==============================================
% Abstract:
%   Utility function to return the index of a popup menu with matching string.
% 
function val = getPopupMatchingValue(popupItem, str)
  
val = 1;
popupStr = get(popupItem, 'String');
for i=1:size(popupStr, 1)
  if strcmp(sl('deblankall', popupStr(i,:)), str)
    val = i;
    break;
  end
end
  
% end getPopupMatchingValue
  

% Function: getPopupCurrentSelectionStr ========================================
% Abstract:
%   Return the string of the current selection of a popup menu.
% 
function val = getPopupCurrentSelectionStr(popupItem)

val = '';
try
  popupStr = get(popupItem, 'String');
  popupVal = get(popupItem, 'Value');
  val = popupStr(popupVal, :);
catch
  % do nothing
end
  
% end getPopupCurrentSelectionStr
  

% Function: openDialog =========================================================
% Abstract:
%   Function to create the block dialog for the selected Data Store
%   Read/Write block if doesn't have one, or refresh the associated block
%   dialog and make it visible if it does.
%
function hdl = openDialog(blkHdl)

% Check to see if block has a dialog
updateDataOnly = 0;
hdl = get_param(blkHdl, 'Figure');
if ~isempty(hdl) && ishandle(hdl) && hdl ~= -1
  figure(hdl);
  updateDataOnly = 1;
end

%
% If there is no dialog associated with this block, we have to create one
%
if ~updateDataOnly
  hdl = createDialog(blkHdl);
end

ud = get(hdl, 'UserData');

% update its parameter field
if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  % Update the from blocks list
  doRefreshSrcList(ud.dsNameEdit, []);
end

% Show the dialog
set(hdl, 'visible', 'on');

% end openDialog

  
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
      if strcmp(get(ud.okButton, 'Enable'), 'on')
        doOK(ud.okButton, []);
      end
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


% [EOF]
