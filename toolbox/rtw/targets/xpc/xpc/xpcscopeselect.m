function varargout = xpcscopeselect(varargin)
% XPCSCOPESELECT xPC Target Simulink viewer helper function.
%
%   This function should not be called directly.
%
%   See also XPCSIMVIEW

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2004/04/08 21:05:09 $

if nargin == 0
    varargin = {'create', [], []};
elseif ~ischar(varargin{1})
    error('Unrecognized constructor');
end

% Evaluate function with correct number of outputs - FEVAL switchyard.
if nargout
    [varargout{1:nargout}] = feval(varargin{:});
else
    feval(varargin{:});
end

function fig = create(varargin)
% Open fig file with stored settings.  Note: This executes all component
% specific create functions with an empty HANDLES structure.
[fig] = openfig(mfilename,'reuse');

% Use system color scheme for figure:
set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));

% Generate HANDLES structure for use in setup and callbacks.
handles = guihandles(fig);

% Store HANDLES structure
guidata(fig, handles);

% Note: The HANDLES structure is now populated.
setup(fig, [], guidata(fig), varargin{:});
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function setup(h, eventdata, handles, dataName, data)
% Add custom initialization code here.
if isempty(dataName)
  return
end
popH = handles.xPCScopeSelPopup;
value  = get(popH, 'Value');
if value > length(data.ScopeList)
  value = length(data.ScopeList);
end

set(popH, 'String', data.PopupItems, ...
          'Value', value,            ...
          'UserData', struct('ScopeList', data.ScopeList, ...
                             'ScopeType', data.ScopeType));
name = data.SignalName;
if data.SignalWidth > 1
  name(end + 1 : end + 3) = '/s1';        % the first one
end

fvisibiltystat=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
figslvH = findobj('Type','Figure','Tag','xPCSLViewFigure');
set(0,'showhiddenhandles',fvisibiltystat);
modelname=xpcgate('getname');
s = xpcgate('getsignalid', name,modelname);
set(handles.xPCScopeSelDisplay, 'String', wrap(data.SignalName, 30), ...
        'UserData', struct('sigId', s, 'sigName', data.SignalName, ...
                           'sigWidth', data.SignalWidth));
set(handles.VectorSignalList, 'UserData', []);
setappdata(handles.VectorSignalList, 'Auto', 1);
fields = fieldnames(handles);
for i = 1 : length(fields)
  fun = [fields{i} '_Callback'];
  if isempty(which(fun)), continue, end
  cb.(fields{i}) = str2func(fun);
end
setappdata(h, 'Callbacks', cb);
updateGUI(handles);

% --------------------------------------------------------------------
function xPCScopeSelPopup_Callback(h, eventdata, handles)
updateGUI(handles);

% --------------------------------------------------------------------
function xPCScopeSelButton_Callback(h, eventdata, handles)
[changed, sigs, scId, scType] = updateGUI(handles);
if changed, return, end
state   = xpcgate('getscstate', scId);  % value is cached for use later

numsigs = length(sigs);
sigId   = getField(get(handles.xPCScopeSelDisplay, 'UserData'), 'sigId');
baseId  = sigId;
tmp     = get(handles.VectorSignalList, 'UserData');
if ~isempty(get(handles.VectorSignalList, 'UserData'))
  sigId  = sigId + tmp - 1;
end
remove = strcmp(get(h, 'String'), 'Remove Signal');

[scWinH, scMgrH] = findScopeWindow(scId, scType);

if remove & xpcgate('getsctriggermode', scId) == 3 & ... % signal trigger
      ismember(xpcgate('getsctriggersignal'),sigId)
  errordlg('You cannot remove the trigger Signal');
end

if (state ~= 3 & state ~= 4) % finished or interrupted
  if scMgrH < 0 | (scType == 1 & scWinH < 0)
    xpcgate('scstop', scId);
  else
    StartStopScopeViaGUI(scId, scType, scMgrH, scWinH, numsigs, 'stop');
  end
end

ud = get(handles.xPCScopeSelDisplay, 'UserData');
if strcmp(get(h,'String'), 'Add Signal')
  xpcgate('addsig', scId, sigId);
  for i = 1 : length(sigId)
    if ud.sigWidth > 1
      name = [ud.sigName, sprintf('/s%d', sigId(i) - baseId + 1)];
    else
      name = ud.sigName;
    end
    addSig2ScWin(scWinH, name, sigId(i), scType);
    numsigs = numsigs + 1;
  end
else
  xpcgate('remsignal', scId, sigId);
  for i = 1 : length(sigId)
    if ud.sigWidth > 1
      name = [ud.sigName, sprintf('/s%d', sigId(i) - baseId + 1)];
    else
      name = ud.sigName;
    end
    remSigFromScWin(scWinH, name, sigId(i), scType);
    numsigs = numsigs - 1;
  end
end

% if scope now has > 0 signals, restart it
if numsigs > 0
  if scMgrH < 0 | (scType == 1 & scWinH < 0)
    xpcgate('scstart', scId);
  else
    StartStopScopeViaGUI(scId, scType, scMgrH, scWinH, numsigs, 'start');
  end
elseif scType == 2 & scMgrH > 0
  StartStopScopeViaGUI(scId, scType, scMgrH, scWinH, numsigs, 'refresh');
end
updateGUI(handles);

% --------------------------------------------------------------------
function VectorSignalList_Callback(h, eventdata, handles)
setappdata(h, 'Auto', 0);
string = get(h, 'String');
if isempty(string)
  signals = [];
  setappdata(h, 'Auto', 1);
else
  signals = eval(get(h, 'String'), 'errordlg(lasterr)');
  width = getField(get(handles.xPCScopeSelDisplay, 'UserData'), 'sigWidth');
  if ~(isnumeric(signals) & ...         %
       prod(size(signals)) == length(signals) & ...
       all(double(uint32(signals)) == signals) & ...
       all(signals > 0) & all(signals < (width + 1)) & ...
       length(signals) == length(unique(signals)))
    errordlg({'You must enter a one-dimensional vector of unique positive', ...
              ['integers less than ' sprintf('%d', width + 1)]});
    set(handles.xPCScopeSelButton, 'Enable', 'off');
    return
  end
  sigsInSc = length(getappdata(handles.xPCScopeSelPopup, 'sigsInSc'));
  if (length(signals) > 10 - sigsInSc)
    str1 = sprintf('%d signals have previously been added to this scope', ...
                   sigsInSc);
    str2 = sprintf('the maximum number of signals you can add is %d.', ...
                   10 - sigsInSc);
    errordlg({str1, ...
              'Since a scope can have a maximum of 10 signals,', ...
              str2}, 'Too many signals');
    return
  end
end
set(h, 'UserData', double(signals));
updateGUI(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addSig2ScWin(h, name, id, scType)
if h < 0                                % the window is not open
  return
end

ud = get(h, 'UserData');
% Don't do anything if the signal already exists
if any(ud.edit.api.signals2trace{1} == id)
  return;
end
ud = deleteOtherWindows(ud);            % signal selection, trigger windows

name = getsignal(name);                 % convert to dotted form
if scType == 1                          % host
  [ud, clr, cNum] = getcolor(ud);       % get color for signal
end

ud.edit.signals2trace{end + 1}           = name;
ud.edit.api.signals2trace{1}(end + 1)    = id;
if scType == 1
  ud.edit.api.signals2trace{2}(end + 1, :) = clr;
  ud.edit.api.signals2trace{3}(end + 1)    = cNum;
  ud = setcolorframe(ud);
end
set(h, 'UserData', ud);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remSigFromScWin(h, name, sigId, scType)
if h < 0
  return                                % the window is not open
end
ud = get(h, 'UserData');                % scope window userdata
% if the signal is gone, don't bother
idx = find(ud.edit.api.signals2trace{1} == sigId);
if isempty(idx)
  return
end
if ~isempty(ud.edit.api.triggersignal)
  if (ud.edit.api.triggersignal{1} == sigId) & ud.edit.trigger.mode == 3
    errordlg('You cannot remove the Trigger Signal');
  end
end
ud = deleteOtherWindows(ud);            % signal selection, trigger windows
name = getsignal(name);                 % convert to dotted form

ud.edit.signals2trace(idx)                              = [];
ud.edit.api.signals2trace{1}(idx)                       = [];
if scType == 1                          % host
  ud.edit.api.signals2trace{2}(idx, :)                  = [];
  ud.edit.color.used(ud.edit.api.signals2trace{3}(idx)) = 0;
  ud.edit.api.signals2trace{3}(idx)                     = [];
  ud = setcolorframe(ud);
end
set(h, 'UserData', ud);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [h, scMgrH] = findScopeWindow(scNum, scType)
if scType == 1                          % host
  scMgrH = withhiddenhandles('findobj', 'Type', 'Figure', ...
                             'Tag', 'xPCTargetHostScopeManager');
else
  scMgrH = withhiddenhandles('findobj', 'Type', 'Figure', ...
                             'Name', 'xPC Target: Target Manager');
end
if isempty(scMgrH)
  scMgrH = -1;
  h      = -1;
  return
end
ud = get(scMgrH, 'UserData');
if scType == 1                          % host
  scWinH = ud.scopes(ud.scopes > 0);
  scUD = get(scWinH, 'UserData');
  if ~isa(scUD, 'cell')
    scUD = {scUD};
  end
  h = -1;
  for i = 1 : length(scUD)
    % scope number is in scUD{i}.edit.scopenumber
    if scNum == getfield(getfield(scUD{i}, 'edit'), 'scopenumber')
      h = scWinH(i);
      break
    end
  end
else
  h = ud.handles.xpctgscwin(scNum);
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w = wrap(w, width)
% remove stuff up to the first '/' and wrap the rest in 'width' columns
%idx = find(w == '/');
%w(1 : idx(1)) = [];
tmp = {};
l = min(length(w), width);
while l > 0
  tmp{end + 1} = w(1 : l);
  w(1 : l)     = [];
  l = min(length(w), width);
end
if length(tmp) == 1
  tmp = tmp{1};
end
w = tmp;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [changed, sigsInSc, scId, scType] = updateGUI(handles)
% changed reports whether the button string has changed.
% sigsInSc is the list of signals in the currently selected scope
% scId is the scope ID of the currently selected scope (NOT the array idx)
txtH     = handles.xPCScopeSelDisplay;
popH     = handles.xPCScopeSelPopup;
butH     = handles.xPCScopeSelButton;
sigListH = handles.VectorSignalList;
sigListL = handles.VectorSignalLabel;

ud       = get(txtH, 'UserData');
sigId    = ud.sigId;
sigWidth = ud.sigWidth;
ud       = get(popH, 'UserData');
scopes   = ud.ScopeList;
scTypes  = ud.ScopeType;
scId     = scopes( get(popH, 'Value'));
scType   = scTypes(get(popH, 'Value'));
sigsInSc = xpcgate('getscsignals', scId);
old      = get(butH, 'String');

setappdata(popH, 'sigsInSc', sigsInSc);

if isempty(sigId)
  set(txtH, 'String', '???', 'ForegroundColor', 'red');
  set(butH, 'Enable', 'off');
  changed = 1;
  return
end

if sigWidth > 1
  set([sigListH, sigListL], ...
      'Enable', 'on', 'Visible', 'on', ...
      'ToolTipString', ...
      sprintf(['Enter a list of elements to be added to\n', ...
               'or removed from this scope.\n', ...
               'This signal has a width of %d.'], sigWidth));
  set(txtH, 'ToolTipString', sprintf('Width: %d', sigWidth));
  if getappdata(sigListH, 'Auto')
    ud = [];                            % force refresh
  else
    ud = get(sigListH, 'UserData');
  end
  sigIdsPresent = intersect(1 : sigWidth, sigsInSc - sigId + 1);
  if isempty(ud)
    if ~isempty(sigIdsPresent)
      str      = ['[', sprintf('%d ', sigIdsPresent)];
      str(end) = ']';                   % replace last ' ' by ']'
    else
      str = '';
    end
    set(sigListH, 'UserData', sigIdsPresent, 'String', str);
  end
  ud = get(sigListH, 'UserData');
  addToScope = ~(unique(ismember(ud + sigId - 1, sigsInSc)));
  if length(addToScope) > 1             % contains both sigs in scope and not
    errordlg({'Some, but not all, of the signals you entered have',     ...
              'previously been added to this scope.',                   ...
              '',                                                       ...
              'Enter a vector containing either only previously added', ...
              'signals (to be removed), or only new signals (to be',    ...
              'added).',                                                ...
              '',                                                       ...
              'To see a list of signals that have previously been',     ...
              'added to this scope, delete the vector you entered',     ...
              'and press the enter key.'},                              ...
             'Add/Remove ambiguity', 'modal');

    set(butH, 'Enable', 'off');
    return
  end
else
  addToScope = ~ismember(sigId, sigsInSc);
  set([sigListH sigListL], 'UserData', [], 'Enable', 'off', 'Visible', ...
                    'off');
  setappdata(sigListH, 'Auto', 1);
  set(txtH, 'ToolTipString', '');
end

if isempty(addToScope)
  enable = 'off';
  new = 'Add/Remove';
else
  enable = 'on';
  if addToScope
    new = 'Add Signal';
  else
    new = 'Remove Signal';
  end
end

set(txtH, 'ForegroundColor', 'black');
set(butH, 'Enable', enable);

changed = ~strcmp(old, new);
if changed
  set(butH, 'String', new);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = deleteOtherWindows(ud)
h = ud.edit.subfigures.signals;
if h > 0
  cb = getappdata(h, 'Callbacks');
  feval(cb.CloseRequest, h, []);
  ud.edit.subfigures.signals = -1;
end
if ud.edit.subfigures.trigger > 0
  delete(ud.edit.subfigures.trigger);
  ud.edit.subfigures.trigger = -1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StartStopScopeViaGUI(scId, scType, scMgrH, scWinH, numsigs, action)
if scType == 1
  switch action
   case 'stop',
    xpcscwin(-9, [], scWinH);
   case 'start'
    xpcscwin(-8, [], scWinH);
  end
  return
else
  % find which pushbutton corresponds to the scope
  ud = get(scMgrH, 'UserData');
  % Only look in the visible ones to see which of the ones matches
  pbs = findobj(ud.figure, 'Type', 'UIControl', 'Style', 'PushButton', ...
               'Visible', 'On');
  pbH = pbs(strmatch(sprintf('Scope %d', scId), get(pbs, 'String'), 'exact'));
  % find the corresponding patch
  idx    = find(pbH == ud.tgscpb);
  patchH = ud.patch(idx);
  if numsigs > 0, str = 'on'; else str = 'off'; end
  set(ud.menu(idx).startstop, 'Enable', str);
  if ~strcmp(action, 'refresh')         % don't start/stop if it is refresh
    xpctgscope(-4, scMgrH, patchH);
  end
end


% --- Executes on button press in closePBscel.
function closePBscel_Callback(hObject, eventdata, handles)

delete(handles.xPCScopeSelFigure)
