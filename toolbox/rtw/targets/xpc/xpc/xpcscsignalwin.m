function xpcscsignalwin(scWinH)
% XPCSCSIGNALWIN - XPCSCOPE Helper Function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $ $Date: 2004/04/08 21:05:10 $

usrdata = get(scWinH, 'UserData');
figH = figure('Color', get(0, 'DefaultUiControlBackgroundColor'), ...
              'Position',usrdata.edit.subfigure.signals.position, ...
              'Number', 'off', ...
              'MenuBar', 'none', ...
              'HandleVisibility','off',...
              'IntegerHandle', 'off', ...
              'CloseRequestFcn', @xpcscsigwin_close, ...
              'Name', ['xPC Target: Add/Remove Signals for Scope ', ...
                    num2str(usrdata.edit.scopenumber)], ...
              'Tag','add_remove_figure');
usrdata.edit.subfigures.signals = figH;
setxpcfont(figH,8,9);
set(figH, 'Userdata', scWinH);

%-----------------------------------------------
% Listbox Add Signal
%-----------------------------------------------
uicontrol('Parent',             figH, ...
          'Units',              'normalized', ...
          'Position',           [0.03 0.03 0.46 0.92], ...
          'Style',              'frame', ...
          'Tag',                 'frm_addsignal');

uicontrol('Parent',              figH, ...
          'Units',               'normalized', ...
          'HorizontalAlignment', 'center', ...
          'Position',            [.05 .92 .15 .05], ...
          'String',              'SIGNAL LIST', ...
          'Style',               'text', ...
          'Tag',                 'ftl_addsignal');

uicontrol('Parent',              figH, ...
          'Units',               'normalized', ...
          'BackgroundColor',     [1 1 1], ...
          'Position',            [.05 .17 .42 .73], ...
          'String',              '', ...
          'Style',               'listbox', ...
          'CallBack',            @xpcscsigwin_lb_addsignal, ...
          'Tag',                 'lb_addsignal', ...
          'Value',               1);

uicontrol('Parent',   figH, ...
          'Units',    'normalized', ...
          'Position', [.15 .07 .2 .07], ...
          'String',   'Add Signal', ...
          'CallBack', @xpcscsigwin_pb_addsignal, ....
          'Tag','     pb_addsignal');

%-----------------------------------------------
% Listbox Remove Signal
%-----------------------------------------------
uicontrol('Parent',figH, ...
          'Units','normalized', ...
          'Position',[0.51 0.03 0.46 0.92], ...
          'Style','frame', ...
          'Tag','frm_remsignal');

uicontrol('Parent',figH, ...
          'Units','normalized', ...
          'HorizontalAlignment','center', ...
          'Position',[.53 .92 .23 .05], ...
          'String','SIGNALS TO TRACE', ...
          'Style','text', ...
          'Tag','ftl_remsignal');


uicontrol('Parent',figH, ...
          'Units','normalized', ...
          'BackgroundColor',[1 1 1], ...
          'Position',[.53 .17 .42 .73], ...
          'String', '', ...
          'Style','listbox', ...
          'Tag','lb_remsignal', ...
          'Value',1);

uicontrol('Parent',figH, ...
          'Units','normalized', ...
          'Position',[.65 .07 .2 .07], ...
          'Enable', 'off', ...
          'CallBack', @xpcscsigwin_pb_remsignal, ....
          'String', 'Remove Signal', ...
          'Tag','pb_remsignal');

handles = guihandles(figH);
setappdata(figH, 'Callbacks', ...
                 struct('pb_remsignal', @xpcscsigwin_pb_remsignal, ...
                        'pb_addsignal', @xpcscsigwin_pb_addsignal, ...
                        'lb_addsignal', @xpcscsigwin_lb_addsignal, ...
                        'CloseRequest', @xpcscsigwin_close));

if ~isempty(usrdata.edit.signals2trace)
  set(handles.pb_remsignal, 'Enable', 'on');
end

%txt_rem_signals = strrep(usrdata.edit.signals2trace, '.', '/');
set(handles.lb_remsignal, 'String', ...
                  strrep(usrdata.edit.signals2trace, '.', '/'));

usrdata = refresh_signals(usrdata, handles.lb_addsignal);

set(scWinH, 'userdata', usrdata);
guidata(figH, guihandles(figH));

%----------------------------------------
% push button Add Signal
%----------------------------------------
function xpcscsigwin_pb_addsignal(h, eventdata)
figH            = get(h,      'Parent');
scWinH          = get(figH,   'UserData');
usrdata         = get(scWinH, 'UserData');
handles         = guidata(figH);
txt_rem_signals = usrdata.edit.signals2trace;
txt_add_signals = usrdata.S.fnames;
num_add_signal  = get(handles.lb_addsignal, 'Value');
value           = num_add_signal;

if isempty(usrdata.S.modelpath)
  txt_add_signal = txt_add_signals{num_add_signal};
else
  value = value - 1;
  if get(handles.lb_addsignal, 'Value') ~= 1
    txt_add_signal = txt_add_signals{num_add_signal - 1};
  else
    return
  end
end

if usrdata.S.submodels(value)
  return
end

% test if signal is in list
if ~isempty(strmatch([usrdata.S.modelpath,'.',txt_add_signal], ...
                     txt_rem_signals, 'exact'))
  return
end

txt_rem_signals{end + 1} = [usrdata.S.modelpath,'.',txt_add_signal];
usrdata.edit.signals2trace = txt_rem_signals;
txt_rem_signals = strrep(txt_rem_signals, '.', '/');
%txt_rem_signals{1}(1)=[];
if isempty(usrdata.edit.api.signals2trace)
  [trace, color, colornum] = deal([]);
else
  [trace,color,colornum] = deal(usrdata.edit.api.signals2trace{:});
end

trace(end+1)=eval(['usrdata.S.model',[usrdata.S.modelpath,'.',txt_add_signal]]);
usrdata.edit.api.addsignalnr   = trace(end);
[usrdata,newcolor,newcolornum] = getcolor(usrdata);
[lengthcolor, nop]             = size(color);
color(lengthcolor+1,:)         = newcolor;
colornum(end + 1)              = newcolornum;
usrdata.edit.api.signals2trace = {trace, color, colornum};

usrdata = setcolorframe(usrdata);

usrdata = add_queue(usrdata, ...
                    'xpcgate(''addsig'',usrdata.edit.scopenumber,usrdata.edit.api.addsignalnr)');
usrdata = exec_queue(usrdata);

set(handles.lb_remsignal, 'String', txt_rem_signals);
set(handles.pb_remsignal, 'Enable', 'on');

if usrdata.edit.subfigures.trigger~=-1 & usrdata.edit.trigger.mode==3
  txt_list_signals = strrep(usrdata.edit.signals2trace, '.', '/');
  set(usrdata.subfigure.trigger.lb_signallist, 'String',txt_list_signals);
end
set(scWinH, 'userdata', usrdata);

%----------------------------------------
% push button Remove Signal
%----------------------------------------
function xpcscsigwin_pb_remsignal(h, eventdata)
figH            = get(h,      'Parent');
scWinH          = get(figH,   'UserData');
usrdata         = get(scWinH, 'UserData');
handles         = guidata(figH);
txt_rem_signals = usrdata.edit.signals2trace;
num_rem_signals = length(usrdata.edit.signals2trace);
num_rem_signal  = get(handles.lb_remsignal, 'Value');
iidx=strfind(txt_rem_signals{num_rem_signal},'._');
sig_to_be_rem=txt_rem_signals{num_rem_signal};
if ~isempty(iidx)
    sig_to_be_rem(iidx+1)='';
end    

usrdata.edit.api.remsignalnr = ...
    eval(['usrdata.S.model',sig_to_be_rem]);

if ~isempty(usrdata.edit.api.triggersignal)
  if usrdata.edit.api.triggersignal{1,1} == usrdata.edit.api.remsignalnr & ...
     usrdata.edit.trigger.mode           == 3
    errordlg('You cannot remove the Trigger Signal');
    return
  end
end

%last name in listbox
if num_rem_signals == num_rem_signal
  set(handles.lb_remsignal, 'Value', num_rem_signal - 1);
end

txt_rem_signals(num_rem_signal) = [];   % delete the appropriate one

%no names in listbox, disable pushbutton REMOVE
if num_rem_signals == 1
  set(handles.pb_remsignal, 'Enable', 'off');
  set(handles.lb_remsignal, 'Value', 1);
  txt_rem_signals = {};
  set(usrdata.figure.scope.pb_start, 'String', 'Start', ...
                    'CallBack','xpcscwin(-8)');
  xpcgate('scstop',usrdata.edit.scopenumber);
  scopemanager = get(usrdata.scopemanager.figure, 'Userdata');
  if length(scopemanager.handles.scopestart) == 1
    scopemanager.handles.scopestart = [];
    stopxpctimer(3);
  else
    if ~isempty(scopemanager.handles.scopestart)
      findscope=find(scopemanager.handles.scopestart==usrdata.figures.scope);
      scopemanager.handles.scopestart(findscope)=[];
    end
  end
  set(scopemanager.figure, 'UserData', scopemanager);
end

usrdata.edit.signals2trace = txt_rem_signals;
txt_rem_signals = strrep(txt_rem_signals, '.', '/');

[trace, color, colornum] = deal(usrdata.edit.api.signals2trace{:});
usrdata.edit.color.used(colornum(num_rem_signal)) = 0;

trace(num_rem_signal)    = [];
color(num_rem_signal,:)  = [];
colornum(num_rem_signal) = [];

usrdata.edit.api.signals2trace = {trace, color, colornum};

usrdata = setcolorframe(usrdata);

usrdata = add_queue(usrdata,'xpcgate(''remsignal'',usrdata.edit.scopenumber,usrdata.edit.api.remsignalnr)');
usrdata = exec_queue(usrdata);

if usrdata.edit.subfigures.trigger ~= -1 & usrdata.edit.trigger.mode == 3
  txt_list_signals = strrep(usrdata.edit.signals2trace, '.', '/');
  set(usrdata.subfigure.trigger.lb_signallist, 'Value',  1);
  set(usrdata.subfigure.trigger.lb_signallist, 'String', txt_list_signals);
end

set(handles.lb_remsignal, 'String', txt_rem_signals);
set(scWinH, 'userdata', usrdata);


%----------------------------------------
% Manage left panel
%----------------------------------------
function xpcscsigwin_lb_addsignal(h, eventdata)
scWinH  = get(get(h, 'Parent'), 'UserData');
usrdata = get(scWinH,           'UserData');
set(scWinH, 'UserData', callback_listbox(h, usrdata));

%----------------------------------------
% close figure
%----------------------------------------
function xpcscsigwin_close(h, eventdata)
scWinH  = get(h,      'UserData');
usrdata = get(scWinH, 'UserData');
delete(h);
usrdata.edit.subfigures.signals=-1;
set(scWinH, 'UserData', usrdata);


function usrdata = callback_listbox(lbH, usrdata)
value = get(lbH,'Value');
if ~isempty(usrdata.S.modelpath)
  value = value-1;
end

if value == 0 % .. pressed -> go up one step
  % dump everything from the last '.' onwards
  index = find(usrdata.S.modelpath == '.');
  usrdata.S.modelpath(index(end) : end) = [];
  usrdata = refresh_signals(usrdata, lbH);
else
  if usrdata.S.submodels(value)
    usrdata.S.modelpath = [usrdata.S.modelpath,'.',usrdata.S.fnames{value}];
    set(lbH,'Value',1);
    usrdata = refresh_signals(usrdata, lbH);
  end
end
