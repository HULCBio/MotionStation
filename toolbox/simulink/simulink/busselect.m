function varargout = busselect(varargin)
% BUSSELECT   Creates the block dialog for the Bus Selector.
%   This function creates the block dialog for the Bus Selector block.
%   It consists of two frames. The left hand side frame contains a
%   listbox which lists all the bus signals in a tree hierarchy, along
%   with a select button whichallows the user to select multiple bus
%   signals at a time.
%   The right hand frame consists of a listbox which shows the
%   selections. There are four buttons which allow the user to
%   manipulate the order of the selected signals.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.34 $
%   Sanjai Singh 01-17-98
%   Modified by Jun Wu, Apr. 2001

dialog_handle = -1;
errorFlag     = 0;

if nargin==3
  BlockHandle   = varargin{1};
  Command       = varargin{2};
  Bus           = varargin{3};
  dialog_handle = OpenBlockDialog(BlockHandle, Bus);
end

if nargin==1
  switch varargin{1}
   case 'update'
    UpdateButtons;  
   case 'select'
    SelectSignals;
   case 'find'
    FindSignals;
   case 'refresh'
    RefreshSignals;
   case 'up'
    MoveUpSignals;
   case 'down'
    MoveDownSignals;
   case 'remove'
    RemoveSignals;
   case 'apply'
    errorFlag = ApplyDialog;
   case 'help'
    HelpDialog;
   case 'cancel'
    errorFlag = CloseDialog('cancel');
   case 'ok'
    errorFlag = CloseDialog('save');
   case 'resize',
    locResizeFig(gcbf);
  end
  
end

if nargin==2,
  blockH = varargin{2};
  switch varargin{1}
   case 'delete'
    DeleteDialog(blockH);
  case 'nameChange'
    UpdateDialogName(blockH);
  end
end

if (errorFlag)
  errordlg(lasterr);
end

if nargout,
  varargout{1}=dialog_handle;
end


% Function: OpenBlockDialog ====================================================
% Abstract: 
%   Function to create the block dialog for the selected Bus selector block.
%
function H = OpenBlockDialog(blockH, busData)

% Check to see if block has a dialog
updateDataOnly = 0;
H = get_param(blockH, 'Figure');
if ~isempty(H) & ishandle(H) & H ~= -1
  figure(H)
  updateDataOnly = 1;
end

% If it is update only, then we don't have to create
% the dialog again.
if ~updateDataOnly
  H = CreateBlockDialog(blockH, busData);
end

Data = get(H, 'UserData');

if ~strcmp(get_param(bdroot(blockH),'Lock'), 'on')
  % Update the signal list
  if updateDataOnly
    treeview('Create', Data.TreeList, busData);
  end
  
  % Update the selected list
  if updateDataOnly
    inputArray = StripSelection(get(Data.SelectedList, 'String'));
  else
    inString = get_param(blockH, 'OutputSignals');
    inputArray = DelimitString(inString, ',');
  end
  modifiedArray = CheckSelection(inputArray, busData);
  set(Data.SelectedList, 'String', modifiedArray)
end
  
% Show the dialog
set(H, 'visible', 'on');

% Function: locResizeFig =======================================================
% Abstract:
%
function locResizeFig(figHandle)

Data=get(figHandle,'UserData');

set(figHandle,'Units','pixels');
figPos=get(figHandle,'Position');
if figPos(3)<Data.origSize(1) | figPos(4) < 290,
  set(figHandle,'Units','normalized');
  return
end

allHandles=[figHandle Data.F0 Data.T0 Data.L0 Data.F1 Data.T1 Data.F2 ...
	    Data.T2 Data.TreeList Data.SelectedList Data.MuxedOutput ...
	    Data.UpButton Data.DownButton Data.RemoveButton Data.FindButton ...
	    Data.SelectButton Data.RefreshButton Data.OKButton ...
	    Data.CancelButton Data.HelpButton Data.ApplyButton];

set(allHandles,'Units','characters');

offset=1;
btnWidth=12;
btnHeight=1.75;
txtMove=.5;

figPos=get(figHandle,'Position');

% Start on bottom row
posApply = [figPos(3)-offset-btnWidth offset btnWidth btnHeight];

posHelp = posApply;
posHelp(1)=[posApply(1)-2*offset-btnWidth]; 

posCancel = posHelp;
posCancel(1)=[posHelp(1)-2*offset-btnWidth]; 

posOK = posCancel;
posOK(1)=[posCancel(1)-2*offset-btnWidth]; 

posT0=get(Data.T0,'Position');

posL0 = get(Data.L0,'Position');
posL0(3) = figPos(3)-4*offset;
set(Data.L0,'Position',posL0);
txt = char(get(Data.L0,'String'));
txttmp='';
for lp=1:size(txt,1),
  txttmp=[txttmp deblank(txt(lp,:)) ' '];
end
txt = {strrep(txttmp,sprintf('\n'),' ')};
[L0String,L0pos] = textwrap(Data.L0,txt);
set(Data.L0,'String',L0String);

t0e = get(Data.T0,'Extent');
L0e = get(Data.L0, 'Extent');
T1e = get(Data.T1, 'Extent');
T2e = get(Data.T2, 'Extent');

fWidth = (figPos(3)-3*offset-(2*offset+btnWidth))/2;

posT0 = [2*offset figPos(4)-t0e(4) t0e(3) t0e(4)];

posF0(4)=L0e(4)+2*offset;
posF0=[offset posT0(2)-posF0(4) figPos(3)-2*offset posF0(4) ];

posL0=[2*offset posF0(2)+offset posF0(3)-2*offset posF0(4)-2*offset];

posT0(2)=posT0(2)-txtMove;

posT1=[2*offset posF0(2)-T1e(4)-offset T1e(3) T1e(4)];
posF1=[offset sum(posOK([2 4]))+offset fWidth 1];
posF1(4)=posT1(2)-posF1(2);
posSelect=[sum(posF1([1 3]))-offset-btnWidth posF1(2)+offset ...
	   btnWidth btnHeight];
posRefresh = posSelect;
posRefresh(1)=posSelect(1)-offset-btnWidth;
posFind=posRefresh;
posFind(1)=posL0(1)+offset;
posTree=[posF1(1)+offset sum(posRefresh([2 4]))+offset posF1(3)-2*offset 1];
posTree(4)=sum(posF1([2 4]))-offset-posTree(2);
posT1(2)=posT1(2)-txtMove;

posT2=posT1;
posF2=posF1;
posF2(1)=sum(posF1([1 3]))+offset;
posF2(3)=figPos(3)-offset-posF2(1);
posT2(1)=posF2(1)+offset;
posUp=[posF2(1)+offset sum(posF1([2 4]))-offset-btnHeight btnWidth btnHeight];

posDown=posUp;
posDown(2)=posUp(2)-offset-btnHeight;
posRemove=posDown;
posRemove(2)=posDown(2)-offset-btnHeight;
posMuxed=[sum(posRemove([1 3]))+offset posF2(2)+offset 1 btnHeight];
posMuxed(3)=sum(posF2([1 3]))-offset-posMuxed(1);
posSelected=[posMuxed(1) sum(posMuxed([2 4]))+offset posMuxed(3) 1];
posSelected(4)=sum(posF1([2 4]))-offset-posSelected(2);

allPos=[posF0; posT0; posL0; posF1; posT1; posF2; posT2; posTree; posSelected;
	posMuxed;posUp;posDown;posRemove;posSelect;posRefresh;posFind;posOK;
	posCancel;posHelp;posApply];

set(Data.F0,'Position',posF0);
set(Data.T0,'Position',posT0);
set(Data.L0,'Position',posL0);
set(Data.F1,'Position',posF1);
set(Data.T1,'Position',posT1);
set(Data.F2,'Position',posF2);
set(Data.T2,'Position',posT2);
set(Data.TreeList,'Position',posTree);
set(Data.SelectedList,'Position',posSelected);
set(Data.MuxedOutput,'Position',posMuxed);
set(Data.UpButton,'Position',posUp);
set(Data.DownButton,'Position',posDown);
set(Data.RemoveButton,'Position',posRemove);
set(Data.SelectButton,'Position',posSelect);
set(Data.RefreshButton,'Position',posRefresh);
set(Data.FindButton,'Position',posFind);
set(Data.OKButton,'Position',posOK);
set(Data.CancelButton,'Position',posCancel);
set(Data.HelpButton,'Position',posHelp);
set(Data.ApplyButton,'Position',posApply);

set(allHandles,'Units','normalized');


% Function: CreateBlockDialog ==================================================
%
function H = CreateBlockDialog(blockH, busData)  

gray = get(0,'defaultuicontrolbackgroundcolor');
%
% Create the figure for the block dialog
%
dialogPos = [1 1 580 480];
H = figure(...
    'numbertitle', 'off',...
    'name',        ['Block Parameters: ' get_param(blockH, 'name')], ...
    'menubar',     'none', ...
    'visible',     'off', ...
    'HandleVisibility', 'callback', ...
    'IntegerHandle','off', ...
    'color',        gray, ...
    'Units',        'pixels', ...
    'Resize',       'on', ...
    'Position',     dialogPos);
set(H, 'DeleteFcn', {@DeleteFcn});

Data.BlockHandle = blockH; 
Data.BlockDialogHandle = H;

% Create MAIN frame
Data.F0 = uicontrol(H, ...
		    'style', 'frame', ...
		    'backgroundcolor', gray ...
		    );

Data.T0 = uicontrol(H, ...
		    'style','text', ...
		    'backgroundcolor', gray, ...
		    'String', 'Bus Selector');

DescStr = get_param(blockH, 'BlockDescription');

Data.L0 = uicontrol(H, ...
		    'style', 'text', ...
		    'backgroundcolor', gray, ...
		    'max', 2, ...
		    'min', 0, ...
		    'horizontalalignment', 'left', ...
		    'value', [], ...
		    'String', DescStr);

%
% Create 2 frames and their titles
%
Data.F1 = uicontrol(H, ...
		    'style', 'frame', ...
		    'backgroundcolor', gray);

Data.T1 = uicontrol(H, ...
		    'style','text', ...
		    'backgroundcolor', gray, ...
		    'String', 'Signals in the bus');

Data.F2 = uicontrol(H, ...
		    'style', 'frame', ...
		    'backgroundcolor', gray);

Data.T2 = uicontrol(H, ...
		    'style','text', ...
		    'backgroundcolor', gray, ...
		    'String', 'Selected signals');       
%
% Create the 2 listboxes to hold the Bus information
% and the selected data.
%
try
  Data.TreeList = treeview('Create', H, busData);
  set(Data.TreeList,'FontName','FixedWidth');
catch
  errordlg('Incorrect signal specification');
  close(H)
  return
end

Data.SelectedList = uicontrol(H, ...
			      'Style', 'Listbox', ...
			      'Max', 2, ...
			      'Min', 0, ...
			      'FontName','FixedWidth', ...
			      'Callback', 'busselect update;', ...
			      'String', {}, ...
			      'Value', [], ...
			      'Backgroundcolor', [1 1 1]);

muxValue = get_param(blockH, 'MuxedOutput');

Data.MuxedOutput = uicontrol(H, ...
			     'Style', 'checkbox', ...
			     'Value', strcmp(muxValue, 'on'), ...
			     'backgroundcolor', gray, ...
			     'Enable', 'on', ...
			     'HorizontalAlignment', 'left', ...
			     'String', 'Muxed output');

% 
% Create the buttons that will be used to manipulate the selection
% list 
%
Data.UpButton = uicontrol(H, ...
			  'Style', 'pushbutton', ...
			  'backgroundcolor', gray, ...
			  'String', 'Up', ...
			  'Enable', 'off', ...
			  'Callback', 'busselect up;');

Data.DownButton = uicontrol(H, ...
			    'Style', 'pushbutton', ...
			    'backgroundcolor', gray, ...
			    'String', 'Down', ...
			    'Enable', 'off', ...
			    'Callback', 'busselect down;');

Data.RemoveButton = uicontrol(H, ...
			      'Style', 'pushbutton', ...
			      'backgroundcolor', gray, ...
			      'String', 'Remove', ...
			      'Enable', 'off', ...
			      'Callback', 'busselect remove;');

%
% Create the buttons for bus list
%
Data.SelectButton = uicontrol(H, ...
			      'Style', 'pushbutton', ...
			      'backgroundcolor', gray, ...
			      'String', 'Select >>', ...
			      'Callback', 'busselect select;');

%
% Create the refresh button
%
Data.RefreshButton = uicontrol(H, ...
			       'Style', 'pushbutton', ...
			       'backgroundcolor', gray, ...
			       'String', 'Refresh', ...
			       'Callback', 'busselect refresh;');

%
% Create the find button
%
Data.FindButton = uicontrol(H, ...
			    'Style',           'pushbutton', ...
			    'backgroundcolor', gray, ...
			    'String',          'Find', ...
			    'Callback',        'busselect find;');

%
% Create the "standard" buttons 
%
Data.OKButton = uicontrol(H, ...
			  'Style', 'pushbutton', ...
			  'backgroundcolor', gray, ...
			  'String', 'OK', ...
			  'Callback', 'busselect ok;');

Data.CancelButton = uicontrol(H, ...
			      'Style', 'pushbutton', ...
			      'Backgroundcolor', gray, ...
			      'String', 'Cancel', ...
			      'Callback', 'busselect cancel;');

Data.HelpButton = uicontrol(H, ...
			    'Style', 'pushbutton', ...
			    'Backgroundcolor', gray, ...
			    'Enable', 'on', ...
			    'String', 'Help', ...
			    'Callback', 'busselect help;');

Data.ApplyButton = uicontrol(H, ...
			     'Style', 'pushbutton', ...
			     'backgroundcolor', gray, ...
			     'String', 'Apply', ...
			     'Callback', 'busselect apply;');

Data.origSize=[0 0];
Data.hilitedBlk = -1;
set(H,'UserData',Data);
locResizeFig(H);

set(H,'Units','pixels');
dialogPos = get(H,'Position');
bdPos     = get_param(get_param(gcb, 'Parent'),'Location');
blkPos    = get_param(gcb, 'Position');
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

Data.origSize=dialogPos(3:4);

set(H, ...
    'Position',  dialogPos, ...
    'Units',     'normalized', ...
    'UserData',  Data, ...
    'ResizeFcn', 'busselect resize');

%
% Update the userdata only if it is a changeable block
% else show a disabled version of the gui.
%
if ~strcmp(get_param(bdroot(blockH),'Lock'), 'on')
  if strcmp(get_param(blockH, 'LinkStatus'), 'none')
    set_param(blockH, 'Figure', H)
  else
    UiControls = [Data.OKButton; Data.ApplyButton; Data.RefreshButton];
    set(UiControls, 'enable', 'off');
  end
else
  UiControls = [Data.TreeList; Data.SelectedList; Data.MuxedOutput; ...
                Data.UpButton; Data.DownButton; Data.RemoveButton; ...
                Data.SelectButton; Data.FindButton; Data.T1; Data.T2; ...
                Data.OKButton; Data.ApplyButton; Data.RefreshButton];
  set(UiControls, 'enable', 'off');
end

% Function: ApplyDialog ========================================================
%
function errFlag = ApplyDialog
H       = gcbf;
errFlag = 0;

Data = get(H, 'UserData');

% un-hilite hilited system
if Data.hilitedBlk ~= -1
  try
    set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  Data.hilitedBlk = -1;
end

blockH = Data.BlockHandle;
signalList = get(Data.SelectedList, 'string');

if ~isempty(signalList)
  signals = StripSelection(signalList);
  signals = signals(:)';
  signals(2,:) = {','};
  selSignals = cat(2, signals{:});
  selSignals(end) = [];
else
  selSignals = 'empty';
end

muxedValue = get(Data.MuxedOutput, 'value');
muxed = 'off';
if muxedValue==1
  muxed = 'on';
end

% Perform the set_param only if parameters have changed
CurrentOutSignals = get_param(blockH, 'OutputSignals');
CurrentMuxed      = get_param(blockH, 'MuxedOutput');

setNeeded = 1;
if (strcmp(CurrentOutSignals, selSignals) & strcmp(CurrentMuxed, muxed))
  setNeeded = 0;
end

if setNeeded
  try 
    set_param(blockH, ...
	      'OutputSignals',selSignals, ...
	      'MuxedOutput', muxed)
  catch
    errFlag = 1;
  end
end

set(H, 'UserData', Data);


% Function: CloseDialog ========================================================
%
function errorFlag = CloseDialog(action)

errorFlag = 0;
if strcmp(action, 'save')
  errorFlag = ApplyDialog;
end

if errorFlag==0
  H = gcbf;
  Data = get(H, 'userdata');
  
  if ~strcmp(get_param(bdroot(Data.BlockHandle),'Lock'), 'on')
    % un-hilite hilited system
    if Data.hilitedBlk ~= -1
      try
        set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
      catch
        % do nothing is pre-hilited block has already gone
      end
      Data.hilitedBlk = -1;
    end
    if strcmp(get_param(Data.BlockHandle, 'LinkStatus'), 'none')
      set_param(Data.BlockHandle, 'Figure', -1)
    end
    close(H);
  else
    delete(H);
  end
end


% Function: HelpDialog =========================================================
%
function HelpDialog

H = gcbf;
Data = get(H, 'userdata');
slhelp(Data.BlockHandle);


% Function: DeleteDialog =======================================================
%
function errorFlag = DeleteDialog(blockH)

H = get_param(blockH, 'Figure');
if ~isempty(H) & ishandle(H) & H ~= -1
  Data = get(H, 'userdata');
  
  % un-hilite hilited system
  if Data.hilitedBlk ~= -1
    try
      set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
    catch
      % do nothing is pre-hilited block has already gone
    end
    Data.hilitedBlk = -1;
  end
  
  if ~strcmp(get_param(bdroot(blockH), 'Lock'), 'on')
    close(H);
    set_param(blockH, 'Figure', -1);
  end
end


% Function: DeleteFcn ==========================================================
% Abstract: 
%   Get called when the dialog figure is deleted.
%
function DeleteFcn(H, evd)

Data = get(H, 'UserData');
% un-hilite_system
if Data.hilitedBlk ~= -1
  try
    set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
end


% Function: UpdateDialogName ===================================================
%
function errorFlag = UpdateDialogName(blockH)

H = get_param(blockH, 'Figure');
if ~isempty(H) & ishandle(H) & H ~= -1
  set(H, 'name', ['Block Parameters: ' get_param(blockH, 'name')])
end


% Function: SelectSignals ======================================================
%
function SelectSignals

H = gcbf;

Data = get(H, 'UserData');
selected = get(Data.TreeList, 'value');
treeData = get(Data.TreeList, 'userdata');

[dispData idx] = FindDisplayedData(treeData);

if ~isempty(selected)
  newSignals = {dispData(selected).Fullname};
  existingSignals = get(Data.SelectedList, 'String');
  if isempty(existingSignals)
    allSignals = newSignals(:);
  else
    allSignals = [existingSignals(:); newSignals(:)];
  end
  set(Data.SelectedList, 'String', allSignals)
  set(Data.SelectedList, 'Value', [])
  set(Data.TreeList,     'Value', [])
end


% Function: RefreshSignals =====================================================
%
function RefreshSignals

H    = gcbf;
Data = get(H, 'UserData');
open_system(Data.BlockHandle);

% un-hilite hilited system
if Data.hilitedBlk ~= -1
  try
    set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  Data.hilitedBlk = -1;
end

set(H, 'UserData', Data);


% Function: FindSignals ========================================================
%
function FindSignals

H    = gcbf;
Data = get(H, 'UserData');

warningState = [warning; warning('query','backtrace')];
warning off backtrace;
warning on;
busStruct = get_param(Data.BlockHandle, 'BusStruct');
warning(warningState);

selected = get(Data.TreeList, 'Value');
signals  = get(Data.TreeList, 'String');

% un-hilite previously hilited blocks
if Data.hilitedBlk ~= -1
  try
    set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end
  Data.hilitedBlk = -1;
end

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

  % don't hilite the Bus Selector associated with this dialog
  if ~isempty(signalSrc)
    if signalSrc ~= Data.BlockHandle
      if ~isempty(signalSrc)
	% use 'find' scheme in hilite_system
	set_param(signalSrc, 'HiliteAncestors', 'find');
	Data.hilitedBlk = signalSrc;
      else
	msg = ['Unable to find signal named ' signals{selected} '.'];
	msgbox(msg, 'Bus Signal Locating Message', 'modal');
      end
    end
  end
end

set(H, 'UserData', Data);


% Function: SyncHilite =========================================================
%
function SyncHilite

H    = gcbf;
Data = get(H, 'UserData');

if Data.hilitedBlk ~= -1
  try
    set_param(Data.hilitedBlk, 'HiliteAncestors', 'off');
  catch
    % do nothing is pre-hilited block has already gone
  end

  Data.hilitedBlk = -1;
end

set(H, 'UserData', Data);


% Function: RemoveSignals ======================================================
%
function RemoveSignals

H = gcbf;
Data = get(H, 'UserData');
selected = get(Data.SelectedList, 'value');
signalList = get(Data.SelectedList, 'string');
signalList(selected) = [];
set(Data.SelectedList, 'string', signalList);

% Highlight the next choice
if length(signalList) >= selected
  set(Data.SelectedList, 'value', selected)
else
  set(Data.SelectedList, 'value', length(signalList))
end

UpdateButtons


% Function: MoveUpSignals ======================================================
%
function MoveUpSignals

H = gcbf;
Data = get(H, 'UserData');
selected = get(Data.SelectedList, 'value');
signalList = get(Data.SelectedList, 'string');
signalList([selected-1 selected]) = signalList([selected selected-1]);
set(Data.SelectedList, 'string', signalList);
set(Data.SelectedList, 'value', selected-1)
UpdateButtons


% Function: MoveDownSignals ====================================================
%
function MoveDownSignals

H = gcbf;
Data = get(H, 'UserData');
selected = get(Data.SelectedList, 'value');
signalList = get(Data.SelectedList, 'string');
signalList([selected+1 selected]) = signalList([selected selected+1]);
set(Data.SelectedList, 'string', signalList);
set(Data.SelectedList, 'value', selected+1)
UpdateButtons


% Function: UpdateButtons ======================================================
%
function UpdateButtons

H = gcbf;
Data = get(H, 'UserData');
selected = get(Data.SelectedList, 'value');
signalList = get(Data.SelectedList, 'string');

if isempty(selected) | isempty(signalList)
  upState = 'off';
  downState = 'off';
  removeState = 'off';
else
  % we have selections and a signalList
  upState = 'on';
  downState = 'on';
  removeState = 'on';

  if length(selected) ~= 1
    % we can move only 1 selection up or down
    upState = 'off';
    downState = 'off';
  else
    % there is only 1 value selected
    if selected==1
      % first value selected
      upState = 'off';
    end    
    if selected==length(signalList)
      % last value selected
      downState = 'off';
    end
  end
  
end

set(Data.UpButton, 'Enable', upState)
set(Data.DownButton, 'Enable', downState)
set(Data.RemoveButton, 'Enable', removeState)
  
    
% Function: FindDisplayedData ==================================================
%
function [dd, idx] = FindDisplayedData(ud)

dd  = ud;
idx = [];
rem = [];

for i = 1:length(ud)
  if ud(i).IsDisplayed
    idx = [idx i];
  else
    rem = [rem i];
  end
end
dd(rem) = [];

% Function: DelimitString ======================================================
%
function array = DelimitString(str, sep)

array = {};
idx = find(str == sep);

if ~isempty(idx)
  idx = [0 idx length(str)+1];
  for i = 1:length(idx)-1
    % we have that many signals
    array{i} = str(idx(i)+1:idx(i+1)-1);
  end
else
  array{1} = str;
end


% Function: CheckSelection =====================================================
%
function modArray = CheckSelection(inArray, data)

modArray = inArray;

if isstruct(data)
  for i = 1:length(inArray)
    try
      eval(['data.' inArray{i} ';'])
    catch
      modArray{i} = ['??? ' inArray{i}];
    end   
  end
end

if iscell(data)

  for i = 1:length(inArray)

    delimArray = DelimitString(inArray{i}, '.');
    currData = data;
    preStr   = '';

    for k = 1:length(delimArray)
      currName = delimArray{k};
      found = 0;

      for j = 1:length(currData)

	if iscell(currData{j})
	  compareName = currData{j}{1};
	else
	  compareName = currData{j};
	end	  
	    
	if strcmp(currName, compareName)
	  found = 1;
	  if iscell(currData{j})
	    currData = currData{j}{2};
	  end
	  break;
	end
      end
	
      if (found==0)
	preStr = '??? ';
	break;
      end
    end
      
    modArray{i} = [preStr inArray{i}];      
  end

end

% Function: StripSelection =====================================================
%
function modArray = StripSelection(inArray)

modArray = strrep(inArray, '??? ', '');

