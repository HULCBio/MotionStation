function varargout = sldatastoredlg(varargin)
% Data Store Read/Write block   Creates block dialog for Data Store blocks.
% 
%   It provides the following functionalities for user:
%     - view and set the Data Store name;
%     - browse the Data Stoer names that are propagated in the model;
%     - for Data Store Read, list the source of Data Store Write block and be
%       able to locate it; 
%     - for Data Store Write, list all Data Store Read blocks that have the
%       matching Data Store name and be able to locate any of them;
%     - view and set the sample time;
%
%   This is an internal Simulink function.
%
%   See also slfromdlg, slgotodlg, sldsmemdlg.
  
%   Jun Wu, 10/12/2001
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/15 00:32:32 $

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
    error('SimulinkDialog:InternalError', ...
	  (['Invalid command "' varargin{1} ...
	    '" for Data Store ', blkType(10:end), ...
	    ' block parameter dialog.']));
  end
  
 case 3,
  if strcmp(varargin{1}, 'get')
    blkHdl = varargin{2};
    hdl    = get_param(blkHdl, 'Figure');
    ud     = get(hdl, 'UserData');
    varargout = {''};
    switch varargin{3}
     case 0 % DataStoreName
      varargout{1} = sl('deblankall', get(ud.dsNameEdit, 'String'));
     case 1 % SampleTime
      varargout{1} = sl('deblankall', get(ud.tsEdit, 'String'));
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
      doDSName(ud.dsNameEdit, []);
     case 1 % sampleTime
      set(ud.tsEdit, 'String', sl('deblankall', varargin{3}));
      doSampleTime(ud.tsEdit, []);
    end
    return;
  end
  
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
objBGColor = get(0,'defaultuicontrolbackgroundcolor');

if findstr(get_param(blkHdl, 'BlockType'), 'Read')
  descStr = 'Read values from specified data store.';
  blkType = 'Data Store Read';
  blkTypeEnum = 1;
else
  descStr = 'Write values to specified data store.';
  blkType = 'Data Store Write';
  blkTypeEnum = 0;
end

%
% create the figure for the block dialog
%
dialogPos = [1 1 350 340];

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
    'Resize',           'on' ...
    );

tmpText = uicontrol(hdl, 'style', 'text', ...
                    'fontunit', 'pixel', ...
		    'visible', 'off', ...
		    'string', 'www');
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

% create description frame
ud.desc = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'enable',          'inactive', ...
    'backgroundcolor', objBGColor, ...
    'foregroundcolor', [255 251 240]/255);

ud.descTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          blkType);

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
    'enable',          'inactive', ...
    'foregroundcolor', [255 251 240]/255);

ud.paramTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Parameters');

% create "Data store name" field
ud.dsNamePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Data store name: ');

dsName = get_param(blkHdl, 'DataStoreName');
ud.dsNameEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              dsName, ...
    'callback',            {@doDSName});

% create "Select data store name >>" button and uimenu item.
ud.cmenu = uicontextmenu( ...
    'Parent',          hdl, ...
    'Callback',        {@doContextMenu});
ud.selectButton = uicontrol(...
    hdl, ...
    'style',               'pushbutton', ...
    'backgroundcolor',     objBGColor, ...
    'string',              'Select data store name >> ', ...
    'visible',             'on', ...
    'uicontextmenu',       ud.cmenu, ...
    'tooltip', ...
    'Setting data store name by selecting it from the list', ...
    'callback',            {@doDSNameSelect});

% create data store memory block prompt and text field
ud.dsmSrcPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Data store memory block: ');

dsmSrc = findMatchingDSMemBlock(ud.blkHdl, get(ud.dsNameEdit, 'String'));
if ~isempty(dsmSrc)
  dsmSrc = strrep(dsmSrc, sprintf('\n'), ' ');
end
ud.dsmSrcEdit = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'horizontalalignment', 'left', ...
    'Tooltip',             'Click to locate the block', ...
    'Foregroundcolor',     'Blue', ...
    'Enable',              'inactive', ...
    'string',              dsmSrc ...
    );
if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set(ud.dsmSrcEdit, 'ButtonDownFcn',  {@doLocateDSM});
end

% create Read/Write block(s) source edit/listbox
if blkTypeEnum
  dsSrcPrompt = 'Data store write blocks: ';
else
  dsSrcPrompt = 'Data store read blocks: ';
end
ud.srcListPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          dsSrcPrompt);

dsSrcName = getDSSrcBlocks(blkHdl);
% for data store read/write blocks list
ud.srcList = uicontrol(...
    hdl, ...
    'style',           'listbox', ...
    'backgroundcolor', objBGColor, ...
    'String',          dsSrcName, ...
    'Tooltip',         ...
    sprintf(['Double click to locate the selected block.\n', ...
             'Click Apply to refresh the list']), ...
    'callback',        {@doDSSrcSelection});

% sample time prompt and field
ud.tsPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Sample time: ');

ts = get_param(blkHdl, 'SampleTime');
ud.tsEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              ts, ...
    'callback',            {@doSampleTime});

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
ud.hilitedBlk.blkHdl = -1;
ud.hilitedBlk.origHL = 'none';
ud.hilitedDSM.blkHdl = -1;
ud.hilitedDSM.origHL = 'none';
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
    'UserData',  ud, ...
    'ResizeFcn', {@doResize});

%
% Update the userdata only if it is a changeable block
% else show a disabled version of the gui.
%
if strcmp(get_param(blkHdl, 'LinkStatus'), 'none') && ...
      ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set_param(blkHdl, 'Figure', hdl)
else
  UiControls = [ud.dsNamePrompt; ud.dsNameEdit; ud.selectButton; ...
                ud.dsmSrcPrompt; ud.dsmSrcEdit;ud.srcListPrompt;ud.srcList; ... 
                ud.tsPrompt; ud.tsEdit; ud.okButton; ud.applyButton];
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

ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);
ud.hilitedDSM = doUnHiliteBlocks(ud.hilitedDSM);
errmsg = '';
lasterr('');

applyNoError = 1;
set_param(ud.blkHdl, 'Figure', -1);
prevDSName = get_param(ud.blkHdl, 'DataStoreName');
prevTs = get_param(ud.blkHdl, 'SampleTime');
try
  % set the Figure parameter to be off temporarily because we want to
  % perform the real set_param
  set_param(ud.blkHdl, 'DataStoreName', ...
                       sl('deblankall', get(ud.dsNameEdit, 'String')));
catch
  applyNoError = 0;
  try
    % recover the parameter
    set_param(ud.blkHdl, 'DataStoreName', prevDSName);
  catch
  end
  errmsg = [errmsg; {lasterr}];
end

try
  % set the Figure parameter to be off temporarily because we want to
  % perform the real set_param
  set_param(ud.blkHdl, 'SampleTime', sl('deblankall', get(ud.tsEdit, 'String')));
catch
  applyNoError = 0;
  try
    % recover the parameter
    set_param(ud.blkHdl, 'SampleTime', prevTs);
  catch
  end
  errmsg = [errmsg; {lasterr}];
end
% recover the Figure handle setting
set_param(ud.blkHdl, 'Figure', hdl);

if applyNoError
  try
    % update data store r/w blocks list
    doRefreshSrcList(ud.dsNameEdit, []);
  catch
    errmsg = {errmsg; lasterr};
  end

  % switch applyButton
  toggleApply(applyButton, 'off');
end

set(hdl, 'UserData', ud);
if ~isempty(errmsg)
  errordlg(errmsg, 'Error message: Data Store Block', 'modal');
end

% end doApply


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change on it.
%
function doCancel(cancelButton, evd)

hdl = get(cancelButton, 'Parent');
ud  = get(hdl, 'UserData');

ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);
ud.hilitedDSM = doUnHiliteBlocks(ud.hilitedDSM);

set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

if ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  set_param(ud.blkHdl, 'Figure', -1);
  set(ud.dsNameEdit, 'String', get_param(ud.blkHdl, 'DataStoreName'));
  set(ud.tsEdit, 'String', get_param(ud.blkHdl,'SampleTime'));
  set_param(ud.blkHdl, 'Figure', hdl);
  warning(warningState);
end

% end doCancel


% Function: doClose ============================================================
% Abstract:
%   This function will be called when the data store r/w block is vanished.
%
function doClose(blkHdl)

if get_param(blkHdl, 'Figure') ~= -1
  hdl = get_param(blkHdl, 'Figure');
  if ~isempty(hdl) && ishandle(hdl)
    ud  = get(hdl, 'UserData');
    
    % un-hilite_system
    ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);
    ud.hilitedDSM = doUnHiliteBlocks(ud.hilitedDSM);

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


% Function: doRefreshSrcList ===================================================
% Abstract:
%   Refresh Data store source filed according to selected data store name.
%
function doRefreshSrcList(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

srcName = getDSSrcBlocks(ud.blkHdl);
if get(ud.srcList, 'Value') > size(srcName, 1)
  set(ud.srcList, 'Value', 1);
end
set(ud.srcList, 'String', srcName);

dsmSrc = findMatchingDSMemBlock(ud.blkHdl, get(ud.dsNameEdit, 'String'));
if ~isempty(dsmSrc)
  dsmSrc = strrep(dsmSrc, sprintf('\n'), ' ');
end
set(ud.dsmSrcEdit, 'String', dsmSrc);

% end doRefreshSrcList
  
  
% Function: doDSSrcSelection ===================================================
% Abstract:
%   - Toggle the apply button when any item is selected
%   - Double-click will find selected data store r/w block
%
function doDSSrcSelection(srcList, evd)

hdl = get(srcList, 'Parent');
ud  = get(hdl, 'UserData');

if strcmp(lower(get(hdl, 'SelectionType')), 'normal')
  % normal selection callback
  listStr = get(ud.srcList, 'String');

  if ~isempty(listStr)
    % toggle apply button
    toggleApply(ud.applyButton);
  end
elseif strcmp(lower(get(hdl, 'SelectionType')), 'open')
  % double-click action, will call doFind
  doFind(ud.srcList, []);
end

% end doDSSrcSelection


% Function: doDSName ===========================================================
% Abstract:
%   Enable Apply button when called.
%
function doDSName(dsNameEdit, evd)

hdl = get(dsNameEdit, 'Parent');
ud  = get(hdl, 'UserData');
 
% update data store r/w blocks list
doRefreshSrcList(ud.dsNameEdit, []);

% toggle apply button
toggleApply(ud.applyButton);

% end doDSName


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for Bus Creator block.
%
function doHelp(helpButton, evd)

hdl = get(helpButton, 'Parent');
ud  = get(hdl, 'UserData');
slhelp(ud.blkHdl);

% end doHelp


% Function: doDSNameSelect =====================================================
% Abstract:
%   Enable Apply button when called and set selected Data Store Name.
%
function doDSNameSelect(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

doContextMenu(ud.cmenu, []);

% end doDSNameSelect


% Function: doContextMenu ======================================================
% Abstract:
%   Bring up the context menu dialog for Data Store Memory blocks list
%
function doContextMenu(cmenu, evd)
  
hdl = get(cmenu, 'Parent');
ud  = get(hdl, 'UserData');

% clean-up the uimenu list first
delete(get(ud.cmenu, 'Children'));

if strcmp(get_param(ud.blkHdl, 'LinkStatus'), 'none') && ...
      ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  currentDsmStr = get_param(ud.blkHdl, 'DataStoreName');
  
  dsmBlks = find_system(bdroot(ud.blkHdl), 'BlockType', 'DataStoreMemory');
  for i=1:length(dsmBlks)
    dsNameStr = get_param(dsmBlks(i), 'DataStoreName');
    if isempty(findobj(ud.cmenu, 'Label', ['   ' dsNameStr]))
      item = uimenu(ud.cmenu, ...
                    'Label',     ['   ' dsNameStr], ...
                    'Enable',    'on', ...
                    'callback',  {@doSelectTag});
      if strcmp(currentDsmStr, dsNameStr)
        set(item, 'Checked', 'on');
      end
    end
  end
  
  % Adjust the position so it will always appear on the side of Browse button.
  prevUnit = get(ud.selectButton, 'Units');
  set(ud.selectButton, 'Units', 'pixels');
  selectButtonPos = get(ud.selectButton, 'Position');
  set(ud.cmenu, 'Position', selectButtonPos(1:2)+selectButtonPos(3:4));
  set(ud.cmenu, 'Visible', 'on');
  set(ud.selectButton, 'Units', prevUnit);
end

% end doContextMenu


% Function doSelectTag =========================================================
% Abstract: 
%   Callback functions for items on DSMTags list menu.
% 
function doSelectTag(item, evd)
  
hdl = get(get(item, 'Parent'), 'Parent');
ud  = get(hdl, 'UserData');

set(ud.dsNameEdit, 'String', sl('deblankall', get(item, 'Label')));

% refresh data store r/w source field according to new dsm tag
if strcmp(get(ud.dsNameEdit, 'String'), get_param(ud.blkHdl, 'DataStoreName'))
  doRefreshSrcList(ud.dsNameEdit, []);
end

% toggle Apply button
toggleApply(ud.applyButton);

set(hdl, 'UserData', ud);

% end doSelectTag


% Function doLocateDSM =========================================================
% Abstract: 
%   Callback function for locating the current Data Store Memory block.
% 
function doLocateDSM(item, evd)

hdl = get(item, 'Parent');
ud  = get(hdl, 'UserData');

if strcmp(get(hdl, 'SelectionType'), 'alt')
  % do nothing for right mouse click.
  return;
end

% locate the Data Store Memory block that matches the current selected 
% Data store name
dsmBlk = findMatchingDSMemBlock(ud.blkHdl, get(ud.dsNameEdit, 'String'));
if ~isempty(dsmBlk)
  try
    ud.hilitedDSM = doUnHiliteBlocks(ud.hilitedDSM);
    ud.hilitedDSM.origHL = get_param(dsmBlk, 'HiliteAncestors');
    hilite_system(dsmBlk, 'find');
    ud.hilitedDSM.blkHdl = dsmBlk;
  catch
    errordlg(lasterr);
  end
else
  errordlg(['Data store memory block for data store block '...
            '''' get_param(ud.blkHdl, 'Name') '''  was not found.']);
end

set(hdl, 'UserData', ud);

% end doLocateDSM


% Function: doFind =============================================================
% Abstract:
%   This function will find the selected data store r/w block in the mode by
%   using hilite_system.
%
function doFind(obj, evd)

hdl = get(obj, 'Parent');
ud  = get(hdl, 'UserData');

% reset the hilite_system
ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);

listStr = get(ud.srcList, 'String');
% if the listbox is not empty, try to find the selected block
if ~isempty(listStr)
  listSrc = listStr{get(ud.srcList, 'Value')};
  if ~isempty(listSrc)
    try
      % use 'find' scheme in hilite_system
      ud.hilitedBlk.origHL = get_param(listSrc, 'HiliteAncestors');
      hilite_system(listSrc, 'find');
      ud.hilitedBlk.blkHdl = listSrc;
    catch
      msg = ['Unable to find Data Store block named: "' listSrc '". ' lasterr];
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

if doApply(ud.applyButton, evd)
  ud.hilitedBlk = doUnHiliteBlocks(ud.hilitedBlk);
  ud.hilitedDSM = doUnHiliteBlocks(ud.hilitedDSM);

  set(hdl, 'Visible', 'off');
  set(hdl, 'UserData', ud);
end

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
                    'fontunit', 'pixel', 'string', 'www');
pixelRatio = get(tmpText, 'fontsize')/10.667;
delete(tmpText);
if ud.origSize ~= [0 0]
  if figPos(3) < ud.origSize(1) || figPos(4) < 310*pixelRatio
    set(hdl, 'Units', 'normalized');
    return;
  end
end

allHdls = [hdl ud.desc ud.descTitle ud.descText ud.param ud.paramTitle ...
	   ud.dsNamePrompt ud.dsNameEdit ud.selectButton ...
           ud.dsmSrcPrompt ud.dsmSrcEdit ud.srcListPrompt ...
           ud.srcList ud.tsPrompt ud.tsEdit ...
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

% description frame
posDesc      = [offset figPos(4)-3.5*offset figPos(3)-2*offset 2.5*offset];
strExt       = get(ud.descTitle, 'extent');
posDescTitle = [3*offset posDesc(2)+posDesc(4)-strExt(4)/2 ...
		strExt(3:4)];
posDescText  = [posDesc(1)+offset posDesc(2)+.2 ...
		posDesc(3)-2*offset posDesc(4)-offset];

% Parameters frame
posParam      = [offset posOK(2)+posOK(4)+offset ...
		 figPos(3)-2*offset ...
		 posDesc(2)-posOK(4)-3*offset];
strExt        = get(ud.paramTitle, 'extent');
posParamTitle = [3*offset posParam(2)+posParam(4)-strExt(4)/2 strExt(3:4)];

% data store name prompt and edit field
strExt = get(ud.dsNamePrompt, 'extent');
posDSNamePrompt = [posParam(1)+offset ...
                   posParam(4)+posParam(2)-offset-strExt(4) ...
                   strExt(3:4)];

strExt = get(ud.dsNameEdit, 'extent');
posDSNameEdit = [posDSNamePrompt(1) ...
                 posDSNamePrompt(2)-btnHeight ...
                 posParam(3)-2*offset btnHeight];
	
% "select data store name>>" button
strExt = get(ud.selectButton, 'extent');
posSelectButton = [posDSNameEdit(1)+posDSNameEdit(3)-strExt(3) ...
                  posDSNameEdit(2) ...
                  strExt(3) ...
                  btnHeight];
posDSNameEdit(3) = posDSNameEdit(3) - strExt(3) - offset;

% data store memory prompt and edit
strExt = get(ud.dsmSrcPrompt, 'extent');
posDsmSrcPrompt = [posDSNameEdit(1) ...
                   posDSNameEdit(2)-strExt(4)-txtMove ...
                   strExt(3:4)];
posDsmSrcEdit = [posDsmSrcPrompt(1)+posDsmSrcPrompt(3) ...
                 posDsmSrcPrompt(2) ...
                 posParam(3)-2*offset-posDsmSrcPrompt(3) ...
                 posDsmSrcPrompt(4)];         

% sample time prompt and field
posTsEdit = [posParam(1)+offset ...
               posParam(2)+offset ...
               posParam(3)-2*offset btnHeight];
strExt = get(ud.tsPrompt, 'extent');
posTsPrompt = [posTsEdit(1) posTsEdit(2)+posTsEdit(4) strExt(3:4)];

% data store source group: prompt, list and Find button
strExt = get(ud.srcListPrompt, 'extent');
posSrcListPrompt = [posDsmSrcPrompt(1) ...
                    posDsmSrcPrompt(2)-strExt(4)-txtMove ...
                    strExt(3:4)];

% data store source list
strExt = get(ud.srcList, 'extent');
% for data store read/write blocks list
posSrcList = [posSrcListPrompt(1) ...
              posTsPrompt(2)+posTsPrompt(4)+txtMove ...
              figPos(3)-4*offset ...
              posSrcListPrompt(2)-posTsPrompt(2)-posTsPrompt(4)-txtMove];

% set objects' positions
set(ud.desc,          'Position', posDesc);
set(ud.descTitle,     'Position', posDescTitle);
set(ud.descText,      'Position', posDescText); 
set(ud.param,         'Position', posParam);
set(ud.paramTitle,    'Position', posParamTitle);
set(ud.dsNamePrompt,  'Position', posDSNamePrompt);
set(ud.dsNameEdit,    'Position', posDSNameEdit);
set(ud.selectButton,  'Position', posSelectButton);
set(ud.dsmSrcPrompt,  'Position', posDsmSrcPrompt);
set(ud.dsmSrcEdit,    'Position', posDsmSrcEdit);
set(ud.srcListPrompt, 'Position', posSrcListPrompt);
set(ud.srcList,       'Position', posSrcList);
set(ud.tsPrompt,      'Position', posTsPrompt);
set(ud.tsEdit,        'Position', posTsEdit);
set(ud.okButton,      'Position', posOK);
set(ud.cancelButton,  'Position', posCancel);
set(ud.helpButton,    'Position', posHelp);
set(ud.applyButton,   'Position', posApply);

set(allHdls, 'Units', 'normalized');

% end doResize


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
function hilitedBlk = doUnHiliteBlocks(hilitedBlk)
  
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
  
  
% Function: doSampleTime =======================================================
% Abstract:
%   Synchronize the sample time field for Data Store blocks
%
function doSampleTime(ts, evd)

hdl = get(ts, 'Parent');
ud  = get(hdl, 'UserData');

% toggle apply button
toggleApply(ud.applyButton);

% end doSampleTime


% Function: deleteFcn ==========================================================
% Abstract: 
%   Get called when the dialog figure is deleted.
%
function deleteFcn(fig, evd)

ud = get(fig, 'UserData');

doClose(ud.blkHdl);

% end deleteFcn


% Function: findMatchingDSMemBlock =============================================
% Abstract:
%   Get the closest Data Store Memory block.
%
function dsmBlk = findMatchingDSMemBlock(blk, dsName)

dsmBlk = find_system(get_param(blk, 'Parent'), ...
                     'SearchDepth',   1, ...
                     'BlockType',     'DataStoreMemory', ...
                     'DataStoreName', dsName);
if ~isempty(dsmBlk)
  dsmBlk = dsmBlk{1};
else
  blk = get_param(blk, 'Parent');
  if ~strcmp(bdroot(blk), blk)
    dsmBlk = findMatchingDSMemBlock(blk, dsName);
  end
end

% end findMatchingDSMemBlock
  

% Function: getDSSrcBlocks =====================================================
% Abstract:
%   This function will return a list of Read/Write blocks that are 
%   corresponding to current Write/Read block.
%
function srcName = getDSSrcBlocks(blkHdl)

dsSrc = get_param(blkHdl, 'DSReadOrWriteSource');

srcName = '';
if length(dsSrc) > 0
  for i=1:length(dsSrc)
    srcName = [srcName; {dsSrc(i).name}];
  end
end

% end getDSSrcBlocks


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

if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  % refresh Data Store name field
  set(ud.dsNameEdit, 'String', get_param(blkHdl, 'DataStoreName'));
  
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


% [EOF]
