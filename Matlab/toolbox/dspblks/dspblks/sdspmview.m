function  [sys, x0, str, ts] = sdspmview(t,x,u,varargin)
% SDSPMVIEW Signal Processing Blockset M-file S-function to display
%   an input matrix as an image.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:05:30 $

% Syntax:
%
%   sdspmview(t,x,u,flag, params);
%
% where params is a structure containing all block dialog parameters.


% What's in the Figure userdata:
% ------------------------------
% Main scope figure handles:
%   fig_data.block        block name
%   fig_data.hfig         handle to figure
%
%   fig_data.main.haxis         handle to axes
%   fig_data.main.himage        image handles
%   fig_data.main.axiszoom.on   P/V cell-array pairs to turn on zoom
%   fig_data.main.axiszoom.off     and turn it off when requested
%   fig_data.main.axiszoom.cbar    and move it to make room for colorbar
%   fig_data.main.colorbar.h    colorbar image
%   fig_data.main.colorbar.hax  colorbar axis handle
%
% Handles to menu items:
%   - appearing only in figure menu:
%       fig_data.menu.recpos     record position
%
%   - appearing in both figure and context menu:
%       fig_data.menu.top          top-level Axes and Lines in Figure
%       fig_data.menu.context      context menu
%       fig_data.menu.axiszoom     2x1, [fig;context] (checkable)
%       fig_data.menu.axiscolorbar 2x1, [fig;context]
%       fig_data.menu.autoscale
%
%
% What's in the Block userdata:
% -----------------------------
%   block_data.firstcall    flag for first call to function
%   block_data.autoscaling  indicates autoscale computation in progress
%   block_data.hfig         handle to figure
%   block_data.haxis        handle to axes
%   block_data.himage       image handle
%   block_data.params       structure of cached block dialog parameters
%   block_data.hcolorbar    colorbar image handle
%   block_data.haxcolorbar  colorbar axis handle
%
% Parameters structure fields:
% ----------------------------
% .CMap: Nx3 colormap matrix
% .YMin:         Minimum input data value
% .YMax:         Maximum input data value
% .NumCols: Number of columns in input matrix
%
% .AxisParams: indicates whether the Axis Settings are
%              currently displayed in block dialog.
% .AxisOrigin: Lower left cornerUpper left corner
% .XLabel: x-axis label for main image
% .YLabel: y-axis label for main image
% .ZLabel: color bar scaling label
% .FigPos:       figure position
% .AxisZoom:     checkbox
% .AxisColorbar: checkbox

switch(varargin{1})
case 3,
   sys = [];   % mdlOutput - unused
case 2,
   sys = mdlUpdate(t,x,u,varargin{:});
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
sizes.NumInputs      = -1;
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
function sys = mdlUpdate(t,x,u,flag,params)

% Faster implementation of: blk=gcb;
cs   = get_param(0,'CurrentSystem');
sfcn = [cs '/' get_param(cs,'CurrentBlock')];
blk  = get_param(sfcn,'parent');

% Return empty state vector, since we're not using any:
sys = [];

block_data = get_param(blk, 'UserData');
if block_data.firstcall,
   first_update(blk, u, params);
else
   update_image(block_data, u);
end

% end mdlUpdate


% ---------------------------------------------------------------
function update_image(block_data, u)
% UPDATE_IMAGE Update the matrix displayed in the viewer

% u: one matrix of data
% Does not alter block_data

% If the user closed the figure window while the simulation
% was running, then hfig has been reset to empty.
%
% Allow the simulation to continue, but do not put up a new
% figure window (or error out!)
%
%
if isempty(block_data.hfig),
   return
end

% Reshape for matrix input:
nrows = length(u) ./ block_data.params.NumCols;
u = reshape(u, nrows, block_data.params.NumCols);

% Update image:
%
% We cannot compare the new and old data, since
% Simulink has one (fixed) pointer for the data I/O,
% and "writes through" the pointer directly.  In other
% words, the HG image has its data automatically updated
% directly by Simulink.
%
% We could modify u before passing to HG in order to trigger
% a graphical update, but that would cause a deep copy of the
% entire matrix (a possibly large performance hit).  Plus,
% we couldn't add "eps" to a uint8/uint16 matrices.

xold = get(block_data.himage,'XData');
set(block_data.himage, ...
   'CData', u, ...
   'XData',xold+eps, ...
   'XData',xold);

% Since EraseMode='none', we don't need a drawnow
%
% Check if autoscaling is in progress:
if ~isempty(block_data.autoscaling),
   Autoscale(block_data, u);  % next frame of data
end


% ---------------------------------------------------------------
function startImageEraseMode(blk)
% Set image to proper erase mode at start of simulation.

% The image is set to 'normal' mode when a simulation terminates;
% for speed, mode is set to 'none' while running.

block_data = get_param(blk,'UserData');
set(block_data.himage,'EraseMode','none');


% ---------------------------------------------------------------
function terminateImageEraseMode(blk)
% Set image erase mode at simulation termination

block_data = get_param(blk,'UserData');
if isempty(block_data.hfig),
   return  % Skip if HG window is closed
end
set(block_data.himage,'EraseMode','normal');


% ---------------------------------------------------------------
function first_update(blk, u, params)
% FIRST_UPDATE Called the first time the update function is executed
%   in a simulation run.  Creates a new scope GUI if it does not exist,
%   or restarts an existing scope GUI.

% blk: masked subsystem block
% u: data matrix
% Updates block_data

block_data = get_param(blk,'UserData');

% Check that number of columns corresponds to input width:
if rem(length(u), params.NumCols) ~= 0,
   error('Number of channels does not correspond to length of input.');
end

% Record input frame time
% NOTE: This is the per-frame time, NOT the per-sample time
% Check sample time:
ts = get_param(blk,'CompiledSampleTime');
if ts(1) == 0,
   error('Input must be a discrete-time signal.');
end

% Check input data complexity and type:
if ~isreal(u),
   error('Inputs cannot be complex-valued.');
end
if ~isa(u,'double') & isa(u,'uint8'),
   error('Inputs must be uint8 or double-precision values.');
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
   fig_data = create_scope(blk, params);
end

% Get line handle:
himage = fig_data.main.himage;

% Retain the name of the figure window for use when the
% block's name changes. Name is retained in S-fcn block's
% user-data:
block_data.firstcall   = 0;   % reset "new simulation" flag
block_data.hfig      = fig_data.hfig;
block_data.params    = params;

block_data.haxis     = fig_data.main.haxis;
block_data.himage    = himage;
block_data.hcolorbar   = fig_data.main.colorbar.h;
block_data.haxcolorbar = fig_data.main.colorbar.hax;
block_data.autoscaling = []; % turn off any autoscaling, if in progress

% Set block's user data:
set_param(blk, 'UserData', block_data);

% The following block callbacks are assumed to be set
% in the library block:
%
%   CopyFcn		      "sdspmview([],[],[],'BlockCopy');"
%   DeleteFcn		  "sdspmview([],[],[],'BlockDelete');"
%   NameChangeFcn     "sdspmview([],[],[],'NameChange');"

% Set menu checks according to the block_data:
SetMenuChecks(blk);

% Setup scope axes:
setup_axes(blk, u);  % one frame of data

% Set erase mode of data channel lines:
startImageEraseMode(blk);


% ---------------------------------------------------------------
function SetMenuChecks(blk)
% Called from first_update and DialogApply to preset menu checks

% blk: masked subsystem block

block_data = get_param(blk,'UserData');
fig_data   = get(block_data.hfig,'UserData');

% Update AxisZoom menu check:
%
axisZoom = get_param(blk,'AxisZoom');
set(fig_data.menu.axiszoom, 'Checked',axisZoom);

% Update Colorbar menu check:
%
cBarCheck = get_param(blk,'AxisColorbar');
if strcmp(axisZoom,'on'),
   cBarVis='off';
else
   cBarVis='on';
end
set(fig_data.menu.axiscolorbar, ...
   'Checked', cBarCheck, ...
   'Enable',  cBarVis);


% ---------------------------------------------------------------
function RevertDialogParams(blk)
% Reset all current parameters in block dialog
% Only needs to revert evaluation-mode edit boxes

block_data = get_param(blk, 'UserData');
names = get_param(blk,'masknames');

req = {'NumCols','CMap', 'YMin','YMax', 'FigPos'};

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

% Check XLabel:
% -------------
if ~ischar(params.XLabel),
   msg = 'X-axis label must be a string.';
   return
end

% Check YLabel:
% -------------
if ~ischar(params.YLabel),
   msg = 'Y-axis label must be a string.';
   return
end

% Check ZLabel:
% -------------
if ~ischar(params.ZLabel),
   msg = 'Z-axis label must be a string.';
   return
end

% Check number of columns
% ------------------------
x = params.NumCols;
Nx = GetNumberOfElements(x);
if ~isa(x,'double') | issparse(x) | ~isreal(x) | ...
      (Nx ~= 1) | (x ~= floor(x)) | (x <= 0),
   msg = 'Number of channels must be a real, integer-valued scalar > 0.';
   return
end

% Check YMin:
% -----------
x = params.YMin;
Nx = GetNumberOfElements(x);
if ~isa(x,'double') | issparse(x) | ~isreal(x) | ...
      (Nx > 1),
   msg = 'Y-minimum must be a real-valued scalar.';
   return
end
ymin = x;

% Check YMax:
% -----------
x = params.YMax;
Nx = GetNumberOfElements(x);
if ~isa(x,'double') | issparse(x) | ~isreal(x) | ...
      (Nx > 1),
   msg = 'Y-maximum must be a real-valued scalar.';
   return
end
if ~isempty(x) & ~isempty(ymin) & (x <= ymin),
   msg = 'Maximum Y-axis limit must be greater than Minimum Y-axis limit.';
   return
end

% Check FigPos:
% -------------
x = params.FigPos;
if ~isa(x,'double') | issparse(x) | ~isreal(x) | ...
      size(x,1)~= 1 | size(x,2)~=4,
   msg = 'Figure position must be a real-valued 1x4 vector.';
   return
end

% Check CMap:
% -----------
x = params.CMap;
if ~isa(x,'double') | (ndims(x)~=2) | (size(x,2)~=3),
   msg = 'Colormap must be an Nx3 matrix.';
   return
end

% Check AxisParams:
% Check AxisZoom:
% Check AxisColorbar:
% Check AxisOrigin:
% -----------------
% (skip checkboxes and popups)


% ---------------------------------------------------------------
function DialogApply(params,block_name)

% Called from MaskInitialization command via:
%   sdspmview([],[],[],'DialogApply',params);

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
   errordlg(msg,'Matrix Viewer Dialog Error','modal');
   RevertDialogParams(block_name);
   return
end

% On start-up, no params field exists
% Set params, and skip any further processing
if ~isfield(block_data,'params'),
   block_data.params = params;
   set_param(block_name, 'UserData', block_data);
   return
end

% Check for a run-time change (colormap, etc):
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
   
   % Check for a change in the number of columns
   % If they've changed, close the figure
   if block_data.params.NumCols ~= params.NumCols,
      
      block_data.params = params;
      set_param(block_name, 'UserData', block_data);
      
      CloseFigure(block_name);
      return
   end
   
   % GUI is open and a change has been made
   % Update menu checks:
   SetMenuChecks(block_name);
   
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
   
   % Adjust the GUI axes, colormap, etc,
   % passing it ONE INPUT of data (u);
   %
   % Get current image data
   u = get(block_data.himage, 'CData');
   u = u(:);  % Reshape data as Simulink vector
   
   setup_axes(block_name, u);
end


% ---------------------------------------------------------------
function setup_axes(block_name, u)
% Setup viewer x- and y-axes

% Does not alter block_data
% u = input data (one matrix)

block_data = get_param(block_name,'UserData');
hfig    = block_data.hfig;
hax     = block_data.haxis;
himage  = block_data.himage;
ncols   = block_data.params.NumCols;
nrows   = length(u) / ncols;
haxclr  = block_data.haxcolorbar;

% Refresh display: (in case of stray markings):
% ----------------
FigRefresh(block_data.hfig);

% Setup X-axis label:
% -------------------
% Don't modify user-defined domain:
xLabel = block_data.params.XLabel;
if ~isstr(xLabel), xLabel = 'X-Axis'; end
hxLabel = get(hax, 'XLabel');
set(hxLabel, 'String', xLabel);

% Setup Y-axis label:
% -------------------
yLabel = block_data.params.YLabel;
if ~isstr(yLabel), yLabel='Y-Axis'; end
hyLabel = get(hax,'YLabel');
set(hyLabel, 'String', yLabel);

% Setup Colorbar label:
% ---------------------
cLabel = block_data.params.ZLabel;
if ~isstr(yLabel), cLabel='Z-Axis'; end
hyLabel = get(haxclr,'YLabel');
set(hyLabel, 'String', cLabel);

% Setup image data:
% -----------------
% NOTE: update_image() does NOT alter the xdata or ydata,
%       so it could be set up once here:
cmap = block_data.params.CMap;
set(hfig,'colormap', cmap);
set(himage,'CData', reshape(u, nrows, ncols));

% Adjust axis for origin:
origin = block_data.params.AxisOrigin;
isXY=strncmp(origin,'Lower',5);
if isXY, ydir='normal';
else ydir='reverse';
end
set(hax,'YDir',ydir);

% Setup colormap scaling only if input is double-precision, and
% if either ymin/ymax is empty:
% - Figure has the colormap
% - Axis has the clim/climmode
% - image has the image data
if isa(u,'double'),
   % block_data.params.YMin
   % block_data.params.YMax
   if ~isempty(block_data.params.YMin) & ...
         ~isempty(block_data.params.YMax),
      set(hax, ...
         'clim',[block_data.params.YMin block_data.params.YMax], ...
         'climmode','manual');
      set(himage,'CDataMapping','Scaled');
   else
      set(hax, 'climmode','auto');
      set(himage,'CDataMapping','Direct');
   end
end

% Update colorbar image:
% ----------------------
cbar     = block_data.params.AxisColorbar;
axiszoom = block_data.params.AxisZoom;

useColorbar   = strcmp(cbar,'on');
noZoom        = strcmp(axiszoom,'off');
cbarANDnozoom = useColorbar & noZoom;

% Colorbar (and its axis) visibility:
if cbarANDnozoom, cbarVis='on'; else cbarVis='off'; end

% Modify colorbar vertical axis limits to match
% the current scaling method in force:
N = size(cmap,1);
ylim = [1 N];
if isa(u,'double'),
   if ~isempty(block_data.params.YMin) & ...
      ~isempty(block_data.params.YMax),
      ylim = [block_data.params.YMin block_data.params.YMax];
   end
end

set(block_data.hcolorbar, ...
   'CDataMapping','Direct', ...
   'CData',(1:N)', ...
   'YData',ylim, ...
   'vis', cbarVis);

set(haxclr, ...
   'ylim',ylim, ...
   'vis', cbarVis);


% Perform AxisZoom:
% -----------------
% Put axis into correct zoom state:
fig_data = get(hfig,'UserData');
if noZoom,
   % Turn off AxisZoom:
   
   % - turn on menus
   set(fig_data.menu.top,'vis','on');
   set(hfig,'menu','figure');
   
   % - reset axis position
   if useColorbar,
      set(hax, fig_data.main.axiszoom.cbar{:});
   else
      set(hax, fig_data.main.axiszoom.off{:});
   end
   
else
   % Turn on AxisZoom:
   
   % - turn off top-level menus
   set(fig_data.menu.top,'vis','off');
   set(hfig,'menu','none');
   
   % - set axis position
   set(hax, fig_data.main.axiszoom.on{:});
end

set(hax, ...
   'xlim',[0.5 ncols+0.5], ...
   'ylim',[0.5 nrows+0.5], ...
   'zlimmode','manual');

% Update display with the actual line values:
update_image(block_data, u);  % one frame of data


% ---------------------------------------------------------------
function fig_data = create_scope(block_name, params)
% CREATE_SCOPE Create new scope GUI

% Initialize empty settings:
fig_data.main  = [];  % until we move things here
fig_data.menu  = [];

hfig = figure('numbertitle', 'off', ...
   'name',         block_name, ...   % 'menubar','none',
   'position',     params.FigPos, ...
   'nextplot',     'add', ...
   'integerhandle','off', ...
   'renderer',     'painters', ...
   'doublebuffer', 'off', ...
   'DeleteFcn',    'sdspmview([],[],[],''FigDelete'');', ...
   'HandleVisibility','callback');

% Use double-buffer when image EraseMode is set to 'none',
% AND when we're doing a forced double-update.  This would
% reduce the work to one on-screen blit instead of two...

% Axis for the image:
hax = axes('Parent',hfig, ...
   'DrawMode','fast', ...
   'Box','on', 'ticklength',[0 0]);

% Axis for the colorbar:
haxcbar = axes('Parent',hfig, ...
   'xtick', [], ...  % turn off x ticks
   'xlim', [0 1], ...
   'yaxislocation','right', ...
   'Box','on', 'ticklength',[0 0]);
   
% Set up image:
ncols = params.NumCols;
himage = image('parent',hax,'cdata',[]);

% Set up colorbar image:
hcolorbar = image('parent',haxcbar,'cdata',[],'xdata',[0 1]);

% Create a context menu:
mContext = uicontextmenu('parent',hfig);

% Establish settings for all structure fields:
fig_data.block = block_name;
fig_data.hfig  = hfig;

% Store major settings:
fig_data.main.haxis   = hax;
fig_data.main.himage  = himage;
fig_data.menu.context = mContext;

% Store settings for axis zoom:
% Cell-array contains {params, values},
% where params itself is a cell-array of Units and Position
% and values is a cell-array of corresponding values.
p = {'Units','Position'};
fig_data.main.axiszoom.off  = {p, {'Normalized',[.13 .145 .8 .8]}};
fig_data.main.axiszoom.on   = {p, {'Normalized',[ 0   0    1    1]}};
fig_data.main.axiszoom.cbar = {p, {'Normalized',[.13 .145 .645 .8]}};

% Copy colorbar data:
%
fig_data.main.colorbar.pos  = {p, {'Normalized',[.8 .145 .075 .8]}};
fig_data.main.colorbar.h    = hcolorbar;
fig_data.main.colorbar.hax  = haxcbar;

set(hax,    'Position',fig_data.main.axiszoom.cbar{2}{2});
set(haxcbar,'Position',fig_data.main.colorbar.pos{2}{2});

% Define axis menu labels:
%
pcwin = strcmp(computer,'PCWIN');
if pcwin,
   labels = {'&Axes', '&Refresh', ...
         '&Autoscale', 'Axis &Zoom', '&Colorbar', ...
         'Save &Position'};
else
   labels = {'Axes', 'Refresh', ...
         'Autoscale', 'Axis Zoom', 'Colorbar', ...
         'Save Position'};
end
%
% Create figure AXIS menu
mAxes = uimenu(hfig, 'Label', labels{1});  % top-level Axes menu in figure
%
% submenu items:
fig_data.menu.refresh = uimenu(mAxes, 'label',labels{2}, ...
   'callback','sdspmview([],[],[],''FigRefresh'');');
fig_data.menu.autoscale = uimenu(mAxes, 'label',labels{3}, ...
   'separator','on',...
   'callback', 'sdspmview([],[],[],''Autoscale'');');
% - Create Axis Zoom item
fig_data.menu.axiszoom = uimenu(mAxes, ...
   'Label', labels{4}, ...
   'Callback', 'sdspmview([],[],[],''AxisZoom'');');
% - Create Colorbar item
fig_data.menu.axiscolorbar = uimenu(mAxes, ...
   'Label', labels{5}, ...
   'Callback', 'sdspmview([],[],[],''AxisColorbar'');');
% - Create Record Position item
fig_data.menu.recpos = uimenu(mAxes, 'label',labels{6}, ...
   'callback', 'sdspmview([],[],[],''SaveFigPos'');', ...
   'separator','on');

% Store all top-level menu items in one vector
fig_data.menu.top = mAxes;

% Copy menu items in common to both single- and multi-line context menus:
%
% Copy autoscale menu to context menu:
%
cAutoscale = copyobj(fig_data.menu.autoscale, mContext);
set(cAutoscale,'separator','off');  % Turn off separator just above item
%
% Copy AxisZoom menu, storing both menu handles:
cAxisZoom = copyobj(fig_data.menu.axiszoom, mContext);
fig_data.menu.axiszoom = [fig_data.menu.axiszoom cAxisZoom];

%
% Copy Colorbar menu, storing both menu handles:
cColorbar = copyobj(fig_data.menu.axiscolorbar, mContext);
fig_data.menu.axiscolorbar = [fig_data.menu.axiscolorbar cColorbar];

%
% Copy save position menu:
cSavePos = copyobj(fig_data.menu.recpos, mContext);

% Record figure data:
set(hfig, 'UserData', fig_data);

% Assign context menu to the axis, lines, and grid:
set([fig_data.main.haxis fig_data.main.himage], ...
   'UIContextMenu', mContext);


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

% Something could fail during restart if the figure data was
% altered between runs ... for example, by command-line interaction.
% If errors occur, abandon the restart attempt:
try,
   fig_data = get(hfig,'UserData');
   
   % In case memory (persistence) was on:
   FigRefresh(hfig);
   
   figure(hfig); % bring window forward
   
catch
   % Something failed - reset hfig to indicate error during restart:
   fig_data.hfig=[];
   block_data.hfig=[];
end

% Update data structures:
set(hfig, 'UserData',fig_data);
set_param(block_name, 'UserData',block_data);


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
function AxisColorbar(hfig,opt)
% Toggle axis colorbar on and off
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<2, opt='toggle'; end
if nargin<1, hfig=gcbf; end

fig_data = get(hfig, 'UserData');
blk      = fig_data.block;
haxcbar  = fig_data.menu.axiscolorbar;

if strcmp(opt,'toggle'),
   % toggle current setting:
   if strcmp(get(haxcbar,'Checked'),'on'),
      opt='off';
   else
      opt='on';
   end
end

% Update menu check:
set(haxcbar,'Checked',opt);

% Update block dialog setting, so param is recorded in model:
% This will indirectly update the param structure, via the
% mask dialog callbacks.
SetAndApply(blk, 'AxisColorbar', opt);


% ---------------------------------------------------------------
function AxisZoom(hfig,opt)
% Toggle display of zoomed-in axes
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<2, opt='toggle'; end
if nargin<1, hfig=gcbf; end

fig_data = get(hfig, 'UserData');
blk      = fig_data.block;
haxzoom  = fig_data.menu.axiszoom;

if strcmp(opt,'toggle'),
   % toggle current setting:
   if strcmp(get(haxzoom,'Checked'),'on'),
      opt='off';
   else
      opt='on';
   end
end

% Update menu check:
set(haxzoom,'Checked',opt);

% Update block dialog setting, so param is recorded in model:
% This will indirectly update the param structure, via the
% mask dialog callbacks.
SetAndApply(blk, 'AxisZoom', opt);


% ---------------------------------------------------------------
function Autoscale(block_data, u)
% AUTOSCALE Compute min/max y-limits for several input frames

if nargin<2,
   % Begin autoscale iterations
   
   if nargin==1,
      hfig = block_data;  % 1st arg is hfig
   else
      hfig = gcbf;
   end
   
   fig_data = get(hfig,'UserData');
   blk = fig_data.block;
   block_data = get_param(blk,'UserData');
   
   % If an autoscale operation is currently in progress,
   % cancel it and stop:
   if ~isempty(block_data.autoscaling),
      CancelAutoscale(blk);
      return;
   end
   
   % If simulation stopped, do a one-shot autoscale and leave:
   v = get_sysparam(blk,'simulationstatus');
   if ~strcmp(v,'running'),
      % Simulation is stopped or paused - perform simple one-shot autoscaling:
      oneshot_autoscale(hfig);
      return;
   end
   
   
   % Begin countdown
   % This is the number of sequential frames which will be examined
   % in order to determine the min/max y-limits
   count=10;
   
   % Preset min and max
   ymin=+inf;
   ymax=-inf;
   
   % Put up an autoscale indicator:
   str = ['Autoscale: ' mat2str(count)];
   htext = text('units','norm','pos',[0.5 0.5], ...
      'Color','white', ...
      'EraseMode','none', ...
      'horiz','center', 'string',str);
   
   block_data.autoscaling = [count ymin ymax htext];
   set_param(blk, 'UserData', block_data);
   
else
   % 2 input arguments
   
   % Continue processing next frame of inputs
   % to determine autoscale limits
   
   count = block_data.autoscaling(1);
   ymin  = block_data.autoscaling(2);
   ymax  = block_data.autoscaling(3);
   htext = block_data.autoscaling(4);
   
   if count>0,
      % Continue tracking min and max:
      
      fig_data = get(block_data.hfig, 'UserData');
      blk = fig_data.block;
      
      count=count-1;
      ymin=min(ymin,min(u(:)));
      ymax=max(ymax,max(u(:)));
      
      % Update user feedback:
      set(htext,'string',['Autoscale: ' mat2str(count)]);
      
      block_data.autoscaling = [count ymin ymax htext];
      set_param(blk, 'UserData', block_data);
      
   else
      % Finished computing autoscale limits
      
      % Remove autoscale indicator:
      delete(htext);
      htext=[];  % reset so that terminate call deletes an empty handle
      
      % Turn off autoscale flag
      fig_data = get(block_data.hfig, 'UserData');
      blk = fig_data.block;
      
      block_data = get_param(blk,'UserData');
      block_data.autoscaling = [];
      set_param(blk, 'UserData', block_data);
      
      % Protect against horizontal lines:
      if (ymax==ymin),
         ymin=floor(ymin-.5);
         ymax=ceil(ymax+.5);
      end
      
      % Indirectly set these via the DialogApply callback:
      SetAndApply(blk, 'YMin',mat2str(ymin), ...
                       'YMax',mat2str(ymax), 'eval');
   end
end


% ---------------------------------------------------------------
function CancelAutoscale(blk)

% Cancel any pending autoscale operation

block_data = get_param(blk,'UserData');

% No autoscale operation in progress:
if ~isfield(block_data,'autoscaling') | isempty(block_data.autoscaling),
   return;
end

htext = block_data.autoscaling(4);
delete(htext);
block_data.autoscaling=[];
set_param(blk,'UserData', block_data);


% ---------------------------------------------------------------
function oneshot_autoscale(hfig)
% ONESHOT_AUTOSCALE Used when simulation is stopped
%   Cannot use multi-input autoscale, since the simulation is no longer
%   running.  Instead, we compute a one-time ymin/ymax computation, and
%   apply it to the static scope result.

fig_data = get(hfig, 'UserData');
blk = fig_data.block;

% Get data for each line, and find min/max:
himage = fig_data.main.himage;
y = get(himage,'CData');
ymin = min(y(:));
ymax = max(y(:));

% Protect against horizontal lines:
if (ymax==ymin),
   ymin=floor(ymin-.5);
   ymax=ceil(ymax+.5);
end

% Indirectly set these via the DialogApply callback:
SetAndApply(blk, 'YMin',mat2str(ymin), ...
                 'YMax',mat2str(ymax), 'eval');


% ---------------------------------------------------------------
function sys = mdlTerminate
% TERMINATE Clean up any remaining items

sfcn = gcb;
blk  = get_param(sfcn,'parent');
block_data = get_param(blk,'UserData');

% Cancel any pending autoscale operation:
CancelAutoscale(blk);

% Redraw all lines in "normal" mode; when lines redraw over themselves
% in "xor" mode, dots are left at peaks without lines connecting to them.
% This can be visually misleading.
terminateImageEraseMode(blk);

sys = [];  % No states to return


% ---------------------------------------------------------------
function FigRefresh(hfig)
% Refresh display while memory turned on

if nargin<1, hfig=gcbf; end
if ~isempty(hfig),
   refresh(hfig);
end


% ---------------------------------------------------------------
function nEle = GetNumberOfElements(x)
nEle = prod(size(x));

% ------------------------------------------------------------
% [EOF] sdspmview.m
