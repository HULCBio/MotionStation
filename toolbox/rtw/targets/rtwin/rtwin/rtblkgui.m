function rtblkgui(varargin)
%RTBLKGUI Generic input and output block GUI.
%   RTBLKGUI is the GUI interface to the Real-Time Windows Target all Input
%   and Output blocks.
%
%   Not to be called directly.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.24.2.2 $  $Date: 2003/12/31 19:45:54 $  $Author: batserve $

feval(varargin{:});    % the switchyard



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  OPEN
%  opens the GUI window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Open(device)

% if window exists, just bring it to front

H.bh = gcbh;
figh = findobj(GetAllGUIs, 'flat', 'UserData',H.bh);
if ~isempty(figh)
  figure(figh);
  return;
end

% store the block handle, prepare IO device tables

iolab = struct( 'abbrev', {'AI','AO','DI','DO','CI','TO','EI','OI','OO'}, ...
                'full', {'Analog In','Analog Out','Digital In','Digital Out','Counter In','Timer Out','Encoder In','Other In','Other Out'}, ...
                'inout', {'In','Out','In','Out','In','Out','In','In','Out'}, ...
                'outin', {'out','in','out','in','out','in','out','out','in'}, ...
                'figh', {344, 434, 321, 411, 375, 411, 389, 334, 424} ...
              );

% prepare Enable on/off strings for model and locked library

H.rooth = bdroot(H.bh);
H.islocked = strcmp(get_param(H.rooth, 'Lock'), 'on');
if H.islocked
  libtune = 'off';
else
  libtune = 'on';
end

% find device index

H.device = device;
deviceidx = find(strcmp({iolab.abbrev}, device));
FIGW = 370;
FIGH = iolab(deviceidx).figh;
           
% compute the figure position

spos = get(0,'ScreenSize');
parent = get_param(H.bh, 'Parent');
fpos = get_param(parent, 'Location');
bpos = str2double(get_param(parent, 'ZoomFactor')) * get_param(H.bh, 'Position') / 100;
pos = [fpos(1)+bpos(3)+10 (spos(4)-fpos(2)-(bpos(2)+bpos(4)+FIGH)/2)];
if pos(1)+FIGW > spos(3)
  pos(1) = fpos(1)+bpos(1)-10-FIGW;
end
pos = max(min(pos, spos(3:4)-[FIGW+4 FIGH+20]), [4 34]);

% create the figure

figh = dialog('Position',[pos FIGW FIGH],'HandleVisibility','on', 'WindowStyle', 'normal', ...
              'Visible','off', 'Name', ['Block Parameters: ' iolab(deviceidx).full 'put'], ...
              'Tag','RTWin_RTBLKGUI');

% create buttons

uicontrol('Position',[27 4 75 23], 'String','OK', 'Callback','rtblkgui(''Apply'',1);');
uicontrol('Position',[108 4 75 23], 'String','Cancel', 'Callback','close');
uicontrol('Position',[189 4 75 23], 'String','Help', 'Callback','doc rtwin');
uicontrol('Position',[270 4 75 23], 'String','Apply', 'Enable',libtune, 'Callback','rtblkgui(''Apply'',0);');

% create title frame and text

if strcmp(get_param(H.bh, 'LinkStatus'), 'resolved')
  linkst = ' (link)';
else
  linkst = '';
end
Frame3D([5 FIGH-49 360 38], ['RTWin ' iolab(deviceidx).full 'put (mask)' linkst]);
uicontrol('Style','text', 'Position',[12 FIGH-44 260 20], 'HorizontalAlignment','left', ...
          'String',get_param(H.bh,'MaskDescription'));

% create board selection control

Frame3D([5 FIGH-134 360 74], 'Data acquisition board');
H.brdmenu = uicontextmenu('Position',[40 FIGH-96]);
H.brdselect = uicontrol('Style','popup', 'BackgroundColor','w','Position',[12 FIGH-128 260 23], ...
                        'Enable', libtune, 'Callback','rtblkgui BoardSelected', ...
                        'TooltipString', sprintf('Select a board from the list\nof installed boards.'));

% create board setup button

H.brdsetup = uicontrol('Style','pushbutton', 'Position',[283 FIGH-127 75 23], 'String', 'Board setup', ...
                       'Enable', libtune, 'Callback', 'rtblkgui BoardSetup', ...
                       'TooltipString', sprintf('Change configuration of the\nselected board.'));

% create install new board button

H.newbrd = uicontrol('Style','pushbutton', 'Position',[12 FIGH-96 120 23], 'String', 'Install new board', ...
                     'Enable', libtune, 'Callback', 'rtblkgui InstallNewBoard', ...
                     'TooltipString', sprintf('Add new board to the list\nof installed boards.'));

% create delete board button

H.delbrd = uicontrol('Style','pushbutton', 'Position',[152 FIGH-96 120 23], 'String', 'Delete current board', ...
                     'Enable', libtune, 'Callback', 'rtblkgui DeleteBoard', ...
                     'TooltipString', sprintf('Delete current board from the list\nof installed boards.'));

% create parameters frame

Frame3D([5 37 360 FIGH-182] ,'Parameters');

% create Sample time control

uicontrol('Style','text', 'Position',[30 FIGH-176 310 20], 'String','Sample time:', ...
          'HorizontalAlignment','left');
H.sample = uicontrol('Style','edit', 'Position',[30 FIGH-196 310 21], 'BackgroundColor',[1 1 1], ...
                     'Enable', libtune, 'HorizontalAlignment','left', ...
                     'String',CreateEditString(get_param(H.bh,'SampleTime')));

% create Channels control

uicontrol('Style','text', 'Position',[30 FIGH-221 310 20], 'String',[iolab(deviceidx).inout 'put channels:'], ...
          'HorizontalAlignment','left');
H.chan = uicontrol('Style','edit', 'Position',[30 FIGH-239 310 21], 'Enable',libtune, 'BackgroundColor',[1 1 1], ...
                   'HorizontalAlignment','left', ...
                   'String',CreateEditString(get_param(H.bh,'Channels')));


if strcmpi(iolab(deviceidx).inout,'out')   % just for output blocks

% create Initial value control

uicontrol('Style','text', 'Position',[30 111 310 20], 'String','Initial value:', ...
          'HorizontalAlignment','left');
H.ival = uicontrol('Style','edit', 'Position',[30 93 310 21], 'Enable',libtune, 'BackgroundColor',[1 1 1], ...
                   'HorizontalAlignment','left', ...
                   'String',CreateEditString(get_param(H.bh,'InitialValue')), ...
                   'TooltipString',sprintf('Enter initial value or leave blank\nif no initial value is to be set.'));

% create Final value control

uicontrol('Style','text', 'Position',[30 66 310 20], 'String','Final value:', ...
          'HorizontalAlignment','left');
H.fval = uicontrol('Style','edit', 'Position',[30 48 310 21], 'Enable',libtune, 'BackgroundColor',[1 1 1], ...
                   'HorizontalAlignment','left', ...
                   'String',CreateEditString(get_param(H.bh,'FinalValue')), ...
                   'TooltipString',sprintf('Enter final value or leave blank\nif no final value is to be set.'));

end  % of output blocks


% block type dependent controls

DEVY = FIGH - 269;
switch device;


%%%%%%%%%%%%%%%%%%%%%%
%%%   ANALOG I/O   %%%
%%%%%%%%%%%%%%%%%%%%%%

case {'AI', 'AO'};

% create Voltage range control

t = uicontrol('Style','text', 'String',[iolab(deviceidx).inout 'put range:'],...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY ext(3:4)], 'Visible','on');
H.range = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-4 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                    'Callback','rtblkgui(''ParamChange'',get(gcbo,''UserData''))', 'Enable',libtune);
SetRangeString(H, get_param(H.bh, 'DrvName'), 0);

% create Signal mode control

t = uicontrol('Style','text', 'String',['Block ' iolab(deviceidx).outin 'put signal:'],...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY-27 ext(3:4)], 'Visible','on');
modeval = str2double(get_param(H.bh,'RangeMode'));
if modeval<1 || modeval>4
  modeval = 1;
end
H.mode = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-31 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                   'Enable',libtune, 'String', 'Volts|Normalized bipolar|Normalized unipolar|Raw', ...
                   'Value', modeval);


%%%%%%%%%%%%%%%%%%%%%%%
%%%   DIGITAL I/O   %%%
%%%%%%%%%%%%%%%%%%%%%%%

case {'DI', 'DO'};

% create Bit mode control

t = uicontrol('Style','text', 'String','Channel mode:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY ext(3:4)], 'Visible','on');
H.bitmode = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-4 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                      'Enable',libtune, 'String', 'Bit|Byte', ...
                      'Value', str2double(get_param(H.bh,'BitMode')));


%%%%%%%%%%%%%%%%%%%%%%%
%%%   COUNTER I/O   %%%
%%%%%%%%%%%%%%%%%%%%%%%

case {'CI'};

% create Reset mode control

t = uicontrol('Style','text', 'String','Reset after read:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY ext(3:4)], 'Visible','on');
H.resetmode = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-4 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                        'Enable',libtune, 'String', 'never|always|level|rising edge|falling edge|either edge', ...
                        'Value', str2double(get_param(H.bh,'ResetMode')));

t = uicontrol('Style','text', 'String','Clock input active edge:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY-27 ext(3:4)], 'Visible','on');
H.counteredge = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-31 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                          'Enable',libtune, ...
                          'Value', str2double(get_param(H.bh,'CounterEdge')));

t = uicontrol('Style','text', 'String','Gate input functionality:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY-54 ext(3:4)], 'Visible','on');
H.countergate = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-58 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                          'Enable',libtune, ...
                          'Value', str2double(get_param(H.bh,'CounterGate')));

SetRangeString(H, get_param(H.bh, 'DrvName'), 0);


%%%%%%%%%%%%%%%%%%%%%%
%%%   TIMER I/O    %%%
%%%%%%%%%%%%%%%%%%%%%%

case {'TO'};

% create Output mode control

t = uicontrol('Style','text', 'String','Output mode:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY ext(3:4)], 'Visible','on');
H.timingmode = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-4 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                         'Enable',libtune, 'String', 'square wave|single pulse|triggered single pulse|pulse width modulation|delayed pulse|triggered delayed pulse', ...
                         'Value', str2double(get_param(H.bh,'TimingMode')));


%%%%%%%%%%%%%%%%%%%%%%%
%%%   ENCODER I/O   %%%
%%%%%%%%%%%%%%%%%%%%%%%

case {'EI'};

% create Quadrature mode control

t = uicontrol('Style','text', 'String','Quadrature mode:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY ext(3:4)], 'Visible','on');
H.quadmode = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-4 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                       'Enable',libtune, 'String', 'single|double|quadruple', ...
                       'Value', str2double(get_param(H.bh,'QuadMode')));

% create Reset input control

t = uicontrol('Style','text', 'String','Reset input function:',...
              'HorizontalAlignment','left', 'Visible','off');
ext = get(t,'Extent');
set(t, 'Position', [30 DEVY-27 ext(3:4)], 'Visible','on');
H.indexpulse = uicontrol('Style','popup', 'Position',[38+ext(3) DEVY-31 302-ext(3) 25], 'BackgroundColor',[1 1 1], ...
                        'Enable',libtune, 'String', 'gate|reset|rising edge index|falling edge index', ...
                        'Value', str2double(get_param(H.bh,'IndexPulse')));

% create Input filter control

uicontrol('Style','text', 'Position',[30 DEVY-54 310 20], 'String','Input filter clock frequency:',...
          'HorizontalAlignment','left');
H.inputfilter = uicontrol('Style','edit', 'Position',[30 DEVY-72 310 21], 'BackgroundColor',[1 1 1], ...
                        'Enable',libtune, 'HorizontalAlignment','left', ...
                        'String', CreateEditString(get_param(H.bh,'InputFilter')));


%%%%%%%%%%%%%%%%%%%%%
%%%   OTHER I/O   %%%
%%%%%%%%%%%%%%%%%%%%%

case {'OI', 'OO'};

% create Optional parameters control

uicontrol('Style','text', 'Position',[30 DEVY+1 310 20], 'String','Optional parameters:', ...
          'HorizontalAlignment','left');
H.param = uicontrol('Style','edit', 'Position',[30 DEVY-17 310 21], 'BackgroundColor',[1 1 1], ...
                    'Enable',libtune, 'HorizontalAlignment','left', ...
                    'String', CreateEditString(get_param(H.bh,'OptParam')));

end % of block type dependent controls


% set defaults, store handles

setappdata(figh,'Handles',H);
set(figh,'UserData',H.bh);
UpdateBoardList;
if ~strcmp(get_param(H.rooth, 'SimulationStatus'), 'stopped')
  Start(1);
end
set(figh,'Visible','on','HandleVisibility','callback');
drawnow;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  FRAME3D
%  3-D frame for mask GUI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Frame3D(pos,label)

% draw the frame

uicontrol('Style','frame','Position',[pos(1) pos(2)+1 pos(3:4)], 'ForegroundColor',[0.5 0.5 0.5]);
uicontrol('Style','frame','Position',[pos(1:3) 1], 'ForegroundColor',[1 1 1]);
uicontrol('Style','frame','Position',[pos(1)+1 pos(2)+pos(4)-1 pos(3)-2 1], 'ForegroundColor',[1 1 1]);
uicontrol('Style','frame','Position',[pos(1)+1 pos(2)+2 1 pos(4)-2], 'ForegroundColor',[1 1 1]);
uicontrol('Style','frame','Position',[pos(1)+pos(3) pos(2) 1 pos(4)], 'ForegroundColor',[1 1 1]);

% draw the label

if nargin>1
  t = uicontrol('Style','text', 'Position',[pos(1)+10 pos(2)+pos(4)-5 60 10], 'String',label, ...
                'Visible','off');
  ext = get(t,'Extent');
  set(t, 'Position',[pos(1)+8 pos(2)+pos(4)-ext(4)/2-1 ext(3:4)], 'Visible','on');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  CREATEEDITSTRING
%  create string for edit box
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = CreateEditString(str)

if strcmp(str,'[]')
  str = '';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  VALIDATEEDITSTRING
%  validate string passed from edit box
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = ValidateEditString(str)

if isempty(str)
  str = '[]';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  TRYSETPARAM
%  set_param, catching any error, adjusting AttributesFormatString if necessary
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ok = TrySetParam(blk, varargin)

for i = 1:length(blk)

% catch any error into dialog box

  try
    set_param(blk(i), varargin{:});
    ok = true;
  catch
    ok = false;
    errordlg(lasterr,'Error','modal');
    return;
  end

% modify format string if necessary

  if any(strcmp(varargin, 'DrvName') | strcmp(varargin, 'DrvAddress'))
    set_param(blk(i), 'AttributesFormatString', ...
              PrintableDrvName(strrep(get_param(blk(i),'DrvName'), '/', '\n'), ...
              str2double(get_param(blk(i),'DrvAddress'))));
  end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  GETALLGUIS
%  get handles of all GUI figures
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figh = GetAllGUIs

oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
figh = findobj('Type','figure', 'Tag','RTWin_RTBLKGUI');
set(0,'ShowHiddenHandles',oldsh');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  APPLY
%  apply callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Apply(figclose)

H = getappdata(gcbf, 'Handles');

% return immediately if in locked library

if H.islocked
  if figclose
    close(gcbf)
  end
  return;
end

% set driver parameters

if strcmp(get(H.brdselect, 'Enable'), 'on')
  boards = GetInstalledBoards;
  brdidx = get(H.brdselect, 'Value') - 1;
  if brdidx>0
    params = { 'DrvName', boards(brdidx).DrvName, 'DrvAddress', int2str(boards(brdidx).DrvAddress) };
  else
    params = { 'DrvName','', 'DrvAddress','0', 'DrvOptions','0' };
  end
else
  params = {};
end

% set sample time

if strcmp(get(H.sample, 'Enable'), 'on')
  params = [params { 'SampleTime', ValidateEditString(get(H.sample, 'String')) } ];
end

% set channels

params = [params { 'Channels', ValidateEditString(get(H.chan, 'String')) } ];

% set Initial and Final value

if isfield(H,'ival')
  params = [params { 'InitialValue', ValidateEditString(get(H.ival, 'String')), ...
                     'FinalValue', ValidateEditString(get(H.fval, 'String')), ...
                   }];
end


% set I/O device-specific parameters

switch H.device;

case {'AI', 'AO'};
  params = [params {'VoltRange', int2str(get(H.range, 'Value')), ...
                    'RangeMode', int2str(get(H.mode, 'Value')), ...
                   }];

case {'DI', 'DO'};
  params = [params {'BitMode', int2str(get(H.bitmode, 'Value')), ...
                   }];

case {'CI'};
  cedgeval = get(H.counteredge,'UserData');
  cgateval = get(H.countergate,'UserData');
  params = [params {'ResetMode', int2str(get(H.resetmode, 'Value')), ...
                    'CounterEdge', int2str(cedgeval(get(H.counteredge, 'Value'))), ...
                    'CounterGate', int2str(cgateval(get(H.countergate, 'Value'))), ...
                   }];

case {'TO'};
  params = [params {'TimingMode', int2str(get(H.timingmode, 'Value')), ...
                   }];

case {'EI'};
  params = [params {'QuadMode', int2str(get(H.quadmode, 'Value')), ...
                    'IndexPulse', int2str(get(H.indexpulse, 'Value')), ...
                    'InputFilter', get(H.inputfilter, 'String'), ...
                   }];

case {'OI', 'OO'};
  params = [params {'OptParam', get(H.param, 'String'), ...
                   }];

end    % of device switch

% actually set the parameters; close main dialog if requested

if (TrySetParam(H.bh, params{:}) && figclose)
  close(gcbf);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  PARAMCHANGE
%  parameter change callback
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ParamChange(warn)    %#ok called by name from a callback

if (warn)
  warndlg({'You have changed a parameter that is only changeable by a switch', ...
           'or a jumper on the board. Please be sure to have the board', ...
           'set to the same settings as specified by this parameter.'}, ...
           'Hardware setting changed','modal');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETRANGESTRING
%  read ranges from the driver and set the formatted string
%  also return the programmable/jumper flag
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetRangeString(H, drvname, boardchanged)

% channel tip is empty when no board selected

if isempty(drvname)
  chantip = '';
else

% find out the channel type

  iolab = struct( 'abbrev', {'AI','AO','DI','DO','CI','TO','EI','OI','OO'}, ...
                  'field',  {'AnalogInputs','AnalogOutputs','DigitalInputs','DigitalOutputs', ...
                             'CounterInputs','TimerOutputs','EncoderInputs','OtherInputs','OtherOutputs'} ...
                );
  deviceidx = find(strcmp({iolab.abbrev}, H.device));

% read the number of channels from driver

  iocaps = getfield(rtdrvfn('GetIOCaps',drvname), iolab(deviceidx).field);  %#ok can't use .() with function
  if iocaps.Size==0
    chantip = 'The selected board has no channels of this kind.';
  else
    chantip = sprintf('Valid channel numbers are from 1 to %d.', iocaps.Size);
  end

end
set(H.chan, 'TooltipString', chantip);


% process the Range field

if isfield(H, 'range')

% get the parameters from driver

  if isempty(drvname)
    iocaps.Ranges = [];
    iocaps.DefaultRange = 1;
    iocaps.RangeJumper = 1;
  end

% format the range string

  ranges = sprintf('|%g to %g V',iocaps.Ranges');  %#ok iocaps.Ranges is a matrix
  ranges(1) = '';

% get the range index from block

  rval = str2double(get_param(H.bh, 'VoltRange'));
  if boardchanged || isnan(rval) || rval>size(iocaps.Ranges,1)
    rval = iocaps.DefaultRange;
  end

  set(H.range, 'String', ranges, 'Value', rval, 'UserData', iocaps.RangeJumper);
end


% process the counter fields (two of them)

if isfield(H, 'countergate')

  edgestr = {'rising', 'falling'};
  gatestr = {'none', 'enable when high', 'enable when low', 'start on rising edge', 'start on falling edge', ...
             'reset on rising edge', 'reset on falling edge', 'latch on rising edge', 'latch on falling edge', ...
             'latch & reset on rising edge','latch & reset on falling edge'};

% get the parameters from driver

  if ~isempty(drvname)
    edgestr = edgestr(iocaps.EdgeCaps);
    gatestr = gatestr(iocaps.GateCaps);
  else
    iocaps.EdgeCaps = 1;
    iocaps.GateCaps = 1;
  end

% format the control strings

  edges = sprintf('|%s',edgestr{:});
  edges(1) = '';
  gates = sprintf('|%s',gatestr{:});
  gates(1) = '';

% get the edge and gate index from block

  edidx = find(iocaps.EdgeCaps);
  edval = find(str2double(get_param(H.bh, 'CounterEdge')) == edidx);
  if isempty(edval)
    edval = 1;
  end
  
  gidx = find(iocaps.GateCaps);
  gval = find(str2double(get_param(H.bh, 'CounterGate')) == gidx);
  if isempty(gval)
    gval = 1;
  end

% set the control strings

  set(H.counteredge, 'String', edges, 'Value', edval, 'UserData', edidx);
  set(H.countergate, 'String', gates, 'Value', gval, 'UserData', gidx);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  HASBOARDGUI
%  test if a board has GUI for setting parameters or not
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = HasBoardGUI(drvname)

eval(rtdrvfn('GetGUIControls',drvname));     % creates the FIG and GUI structures
y = exist('FIG', 'var');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  UPDATEBOARDCONTROLS
%  update controls that depend on the selected board
%  return drvname and drvaddress for that GUI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [drvname, drvaddress] = UpdateBoardControls(figh, boardchanged)

% only if not in locked library

H = getappdata(figh, 'Handles');
drvname = '';
drvaddress = '[]';
if H.islocked
  return;
end

% get board array and index

boards = GetInstalledBoards;
brdidx = get(H.brdselect, 'Value') - 1;

% if some board selected, change GUI appropriately

if brdidx>0
  drvname = boards(brdidx).DrvName;
  drvaddress = int2str(boards(brdidx).DrvAddress);

  SetRangeString(H, drvname, boardchanged);
  set(H.delbrd, 'Enable', 'on');

  offon = {'off','on'};
  set(H.brdsetup, 'Enable', offon{HasBoardGUI(drvname)+1});

% if not selected, set to defaults

else
  SetRangeString(H, '', boardchanged);
  set(H.delbrd, 'Enable', 'off');
  set(H.brdsetup, 'Enable', 'off');

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  PRINTABLEDRVNAME
%  convert driver name and address to printable form
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function printname = PrintableDrvName(drvname, drvaddress)

if isempty(drvname)
  printname='';
else
  drvname(drvname=='/' | drvname=='_') = ' ';
  printname = strrep(sprintf('%s [%Xh]', drvname, drvaddress), 'FFFFFFFFh', 'auto');
end  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  BOARDSELECTED
%  callback for the board selection menu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BoardSelected    %#ok called by name from a callback

% update board controls first

figh = gcbf;
H = getappdata(figh, 'Handles');
[drvname, drvaddress] = UpdateBoardControls(figh, 1);

% save the board setting immediately

params = { 'DrvName', drvname, 'DrvAddress', drvaddress };

% get options from another block with the same board; if not there, read defaults from driver

if ~isempty(drvname)
  blks = find_system(H.rooth, params{:} );
  blks(blks==H.bh) = [];
  if ~isempty(blks)
    drvopt = get_param(blks(1), 'DrvOptions');
  else
    drvopt = rtdrvfn('GetDefaultParameters',drvname);
    drvopt = mat2str(drvopt(2:end));
  end
  params = [params { 'DrvOptions', drvopt } ];
end

TrySetParam(H.bh, params{:});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  INSTALLNEWBOARD
%  callback for the install new board button
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function InstallNewBoard    %#ok called by name from a callback

H = getappdata(gcbf, 'Handles');

% display board selection menu if it already exists
if ~isempty(get(H.brdmenu, 'Children'))
  set(H.brdmenu, 'Visible','on');
  return,
end

% find driver directory
drvdir = fileparts(which(mfilename));
drvdir = [drvdir(1:find(drvdir==filesep,1,'last')) 'drv'];
mfrlist = dir(drvdir);
mfrlist = mfrlist(find([mfrlist.isdir]));

% display waitbar window
set(gcbf, 'Units','points');
fpos = get(gcbf, 'Position');
set(gcbf, 'Units','pixels');
wbpos(3:4) = [270 56];
wbpos(1:2) = [fpos(1)+(fpos(3)-wbpos(3))/2  fpos(2)+(fpos(4)-wbpos(4))/2];
wb = waitbar(0, 'Building the list of available drivers ...', 'Position',wbpos);
wbinc = 1/size(mfrlist, 1);
wbst = 0;

% create uimenu hierarchy
for mfr = sort({mfrlist.name})
  wbst = wbst+wbinc;
  waitbar(wbst, wb);
  if mfr{1}(1)=='.'; continue; end
  drvlist = dir(fullfile(drvdir, mfr{1}, '*.rwd'));
  if isempty(drvlist); continue; end
  lab = mfr{1};
  lab(lab=='_') = ' ';
  mfrm = uimenu(H.brdmenu, 'Label', lab);
  for drv = sort({drvlist.name})
    lab = drv{1}(1:end-4);
    drvname = [mfr{1} '/' lab];
    lab(lab=='_') = ' ';
    uimenu(mfrm, 'Label', lab, 'UserData',drvname,'Callback','rtblkgui NewBoardInstalled');
  end
end
close(wb);

% display the uimenu
set(H.brdmenu, 'Visible','on');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  NEWBOARDINSTALLED
%  callback when new board installed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewBoardInstalled    %#ok called by name from a callback

H = getappdata(gcbf, 'Handles');
drvname = get(gcbo,'UserData');

% call the driver GUI

while 1
  opt = rtdrvgui('Open', drvname);
  if isempty(opt)
    return;
  end
  addr = opt(1);
  opt(1) = [];
  if ~IsBoardConflict(drvname, addr)
    break;
  end
  if ~HasBoardGUI(drvname)
    return;
  end
end

% set the board parameters

TrySetParam(H.bh, 'DrvName', drvname, 'DrvAddress', int2str(addr), 'DrvOptions', mat2str(opt));

% store board to preferences if not yet there

AddInstalledBoard(drvname,addr);

% update all open dialogs

SetRangeString(H, drvname, 1);
UpdateBoardList;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  DELETEBOARD
%  callback for the Delete board button
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DeleteBoard    %#ok called by name from a callback

% display confirmation dialog

yn = questdlg('This will permanently delete the current board from the list of installed boards. Do you want to continue?',...
              'Confirm board deletion','Yes','No','Yes');
if ~strcmp(yn,'Yes')
  return;
end

% get board list

H = getappdata(gcbf, 'Handles');
boards = GetInstalledBoards;
brdidx = get(H.brdselect,'Value') - 1;

% display another confirmation dialog if board is used

blks = find_system(H.rooth, 'DrvName',boards(brdidx).DrvName, 'DrvAddress',int2str(boards(brdidx).DrvAddress));
if ~isempty(blks(find(blks~=H.bh)))
  yn = questdlg('This board is being used by another block in the diagram. Deleting it will require selecting another board for that block later. Do you still want to delete the board?',...
                'Board used by another block','Yes','No','No');
  if ~strcmp(yn,'Yes')
    return;
  end
end

TrySetParam(blks, 'DrvName','', 'DrvAddress','0', 'DrvOptions','0');

% delete the board from list

RmInstalledBoard(boards(brdidx).DrvName, boards(brdidx).DrvAddress);
UpdateBoardList;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  BOARDSETUP
%  setup the selected board
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BoardSetup    %#ok called by name from a callback

H = getappdata(gcbf, 'Handles');
boards = GetInstalledBoards;
brdidx = get(H.brdselect, 'Value') - 1;
drvname = boards(brdidx).DrvName;

% call the driver GUI and save the changes

oldaddress = boards(brdidx).DrvAddress;
oldoptions = str2num(get_param(H.bh, 'DrvOptions'));   %#ok STR2DOUBLE can't handle vectors
while 1
  newoptions = rtdrvgui('Open', drvname, [oldaddress oldoptions]);
  if isempty(newoptions)
    return;
  end
  newaddress  = newoptions(1);
  newoptions(1) = [];
  if newaddress==oldaddress || ~IsBoardConflict(drvname, newaddress)
    break;
  end
end

% prompt for confirmation if address has changed

if newaddress~=oldaddress
  yn = questdlg({'You have changed the hardware address of the board. This may require physically changing switches on the board or moving the board to different slot. Are you sure you want to do this?',...
                 '','Note: The new address will be permanently saved in the list of installed boards.'},...
                 'Confirm hardware address change','Yes','No','Yes');
  if ~strcmp(yn,'Yes')
    newaddress = oldaddress;
  end
end

% update all blocks in diagram if anything has changed

if newaddress~=oldaddress || any(newoptions~=oldoptions)
  blks = find_system(H.rooth,'DrvName',drvname,'DrvAddress',int2str(oldaddress));
  TrySetParam(blks, 'DrvAddress', int2str(newaddress), 'DrvOptions', mat2str(newoptions));
end

% update board list in registry and in all open dialogs

if newaddress~=oldaddress
  SetInstalledBoard(drvname,oldaddress,newaddress);
  UpdateBoardList;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  ISBOARDCONFLICT
%  test if a board/address pair already exists
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function conflict = IsBoardConflict(drvname, drvaddress)

allboards = GetInstalledBoards;
for b = allboards
  if strcmpi(drvname,b.DrvName) && drvaddress==b.DrvAddress
    uiwait(errordlg({'You have selected an address for this board that is already'
                     'in use by another installed board. If this is really the correct'
                     'setting, please select the appropriate board from'
                     'the board popup menu instead of setting the conflicting address here.'}, ...
                     'Board address setting conflict','modal'));
    conflict = 1;
    return;
  end
end
conflict = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  UPDATEBOARDLIST
%  update board list in all open dialogs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpdateBoardList

% build board list from preferences

[boards, brdpopup] = GetInstalledBoards;

% get figure list

figs = GetAllGUIs;

% set boards popup in all figures

onoff = {'on','off'};
for f = figs'
  H = getappdata(f, 'Handles');
  set(H.brdselect, 'String', brdpopup, 'Enable', onoff{(isempty(boards) | H.islocked)+1});

% find board index for each block

  drvname = get_param(H.bh, 'DrvName');
  if isempty(drvname)

    brdidx = 0;

  else
    drvaddress = str2double(get_param(H.bh, 'DrvAddress'));
    brdidx = FindBoardIndex(boards, drvname, drvaddress);

% if board not found, offer a dialog for adding it

    if brdidx==0
      yn = questdlg(sprintf('This block references board "%s" which is not on the installed boards list for this computer. Do you want to add it to the list?',...
                             PrintableDrvName(drvname, drvaddress)), ...
                    'Board not installed','Yes','No','Yes');
      if strcmp(yn,'Yes')
        AddInstalledBoard(drvname,drvaddress);
        UpdateBoardList;
        return;
      end
    end

  end


  set(H.brdselect, 'Value', brdidx+1);
  UpdateBoardControls(f, 0);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  GETINSTALLEDBOARDS
%  get all installed boards from preferences
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [boards, brdpopup] = GetInstalledBoards

% upgrade board list stored in preferences

UpgradeSavedBoardList;

% retrieve all the installed boards from preferences

boards = getpref('RealTimeWindowsTarget', 'InstalledBoards', struct('DrvName',{},'DrvAddress',{}));

% build board popup string if requested

if nargout>1
  if isempty(boards)
    brdpopup = '< no board installed >';
  else
    brdpopup = '';
    for brd=boards
      brdpopup = [brdpopup '|' PrintableDrvName(brd.DrvName, brd.DrvAddress)];
    end
    brdpopup = ['< no board selected >' brdpopup];
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  ADDINSTALLEDBOARD
%  add a new board to the list of installed boards
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AddInstalledBoard(drvname, drvaddress)

% build the board structure

brd.DrvName = drvname;
brd.DrvAddress = drvaddress;

% add the board to the boards array

boards = [GetInstalledBoards brd];
setpref('RealTimeWindowsTarget','InstalledBoards', SortBoards(boards));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SETINSTALLEDBOARD
%  set new value for a specific installed board
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetInstalledBoard(drvname, oldaddress, newaddress)

% find the board in the boards array

boards = GetInstalledBoards;
brdidx = FindBoardIndex(boards, drvname, oldaddress);
if (brdidx==0)
  return;
end

% change the old address to the new address

boards(brdidx).DrvAddress = newaddress;
setpref('RealTimeWindowsTarget','InstalledBoards', SortBoards(boards));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  RMINSTALLEDBOARD
%  remove a specific board
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RmInstalledBoard(drvname, drvaddress)

% find the board in the boards array

boards = GetInstalledBoards;
brdidx = FindBoardIndex(boards, drvname, drvaddress);
if (brdidx==0)
  return;
end

% remove it

boards(brdidx) = [];
setpref('RealTimeWindowsTarget','InstalledBoards', boards);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  FINDBOARDINDEX
%  find board index in the boards array; zero if not found
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function idx = FindBoardIndex(boards, drvname, drvaddress)

if ~isempty(boards)
  idx = find(strcmpi(drvname, {boards.DrvName}) & drvaddress==[boards.DrvAddress]);
  if isempty(idx)
    idx = 0;
  end
else
  idx = 0;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  SORTBOARDS
%  sort the boards array - board name, then board address
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function boards = SortBoards(boards)

if ~isempty(boards)
  [dummy, srt] = sort([boards.DrvAddress]);  %#ok DUMMY is dummy
  boards = boards(srt);
  [dummy, srt] = sort({boards.DrvName});  %#ok DUMMY is dummy
  boards = boards(srt);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  UPGRADESAVEDBOARDLIST
%  upgrade the saved boards list from RTWin 2.0 to RTWin 2.1 format
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function UpgradeSavedBoardList

% don't do anything if already upgraded

if ~ispref('RealTimeWindowsTarget') || ispref('RealTimeWindowsTarget', 'InstalledBoards')
  return;
end

% retrieve all the installed boards from preferences

prefs = getpref('RealTimeWindowsTarget');

prefnames = fieldnames(prefs);
prefidx = strmatch('Board',prefnames);
prefs = struct2cell(prefs);
prefs = prefs(prefidx)';

% convert the boards into the new format

boards = struct([]);
for brdstr=prefs
  brdstr = brdstr{:};
  atchar = find(brdstr=='@');
  brd.DrvName = brdstr(1:atchar-1);
  brd.DrvAddress = str2double(brdstr(atchar+1:end));
  boards = [boards brd];
end

% save the new preference

addpref('RealTimeWindowsTarget', 'InstalledBoards', SortBoards(boards));

% clear the old preferences

prefnames = prefnames(prefidx);
rmpref('RealTimeWindowsTarget', [{'LastBoard'}; prefnames]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  MODELCLOSE
%  callback for closing a model or parent subsystem
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ModelClose    %#ok called by name from a callback

% close the GUI window if open

close(findobj(GetAllGUIs, 'flat', 'UserData',gcbh));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  START
%  callback for simulation start or stop
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Start(start)

% test if GUI window open

figh = findobj(GetAllGUIs, 'flat', 'UserData',gcbh);
if isempty(figh)
  return;
end

% enable or disable appropriate controls

H = getappdata(figh, 'Handles');
handles = [H.brdselect H.brdsetup H.newbrd H.delbrd H.sample];
if strcmp(H.device,'CI')
  handles = [handles H.resetmode];
end
if strcmp(H.device,'EI')
  handles = [handles H.quadmode H.indexpulse];
end

onoff = {'on', 'off'};
set(handles,'Enable',onoff{start+1});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  LOAD
%  callback for block load
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Load    %#ok called by name from a callback

% do nothing for a library block

bh = gcbh;
if strcmp(get_param(bdroot(bh), 'BlockDiagramType'), 'library')
  return;
end

% do nothing if no board selected for the block

drvname = get_param(bh, 'DrvName');
if isempty(drvname)
  return;
end

drvaddress = get_param(bh, 'DrvAddress');
allboards = GetInstalledBoards;

% if the selected board for this block is on the list of installed boards, it's OK

if ~isempty(allboards) && any(strcmpi(drvname,{allboards.DrvName}) & str2double(drvaddress)==[allboards.DrvAddress])
  return;
end

% warn that the board is not installed

warning('RTWIN:boardnotonlist', ...
        'Block "%s" references board "%s" which is not on the installed boards list for this computer.', ...
        get_param(bh, 'Name'), ...
        PrintableDrvName(drvname, str2double(drvaddress)) );
