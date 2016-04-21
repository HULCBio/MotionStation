function  [sys, x0, str, ts] = sdspwwvdisp(t,x,u,varargin)
%SDSPWWVDISP S-Function implementing custom display for WWV demo.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/12/23 22:32:36 $

% Syntax:
%
%   sdspwwvdisp(t,x,u,flag, params);
%
% where params is a structure containing all block dialog parameters.


% What's in the Figure userdata:
% ------------------------------
% Main display handles:
%   fig_data.block        block name
%   fig_data.hfig         handle to figure
%   fig_data.gui.date
%   fig_data.gui.utc
%   fig_data.gui.ut1
%   fig_data.gui.ds1
%   fig_data.gui.ds2
%   fig_data.gui.leap
%   fig_data.gui.detect
%   fig_data.gui.lock
%
% Handles to menu items:
%   fig_data.menu.top        top-level menus in Figure
%   fig_data.menu.context    context menu
%
%   - appearing only in figure menu:
%
%   - appearing in both figure and context menu:
%       fig_data.menu.recpos     record position
%
% What's in the Block userdata:
% -----------------------------
%   block_data.firstcall    flag for first call to function
%   block_data.hfig         handle to figure
%   block_data.params       structure of cached block dialog parameters
%   block_data.last_u       copy of last input vector
%
% Parameters structure fields: (.params.xxx)
% ----------------------------
% .FigPos: figure position
%
%
% Input to block must be an 8-element vector
%   containing one frame of display data:
%
% [ UTC ;
%   UT1 ;
%   Year ;
%   DayOfYear ;
%   DaylightSavings1 ;
%   DaylightSavings2 ;
%   LeapSeconds ;
%   Tick ]

switch(varargin{1})
case 2,
   sys = mdlUpdate(t,x,u,varargin{:});
case 3,
   sys = [];   % mdlOutput - unused
case 0,
   [sys,x0,str,ts] = mdlInitializeSizes;
case 9,
   sys = mdlTerminate;
otherwise
   % GUI callback:
   feval(varargin{:});
   sys = [];   % None of these options change the state:
end


% -----------------------------------------------------------
function [sys,x0,str,ts] = mdlInitializeSizes

sfcn   = gcb;  % s-fcn
blk    = get_param(sfcn,'parent');
parent = get_param(blk, 'parent');

sizes = simsizes;
sizes.NumInputs      =  9;
sizes.NumOutputs     =  0;
sizes.NumSampleTimes =  1;
sys = simsizes(sizes);
x0  = [];           % states
str = '';           % state ordering strings
ts  = [-1 1];       % inherited sample time, fixed in minor steps

if ~syslocked(parent),
   % No need to execute in a library
   %  (we also want to keep the block UserData empty so that
   %   DialogApply will not run)
   
   % Setup minimally required block data:
   block_data = get_param(blk,'UserData');
   block_data.firstcall = 1;
   if ~isfield(block_data,'hfig'),
      block_data.hfig = [];
   end
   set_param(blk,'UserData',block_data);
end


% ------------------------------------------------------------
function y = syslocked(sys)
% SYSLOCKED Determine whether a system is locked.
%  This function is error-protected against calls on
%  subsystems or blocks, which do not have a lock parameter.

y = ~isempty(sys);
if y,
   y = strcmpi(get_param(bdroot(sys),'lock'),'on');
end


% ------------------------------------------------------------
function sys = mdlUpdate(t,x,u,flag,params)

% Return empty state vector, since we're not using any:
sys = [];

% Faster implementation of: blk=gcb;
cs   = get_param(0,'CurrentSystem');
sfcn = [cs '/' get_param(cs,'CurrentBlock')];
% sfcn = gcb;
blk  = get_param(sfcn,'parent');

block_data = get_param(blk, 'UserData');
if block_data.firstcall,
   first_update(blk, u, params);
else
   update_disp(block_data, u);
end


% ---------------------------------------------------------------
function update_disp(block_data, u)
% UPDATE_DISP Update the time display

% u: one frame of data
% [ UTC ;
%   UT1 ;
%   Year ;
%   DayOfYear ;
%   DaylightSavings1 ;
%   DaylightSavings2 ;
%   LeapSeconds ;
%   Detect ;
%   Lock ]

% Does not alter block_data
%
% If the user closed the figure window while the simulation
% was running, then hfig has been reset to empty.
%
% Allow the simulation to continue, but do not put up a new
% figure window (or error out!)

if isempty(block_data.hfig),
   return;
end
fig_data = get(block_data.hfig,'UserData');

utc    = u(1);
ut1    = u(2);
yy     = u(3);
doy    = u(4);
ds1    = u(5);
ds2    = u(6);
leap   = u(7);
detect = u(8);
lock   = u(9);

% Only update info which changed:
last_u = block_data.last_u;

% If last_u is empty, this is the first update
change = isempty(last_u);

if ~all(u==0),

% If UTC didn't change, none of the other time code changed
% Lock and Detect may have, however:

if change | (last_u(1) ~= utc),
   if change | (last_u(4) ~= doy) | (last_u(3) ~= yy),
      wwvgui_date(fig_data, doy, yy);
   end
   
   if change | (last_u(2) ~= ut1),
      wwvgui_ut1(fig_data, ut1);
   end
   
   if change | (last_u(5) ~= ds1) | (last_u(6) ~= ds2),
      wwvgui_ds(fig_data, [ds1 ds2]);
   end
   
   if change | (last_u(7) ~= leap),
      wwvgui_leap(fig_data, leap);
   end
   
   change=1;
   wwvgui_utc(fig_data, utc);
end

if change | (last_u(8) ~= detect),
   change=1;
   wwvgui_detect(fig_data, detect);
end

if change | (last_u(9) ~= lock),
   change=1;
   wwvgui_lock(fig_data, lock);
end

end

if change,
   % block_data.last_u = 2*u;  % break link
   % block_data.last_u = block_data.last_u/2;  % break link
   block_data.last_u = u + 1 - 1;  % break link
   set_param(fig_data.block,'UserData',block_data);
end


% ---------------------------------------------------------------
function first_update(blk, u, params)
% FIRST_UPDATE Called the first time the update function is executed
%   in a simulation run.  Creates a new scope GUI if it does not exist,
%   or restarts an existing scope GUI.

% blk: masked subsystem block
% u: one frame of data
% Updates block_data

block_data = get_param(blk,'UserData');

% Record input frame time
% NOTE: This is the per-frame time, NOT the per-sample time
ts = get_param(blk,'CompiledSampleTime');
if ts(1) <= 0,
   error('Input must be a discrete-time signal.');
end

% Check input data complexity and type:
if ~isreal(u) | ~isa(u,'double'),
   error('Inputs must be real, double-precision values.');
end

% Construct new scope figure window, or bring up old one:
if isfield(block_data,'hfig'),
   hfig = block_data.hfig; % scope already exists
else
   hfig = [];              % scope was never run before
end

% Establish a valid scope GUI:
if ~isempty(hfig),
   % Found existing scope figure window:
   
   % Prepare to re-start with existing scope window:
   fig_data = restart_scope(blk, params);
   
   % If things did not go well during restart, say the axis
   % was somehow deleted from the existing scope figure, etc.,
   % then hfig is left empty, and a new scope must be created.
   % Get hfig, then check if it is empty later:
   hfig = fig_data.hfig;
end

if isempty(hfig),
   % Initialize new figure window:
   % Create the scope GUI
   fig_data = create_display(blk, params);
end

% Get line handle:
% hline = fig_data.main.hline;

% Retain the name of the figure window for use when the
% block's name changes. Name is retained in S-fcn block's
% user-data:
block_data.firstcall   = 0;   % reset "new simulation" flag
block_data.hfig      = fig_data.hfig;
block_data.params    = params;
block_data.last_u    = [];

% Set block's user data:
set_param(blk, 'UserData', block_data);

% The following block callbacks are assumed to be set
% in the library block:
%
%   CopyFcn		      "sdspwwvdisp([],[],[],'BlockCopy');"
%   DeleteFcn		  "sdspwwvdisp([],[],[],'BlockDelete');"
%   NameChangeFcn     "sdspwwvdisp([],[],[],'NameChange');"

% Setup scope axes:
setup_axes(blk, u);  % one frame of data


% ---------------------------------------------------------------
function RevertDialogParams(blk)
% Reset all current parameters in block dialog

block_data = get_param(blk, 'UserData');
names = get_param(blk,'masknames');

req = {'FigPos'};

pv={};
for i=1:length(names),
   p = names{i};
   % Only update required fields (eval-mode edit fields):
   if strmatch(p, req),
      v = mat2str(getfield(block_data.params,p));
      % Only evaluation-mode edits are a problem:
      pv = [pv {p,v}];
   end
end
set_param(blk,pv{:});


% ---------------------------------------------------------------
function msg = CheckParams(blk, params)

msg = '';

% Check FigPos:
% -------------
x = params.FigPos;
if ~isa(x,'double') | issparse(x) | ~isreal(x) | ...
      size(x,1)~= 1 | size(x,2)~=4,
   msg = 'Figure position must be a real-valued 1x4 vector.';
   return
end


% ---------------------------------------------------------------
function DialogApply(params,block_name)

% Called from MaskInitialization command via:
%   sdspwwvdisp([],[],[],'DialogApply',params);

% Updates block_data

% In case of call from an internal method (not a callback)
% For example, SetAndApply calls us directly, and gcb might
% not be correct...
if nargin<2,
   block_name = gcb;
end
block_data = get_param(block_name, 'UserData');

if isempty(block_data),
   return;  % System has not run yet
end

% Check dialog parameters:
% ------------------------
msg = CheckParams(block_name, params);
if ~isempty(msg),
   % Invalid parameters
   errordlg(msg,'WWV Display Dialog Error','modal');
   RevertDialogParams(block_name);
   return
end


% On start-up, no params field exists
% Set params, and skip any further processing
if ~isfield(block_data,'params'),
   block_data.params = params;
   set_param(block_name, 'UserData', block_data);
   return;
end

% Check for a run-time change in the scaling or units:
params_changed = ~isequal(params, block_data.params);

if params_changed & isempty(block_data.hfig),
   % GUI is not open
   
   % Just record new param info:
   block_data.params = params;
   set_param(block_name, 'UserData', block_data);
   return;
end

if params_changed,
   % GUI open:
   
   % Handle figure position changes here:
   % Only update if the current block dialog FigPos differs from
   % the cached block_data FigPos.  The figure itself might be at
   % a different position, which we should not change UNLESS the
   % user actually made an explicit change in the mask (or, hit
   % the RecordFigPos menu item, which simply changes the mask).
   if ~isequal(block_data.params.FigPos, params.FigPos),
      set(block_data.hfig,'Position',params.FigPos);
   end
   
   % Record new param info:
   block_data.params = params;
   set_param(block_name, 'UserData', block_data);
   
   % Adjust the GUI, passing it ONE FRAME of data (u);
   %
   setup_axes(block_name, u);
end


% ---------------------------------------------------------------
function setup_axes(block_name, u)
% Setup scope x- and y-axes

% Does not alter block_data
% u = input data, one frame of data

block_data = get_param(block_name,'UserData');

% Update display with the actual values:
update_disp(block_data, u);


% ---------------------------------------------------------------
function FigResize
% Callback from window resize function

%hfig     = gcbf;
%fig_data = get(hfig,'UserData');
%blk      = fig_data.block

% ---------------------------------------------------------------
function wwvgui_date(fig_data, doy, yy)
% Update date info
% doy=day of year
% yy=year

if (doy == 0) | (yy == 0),
    return
end

if yy<2000,
    yy=yy+100;
end
sjan1 = datenum(yy,01,01);  % Serial date for Jan 1 of this year
s = sjan1 + doy-1;          % Serial date for today
dow = datestr(s, 8);        % Day of week, ex: 'Wed'
[yyyy mm dom] = datevec(s); % year, month, day of month
months={'Jan','Feb','Mar','Apr','May','Jun', ...
      'Jul','Aug','Sep','Oct','Nov','Dec'};
q = [dow '., ' months{mm} '. ' num2str(dom) ', ' num2str(yyyy) ];

% new tooltip string:
t = sprintf('Day %d of %d',doy,yyyy);

set(fig_data.gui.date, 'string',q, 'tooltip',t);


% ---------------------------------------------------------------
function wwvgui_utc(fig_data,utc)
% Update UTC info
% utc=hh.mm

hh=floor(utc/100);
mm=utc-hh*100;
ss=0;
hms=sprintf('%02d:%02d:%02d UTC',hh,mm,ss);
set(fig_data.gui.utc,'string',hms);


% ---------------------------------------------------------------
function wwvgui_ut1(fig_data,ut1)
% Update UT1 info
% ut1= +/- 0.7 secs

sut1=sprintf('%+01.1f sec UT1',ut1);
set(fig_data.gui.ut1,'string',sut1);

% ---------------------------------------------------------------
function wwvgui_ds(fig_data, ds)
% Update daylight savings info
% ds=[ds1 ds1], each may be 0=no or 1=yes

clrs = {[0 .3 0], [0 1 0]};  % colors: {off, on}
set(fig_data.gui.ds1,'backgr',clrs{ds(1)+1});
set(fig_data.gui.ds2,'backgr',clrs{ds(2)+1});


% ---------------------------------------------------------------
function wwvgui_leap(fig_data, leap)
% Update leap-second info
% leap: 0=no, 1=yes

clrs = {[0 .3 0], [0 1 0]};  % colors: {off, on}
set(fig_data.gui.leap,'backgr',clrs{leap+1});

% ---------------------------------------------------------------
function wwvgui_detect(fig_data, detect)
% Update signal-detection info
% detect: 0=no, 1=yes

clrs = {[.4 0 0], [1 0 0]};  % colors: {off, on}
set(fig_data.gui.detect,'backgr',clrs{detect+1});


% ---------------------------------------------------------------
function wwvgui_lock(fig_data, lock)
% Update receiver-lock info
% lock: 0=no, 1=yes

clrs = {[.4 0 0], [1 0 0]};  % colors: {off, on}
if lock,
   t = 'Synchronized to WWV broadcast';
else
   t = 'Cannot synchronize to WWV broadcast';
end
set(fig_data.gui.lock(1),'backgr',clrs{lock+1});
set(fig_data.gui.lock, 'tooltip',t);

% ---------------------------------------------------------------
function reset_display(hfig)

ud = get(hfig,'userdata');
h = ud.gui;

set(h.date, ...
   'tooltip','Day 1 of 1900', ...
   'string','Mon., Jan. 1, 1900');
set(h.utc, ...
   'tooltip','Coordinated Universal Time', ...
   'string','00:00:00 UTC');
set(h.ut1, ...
   'tooltip','Compensation for rotation of Earth', ...
   'string','+0.0 sec UT1');
set(h.ds1, ...
   'backgr',[0 .5 0], ...
   'tooltip','Daylight savings indicator #1');
set(h.ds2, ...
   'backgr',[0 .5 0], ...
   'tooltip','Daylight savings indicator #2');
set(h.leap, ...
   'backgr',[0 .5 0], ...
   'tooltip','Compensation for rotation of Earth');
set(h.detect, ...
   'backgr',[.5 0 0], ...
   'tooltip','Detecting 100 Hz data signal');
set(h.lock(1), ...
   'backgr',[.5 0 0]);


% ---------------------------------------------------------------
function h = wwvgui(hfig)
% Create WWV GUI

lg=18;
sm=12;
bg=get(hfig,'color');
set(hfig,'units','points');
y=7.5;
dy=lg;

% Day/Date:
h.date = uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'horiz','left', ...
   'units','points', ...
   'fontsize',lg, ...
   'pos',[0.4 y 10 1.5]*lg);

% UTC:
h.utc = uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'horiz','left', ...
   'units','points', ...
   'fontsize',lg, ...
   'pos',[0.4 y-1.5 10 1.5]*lg);

% UT1:
h.ut1 = uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'horiz','left', ...
   'units','points', ...
   'fontsize',lg, ...
   'pos',[0.4 y-3 10 1.5]*lg);

% DS1:
h.ds1=uicontrol('parent',hfig, ...
   'style','frame', ...
   'backgr',[0 .5 0], ...
   'foregr','k', ...
   'units','points', ...
   'pos',[1.1 y-4 1.1/2 .5]*lg);
h.ds2=uicontrol('parent',hfig, ...
   'style','frame', ...
   'backgr',[0 .5 0], ...
   'foregr','k', ...
   'units','points', ...
   'pos',[1.6 y-4 1.1/2 .5]*lg);
uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'units','points', ...
   'fontsize', sm, ...
   'horiz','left', ...
   'pos',[2.4*lg (y-4.1)*lg 10*sm sm], ...
   'string','Daylight savings', ...
   'tooltip', 'Daylight savings is in effect');

% Leap second:
s = 'Compensation for rotation of Earth';
h.leap=uicontrol('parent',hfig, ...
   'style','frame', ...
   'backgr',[0 .5 0], ...
   'foregr','k', ...
   'units','points', ...
   'pos',[1.1 y-4.7 1.1 .5]*lg, ...
   'tooltip',s);
uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'units','points', ...
   'fontsize', sm, ...
   'horiz','left', ...
   'pos',[2.4*lg (y-4.75)*lg 10*sm sm], ...
   'string','Leap second', ...
   'tooltip',s);

% Signal detection:
s = 'Detecting 100 Hz data signal';
h.detect=uicontrol('parent',hfig, ...
   'style','frame', ...
   'backgr',[1 0 0], ...
   'foregr','k', ...
   'units','points', ...
   'pos',[1.1 y-6 1.1 .5]*lg, ...
   'tooltip',s);
uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'units','points', ...
   'fontsize', sm, ...
   'horiz','left', ...
   'pos',[2.4*lg (y-6.1)*lg 10*sm sm], ...
   'string','Receiving WWV', ...
   'tooltip',s);

% Receiver lock:
s = 'Currently decoding WWV broadcast';
h.lock=uicontrol('parent',hfig, ...
   'style','frame', ...
   'backgr',[1 0 0], ...
   'foregr','k', ...
   'units','points', ...
   'pos',[1.1 y-6.7 1.1 .5]*lg, ...
   'tooltip',s);
h.lock(2) = uicontrol('parent',hfig, ...
   'backgroundcolor',bg, ...
   'style','text', ...
   'units','points', ...
   'fontsize', sm, ...
   'horiz','left', ...
   'pos',[2.4*lg (y-6.75)*lg 10*sm sm], ...
   'string','Locked-in', ...
   'tooltip',s);


% ---------------------------------------------------------------
function fig_data = create_display(block_name, params)
% CREATE_DISPLAY Create new scope GUI

% Initialize empty settings:
fig_data.main  = [];  % until we move things here
fig_data.menu  = [];

hfig = figure('numbertitle', 'off', ...
   'name',         block_name, ...
   'menubar','none', ...
   'position',     params.FigPos, ...
   'nextplot',     'add', ...
   'integerhandle','off', ...
   'doublebuffer', 'off', ...
   'ResizeFcn',    'sdspwwvdisp([],[],[],''FigResize'');', ...
   'DeleteFcn',    'sdspwwvdisp([],[],[],''FigDelete'');', ...
   'HandleVisibility','callback');
     
% Create main display
fig_data.gui = wwvgui(hfig);

% Establish settings for all structure fields:
fig_data.block  = block_name;
fig_data.hfig   = hfig;

% Record figure data:
set(hfig, 'UserData', fig_data);

reset_display(hfig);

% ---------------------------------------------------------------
function fig_data = restart_scope(block_name, params)
% RESTART_SCOPE Restart with existing scope window

% We want to confirm to a reasonable probability that
% the existing scope window is valid and can be restarted.

% The caller already verified that hfig is non-empty
block_data = get_param(block_name,'UserData');
hfig = block_data.hfig;

% We don't know if the handle points to a valid window:
if isempty(hfig) | ~ishandle(hfig),
   block_data.hfig = [];  % reset it back
   set_param(block_name,'UserData',block_data);
   fig_data = [];
   return;
end

figure(hfig); % bring window forward
fig_data = get(hfig,'UserData');
reset_display(hfig);


% ---------------------------------------------------------------
function NameChange
% In response to the name change, we must do the following:
%
% (1) find the old figure window, only if the block had a GUI 
%     associated with it.
%     NOTE: Current block is parent of the S-function block
block_name = gcb;
block_data = get_param(block_name, 'UserData');

% System might never have been run since loading.
% Therefore, block_data might be empty:
if ~isempty(block_data),
   %isstruct(block_data),
   % (2) change name of figure window (cosmetic)
   hfig = block_data.hfig;
   set(hfig,'name',block_name);
   
   % (3) update figure's userdata so that the new blockname
   %     can be used if the figure gets deleted
   fig_data = get(hfig,'UserData');
   fig_data.block = block_name;
   set(hfig,'UserData',fig_data);
end



% ---------------------------------------------------------------
function CloseFigure(blk)
% Manual (programmatic) closing of the figure window

block_data = get_param(blk,'UserData');
hfig       = block_data.hfig;
fig_data   = get(hfig,'UserData');

% Reset the block's figure handle:
block_data.hfig = [];
set_param(blk, 'UserData',block_data);

% Delete the window:
set(hfig,'DeleteFcn','');  % prevent recursion
delete(hfig);


% ---------------------------------------------------------------
function FigDelete
% Callback from figure window
% Called when the figure is closed or deleted

hfig = gcbf;
fig_data = get(hfig,'UserData');
if hfig ~= fig_data.hfig,
   error('Figure handle consistency error in FigDelete.');
end

% Close the figure window
CloseFigure(fig_data.block);


% ---------------------------------------------------------------
function BlockDelete
% Block is being deleted from the model

% clear out figure's close function
% delete figure manually
blk = gcbh;
block_data = get_param(blk,'UserData');
if isstruct(block_data),
   set(block_data.hfig, 'DeleteFcn','');
   delete(block_data.hfig);
   block_data.hfig = [];
   set_param(blk,'UserData',block_data);
end


% ---------------------------------------------------------------
function BlockCopy
% Block is being copied from the model

% clear out stored figure handle
blk = gcbh;
block_data = get_param(blk,'UserData');
if isstruct(block_data),
   block_data.hfig = [];
   set_param(blk,'UserData',block_data);
end


% ---------------------------------------------------------------
function SaveFigPos
% Record the current position of the figure into the block's mask

% Get the block's name:
hfig = gcbf;
fig_data = get(hfig,'UserData');
if hfig ~= fig_data.hfig,
   error('Figure handle consistency error in SaveFigPos.');
end

% Record the figure position, as a string, into the appropriate mask dialog:
FigPos = get(hfig,'Position');             % Get the fig position in pixels
blk = fig_data.block;
set_param(blk, 'FigPos', mat2str(FigPos)); % Record new position
% No need for SetAndApply here


% ---------------------------------------------------------------
function SetAndApply(blk,varargin)

if strcmp(varargin{end},'eval'),
   evalmode=1;
   varargin=varargin(1:end-1);
else
   evalmode=0;
end

% Set value into mask param:
set_param(blk, varargin{:});

% Determine if dialog is open:
dialog_open = 1;  % xxx Must determine this dynamically

if dialog_open,
   % Manually apply changes, since dynamic dialog behavior
   % does not allow the change to apply when dialog is open:
   block_data = get_param(blk,'UserData');
   params = block_data.params;
   for i=1:length(varargin)/2,
      v = varargin(2*i-1 : 2*i);
      if evalmode,
         % evaluation value in p/v pair:
         v{2} = str2double(v{2});
      end
      params = setfield(params,v{:});
   end
   DialogApply(params, blk);
end


% ---------------------------------------------------------------
function sys = mdlTerminate
% TERMINATE Clean up any remaining items

sfcn = gcb;
blk  = get_param(sfcn,'parent');
block_data = get_param(blk,'UserData');


sys = [];  % No states to return


% ------------------------------------------------------------
% [EOF] sdspwwvdisp.m
