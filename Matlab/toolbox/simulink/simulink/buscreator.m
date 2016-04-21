function varargout = buscreator(varargin)
% BUSCREATOR   Creates the block dialog for the Bus Creator block.
% 
%   It provides the following functionalities for user:
%   1) specifying the number of input ports;
%   2) changing the order of input ports;
%   3) modifying signal names to match input signals.
%
%   This is an internal Simulink function used to create the dialog
%   for the Bus Creator block.
%
%   See also BUSSELECT. 
  
%   Jun Wu, 12/12/2000
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.34.2.5 $

hdl = -1;
switch(nargin) 
  
 case 1,
  % This is unneccesary because we use function handles for internal callbacks.
  
 case 2,
  %--------------------------------------------------------------%
  % Simulink is telling us the block changed name or was deleted %
  %--------------------------------------------------------------%
  blkHdl = varargin{2};
  switch lower(varargin{1})
   case 'delete'
    doClose(blkHdl);
   case 'namechange'
    doUpdateName(blkHdl);
   otherwise
    error(['Invalid command "' varargin{1} ...
	   '" for Bus Creator block parameter dialog.']);
  end
  
 case 3,
  %------------------------------------------%
  % Simulink is asking us to open the dialog %
  %------------------------------------------%
  blkHdl    = varargin{1};
  command   = varargin{2};
  busStruct = varargin{3};
  hdl       = openDialog(blkHdl, busStruct);
  
 otherwise,
  error(['Invalid number of arguments ', num2str(nargin)]);
end

if nargout
  varargout{1} = hdl;			% output handle
end

% end buscreator


% Function: busTreeView ========================================================
% Abstract:
%   This function constructs the graphical objects for the dialog.
%
function treeList = busTreeView(action, fig, busStruct)

% re-organize the busdata structure so that it can use treeview function to
% display its signal name structure.
try 
  ud = get(get(fig, 'Parent'), 'UserData');
  showType = get(ud.inputPopup, 'Value');
catch
  showType = 1;
end
busData = struct2cellarr(busStruct, showType);

% display the data in this treeview
treeList = treeview(action, fig, busData);

% end busTreeView


% Function: cellarr2str ========================================================
% Abstract:
%   This function will convert a cell array into a string delimitated by ','. 
%
function str = cellarr2str(signalArray)

if ~isempty(signalArray)
  str = [];
  sep = '';
  for i = 1:length(signalArray)
    sig   = deblankall(signalArray{i});
    valid = validateSignalName(sig);
    if (~valid)
      %
      % Take care of invalid chars: '.' and ';'
      % This is consistent with the code in mux.c
      %
      strrep(sig, '.', ':');
      strrep(sig, ',', ';');
    end
    
    str = [str sep '''' sig ''''];
    sep = ',';
  end
end
% end cellarr2str
  

% Function: createDialog =======================================================
% Abstract:
%   This function constructs the graphical objects for the dialog.
%
function hdl = createDialog(blkHdl, busStruct)

% keep the background color consistent for each uicontrol objects
objBGColor = get(0,'defaultuicontrolbackgroundcolor');

%
% create the figure for the block dialog
%
dialogPos = [1 1 350 400];
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
    'backgroundcolor', objBGColor);

ud.descTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Bus Creator');

descStr = ['Used to group signals into a single bus signal for graphical' ...
	   ' modeling convenience. Individual signals within the bus can be' ...
	   ' extracted using the Bus Selector block. Hierachy can be defined' ...
	   ' in the bus signal by cascading Bus Creator blocks.'];

ud.descText = uicontrol(...
    hdl, ...
    'style',               'text', ...
    'backgroundcolor',     objBGColor, ...
    'max',                 2, ...
    'min',                 0, ...
    'horizontalalignment', 'left', ...
    'value',               [], ...
    'string',              descStr);

% create Parameters frame and the tile
ud.param = uicontrol(...
    hdl, ...
    'style',           'frame', ...
    'backgroundcolor', objBGColor);

ud.paramTitle = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Parameters');

% create popup menu
% do not change the order of popupStr without looking at other part of the code
popupStr = {'Inherit bus signal names from input ports'; ...
	    'Require input signal names to match signals below'};
ud.inputPopup = uicontrol(...
    hdl, ...
    'style',               'popup', ...
    'horizontalalignment', 'left', ...
    'string',              popupStr, ...
    'callback',            {@doInputPopup});
if strcmp(lower(computer), 'pcwin')
  set(ud.inputPopup, 'backgroundcolor', 'white');
else
  set(ud.inputPopup, 'backgroundcolor', ...
		    get(0, 'FactoryUicontrolBackgroundColor'));
end

% create number of inputs edit field and its prompt
ud.inputPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Number of inputs: ');

[numInputs, isNumber] = getInputs(blkHdl, get(ud.inputPopup, 'Value'));
ud.inputEdit = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              numInputs, ...
    'callback',            {@doInputNumber});
if isNumber
  set(ud.inputPopup, 'Value', 1);
else
  set(ud.inputPopup, 'Value', 2);
end

% Create the listbox to hold the Bus information and the selected data.
ud.listPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Signals in bus: ');

try
  ud.signalList = busTreeView('Create', hdl, busStruct);
  set(ud.signalList, ...
      'FontName',  'FixedWidth', ...
      'callback',  {@doSignalList});
catch
  errordlg('Incorrect signal specification');
  close(hdl);
  hdl = -1;
  return;
end

% create rename edit field and its prompt
ud.renamePrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'Enable',          'off', ...
    'string',          'Rename selected signal: ');

ud.renameEdit   = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'Enable',              'off', ...
    'horizontalalignment', 'left', ...
    'string',              '', ...
    'callback',            {@doRename});

% create Up, Down, Find and Refresh buttons
ud.upButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Up', ...
    'Visible',         'off', ...
    'Callback',        {@doUp});

ud.downButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Down', ...
    'Visible',         'off', ...
    'Callback',        {@doDown});

ud.findButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Find', ...
    'Enable',          'off', ...
    'Visible',         'on', ...
    'Callback',        {@doFind});

ud.refreshButton = uicontrol(...
    hdl, ...
    'Style',           'pushbutton', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Refresh', ...
    'Callback',        {@doRefresh});

ud.objectPrompt = uicontrol(...
    hdl, ...
    'style',           'text', ...
    'backgroundcolor', objBGColor, ...
    'string',          'Bus object: ');

ud.specifyViaObjectCheckbox = uicontrol(...
    hdl, ...
    'Style',           'checkbox', ...
    'backgroundcolor', objBGColor, ...
    'HorizontalAlignment', 'left', ...
    'string',          'Specify properties via bus object', ...
    'Callback',        {@doSpecifyViaObjectCallback});

ud.objectEdit   = uicontrol(...
    hdl, ...
    'style',               'edit', ...
    'backgroundcolor',     [1 1 1], ...
    'horizontalalignment', 'left', ...
    'string',              '', ...
    'callback',            {@doBusObjectCallback});

ud.nonVirtCheckbox = uicontrol(...
    hdl, ...
    'Style',           'checkbox', ...
    'backgroundcolor', objBGColor, ...
    'HorizontalAlignment', 'left', ...
    'string',          'Output as nonvirtual bus', ...
    'Callback',        {@doNonVirtualCallback});

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
ud.hilitedBlk = -1;
set(hdl, 'UserData', ud);

% setting up the proper size for this dialog
doResize(hdl, []);

% adjust the dialog's position according to block's position
set(hdl, 'Units', 'pixels');
dialogPos = get(hdl,'Position');
bdPos     = get_param(get_param(blkHdl,'Parent'),'Location');
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
if strcmp(get_param(blkHdl, 'LinkStatus'), 'none') & ...
      ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  set_param(blkHdl, 'Figure', hdl);
else
  UiControls = [ud.inputPrompt; ud.listPrompt; ud.inputPopup; ud.inputEdit; ...
                ud.signalList; ud.renameEdit; ud.upButton; ud.downButton; ...
                ud.refreshButton; ud.specifyViaObjectCheckbox; ...
                ud.objectEdit; ud.objectPrompt; ud.nonVirtCheckbox; ...
                ud.okButton; ud.findButton; ud.applyButton];
  set(UiControls, 'enable', 'off');
end

% end createDialog


% Function: doApply ============================================================
% Abstract:
%   This function will apply all the current settings appeared on the dialog.
%
function doApply(applyButton, evd)

hdl = get(applyButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

input = get(ud.inputEdit, 'String');
[result, count] = sscanf(input, '%d%s');
if count ~= 1 | result <= 0
  errordlg(['Invalid number of ports specified in parameter Inputs of ' ...
	    'block ''' get_param(ud.blkHdl, 'Name') '''. The number of ' ...
	    'ports must be a finite and positive integer.'], ...
	   'Error', 'modal');
  return;
end

% set bus signals's name
if get(ud.inputPopup, 'Value') == 2
  % in this case, just save all signal names listed into block's INPUTS
  % property. 
  signalArray = get(ud.signalList, 'String');
  sortedList  = sort(signalArray);
  
  for ll = 2:length(sortedList)
    if strcmp(sortedList(ll), sortedList(ll-1))
      errordlg(['Non-unique signal names specified in block ' ...
		get_param(ud.blkHdl, 'Name') ' .']);
      return;
    end
  end
  
  inputNames  = cellarr2str(signalArray);
  
  set_param(ud.blkHdl, 'Inputs', inputNames);
else
  % set number of inputs
  set_param(ud.blkHdl, 'Inputs', get(ud.inputEdit, 'string'));
end

if get(ud.specifyViaObjectCheckbox, 'value') == 1
  set_param(ud.blkHdl, 'UseBusObject', 'on')
  if get(ud.nonVirtCheckbox, 'value') == 1
    % If we select nonvirtual, make sure a bus object is specified, then set
    % it before selecting the box.
    if isempty(get(ud.objectEdit, 'String'))
      errordlg(['Invalid setting for ''Output as nonvirtual bus'' parameter; ' ...
                'this option may only be selected when a bus object is ' ...
                'specified.']);
      return;
    else
      set_param(ud.blkHdl, 'BusObject', get(ud.objectEdit, 'String'));
  end
  set_param(ud.blkHdl, 'NonVirtualBus', 'on')
  else
    % If we select virtual, turn off the switch before setting the bus
    % object in case the bus object is empty.
    set_param(ud.blkHdl, 'NonVirtualBus', 'off')
    set_param(ud.blkHdl, 'BusObject', get(ud.objectEdit, 'String'));
  end
else
  set_param(ud.blkHdl, 'UseBusObject', 'off')
end

% switch applyButton
toggleApply(applyButton, 'off');

set(hdl, 'UserData', ud);

% end doApply


% Function: doCancel ===========================================================
% Abstract:
%   This function will close the dialog without saving any change on it.
%
function doCancel(cancelButton, evd)

hdl = get(cancelButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

set(hdl, 'Visible', 'off');
set(hdl, 'UserData', ud);

if ~strcmp(get_param(bdroot(ud.blkHdl),'Lock'), 'on')
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  set_param(ud.blkHdl, 'Figure', hdl);
  warning(warningState);
else
  % delete the figure
  delete(hdl);
end

% end doCancel


% Function: doClose ============================================================
% Abstract:
%   This function will be called when the Bus Creator block is vanished.
%
function doClose(blkHdl)

if get_param(blkHdl, 'Figure') ~= -1
  hdl = get_param(blkHdl, 'Figure');
  if ~isempty(hdl) & ishandle(hdl)
    ud  = get(hdl, 'UserData');

    % un-hilite_system
    if ud.hilitedBlk ~= -1
      try
        set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
      catch
        % do nothing is pre-hilited block has already gone
      end
      ud.hilitedBlk = -1;
    end
    if ~strcmp(get_param(bdroot(blkHdl), 'Lock'), 'on')
      close(hdl);
      set_param(blkHdl, 'Figure', -1);
    end
  end
end

% end doClose


% Function: doDown =============================================================
% Abstract:
%   This function will move the selected signal one level down.
%
function doDown(downButton, evd)

hdl = get(downButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% switch applyButton
toggleApply(ud.applyButton);

idx = get(ud.signalList, 'Value');
str = get(ud.signalList, 'String');

tmp = str{idx+1};
str{idx+1} = str{idx};
str{idx}   = tmp;

set(ud.signalList, 'String', str);
set(ud.signalList, 'Value', idx+1);

doSignalList(ud.signalList, []);

% end doDown


% Function: doHelp =============================================================
% Abstract:
%   This fucntion will load online documentation for Bus Creator block.
%
function doHelp(helpButton, evd)

hdl = get(helpButton, 'Parent');
ud  = get(hdl, 'UserData');
slhelp(ud.blkHdl);

% end doHelp


% Function: doInputNumber ======================================================
% Abstract:
%   Set the number of input port for selected Bus Creator block
%
function doInputNumber(inputEdit, evd)

hdl = get(inputEdit, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% switch applyButton
toggleApply(ud.applyButton);

input = get(inputEdit, 'String');
[result, count] = sscanf(input, '%d%s');
if count ~= 1 | result <= 0
  errordlg(['Invalid number of ports specified in parameter "Inputs" of ' ...
	    'block ''' get_param(ud.blkHdl, 'Name') '''. The number of ' ...
	    'ports must be a finite and positive integer.'], ...
	   'Error', 'modal');
  return;
end

existingSignals = get(ud.signalList, 'String');
existingSelection = get(ud.signalList, 'Value');
newSignals = {};
numInputs = str2num(get(inputEdit,'String'));
if length(existingSignals) < numInputs
  newSignals = existingSignals;
  for i = 1 : numInputs-length(existingSignals)
    newSignals = [newSignals; {['Signal', num2str(length(newSignals)+1)]}];
  end
elseif length(existingSignals) > numInputs
  newSignals = existingSignals(1:numInputs);
  if existingSelection > numInputs
    existingSelection = numInputs;
  end
else
  newSignals = existingSignals;
end
set(ud.signalList,'String', newSignals, ...
		  'Value', existingSelection);
set(ud.renameEdit, 'String', newSignals(existingSelection));
  
% end doInputNumber


% Function: doInputPopup =======================================================
% Abstract:
%   When selection is "Inherit bus signal names from input ports", disable the
%   "Rename selected signals" edit field; otherwise, enable it to allow user
%   change selected signal's name.
%
function doInputPopup(inputPopup, evd)

hdl = get(inputPopup, 'Parent');
ud  = get(hdl, 'UserData');

% switch applyButton
toggleApply(ud.applyButton);

% refresh the whole dialog
doRefresh(ud.refreshButton, []);

% end doInputPopup


% Function: doFind =============================================================
% Abstract:
%   This function will find the selected signal in the mode by using
%   hilite_system.
%
function doFind(findButton, evd)

hdl = get(findButton, 'Parent');
ud  = get(hdl, 'UserData');

if get(ud.inputPopup, 'Value') == 2
  doApply(ud.applyButton, []);
end

blkHdl    = ud.blkHdl;
warningState = [warning; warning('query','backtrace')];
warning off backtrace;
warning on;
busStruct = get_param(blkHdl, 'BusStruct');
warning(warningState);

selected = get(ud.signalList, 'value');
signals  = get(ud.signalList, 'string');

if ~isempty(selected) & ~isempty(signals) & length(selected) == 1
  signal = signals{selected};
  % If this signal is from another bus, we need to find its bus first
  % so we construct a "." deliminated string to represent its hierachy.
  % For example, abc.xyz.signal means the signal name is "signal", and it is
  % from a bus block "xyz", which is from another bus block "abc".
  numBlanks = length(signal) - length(deblank(fliplr(signal)));
  for i=selected-1:-1:1
    if numBlanks == 0
      break;
    end
    prevSignal = signals{i};
    if ~strcmp(prevSignal(numBlanks-1), ' ')
      signal    = [deblankall(prevSignal(numBlanks+1:end)) '.' ...
		   deblankall(signal)];
      numBlanks = numBlanks - 2;
    end
  end

  % when the signal is from another bus, we need to find that signal.
  signalSrc = findbussrc(busStruct, signal);

  % don't hilite the Bus Creator associateed with this dialog
  if ~isempty(signalSrc)
    if signalSrc ~= blkHdl
      if ~isempty(signalSrc)
	% use 'find' scheme in hilite_system
	set_param(signalSrc, 'HiliteAncestors', 'find');
	ud.hilitedBlk = signalSrc;
      else
	msg = ['Unable to find signal named ' signals{selected} '.'];
	msgbox(msg, 'Bus Signal Locating Message', 'modal');
      end
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

doApply(ud.applyButton, evd);
doClose(ud.blkHdl);

% end doOK


% Function: doRefresh ==========================================================
% Abstract:
%   This function will refresh the dialog.
%
function doRefresh(refreshButton, evd)

hdl = get(refreshButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% parse the input signals (names and number)
[num, isNumber] = getInputs(ud.blkHdl, get(ud.inputPopup, 'value'));

% set the number of inputs
if ~isempty(num)
  set(ud.inputEdit, 'String', num2str(num));
end

% switch applyButton
toggleApply(ud.applyButton);

% update signal tree viewer
warningState = [warning; warning('query','backtrace')];
warning off backtrace;
warning on;
busTreeView('Create', ud.signalList, get_param(ud.blkHdl, 'BusStruct'));
warning(warningState);

% sync rename field
if get(ud.inputPopup, 'Value') == 2
  syncRenameEdit(ud);
else
  set([ud.renamePrompt ud.renameEdit], 'Enable', 'off');
end

% sync specify via object checkbox
if strcmp(get_param(ud.blkHdl, 'UseBusObject'), 'on')
  set(ud.specifyViaObjectCheckbox, 'value', 1);
  set([ud.nonVirtCheckbox ud.objectPrompt ud.objectEdit], 'Enable', 'on');
else
  set(ud.specifyViaObjectCheckbox, 'value', 0);
  set([ud.nonVirtCheckbox ud.objectPrompt ud.objectEdit], 'Enable', 'off');
end

% sync nonvirtual checkbox
if strcmp(get_param(ud.blkHdl, 'NonVirtualBus'), 'on')
  set(ud.nonVirtCheckbox, 'value', 1);
else
  set(ud.nonVirtCheckbox, 'value', 0);
end

% sync bus object
set(ud.objectEdit, 'string', get_param(ud.blkHdl, 'BusObject'));

% sync buttons
ud = syncButtons(ud);

% end doRefresh


% Function: doRename ===========================================================
% Abstract:
%   This function allow user to change the name of the selected signals.
%
function doRename(renameEdit, evd)

hdl = get(renameEdit, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% switch applyButton
toggleApply(ud.applyButton);

selected = get(ud.signalList, 'value');
signals  = get(ud.signalList, 'string');
if length(selected) > 1
  selected = selected(end);
  set(ud.signalList, 'value', selected);
end

% check if the current selected signal is a sub-bus
signal = signals{selected(end)};
validNameAt = max([findstr(signal, '+') findstr(signal, '-') 0]);
if strcmp(signal(1:end), '  ')
  validNameAt = 1;
end
if validNameAt == 0 | ~isempty(deblank(signal(1:validNameAt)))
  validNameAt = -1;
end

newStr = fliplr(deblank(fliplr(deblank(get(renameEdit, 'String')))));
errmsg = [];
if ~validateSignalName(newStr)
  return;
end

rowStr = signals{selected};
rowStr = [rowStr(1:validNameAt+1) newStr];
signals{selected} = rowStr;
set(ud.signalList, 'String', signals);

set(hdl, 'UserData', ud);

% end doRename


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
if figPos(3) < ud.origSize(1) | figPos(4) < 250
  set(hdl, 'Units', 'normalized');
  return;
end

allHdls = [hdl ud.desc ud.descTitle ud.descText ud.param ud.paramTitle ...
	   ud.inputPopup ud.inputPrompt ud.inputEdit ud.listPrompt ...
	   ud.signalList ud.renamePrompt ud.renameEdit ud.upButton ...
	   ud.downButton ud.refreshButton ud.specifyViaObjectCheckbox ...
           ud.objectEdit ud.objectPrompt ud.nonVirtCheckbox ...
           ud.okButton ud.cancelButton ud.helpButton ud.applyButton ...
           ud.findButton];
set(allHdls, 'Units', 'characters');

offset    = 1;
btnWidth  = 12;
btnHeight = 1.75;
txtMove   = .5;

figPos=get(hdl, 'Position');

% start from bottom row to top
posApply     = [figPos(3)-offset-btnWidth offset btnWidth btnHeight];
posHelp      = posApply;
posHelp(1)   = [posApply(1)-2*offset-btnWidth]; 
posCancel    = posHelp;
posCancel(1) = [posHelp(1)-2*offset-btnWidth]; 
posOK        = posCancel;
posOK(1)     = [posCancel(1)-2*offset-btnWidth]; 

% description frame
posDesc      = [offset figPos(4)-6*offset ...
		figPos(3)-2*offset 5*offset];
strExt       = get(ud.descTitle, 'extent');
posDescTitle = [3*offset posDesc(2)+posDesc(4)-strExt(4)*3/4 ...
		strExt(3:4)];
posDescText  = [posDesc(1)+txtMove posDesc(2)+txtMove ...
		posDesc(3)-offset posDesc(4)-offset];

% Parameters frame
posParam      = [offset posOK(2)+posOK(4)+offset ...
		 figPos(3)-2*offset ...
		 posDesc(2)-posOK(4)-3*offset];
strExt        = get(ud.paramTitle, 'extent');
posParamTitle = [3*offset posParam(2)+posParam(4)-strExt(4)*3/4 ...
		 strExt(3:4)];

% popup menu
strExt = get(ud.inputPopup, 'extent');
posInputPopup = [posParam(1)+offset ...
		 posParam(4)+posParam(2)-offset-strExt(4) ...
		 figPos(3)-4*offset strExt(4)];

% number of input prompt and edit field
strExt = get(ud.inputPrompt, 'extent');
posInputPrompt = [posInputPopup(1) posInputPopup(2)-strExt(4)-offset ...
		  strExt(3:4)];
posInputEdit   = [posInputPrompt(1)+posInputPrompt(3) posInputPrompt(2) ...
		  figPos(3)-posInputPrompt(3)-4*offset 1.2*posInputPrompt(4)];
		 
% listbox title
strExt = get(ud.listPrompt, 'extent');
posListPrompt = [posInputPrompt(1) posInputPrompt(2)-strExt(4)-txtMove ...
		 strExt(3:4)];

strExt = get(ud.nonVirtCheckbox, 'extent');
posNonVirtCheckbox = [2*offset posApply(2)+btnHeight+offset+txtMove ...
		   figPos(3)-4*offset strExt(4)];

strExt = get(ud.objectPrompt, 'extent');
posObjectPrompt = [2*offset posNonVirtCheckbox(2)+posNonVirtCheckbox(4)+txtMove ...
                 strExt(3:4)];

posObjectEdit   = [posObjectPrompt(1)+posObjectPrompt(3) posObjectPrompt(2) ...
                 figPos(3)-posObjectPrompt(3)-4*offset 1.2*posObjectPrompt(4)];

strExt = get(ud.specifyViaObjectCheckbox, 'extent');
posSpecifyViaObjectCheckbox = [2*offset posObjectPrompt(2)+posObjectPrompt(4)+txtMove ...
		   figPos(3)-4*offset strExt(4)];

% Rename edit field and prompt
strExt = get(ud.renamePrompt, 'extent');
posRenamePrompt = [2*offset posSpecifyViaObjectCheckbox(2)+posSpecifyViaObjectCheckbox(4)+txtMove ...
		   strExt(3:4)];
posRenameEdit   = [posRenamePrompt(1)+posRenamePrompt(3) posRenamePrompt(2) ...
		   figPos(3)-5*offset-btnWidth-posRenamePrompt(3) ...
		   1.2*posRenamePrompt(4)];

% treeview listbox
posSignalList = [posRenamePrompt(1) ...
		 posRenamePrompt(2)+txtMove+posRenamePrompt(4) ...
		 posRenamePrompt(3)+posRenameEdit(3) ...
		 posListPrompt(2)-1.5*offset-posRenamePrompt(2)];

% up, down & refresh buttons
posFind      = [posRenameEdit(1)+posRenameEdit(3)+offset ...
		posSignalList(2)+posSignalList(4)-btnHeight ...
		btnWidth btnHeight];
posUp      = [posFind(1) posFind(2)-offset-btnHeight btnWidth btnHeight];
posDown    = [posUp(1) posUp(2)-offset-btnHeight btnWidth btnHeight];
posRefresh = posUp;

% set objects' positions
set(ud.desc,          'Position', posDesc);
set(ud.descTitle,     'Position', posDescTitle);
set(ud.descText,      'Position', posDescText); 
set(ud.param,         'Position', posParam);
set(ud.paramTitle,    'Position', posParamTitle);
set(ud.inputPopup,    'Position', posInputPopup);
set(ud.inputPrompt,   'Position', posInputPrompt);
set(ud.inputEdit,     'Position', posInputEdit);
set(ud.listPrompt,    'Position', posListPrompt);
set(ud.signalList,    'Position', posSignalList);
set(ud.renamePrompt,  'Position', posRenamePrompt);
set(ud.renameEdit,    'Position', posRenameEdit);
set(ud.upButton,      'Position', posUp);
set(ud.downButton,    'Position', posDown);
set(ud.findButton,    'Position', posFind);
set(ud.refreshButton, 'Position', posRefresh);
set(ud.objectEdit,    'Position', posObjectEdit);
set(ud.specifyViaObjectCheckbox,  'Position', posSpecifyViaObjectCheckbox);
set(ud.objectPrompt,  'Position', posObjectPrompt);
set(ud.nonVirtCheckbox,  'Position', posNonVirtCheckbox);
set(ud.okButton,      'Position', posOK);
set(ud.cancelButton,  'Position', posCancel);
set(ud.helpButton,    'Position', posHelp);
set(ud.applyButton,   'Position', posApply);

set(allHdls, 'Units', 'normalized');

% end doResize


% Function: doSignalList =======================================================
% Abstract:
%   This function allows user to manipulate signals in the listbox.
%
function doSignalList(signalList, evd)

hdl = get(signalList, 'Parent');
ud  = get(hdl, 'UserData');
ud.signalList = signalList;

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% run treeview update
treeview('Update');

% switch applyButton
toggleApply(ud.applyButton);

% sync up/down/find buttons' states
ud = syncButtons(ud);

% if signal name change is allowed, enable the rename edit field
if get(ud.inputPopup, 'Value') == 2
  % sync rename eidt field
  syncRenameEdit(ud);
end

set(hdl, 'UserData', ud);

% end doSignalList


% Function: doUp ===============================================================
% Abstract:
%   This function will move the selected signal up one index if applicable.
%
function doUp(upButton, evd)

hdl = get(upButton, 'Parent');
ud  = get(hdl, 'UserData');

% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  ud.hilitedBlk = -1;
end

% switch applyButton
toggleApply(ud.applyButton);

idx = get(ud.signalList, 'Value');
str = get(ud.signalList, 'String');

tmp = str{idx-1};
str{idx-1} = str{idx};
str{idx}   = tmp;

set(ud.signalList, 'String', str);
set(ud.signalList, 'Value', idx-1);

doSignalList(ud.signalList, []);

% end doUp


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


% Function: getInputs ==========================================================
% Abstract:
%   This function will return the number of input signals in the block, and
%   if the input is in a string format delimitated by ",".
%
function [num, isNumber] = getInputs(blkHdl, mode)

errmsg = [];

inputs = get_param(blkHdl, 'Inputs');

[result, count] = sscanf(inputs, '%d%s');

if count ~= 1				% non-numerical integer
  num = 0;
  isNumber = 0;
  if mode == 1
    % in "Inherit bus signal names from input ports" mode, we need to get the
    % inputsignalnames from the block's input port information.
    inputs = get_param(blkHdl, 'InputSignalNames');
    num =length(inputs);
  else
    % if the input is a set of varaible name delimitated by ",", output the
    % string itself and the number of them.
    while ~isempty(inputs)
      [str, inputs] = strtok(inputs, ',');
      num = num + 1;
      if validateSignalName(str)
	% do nothing here
      end
    end
  end
else
  isNumber = 1;
  num      = result;
end

% end getInputs


% Function: openDialog =========================================================
% Abstract:
%   Function to create the block dialog for the selected Bus creator block if
%   it doesn't have one, or refresh the associated block dialog and make it
%   visible if it does.
%
function hdl = openDialog(blkHdl, busStruct)

% Check to see if block has a dialog
updateDataOnly = 0;
hdl = get_param(blkHdl, 'Figure');
if ~isempty(hdl) & ishandle(hdl) & hdl ~= -1
  figure(hdl);
  updateDataOnly = 1;
end

%
% If it is update only, then we don't have to create the dialog again.
%
if ~updateDataOnly
  hdl = createDialog(blkHdl, busStruct);
end

ud = get(hdl, 'UserData');

if ~strcmp(get_param(bdroot(blkHdl),'Lock'), 'on')
  % Update the signal list; turn apply off since refresh will turn on
  doRefresh(ud.refreshButton, []);
  toggleApply(ud.applyButton, 'off');
end

% Show the dialog
set(hdl, 'visible', 'on');

% end openDialog


% Function: deleteFcn ==========================================================
% Abstract: 
%   Get called when the dialog figure is deleted.
%
function deleteFcn(fig, evd)

ud = get(fig, 'UserData');
% un-hilite_system
if ud.hilitedBlk ~= -1
  try
    set_param(ud.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
end

% end deleteFcn


% Function: returnKeyOK ========================================================
% Abstract:
%   This function will be called when user use keyboard to enter command. Now
%   it only does one thing: when it's from Enter key, call doOK function.
%
function returnKeyOK(fig, evd)

ud = get(fig, 'UserData');

if ~isempty(get(fig, 'CurrentChar')) 	% unix keyboard has an empty key
  if (abs(get(fig, 'CurrentChar')) == 13)
    doOK(ud.okButton, []);
  end
end

% end returnKeyOK


% Function: struct2cellarr =====================================================
% Abstract:
%   This function will convert a struct array into a cell array
%   E.g., s(1).name = 'a';
%         s(1).signals(1).name    = 'b';
%         s(1).signals(1).signasl = [];
%         s(1).signals(2).name    = 'c';
%         s(1).signals(2).signal  = [];
%         s(2).name    = 'd';
%         s(2).signals = [];
%   will be converted to busData(1) = {'a'; {'b';'c'}}, bus(2)={'d'}.
%   Note: When inherit bus signal names fom input ports, only the direct
%   signal name will be shown. When user is allowed to specify the signal's
%   name, we will explore the whole bus structure. In the second case, this
%   is a recursive function.
%
function busData = struct2cellarr(busStruct, showType)

busData = {};
if ~isempty(busStruct)
  for i = 1:length(busStruct)
    busData(i,1) = {busStruct(i).name};
    if ~isempty(busStruct(i).signals) & showType == 1
      subBusStruct = busStruct(i).signals;
      subBusData   = struct2cellarr(subBusStruct, showType);
      busData(i, 1) = {[busData(i,1), {subBusData}]};
    else
      %do nothing
    end
  end
end

% end struct2cellarr


% Function: syncRenameEdit =====================================================
% Abstract:
%   Synchronize rename edit field according to selection
%
function syncRenameEdit(ud)

selected = get(ud.signalList, 'value');
signals  = get(ud.signalList, 'string');

set([ud.renamePrompt ud.renameEdit], 'Enable', 'on');

if ~isempty(selected)
  % set the current selected signal name into the edit field
  signal = signals{selected(end)};
  validNameAt = max([findstr(signal, '+') findstr(signal, '-') 0]);
  if strcmp(signal(1:end), '  ')
    validNameAt = 1;
  end
  if validNameAt == 0 | ~isempty(deblank(signal(1:validNameAt)))
    validNameAt = -1;
  end
  
  str = deblankall(signal(validNameAt+2:end));
else
  str = '';
end
set(ud.renameEdit, 'string', str);

% end syncRenameEdit


% Function: syncButtons ========================================================
% Abstract:
%   Synchronize the states of Up, Down and Find buttons.
%
function ud = syncButtons(ud)

selected = get(ud.signalList, 'value');
signals  = get(ud.signalList, 'string');

% can't find empty signal selection or multiple signals
findState = 'off';
if ~isempty(selected) & ~isempty(signals) & length(selected) == 1
  findState = 'on';
end

refreshState = 'off';
if get(ud.inputPopup, 'Value') == 1
  upState      = 'off';
  downState    = 'off';
  visibleS     = 'off';
  refreshState = 'on';
else
  visibleS  = 'on';
  % we have selections and a signalList
  upState   = 'on';
  downState = 'on';

  if length(selected) ~= 1
    % we can move only 1 selection up or down
    upState   = 'off';
    downState = 'off';
  else
    % there is only 1 value selected
    if selected == 1
      % first value selected
      upState = 'off';
    end    
    if selected == length(signals)
      % last value selected
      downState = 'off';
    end
  end
end

set(ud.upButton, 'Enable', upState, 'Visible', visibleS);
set(ud.downButton, 'Enable', downState, 'Visible', visibleS);
set(ud.findButton, 'Enable', findState);
set(ud.refreshButton, 'Visible', refreshState);

% end syncButtons


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


% Function: validate ===========================================================
% Abstract:
%   Detect the valid MATLAB variable.
% 
function valid = validate(var)
eval([var '=[];valid=1;'],'valid=0;')

% end validate


% Function: validateSignalName =================================================
% Abstract:
%   Detect if a signal name contains "," or ".".
% 
function valid = validateSignalName(str)

if  ~isempty([findstr(str, '.'), findstr(str, ',')])
  errmsg = ['The characters ''.'' and '','' are not allowed in signal ' ...
	    'name in Bus Creator block.'];
  errordlg(errmsg, 'Bus Creator Signal Name Error', 'modal');
  valid = 0;
else
  valid = 1;
end

% end validateSignalName


% Function: doSpecifyViaObjectCallback ==========================================================
% Abstract:
%   This function will refresh the dialog.
%
function doSpecifyViaObjectCallback(specifyViaObjectCheckbox, evd)

hdl = get(specifyViaObjectCheckbox, 'Parent');
ud  = get(hdl, 'UserData');

if get(ud.specifyViaObjectCheckbox, 'value') == 1
  set_param(ud.blkHdl, 'UseBusObject', 'on')
else
  set_param(ud.blkHdl, 'UseBusObject', 'off')
end

% refresh the whole dialog
doRefresh(ud.refreshButton, []);



% Function: doNonVirtualCallback ==========================================================
% Abstract:
%   This function will refresh the dialog.
%
function doNonVirtualCallback(nonVirtCheckbox, evd)

hdl = get(nonVirtCheckbox, 'Parent');
ud  = get(hdl, 'UserData');

% switch applyButton
toggleApply(ud.applyButton);



% Function: doBusObjectCallback =================================================
% Abstract:
%   This function will refresh the dialog.
%
function doBusObjectCallback(objectEdit, evd)

hdl = get(objectEdit, 'Parent');
ud  = get(hdl, 'UserData');

% switch applyButton
toggleApply(ud.applyButton);



% [EOF]
