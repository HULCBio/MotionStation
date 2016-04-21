function [sys, x0, str, ts] = sdspwfall(t,x,u,flag,varargin)
%SDSPWFALL Signal Processing Blockset S-Function implementing Waterfall plot.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.5.4.4 $  $Date: 2004/04/12 23:05:31 $

% The following block callbacks are assumed
% to be set in the library block:
% -----------------------------------------
%   CopyFcn		       "sdspwfall([],[],[],'BlockCopy');"
%   DeleteFcn          "sdspwfall([],[],[],'BlockDelete');"
%   UndoDeleteFcn      "sdspwfall([],[],[],'BlockUndoDelete');
%   LoadFcn            "sdspwfall([],[],[],'BlockLoad');"
%   ModelCloseFcn
%   PreSaveFcn
%   PostSaveFcn
%   InitFcn            (done via S-fcn)
%   StartFcn           (done via S-fcn)
%   StopFcn            (done via S-fcn)
%   NameChangeFcn      "sdspwfall([],[],[],'BlockNameChange');"
%   ClipboardFcn
%   DestroyFcn         unused: fires when block no longer able to be
%                               un-deleted, generally at model close
%   OpenFcn            "sdspwfall([],[],[],'BlockOpen');
%   CloseFcn
%   ParentCloseFcn
%   MoveFcn
%   DeleteChildFcn
%   ErrorFcn           "sdspwfall"
%   MaskInitialization "sdspwfall([],[],[],'DialogApply');"
%
% Load-time sequence of calls
% ---------------------------
% Note that MaskSelfModifiable is turned on for this library block,
% in order to get the mask parameters evaluated during load-phase
% of a model that contains the block.  This is necessary so we know
% whether the block must be opened, parameters affecting the initial
% scope placement, etc.
%
%   Block    Event    Handle  ParamsEvaluated
%   -----    -----    ------  ---------------
%      <Load time of model and library>
%   library  LoadFcn  x       no
%   model    InitFcn  y1      yes (we ignore this event)
%   model    LoadFcn  y2      yes (first event we react to)
%
%      <Update diagram: ctrl+d)
%   model    Dynamic  y2      yes (mask dialog)
%   model    InitFcn  y2      yes
%
%   Note that due to the MaskSelfModifiable load sequence, the block
%   handle during the first InitFcn prior to LoadFcn is not the same
%   as the block handle during the rest of the load sequence.
%
%   Note that when a block is deleted, and then un-deleted,
%   the LoadFcn does not execute again.  Instead, we set the
%   UndoDelete function and have it go to the LoadFcn callback.
%
%    Note: leave userdata on the subsystem, and don't move it
%    to the underlying s-function block.  We can guarantee a
%    change in handle for that case, so that will be pointless.
%    The parent/subsystem should have a constant handle, despite
%    the current bug.
%
% What's in the Figure userdata:
% ------------------------------
% Main scope figure handles:
%   fig_data.block        block name
%           .hfig         handle to figure
%           .haxis         handle to axes
%           .history.slider
%           .history.labels
%           .history.frame
%           .hStatusBar.Region
%           .hStatusBar.StatusText
%           .hStatusBar.DataSizes
%           .hStatusBar.TraceInfo
%           .hStatusBar.XformMode
%           .hStatusBar.All  all except .Region and .StatusText
%
% Handles to menu items:
%   fig_data.menu.sptool     export to SPTool
%                .axisgrid    (checkable)
%                .snapshot      (checkable)
%                .suspend       (checkable)
%                .autoscale
%                .top          top-level Axes and Lines in Figure
%                .context      context menu
%                .icons        for dynamic icons
%                .buttons      button bar
%                .buttons.Toolbar
%                .buttons.Params
%                .buttons.[lots more!]
%
% What's in the Block userdata:
% -----------------------------
%   block_data.hfig         handle to figure
%             .haxis        handle to axes
%             .hsurf        surface handle
%             .hdiscontig   handle to discontiguous-time indicator lines
%             .params       structure of cached block dialog parameters
%             .bdroot
%             .BufferFullFcn  what to do when history buffer fills
%             .InputPortDims  block input dimensions
%             .IsScalarInput  derived from .InputPortDims
%             .indims         dimensions into history service
%                             (eg, dimensions coming out of data transformation)
%             .HistoryLengthActual
%             .HistoryID
%             .HistoryRecFcn
%             .HistoryRecFcn_suspend
%             .TriggerFcn
%             .TriggerData
%                   .UserFcn
%                   .LastTimeStamp
%                   .Cnt  input count for trigger
%             .UpdateFcn
%             .XformFcn   user-defined data transformation function
%             .UpdateIntervalCounter  display-update interval counter
%             .DiscontigColors
%             .LastTimeStamp
%             .LastDiscontigSet
%             .Ts
%             .ScopeToolbarVis   Scope toolbar visibility, 'on' or 'off'
%             .param_dlg.hfig
%             .param_dlg.pos
%             .param_dlg.tabNum
%
% Parameters structure fields:
% ----------------------------
%  params.NumTraces     scalar, # of traces
%        .CMapStr       colormap fcn name (string)
%        .TNewest       Transparency fraction, 0=opaque, 1=transparent
%        .TOldest
%        .HistoryLength     edit box, # inputs (beyond one displayfull)
%                                   to record in history buffer
%                            Overwrite, Suspend: actual buffer size
%                            Extend: initial buffer size
%        .HistoryFull     Popup (Overwrite, Suspend, Extend)
%        .UpdateInterval  edit, # inputs to record before updating display
%        .MouseMode       Popup, literal: Arrow|Orbit|Zoom
%        .AxisGrid        Checkbox
%        .Snapshot        Checkbox
%        .Suspend         Checkbox
%        .SyncSnapshots   Checkbox
%        .OpenScopeAtSimStart  checkbox
%        .FigPos        figure position
%        .CameraView   edit box with vector
%        .InportDimsHint edit box with dimensions vector
%        .YMin:         Minimum input data value
%        .YMax:         Maximum input data value
%        .XLabel: x-axis label for main image
%        .YLabel: y-axis label for main image
%        .ZLabel: color bar scaling label
%
%        .TrigStartMode: popup, literal
%               'Immediately|After T seconds|After N inputs|User-defined'
%        .TrigStartT     edit box, eval
%        .TrigStartN     edit box, eval
%        .TrigStartFcn   edit box, literal
%        .TrigStopMode   popup, literal
%               'Never|After T seconds|After N inputs|User-defined'
%        .TrigStopT      edit box, eval
%        .TrigStopN      edit box, eval
%        .TrigStopFcn    edit box, literal
%        .TrigRearmMode  popup, literal
%               'Never|After T seconds|After N inputs|User-defined'
%        .TrigRearmT      edit box, eval
%        .TrigRearmN      edit box, eval
%        .TrigRearmFcn    edit box, literal
%        .XformMode       popup, data transformation mode
%        .XformExpr       edit, literal, expression
%        .XformFcn        edit, literal, function name
%
% HistorySvc
% ----------
%  History is stored as individual records (structures)
%      rec.Values
%         .Time
%         .Discontig

% Gecks:
% -----------------------------
% PRIORITY 1
% (-- these next few are related --)
%  ENH: scalar inputs, improve message
%  ENH: if block is disconnected, what to display?
%                   CheckInportAttributes
%    probably some informative text instead of a display
%    consider suspend mode if disconnected
%    (be sure to disregard sync flag, however)
%  ENH:  (follow up to disconnected block msgs)
%        -> want some sort of general message display for error conditions.
%           Blank axis, centered message - no "hard errors"
%           Use for invalid input data as well
% (-- these next few are related --)
%  ENH: unify input/xform data handling
%     - when to check for input dim errors
%     - when to perform "vector convenience" rule
%     move parts of "first_history_rec" into this check fcn
%     etc
%  ENH: reconcile all the "inportdimshint" caches,
%        in bd.params.indims, inportdimshint in block, etc
%  ENH:
%    Record "raw" input data, transform it afterwards
%    Allows a change in xform to be recomputed across all
%    history data and reflected back to display
%    Upside: really good interactive visualization!
%    Downside: might be recording much more data, if transform
%       simply removed a few points from a large matrix, etc.
%       Then again, why was somebody sending a bit honk of data
%       to the scope anyway?
%
% PRIORITY 2:
% ENH: add option for user-defined x-axis ticks
%      (0:N-1 is the default, others may be needed)
% ENH: export could remove unused data allocations
%      from the buffers (NaNs)
% ENH: Don't use block mask params, just save as UserData
%      and fully decouple behaviors
% ENH: Abstract out the "specific type of plot" code
%      - Add matrix viewer functionality
%      - Add 3-D surf in addition to slices
% ENH: allow solid colors, more opaque borders for traces
%       allow user-defined
% ENH: Export data to MATLAB, option to export time stamps
% ENH: data xform: allow optional "arguments" edit box
%
% PRIORITY 3:
% ENH: direct drive of scope from MATLAB
%      Use new APIs in R14
% ENH: Re: pushbutton to locate parent block/signal in model
%      need an "any click" callback
% ENH: 3-D axis labels
%       - not placed where we want them to be
% ENH: consider "fastdraw" option
% ENH: Move some common fcns into private
%      these are marked with "xxx COMMON"
% ENH: autoscale should not change axis size, only data limits
%      behavior may not be desired

% Debug:
% if nargin==2,
%     fprintf('blk %s: mdlError call\n', gcb);
% elseif nargin>3,
%     fprintf('blk %s: flag=', gcb); disp(flag);
% else
%     fprintf('blk %s: nargin==3\n');
% end

if nargin==2,
    sys = mdlError(t,x);
else
    switch(flag)
        case 2,
            sys = mdlUpdate(t,u);
        case 0,
            [sys,x0,str,ts] = mdlInitializeSizes;
        case 9,
            sys = mdlTerminate;
        otherwise,
            if ischar(flag),
                feval(flag,varargin{:});
            end
    end
end


% =========================================================================
% S-FUNCTION API CALLS
% =========================================================================

% -----------------------------------------------------------
function [sys,x0,str,ts] = mdlInitializeSizes

% gcbh: handle to s-fcn block
blkh  = get_param(get_param(gcbh,'parent'),'handle');

sizes = simsizes;
sizes.NumInputs      = -1;
sizes.NumOutputs     =  0;
sizes.NumSampleTimes =  1;
sys = simsizes(sizes);
x0  = [];           % states
str = '';           % state ordering strings
ts  = [-1 1];       % inherited sample time, fixed in minor steps

% The following are always called at the start of a simulation,
% not just when the scope is open or running.  But note that
% loading a model, or opening a scope when the model is not
% running, does not cause mdlInit to run.

mdlUpdateDiagramOrStart(blkh);
switch get_param(bdroot(blkh),'SimulationStatus')
    case 'updating'
        mdlUpdateDiagram(blkh); % only ctrl+D
    case 'initializing'
        mdlStart(blkh);  % only ctrl+T
end

% ------------------------------------------------------------
function mdlUpdateDiagramOrStart(blkh)
% Called at both ctrl+d and ctrl+t time

update_block_handles(blkh);

% ------------------------------------------------------------
function mdlUpdateDiagram(blkh)
% Called only when the model is "updated"
% That is, ctrl+D pressed, or menu Edit->Update diagram selected
% This is NOT called when the model is run (ctrl+T)


% ------------------------------------------------------------
function mdlStart(blkh)
% Called once at the start of model execution


% Find and cache the input complexity
%
complexHandler_install(blkh);
resetToFirstCall(blkh);
SnapshotSvc('init', blkh);     % initializes Suspend/Snapshot service
setup_history_service(blkh,1); % do flush
xform_init(blkh, 0);
trigger_init(blkh);


% ------------------------------------------------------------
function bd = update_block_handles(blkh)
% Updates handles recorded in library block,
% and in s-fcn block
%
% library block:
%   bdroot
% s-fcn block:
%   handle to library block

bd = get_param(blkh,'UserData');
if isempty(bd),
    % error('Attempt to re-initialize uninitialized block data.');
    %
    % How can we get here legitimately?
    % Copy a new scope block from source library, such that
    % the LoadFcn did not have a chance to execute on this block.
    % Then, attach scope and run model.
    bd = BlockLoad(blkh);
end
bd.bdroot = bdroot(blkh);  % cached for efficiency, initial value
set_param(blkh, 'UserData',bd);

% Setup sfcn data
%
% Data includes:
%    - block handle of parent masked system
sfcn = [getfullname(blkh) '/S-Function'];
set_param(sfcn, 'UserData',blkh);

% Note: block handle recorded in scope figure window, if present,
% does not need updating if block is moved.  The handle remains
% constant even when block path string changes.


% ------------------------------------------------------------
function bd = init_block_data(blkh)
%INIT_BLOCK_DATA
%
% Here we set up all the "common" fields of the block data record,
% frequently called "bd" or "block_data" throughout this code.
% This data lives with the parent masked block, and not the underlying
% M-file S-function block.
%
% Note that we will also leave a small amount of block data with the
% underlying S-Function block that tells us the handle of the parent
% masked subsystem, purely for run-time efficiency.

% xxx Debug:
bd = get_param(blkh,'UserData');
if ~isempty(bd),
    return;% for command line sim
    %error('Attempt to re-initialize block data.');
end

% Marking hfig empty tells the system that the scope
% has not yet been created/is not open:
%
% Note that scope could be up already, so we
% don't want to overwrite field if it exists:
%
bd = [];
bd.hfig       = [];
bd.haxis      = [];
bd.hsurf      = [];
bd.hdiscontig = [];
bd.params = getWorkspaceVarsAsStruct(blkh);   % initial parameter values
bd.bdroot = [];  % block handles are cached later

% Function handles are filled with "bogus" values
% just to validate whether they've been initialized
% correctly later on:
bd.BufferFullFcn          = []; % setup in setup_history_service
bd.LoadPhase              = 0;  % 0=PreLoad, 1=Loading, 2=PostLoad
bd.HistoryLengthActual    = []; % will be set up in setup_history_service
bd.HistoryID              = [];
bd.HistoryRecFcn          = [];
bd.HistoryRecFcn_suspend  = [];
bd.indims                 = [];  % last known xformed dimensions
bd.InputPortDims          = [];  % last known input port dims
bd.Snapshot_engaged       = 0;  % 0=disengaged, 1=engaged
bd.TriggerFcn             = [];
bd.TriggerData            = []; % used to store all trigger-related data
bd.UpdateFcn              = [];
bd.XformFcn               = []; % user-defined data transformation function
bd.complexHandler         = []; % complex-data handler
bd.Ts                     = -Inf;
bd.LastTimeStamp          = -Inf;
bd.LastDiscontigSet       = 0;
bd.DiscontigColors        = {[.8 .8 .8], [.6 .6 .6 ]};
bd.UpdateIntervalCounter  = 0;  % Reset display-update interval counter
bd.SelectedTrace          = -1;  % no trace selected
bd.ScopeToolbarVis        = 'on';  % defaults to 'on'
bd.isSpecialSnapshot      = 0;  % snapshot on, in history extend/suspend mode

% Setup fields for parameter dialog:
bd.param_dlg.hfig   = [];
bd.param_dlg.pos    = [];
bd.param_dlg.tabNum = -1;  % last open tab number, preset to unknown

% Record block data in the masked subsystem:
set_param(blkh, 'UserData', bd);

bd = update_block_handles(blkh);


% ------------------------------------------------------------
function sys = mdlUpdate(t,u)
% Main update loop for scope
% Goal: keep this FAST!
%
% gcbh: returns handle to sfcn block
%       we want handle to parent masked-subsystem block
%  blkh = get_param(gcbh,'ParentHandle');               % not implemented
%  blkh = get_param(get_param(gcbh,'Parent'),'handle'); % too slow
sys  = [];   % Return empty state vector
blkh = get_param(gcbh,'UserData');  % handle to parent cached in S-Fcn block
bd   = get_param(blkh,'UserData');  % block data

% bd = feval(bd.CheckInputDimsFcn, u);  % input-check service

% If input is a scalar, we skip out altogether
% Problem:
%    .IsScalarInput is only set during first_history_rec,
%    so once it's set, it doesn't get un-set, and transforms
%    could change on the fly.
%if bd.IsScalarInput, return; end

u = feval(bd.complexHandler,blkh,u);
u = feval(bd.XformFcn, u);  % data transformation service
if ~isreal(u),
    msg = 'Data cannot be complex-valued after transformation has been applied.';
    errordlg(msg,'Waterfall Transform Error','modal');
    set_param(bd.bdroot,'SimulationCommand','pause');
end
u=u(:);  % at this point, map all vectors to column vectors
feval(bd.TriggerFcn, blkh, t, u);  % triggering service
bd = get_param(blkh,'UserData');  % things may have changed
[rec, buffer_full] = feval(bd.HistoryRecFcn, blkh, t, u);  % history service
feval(bd.UpdateFcn, blkh, rec);  % no need to re-get block data just for .UpdateFcn
if buffer_full,
    feval(bd.BufferFullFcn, blkh);  % history-full service
end

% no need to call "drawnow"; it wastes time when no graphics
% updates are required.  Plus, the pipe flushes itself.

% ---------------------------------------------------------------
function sys = mdlTerminate(blkh)
% TERMINATE Clean up any remaining items

sys = [];  % No states to return
if nargin<1,
    % No block handle passed in
    % gcbh points to the s-fcn, get the parent masked subsystem handle
    
    % I would like to just do this:
    %   blkh = get_param(gcbh,'Parent');
    % but it returns a string path, not a block handle.
    %
    % Instead we must do this:
    %   blkh = get_param(get_param(gcbh,'parent'),'handle');
    %
    % Or cache parent handle in sfcn user data:
    blkh = get_param(gcbh,'UserData');  % handle to parent
end

% Update text readout, if scope open:
bd = get_param(blkh,'UserData');
if ~isempty(bd.hfig),
    fig_data = get(bd.hfig,'UserData');
    discontig_update_hilite(fig_data);
end

% send terminate to all interface controls,
% in case some need to disable, etc:
stopping_controls(blkh);

% Always turn off snapshot and suspend when sim terminates
set_param(blkh, ...
    'Snapshot','off', ...
    'Suspend','off');

SnapshotSvc('terminate', blkh);  % terminate suspend/snapshot svc

% Automatic export to workspace option:
if bd.params.AutoExport,
    UpdateStatusText(bd.hfig,'Exporting...');
    WorkspaceExport([],[], blkh);
end

% Finished terminating, indicate status:
UpdateStatusText(bd.hfig,'Stopped');


% ---------------------------------------------------------------
function y = mdlError(blkh, msgId)
%sdspwfall_err SDSPWFALL Error Handler
%
% Prevents block from opening underlying subsystem
%
% Allows us to prune the error message, removing
% traceback information, etc, that looks 'sloppy'.

% Get error message structure:
s = sllasterror;
txt = s(1).Message;
% Break into CR-delimited substrings, one per cell:
txt = strread(txt,'%s','delimiter','\n','whitespace','');
% Find all lines that begin with "Error"
iError = strmatch('Error', txt);
% remove them from the text stream:
txt(iError)=[];
% Format message with some linefeeds:
CR = sprintf('\n');
y = [CR CR txt{:} '. '];


% =========================================================================
% DISPLAY UPDATE FUNCTIONS
% =========================================================================

% -------------------------------------------------------------------------
function bd = DisplayDisable(blk, bd)
% Disable display updates, if scope is open:

bd.UpdateFcn = @no_display_updates;
set_param(blk,'UserData',bd);

% -------------------------------------------------------------------------
function bd = DisplayEnable(blk, bd)
% Enable display updates
% We need to recompute the display update fcn each time, because
% it varies based on dialog params.

if isempty(bd.hfig) ...
   || strcmp(bd.params.Snapshot,'on') ...
   || strcmp(bd.params.Suspend,'on')
    bd.UpdateFcn = @no_display_updates;
elseif bd.params.UpdateInterval > 1,
    bd.UpdateFcn = @update_wfall_interval;
else
    bd.UpdateFcn = @update_wfall;
end
set_param(blk,'UserData',bd);

% --------------------------------------------------------------------
function no_display_updates(blk, rec)
% Do not display data - nop

% --------------------------------------------------------------------
function update_wfall_interval(blk, rec)
% Used when update interval > 1
% Otherwise, call update_wfall directly.

bd = get_param(blk,'UserData');
cnt = bd.UpdateIntervalCounter + 1;
if cnt >= bd.params.UpdateInterval, % should only ever be < or ==, >= is for safety
    rec = getProcessedHistoryRecs(blk, bd, 0:cnt-1 );
    cnt = 0;
    % Call to update_wfall does NOT modify bd
    % If it does, we will likely fail, since we're going to
    % write bd back into the block after this, and it will
    % have "stale" information in it
    update_wfall(blk, rec);
end
bd.UpdateIntervalCounter = cnt;
set_param(blk,'UserData',bd);


% --------------------------------------------------------------------
function update_wfall(blk, rec)
% 3-D waterfall for multichannel (matrix) input with numCols
%   channels of data
%
% Does NOT modify block_data
%
% Scroll the display by NumCols new vectors
% and introduce NumCols new vectors

% rec is a vector cell array containing structures
%   rec.Values
%   rec.Time
%   rec.Discontig (index 1 or 2)

bd = get_param(blk,'UserData');

% Update waterfall:
M = bd.params.NumTraces;
xlim_min = bd.params.YMin;

% get xdata (patch trace) and userdata (timing info) from all traces
% this is a "get" on a vector of handles, several properties
% returns a cell-array in the shape of a matrix,
%   - each row corresponds to another patch handle
%   - each column corresponds to another property
x = get(bd.hsurf, {'XData','UserData'});

% rec structure could have fewer than, equal to, or greater
%   than NumTraces number of input vectors (columns)
%   xxx Not sure that "greater than" is working (which cols to display?)
dispEntries = min(length(rec), M);
if dispEntries < M,
    % move trace data back by one matrix, only if at
    % least some of the old display will remain visibile
    x(dispEntries+1:M,:) = x(1:M-dispEntries,:);
end
for i=1:dispEntries,
    % xxx is rec a cell of structs or an array of structs???
    % It is BETTER to be an ARRAY of structs vs. a CELL of structs
    %   in terms of access speed.
    x{i,1} = [xlim_min; rec{i}.Values; xlim_min];  % add endpoints
    x{i,2} = rec{i}.Time;
end
set(bd.hsurf, {'XData','UserData'}, x);
drawnow;% we do not need that when play button is hit 
        % but we need it for command-line sim to update the plot for each new frame: see sdspfscope2 line 285
try
    % Update discontig markers
    clr = get(bd.hdiscontig,'FaceColor');
    if dispEntries < M,
        clr(dispEntries+1:M) = clr(1:M-dispEntries);
    end
    % Create discontig vector
    for i=1:dispEntries,
        clr(i) = bd.DiscontigColors(rec{i}.Discontig);
    end
    set(bd.hdiscontig,{'FaceColor'},clr);
catch % need it when sim('dsplpc') is executed and scope is closed in the middle of simulation
    return;
end    


% ---------------------------------------------------------------
function first_display_update(blk, rec)
% Check data, update dimensions, open scope, then update display
%
% Note that history service has been updated prior to calling
% this fcn, so all we need to do is render the current history
% buffer and the most recent input will have been displayed.
% It turns out the call to primary_open does this for us.
% Therefore, do NOT make an explicit call to UpdateFcn at the
% end of this fcn - or a double-update (duplicate displayed data)
% will result.
%
% Since first_history_rec runs immediately prior to this,
% we skip checks on input port attribs as they are now redundant.

% Note: changes block data
bd = get_param(blk,'UserData');
bd = DisplayEnable(blk, bd);    % Setup runtime update function
bd = primary_open(blk);         % Open/update display configuration
UpdateInportDimsHint(blk, bd, rec);  % do data dimensions match last hint?


% -------------------------------------------------------------------------
function complexHandler_install(blkh)

bd = get_param(blkh,'UserData');
bd.complexHandler = @complexHandler_init;
set_param(blkh,'UserData', bd);

% -------------------------------------------------------------------------
function u = complexHandler_init(blkh, u)
% Get around M-file S-function limitation
% Data comes in in two contiguous sections,  [real imag]
% Real data has imag set to all-zeros

complexCheck_blkh = [getfullname(blkh) '/ComplexCheck'];
portComplexity = get_param(complexCheck_blkh,'CompiledPortComplexSignals');
sz=size(u);  % either 2Nx1 or 2xN
if portComplexity.Inport,
    if sz(2)==1, % 2 columns, vert concat
        fcn = @complexHandler_cplx_cols;
    else         % 2 rows, vert concat
        fcn = @complexHandler_cplx_rows;
    end
else
    if sz(2)==1,
        fcn = @complexHandler_real_cols;
    else
        fcn = @complexHandler_real_rows;
    end
end

bd = get_param(blkh,'UserData');
bd.complexHandler = fcn;
set_param(blkh,'UserData', bd);

u = feval(fcn,blkh,u);

% -------------------------------------------------------------------------
function u = complexHandler_cplx_cols(blkh,u)
N=size(u,1)/2;
u = complex(u(1:N,1), u(N+1:end,1));

function u = complexHandler_cplx_rows(blkh,u)
u = complex(u(1,:), u(2,:));

function u = complexHandler_real_cols(blkh,u)
N = size(u,1)/2;
u = u(1:N,1);  % remove all-zero imag part

function u = complexHandler_real_rows(blkh,u)
u = u(1,:);


% =========================================================================
% OPEN DISPLAY FUNCTIONS
% =========================================================================

% ---------------------------------------------------------------
function bd = primary_open(blkh)
% primary_open Called the first time the update function is executed
%   in a simulation run.  Creates a new scope GUI if it does not exist,
%   or restarts an existing scope GUI.
%
%   Calls starting_controls, which resets the history scroll, and ultimately
%   renders one screenful of data from the data history.

bd = get_param(blkh,'UserData');

% Construct new scope figure window, or bring up old one:
hfig = bd.hfig; % scope already exists

% Establish a valid scope GUI:
if ~isempty(hfig),
   % Found existing scope figure window
   % Prepare to re-start with existing scope window
   [bd, fig_data] = verify_scope_figure(blkh);
   
   % If things did not go well during restart, say the axis
   % was somehow deleted from the existing scope figure, etc.,
   % then hfig is left empty, and a new scope must be created.
   % Get hfig, then check if it is empty later:
   hfig = fig_data.hfig;
end
if isempty(hfig),
   % Initialize new figure window:
   % Create the scope GUI
   fig_data = create_scope(blkh, bd.params);
   bd.hsurf      = [];
   bd.hdiscontig = [];
end
bd.hfig   = fig_data.hfig;
bd.haxis  = fig_data.main.haxis;

set_param(blkh, 'UserData', bd);  % Update block_data

setup_history_service(blkh, 0);  % affects block_data, don't flush history
setup_axes(blkh);         % affects block_data
SetMenuChecks(blkh);      % Set menu checks according to block_data, changes bd
starting_controls(blkh);  % refresh display from latest history
update_history_controls(blkh);


% ---------------------------------------------------------------
function openScopeWhileStopped(blkh)
% Opens scope while simulation is stopped
%
% Note: primary_open updates the most recent screen-full of
% data from history service (via starting_controls), so no
% need to do that explicitly here.

openScopeWhileRunning(blkh);
stopping_controls(blkh);

% ---------------------------------------------------------------
function openScopeWhileRunning(blkh)
% We must open GUI; thus, we ignore any other settings
% and pass flag=1 to force GUI to open
% nothing else to do - scope will re-open at next time step

resetToFirstCall(blkh,1,0);  % 1=must open, 0=don't flush history
primary_open(blkh);

% ---------------------------------------------------------------
function isRunning = simIsRunning(bd_root)
status = get_param(bd_root,'SimulationStatus');
isRunning = strcmp(status,'running') ...
    || strcmp(status,'paused') ...
    || strcmp(status,'initializing') ...
    || strcmp(status,'updating');


% ---------------------------------------------------------------
function OpenScope(blkh)
% Open the scope in response to:
%   - open at start of simulation
%   - double-click on block

if nargin<1, blkh=gcbh; end
bd = get_param(blkh,'UserData');


isLibrary = strcmp(get_param(bdroot(blkh),'blockdiagramtype'),'library');
% isLocked = strcmp(get_param(bdroot(blkh),'lock'),'on');
if isLibrary,
   errordlg('The Waterfall Scope is in a library.  You must place it in a model in order to operate it.', ...
       'Error','modal');
   return
end

% Note: bd could be empty here - ex: copy new block into
%   model from library, then double-click block.
if isempty(bd),
    bd = BlockLoad(blkh);
end

if ~isempty(bd.hfig),
    figure(bd.hfig);  % Scope exists - bring it forward
else
    % Need to open/re-open scope:
    if simIsRunning(bd.bdroot),
        openScopeWhileRunning(blkh);
    else
        openScopeWhileStopped(blkh);
    end
end

% Update the block state so that it will open the next time:
if ~bd.params.OpenScopeAtSimStart,
    dirty = get_param(bd.bdroot,'dirty');
    set_param(blkh,'OpenScopeAtSimStart','on');
    set_param(bd.bdroot,'dirty',dirty);
end


% =========================================================================
% MISCELLANEOUS
% =========================================================================

% ---------------------------------------------------------------
function resetToFirstCall(blkh, mustOpen, flush)
% Resets UpdateFcn and HistoryRecFcn to their respective "first"
% call fcns.  However, the UpdateFcn might be set to "no updates."
%
% If mustOpen is passed in, the decision to open a GUI
% will come from mustOpen instead of the dialog param.

% No need to reset block in a library
% (keeps UserData empty so DialogApply won't run)
if syslocked(blkh), return; end

% If flush flag not passed in, assume we must flush
% the history buffer when called --- that's the default.
% If it's passed in, just do what it says:
if nargin<3, flush=1; end

bd = get_param(blkh,'UserData');

% Determine if scope should open at next time step:
if nargin>1,
    willopen = mustOpen;
else
    willopen = bd.params.OpenScopeAtSimStart;
end

% Cache the appropriate update function:
if willopen || ~isempty(bd.hfig),
    bd.UpdateFcn = @first_display_update;
else
    % We get here on a restart when we're not opening
    % the scope at sim start:
    bd.UpdateFcn = @no_display_updates;
end

if flush,
    % Force restart to clear buffer when in 'extend' mode
    bd.HistoryLengthActual = [];
    bd.HistoryRecFcn = @first_history_rec;  % flushes history buffer
else
    % If Suspend is ON, we should leave the history rec fcn
    % as "history_rec_skip" ... this supports CLOSING a scope
    % set in suspend mode, and keeping history rec suspended.
    if strcmp(get_param(blkh,'Suspend'),'off'),
        bd.HistoryRecFcn = @history_rec;
    end
end

set_param(blkh, 'UserData', bd);


% ---------------------------------------------------------------
function bd = SetMenuChecks(blk)
% Called from first_update and DialogApply to preset menu checks
% Changes block data
% blk: masked subsystem block

bd = get_param(blk,'UserData');
fig_data = get(bd.hfig,'UserData');

% Update suspend buttons:
%
optSuspend = get_param(blk,'Suspend');
if strcmp(optSuspend,'off'),
    tip = 'Suspend data capture (Ctrl+D)';
    icon = fig_data.menu.icons.run_rec;
    % icon = fig_data.menu.icons.recording_on;
else
    tip = 'Resume data capture (Ctrl+D)';
    icon = fig_data.menu.icons.pause_rec;
    % icon = fig_data.menu.icons.recording_off;
end
% if strcmp(get_param(blk,'SyncSnapshots'),'on'),
%     % If SyncSnapshot turned on (Linked), indicate this:
%     tip=[tip sprintf('\n') 'Linked'];
% end
% - window menu and context menu
set(fig_data.menu.suspend, 'Checked',optSuspend);
set(fig_data.menu.buttons.Suspend, ...
    'cdata', icon, ...
    'Tooltip',tip, ...
    'State', optSuspend);

% Update snapshot buttons:
%
optSnap = get_param(blk,'Snapshot');
if strcmp(optSnap,'off'),
    tip = 'Snapshot display (Ctrl+S)';
else
    tip = 'Resume display (Ctrl+S)';
end
% if strcmp(get_param(blk,'SyncSnapshots'),'on'),
%     % If SyncSnapshot turned on, indicate this:
%     tip=[tip sprintf('\n') '(Linked)'];
% end
% - window menu and context menu
set(fig_data.menu.snapshot, 'Checked',optSnap);
set(fig_data.menu.buttons.Snapshot, 'State', optSnap, 'Tooltip',tip);

UpdateStandardStatusText(bd.hfig);

% Update for first opening:
HistoryControlsSetLimits(blk);

% Update synchronization toggle:
%
opt = get_param(blk,'SyncSnapshots');
if strcmp(opt,'off'),
    tip = 'Link scopes';  % nexst mode if clicked again
    icon = fig_data.menu.icons.unlinked;  % current mode
else
    tip = 'Unlink scopes'; % next mode if clicked again
    icon = fig_data.menu.icons.linked;  % current mode
end
% - toolbar
set(fig_data.menu.buttons.LinkScopes, ...
    'State', opt', ...
    'Tooltip',tip, ...
    'CData', icon);

% Update AxisGrid menu check:
%
opt = get_param(blk,'AxisGrid');
if strcmp(opt,'off'),
    tip = 'Show grid (Ctrl+G)';
else
    tip = 'Hide grid (Ctrl+G)';
end
% - window menu and context menu
set(fig_data.menu.axisgrid, 'Checked',opt);
% - toolbar
set(fig_data.menu.buttons.AxisGrid, 'State', opt, 'Tooltip',tip);

UpdateDataSizesReadout(blk);
UpdateXformModeReadout(blk);

% Update Scope Toolbar uimenu check:
% changes block data
bd = ScopeToolbarVis(bd.hfig, bd.ScopeToolbarVis);


% ---------------------------------------------------------------
function starting_controls(blkh)
% Update controls when simulation begins to run
% Sim may not be running, this is called from primary_open
%
% NOTE: This *updates the display* to the most recent set of
%       history data, via call to HistoryControlsSetToNewest.

bd = get_param(blkh,'UserData');
hfig = bd.hfig;
SnapshotSuspendControlsEnable(hfig, 1);  % Enable
HistoryControlsEnable(hfig, 0);   % Disable
HistoryControlsSetToNewest(hfig); % Updates the display

% ---------------------------------------------------------------
function stopping_controls(blkh)
% Update controls when simulation stops running

bd = get_param(blkh,'UserData');
hfig = bd.hfig;
% If block is closed, skip this:
if ~isempty(hfig),
    % Turn off individual controls in case they were on
    % Make these calls BEFORE the general disable call
    % to snapshot/suspend later, since these calls each
    % enable the other control visibility ... ultimately,
    % both snapshot and suspend are visible when we do this.
    SnapshotDisplay([],[],hfig,'off');
    SuspendDataCapture( [],[],hfig,'off');

    % Shut down snapshot and suspend visibilities:
    SnapshotSuspendControlsEnable(hfig,0); % Disable
    HistoryControlsEnable(hfig,1);  % Enable
end


% =========================================================================
% MASK DIALOG INTERFACE AND CHECKS
% =========================================================================

% ---------------------------------------------------------------
function y = getMaskEvaluateMode(blk)
% Return vector of booleans, true wherever a mask parameter is set to
% "Evaluate mode"
%
% Note that we can't get this information directly
% We must parse the MaskVariables string
% Example:
%   MaskVariables = 'var1=&1;var2=@2;var3=@3;'
%     where   & means literal
%       and   @ means evaluate

% xxx COMMON

mask_Vars = get_param(blk,'MaskVariables');
iEq = find(mask_Vars == '=');  
iMode = mask_Vars(iEq+1);  % Get @ or & character corresponding to each variable
y = (iMode=='@')';  % make it a column


% % ---------------------------------------------------------------
% function y = MaskEvalModeEditDlgs(blk)
% % Return list of mask variables that are Evaluate-mode Edit boxes
% % We determine this on-the-fly so we don't need to prestore the list
% 
% % xxx COMMON
% 
% mask_Names = get_param(blk,'MaskNames');
% mask_Styles = get_param(blk,'MaskStyles');
% isEdit = strcmp(mask_Styles,'edit');
% isEval = getMaskEvaluateMode(blk);
% idx = find(isEdit & isEval);
% y = mask_Names(idx);

% ---------------------------------------------------------------
function y = MaskEditDlgs(blk)
% Return list of mask variables that are Edit boxes,
% both literal and evaluate mode

% xxx COMMON

mask_Names = get_param(blk,'MaskNames');
mask_Styles = get_param(blk,'MaskStyles');
isEdit = strcmp(mask_Styles,'edit');
idx = find(isEdit);
y = mask_Names(idx);

% ---------------------------------------------------------------
function RevertDialogParams(blk)
% Reset current parameters in block dialog in response
%  to an invalid input

% Only needs to revert evaluation-mode edit boxes
%
% Well, now we need to revert literal-mode edit boxes too,
% since data transformations have literal strings and they
% could fail on test-evaluation.

% xxx COMMON

block_data = get_param(blk, 'UserData');
params = block_data.params;

% Synthesize list of tunable edit-boxes in dialog
%dlgVar = MaskEvalModeEditDlgs(blk);
dlgVar = MaskEditDlgs(blk);

% Get last valid param value, and change from eval'd to string form
pv={};
for i=1:length(dlgVar),
    p = dlgVar{i};
    mat = subsref(params, substruct('.',p));
    v = mat2str(mat);
    pv = [pv {p,v}];
end
set_param(blk,pv{:});

% At this point, we should be able to simply update the
% param dialog and be done.  However, Simulink does not
% update the mask workspace, which still has the incorrect values,
% and the reverted changes do not get seen.
%
% Update parameter dialog, if open:
% Use the params cache from the block userdata
sdspwfall_params('refresh_dialog_from_blk', blk, params);


% ---------------------------------------------------------------
function [msg,silent] = CheckParams(blk, params)

msg = '';
silent = 0;

% Check NumTraces:
% ----------------
x = params.NumTraces;
Nx = numel(x);
if ~isa(x,'double') || issparse(x) || ~isreal(x) || ...
      (Nx ~= 1) || (x~=floor(x)),
   msg = 'NumTraces must be an integer-valued scalar.';
   return
end
if ~isempty(x) && (x <= 1),
   msg = 'NumTraces must be > 1.';
   return
end

% Check transparency, newest and oldest:
% --------------------------------------
x = params.TNewest;
Nx = numel(x);
if (Nx~=1) || ~isa(x,'double') || issparse(x) || ~isreal(x),
    msg = 'Newest transparency value must be a real-valued scalar.';
    return
end
if (x<0) || (x>1),
    msg = 'Newest transparency value must be in the range [0,1].';
    return
end
x = params.TOldest;
Nx = numel(x);
if (Nx~=1) || ~isa(x,'double') || issparse(x) || ~isreal(x),
    msg = 'Oldest transparency value must be a real-valued scalar.';
    return
end
if (x<0) || (x>1),
    msg = 'Oldest transparency value must be in the range [0,1].';
    return
end

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

% Check YMin:
% -----------
x = params.YMin;
Nx = numel(x);
if (Nx~=1) || ~isa(x,'double') || issparse(x) || ~isreal(x),
   msg = 'Y-minimum must be a real-valued scalar.';
   return
end
ymin = x;

% Check YMax:
% -----------
x = params.YMax;
Nx = numel(x);
if (Nx~=1) || ~isa(x,'double') || issparse(x) || ~isreal(x),
   msg = 'Y-maximum must be a real-valued scalar.';
   return
end
if (x <= ymin),
   msg = 'Maximum Y-axis limit must be greater than Minimum Y-axis limit.';
   return
end

% Check FigPos:
% -------------
x = params.FigPos;
if ~isa(x,'double') || issparse(x) || ~isreal(x) || ...
      (size(x,1)~= 1) || (size(x,2)~=4),
   msg = 'Figure position must be a real-valued 1x4 vector.';
   return
end

% Check CMapStr:
% --------------
x = feval(params.CMapStr, params.NumTraces);
if ~isa(x,'double') || (ndims(x)~=2) || (size(x,2)~=3),
   msg = 'Colormap must return an Nx3 matrix.';
   return
end

% Check CameraView:
% -----------------
if 0,
x = params.CameraView;
if ~isa(x,'double') || issparse(x) || ~isreal(x) || ...
     (size(x,1)~= 3) || (size(x,2)~=3),
  msg = 'Camera View must be a real-valued 3x3 matrix.';
  return
end
end

% History length:
% ---------------
x = params.HistoryLength;
Nx = numel(x);
if ~isa(x,'double') || issparse(x) || ~isreal(x) || ...
      (Nx ~= 1) || (x~=floor(x)),
   msg = 'History Length must be an integer-valued scalar.';
   return
end
if ~isempty(x) && (x < 0),
   msg = 'History Length must be >= 0.';
   return
end
if isinf(x) || (x > 1e5),
    msg = 'Initial History length too large - consider using "Extend" mode when buffer is full.';
    return
end

% Update Interval:
% ----------------
x = params.UpdateInterval;
Nx = numel(x);
if ~isa(x,'double') || issparse(x) || ~isreal(x) || ...
      (Nx ~= 1) || (x~=floor(x)),
   msg = 'Display Update Interval must be an integer-valued scalar.';
   return
end
if ~isempty(x) && (x < 1),
   msg = 'Display Update Interval must be > 0.';
   return
end

% AxisColor
% ---------
% Use an invisible text control, and try to set color into it
% 
% First, try to evaluate string-literal:
bd = get_param(blk,'UserData');
fig_data = get(bd.hfig,'UserData');
if ~isempty(fig_data),         % can't test colorspec if GUI not up because
    htxt = fig_data.testtext;  % we need the text control to check it
    try,
        % '[1 1 0]' or 'w'
        clr = eval(params.AxisColor);
        set(htxt,'foregr', clr);
    catch
        msg = 'Invalid color specification.';
        return;
    end
end

% Triggering options
% ------------------
%
switch params.TrigStartMode
    case 'Immediately',
        % no params to check
    case 'After T seconds',
        msg = checkTriggerTime(params.TrigStartT);
    case 'After N inputs',
        msg = checkTriggerCount(params.TrigStartN);
    case 'User-defined',
        msg = checkTriggerFcn(params.TrigStartFcn);
    otherwise, 
        msg = 'Unrecognized TrigStartMode.';
end
if ~isempty(msg), return; end

switch params.TrigStopMode
    case 'Never',
        % no params to check
    case 'After T seconds',
        msg = checkTriggerTime(params.TrigStopT, 1);
    case 'After N inputs',
        msg = checkTriggerCount(params.TrigStopN, 1);
    case 'User-defined',
        msg = checkTriggerFcn(params.TrigStopFcn);
    otherwise, 
        msg = 'Unrecognized TrigStopMode.';
end
if ~isempty(msg), return; end

switch params.TrigRearmMode
    case 'Never',
        % no params to check
    case 'After T seconds',
        msg = checkTriggerTime(params.TrigRearmT);
    case 'After N inputs',
        msg = checkTriggerCount(params.TrigRearmN);
    case 'User-defined',
        msg = checkTriggerFcn(params.TrigRearmFcn);
    otherwise, 
        msg = 'Unrecognized TrigRearmMode.';
end
if ~isempty(msg), return; end

% Check transforms
% ----------------
%
switch params.XformMode
    case 'User-defined expr'
        msg = checkXformExpr(params.XformExpr, bd);
    case 'User-defined fcn'
        msg = checkXformFcn(params.XformFcn, bd);
end
if ~isempty(msg), 
    silent=1;  % transformation-mode checks already issued a dialog
    return
end


% ---------------------------------------------------------------
function msg = checkXformFcn(x, bd);
% Check the transformation FUNCTION
%
msg = '';
s=size(x);
if ~isa(x,'char') || s(1)~=1 || (ndims(x)>2),
    msg = 'Transform function must be a string.';
    return
end
switch which(x)
    case {'','variable'},
        valid=0;
    otherwise,
        valid=1;
end
if ~valid,
    % Invalid expression, use default nop fcn
    msg = sprintf('Could not find transformation function "%s"', x);
    return
end
try
    valid = 1;
    if simIsRunning(bd.bdroot),
        % Only do a function-invocation test if we're running
        y=feval(x,zeros(bd.InputPortDims));
    end
catch
    valid=0;
end
if ~valid,
    % Invalid expression, use default nop fcn
    override = XformOverride(x, 'Function');
    if ~override,
        msg = 'Invalid transformation function.';
        return
    end
end


% ---------------------------------------------------------------
function msg = checkXformExpr(x, bd)
% Check the transformation EXPRESSION
%
msg = '';
s=size(x);
if ~isa(x,'char') || s(1)~=1 || (ndims(x)>2),
    msg = 'Transform expression must be a string.';
    return
end
try,
    valid=1;
    % Try our best to test the expression
    % Can't do a "function exist" check, so we'd like to do
    % a bit more here if we can
    %
    % Whether sim is running or not, try last cached input dims
    % size
    %
    evalObj = evalExpr(x);
    if ~isempty(bd.InputPortDims),
        % Shut off warnings, in case manufactured data is not the best
        % data to input to the function
        s=warning;
        warning off;
        u = 0.99*ones(bd.InputPortDims);  % dummy data
        y = feval(evalObj,u(:));  % test with manufactured data
        warning(s);
    end
catch
    valid=0;
end
if ~valid,
    % Potentially invalid expression - but we just don't know
    % It could be that bd.indims is no longer valid, etc
    % So, we ask user what to do:
    override = XformOverride(x,'Expression');
    if ~override,
        msg = 'Invalid transformation expression.';
        return
    end
end


% -------------------------------------------------------------------------
function override = XformOverride(x,fcnExpr)
% Ask user if they wish to override the possible error in expression

Question = {[fcnExpr ' does not successfully execute on test data']; ...
            'created from previously seen input data dimensions.'; ...
            'This may indicate a problem with the expression, or'; ...
            'the previous data dimensions could simply be inappropriate.'; ...
            ''; ...
            'By default, this expression will be considered invalid'; ...
            'and the previous expression will be retained.'; ...
            ''; ...            
            'You can choose to override this decision, but if the'; ...
            'expression is not valid, the simulation will STOP.'; ...
            ''; ...
            ['Accept ' lower(fcnExpr) ' as valid?']};
Title = ['Invalid transformation ' lower(fcnExpr)];
Btn1='No';
Btn2='Yes';
DEFAULT='No';
ButtonName = questdlg(Question,Title,Btn1,Btn2,DEFAULT);
override = strcmp(ButtonName,'Yes');


% ---------------------------------------------------------------
function msg = checkTriggerFcn(x)
msg = '';
s=size(x);
if ~isa(x,'char') || s(1)~=1 || (ndims(x)>2),
    msg = 'Trigger function must be a string name.';
    return
end
try
    if ~exist(x),
        %msg = 'Function does not exist on MATLAB path.';
        %return
    end
    
    blk=''; t=0; u=0;
    % y=feval(x,blk,t,u); % xxx must check trigger fcn
catch
    msg = ['Failed when attempting to call trigger function "' x '".'];
    return
end

% ---------------------------------------------------------------
function msg = checkTriggerCount(x,disallowZero)
msg = '';

% Allow zero count unless otherwise specified:
if nargin<2, disallowZero = 0; end

Nx = numel(x);
if ~isa(x,'double') || issparse(x) || ~isreal(x) ...
    || (Nx ~= 1) || (x ~= floor(x)) || isempty(x),
    msg = 'Trigger count must be an integer-valued scalar.';
    return
end
if disallowZero,
    if x<=0,
        msg = 'Trigger count must be > 0.';
    end
else
    if x<0,
        msg = 'Trigger count must be >= 0.';
    end
end
if ~isempty(msg), return; end

% ---------------------------------------------------------------
function msg = checkTriggerTime(x, disallowZero)
msg = '';

% Allow zero time unless otherwise specified:
if nargin<2, disallowZero = 0; end

Nx = numel(x);
if ~isa(x,'double') || issparse(x) || ~isreal(x) || (Nx ~= 1) || isempty(x),
    msg = 'Trigger time must be a real-valued scalar.';
    return
end
if disallowZero,
    if x<=0,
        msg = 'Trigger time must be > 0.';
    end
else
    if x<0,
        msg = 'Trigger time must be >= 0.';
    end
end
if ~isempty(msg), return; end

% ---------------------------------------------------------------
function y = relevant_params_changed(params1, params2)

% Remove the "dialog tab" fields, eg, fields that can change
% without affecting any user options:
%
fields={'TraceProperties','DisplayProperties','AxisProperties','TriggerProperties'};
% Method 1 - remove the structure fields
% params1 = rmfield(params1,fields);
% params2 = rmfield(params2,fields);
%
% Method 2 - set fields of 2nd structure to the
% values found in the 1st structure - faster?
% s.subs = '';
s.type = '.';
for i=1:length(fields),
    s.subs=fields{i};
    subsasgn(params1,s,subsref(params2,s));
end

y = ~isequal(params1,params2);


% ---------------------------------------------------------------
function bd = reset_UpdateIntervalCounter(blk, bd)
% We must reset the interval counter if a change to the update interval
% occurs.  If we don't, we might have counted *beyond* the new update
% interval, and due to the way in which we test the count, we would
% keep counting to infinity!  So, we reset the counter every time the
% interval is changed:

bd = get_param(blk,'UserData');
bd = DisplayEnable(blk, bd);  % in case update function has now changed
bd.UpdateIntervalCounter = 0;
set_param(blk,'UserData',bd);


% ---------------------------------------------------------------
function DialogApply(blk)
% Block mask updated/loaded
% Updates param dialog GUI, if open
%
% Called from MaskInitialization command via:
%   sdspwfall([],[],[],'DialogApply');
%
% Updates block_data

if nargin<1, blk = gcbh; end
bd = get_param(blk, 'UserData');

% If system has not run yet, skip out:
if isempty(bd), return; end

% If pre-load, skip out
% 0=PreLoad, 1=Loading, 2=PostLoad
% We have an invalid block handle
if bd.LoadPhase < 2, return; end

% Get params directly from block
params = getWorkspaceVarsAsStruct(blk);

% Check dialog parameters:
% ------------------------
[msg,silent] = CheckParams(blk, params);
if ~isempty(msg),
   % Invalid parameters
   RevertDialogParams(blk);
   if ~silent,
       errordlg(msg,'Waterfall Dialog Error','modal');
   end
   return
end

% Check for a run-time parameter change:
if ~relevant_params_changed(params, bd.params),
    return;
end

if isempty(bd.hfig),
    % GUI is not open
    %
    % we need to perform the update_suspend_state here
    % to allow synchronized suspends even when scopes are "closed"
    %   
    % Need those bd.params updated first:
    bd.params = params;
    set_param(blk, 'UserData', bd);
    
    bd = update_suspend_state(blk, bd);
    return;   % Nothing more to do
end


% Dialog params changed

% GUI is open and a change has been made


isRunning = simIsRunning(bd.bdroot);


% Handle figure position changes here:
% Only update if the current block dialog FigPos differs from
% the cached block_data FigPos.  In other words, ignore the
% actual figure window position itself, and only examine the
% stored position in the block dialog and the cached position
% in the block data.
%
% The figure itself might be at
% a different position, which we should not change UNLESS the
% user actually made an explicit change in the mask (or, hit
% the RecordFigPos menu item, which simply changes the mask).
if ~isequal(bd.params.FigPos, params.FigPos),
    set(bd.hfig,'Position', params.FigPos);
end
% Same goes for camera view
if ~isequal(bd.params.CameraView, params.CameraView),
    update_cam_view(bd.hfig, params);
end
% Same goes for mouse mode
%  (arrow, camera view)
if ~isequal(bd.params.MouseMode, params.MouseMode),
    % Update MouseMode toolbar button and associated callbacks:
    SetCurrentMouseMode(bd.hfig,params);
end

% Check for a change in history length or # traces,
% such that a change to the total history must be made:
%
history_full_changed =  ~isequal(bd.params.HistoryFull, params.HistoryFull);
if history_full_changed,
    bd = set_buffer_full_fcn(blk, bd, params.HistoryFull);
end
% Different history modes require different change detection here
% Overwrite, Suspend:
%   params.HistoryLength is the actual history buffer size,
%   so any changes to it must cause resizing of the history buffer
% Extend:
%   params.HistoryLength is just the *initial* buffer size,
%   and the actual history length (bd.HistoryLengthActual) controls
%   history size --- resizing for that parameter is not done here.
%
num_traces_changed  = bd.params.NumTraces     ~= params.NumTraces;
hist_init_changed   = bd.params.HistoryLength ~= params.HistoryLength;
hist_init_is_actual = ~strcmp(params.HistoryFull,'Extend');

if hist_init_is_actual && hist_init_changed,
    % Record the new actual history length:
    bd.HistoryLengthActual = params.HistoryLength;
    set_param(blk, 'UserData', bd);
end

if num_traces_changed || ...
  (hist_init_is_actual && hist_init_changed),
    total_history = params.NumTraces + bd.HistoryLengthActual;
    HistorySvc('change_size', bd.HistoryID, total_history);
end

% Check for a change in UpdateInterval
%
if bd.params.UpdateInterval ~= params.UpdateInterval,
    bd = reset_UpdateIntervalCounter(blk);
end

% If number of traces changed, react to new desired
% number of traces (params.NumTraces):
if num_traces_changed,
    bd = update_num_traces(params.NumTraces, blk);
end

% Detect changes in limits:
%
current_xlim = [bd.params.YMin bd.params.YMax];
desired_xlim = [   params.YMin    params.YMax];
if ~isequal(current_xlim, desired_xlim),
    update_xlim(desired_xlim, blk);
end

% Detect changes in transform options:
%
reinitialize_xform = xform_options_changed(bd, params);

% Detect changes in triggering options:
%
reinitialize_trigger = trigger_options_changed(bd, params);

% Record new param info
bd.params = params;
set_param(blk, 'UserData', bd);

% Adjust the GUI axes, colormap, etc,
bd = setup_axes(blk);

% Update parameter dialog, if open:
sdspwfall_params('refresh_dialog_from_blk', blk);

% Update patches with history, if available
% This is needed in case # display traces updated, etc
UpdateDisplayWithHistory(blk);

if reinitialize_xform, % New data transformation selected
    bd = xform_init(blk, isRunning);
end

% GUI is open and a change has been made
% Update menu checks, visibility of GUI components, etc
%
% Do this after data transformation changes have occurred,
% so that the status bar data-size readout is up-to-date:
bd = SetMenuChecks(blk);  % calls HistoryControlsSetLimits, etc

if reinitialize_trigger,
    trigger_init(blk);
end


% ---------------------------------------------------------------
function suppressOutputs = CheckInportAttributes(uDims)
% xxx update these to use a central messaging system,
%     and perhaps shut down display?

suppressOutputs = 0;

% msg = '';
% if ~isreal(u),
%    msg = 'Input cannot be complex-valued.';
%    InportAttributesError(msg); return
% end

if prod(uDims)==1,
    msg = 'Input is a scalar.';
    errordlg(msg,'Waterfall Dialog Error','modal');
    suppressOutputs = 1;
    return;
end

i=length(find(uDims > 1));
if i>1,
    % More than one non-singleton dimension
    % Must be > 1-D input
    msg = 'Display of matrices not supported.';
    msg = [msg sprintf('\n\n') ...
            'Consider selecting a Transformation filter from the parameters dialog.'];
    errordlg(msg,'Waterfall Dialog Error','modal');
    return;
end



% =========================================================================
% UPDATE PORTIONS OF DISPLAY
% =========================================================================

% ---------------------------------------------------------------
function update_xlim(desired_xlim, blk)
% Assumes all surfaces exist
% Adjusts data for all surfaces according to new xlim
% Does *not* update block_data.params with new xlim

% Set new visibility limits on axis:
bd = get_param(blk, 'UserData');
set(bd.haxis,'xlim',desired_xlim);

% Update "endpoints" of all patches:
hsurf      = bd.hsurf;
hdiscontig = bd.hdiscontig;
xlim_min   = desired_xlim(1);
xsurf      = get(hsurf,'xdata');
for i = 1 : length(xsurf),
    set(hsurf(i),      'xdata', [xlim_min; xsurf{i}(2:end-1); xlim_min]);
    set(hdiscontig(i), 'xdata', xlim_min*ones(1,4));
end

% ---------------------------------------------------------------
function [samps,chans] = GetSampsAndChans(dims)
% Vector-convenience mode of operation
% Basically, if input is any type of vector, put it into Mx1 form
% xxx COMMON

if isempty(dims),
    dims=[0 1]; % make into empty 2-D vector
end
if length(dims)==1,
    dims=[dims 1];  % make 1-D into 2-D
end
if dims(1)==1,
    % 1xN, take N as samples/channel, and chans=1
    samps = dims(2);
    chans = dims(1);
else
    % Mx1 or MxN, take M as samples/channel, and chans=N
    samps = dims(1);
    chans = dims(2);
end

% -------------------------------------------------------------------------
function UpdateInportDimsHint(blk, bd, rec)
% Check if input data dimensions match the last hint
% i.e., is the last saved view-orientation going to work?
%
% rec is a cell-array of data
%
% Note that this will automatically write the new hint dimensions
% into the block mask, without "dirtying" the model
% The explicit action "SaveAxesToBlock" does the same thing,
% but it does dirty the model.
if ~isempty(rec{1}), % which could happen if history rec is shut off
    siz = size(rec{1}.Values);
    if ~isequal(bd.params.InportDimsHint, siz),
        dirty = get_param(bd.bdroot,'dirty');
        
        % side effect: setting this will cause DialogApply to run,
        % causing various updates to occur
        set_param(blk,'InportDimsHint', mat2str(siz));
        
        set_param(bd.bdroot,'dirty',dirty);
        
        % Reset display aspect ratios:
        axis(bd.haxis,'normal');
        axis(bd.haxis,'vis3d');
    end
end

% ---------------------------------------------------------------
function block_data = update_indims(desired_indims, blk)
% If a change to the input dimensions occurs,
%   - update axis limits
%   - clear the display
%   - clear the history
% Turns out that we call this from first_history_rec, 
% which does a history flush; and if display is on,
% the first_display_update fcn calls primary_open,
% so we accomplish all the above steps

block_data = get_param(blk,'UserData');

% update stored indims
block_data.indims = desired_indims;
set_param(blk, 'UserData', block_data);

% if display is open, update axis limits, etc:
if ~isempty(block_data.hfig),
    % Modify waterfall and discontig patches
    
    hax = block_data.haxis;
    [N, chans] = GetSampsAndChans(desired_indims);
    
    % Update the ydata of all patches in waterfall
    % Can't restore from history, since it must have wrong
    % size if it has any data at all.
    hsurf = block_data.hsurf;
    y = get(hsurf(1),'ydata');
    if length(y) ~= N+2,
        % Update waterfall slices:
        new_x = NaN*ones(N+2,1);
        new_y = [1 1:N N]';
        new_z = ones(N+2,1);
        for i=1:length(hsurf),
            set(hsurf(i), ...
                'xdata',new_x, ...
                'ydata',new_y, ...
                'zdata',i*new_z);
        end
        
        % Update discontig patches:
        % Only changing y-dim, can leave all else alone
        hdiscontig = block_data.hdiscontig;
        yd2=ceil(N*1.1);
        yd=[N N yd2 yd2];
        set(hdiscontig, {'ydata'}, {yd});
    end
    
    % Modify axis limits:
    set(hax, 'ylim', [0 ceil(N*1.1)+1]);
end

% ---------------------------------------------------------------
function block_data = update_num_traces(desired_NumTraces, blk)

% Adds/removes 3-D patches as necessary
% Does *not* update block_data.params with new value of NumTraces
% If patches are added, initializes to IC value
% Sets patch transparency
%
% NOTE: Fcn modifies block_data (updates .hsurf), so the
%       structure is returned as a convenience

block_data = get_param(blk, 'UserData');
hfig       = block_data.hfig;
fig_data   = get(hfig,'UserData');
if fig_data.block ~= blk 
    fig_data.block = blk; % only when sim command is used from command line
    set(hfig,'UserData', fig_data);
end  
hax        = block_data.haxis;
hsurf      = block_data.hsurf;
hdiscontig = block_data.hdiscontig;
indims     = block_data.indims;  % last input dims, or defaults
[N, chans] = GetSampsAndChans(indims);
xlim       = [block_data.params.YMin block_data.params.YMax];
current_NumTraces = block_data.params.NumTraces;

% If hsurf is empty, this must be the 1st call to this fcn since
% the most recent restart of the simulation.  No surfaces have yet been
% created.  Nevertheless, params is loaded with NumTraces set to desired
% # so we reset the "local" current # traces:
if isempty(hsurf), current_NumTraces = 0; end
if length(hsurf) ~= current_NumTraces,
    error('NumTraces ~= length(hsurf)');
end

% Create or delete surfaces as needed:
%
if desired_NumTraces > current_NumTraces,
    % Want more traces - create additional patches:
    ic = NaN*ones(indims);
    x = [xlim(1); ic; xlim(1)];  % initialize patches to IC value
    y = [1 1:N N]';
    for i = current_NumTraces+1 : desired_NumTraces,
        z=i*ones(N+2,1);
        hsurf(i) = patch(x,y,z,i, ...
            'Parent', hax, ...
            'CDataMapping', 'direct');
        
        % Add markers at the endpoints of each patch
        % so that we can selectively mark various slices as
        % being discontiguous in time relative to the immediately
        % prior time slice.
        xd=xlim(1)*ones(1,4);
        yd2=ceil(N*1.1);
        yd=[N N yd2 yd2];
        zd=[i-.5 i+.5 i+.5 i-.5];
        hdiscontig(i) = patch(xd,yd,zd,[1 1 1], ...
            'LineStyle','none', ...
            'Parent', hax, ...
            'ButtonDownFcn', @discontig_buttondown, ...
            'UserData', i-1, ...
            'CDataMapping','direct');
    end

    % Attach context menus to new patches
    %
    % xxx the problem is that the Camera menu may be on,
    %     and it has installed its own context menu and cached away
    %     ours.  Thus, there's no simple way of doing this now.
    % mContext = get(hsurf(1),'UIContextMenu');
    % set(hsurf, 'UIContextMenu', mContext);
    
elseif current_NumTraces > desired_NumTraces,
    % Want fewer traces - delete oldest:
    
    delete(hsurf(desired_NumTraces+1:end));
    hsurf = hsurf(1:desired_NumTraces);
    
    delete(hdiscontig(desired_NumTraces+1:end));
    hdiscontig = hdiscontig(1:desired_NumTraces);
end

% Update patch transparency
%
NumTraces = desired_NumTraces;
OpNewest  = block_data.params.TNewest;
OpOldest  = block_data.params.TOldest;
alpha     = linspace(OpNewest, OpOldest, NumTraces); % face opacity profile
edgealpha = linspace(0.2, 0.2, NumTraces);           % constant edge opacity
for i=1:NumTraces,
    set(hsurf(i), ...
        'FaceAlpha', alpha(i), ...
        'EdgeAlpha', edgealpha(i));
end

% First patch gets an opaque, dark gray border:
%set(hsurf(1), ...
%    'edgealpha',1, ...
%    'edgecolor',.15*[1 1 1]);

% Modify axis to show all patches, but leave camera view alone
set(hax, ...
    'xlim', xlim, ...
    'ylim', [0 ceil(N*1.1)+1], ...
    'zlim', [0.5 NumTraces+0.5]);

% Update z-axis tick labels
%
% The default ticks would be 0:N-1, with 0 indicating the most recent time
% instant, and N-1 indicating the oldest.  However, we want these to read
% 0:-1:1-N, with a negative indicating the past.  'ztick' will only accept
% monotonically increasing values, so we must directly set 'zticklabel'.
posTicks = get(hax,'ztick');
numTicks = length(posTicks);
negTicks = cell(1,numTicks);
for i=1:numTicks,
    negTicks{i} = num2str(1-posTicks(i));
end
set(hax,'zticklabel',negTicks);


% Update data cache:
block_data.hsurf      = hsurf;
block_data.hdiscontig = hdiscontig;
set_param(blk,'UserData', block_data);

discontig_update_hilite(fig_data);


% -------------------------------------------------------------------------
function bd_AxisLabels(hcb, eventStruct)
% ButtonDownFcn for axis labels
% Opens the param dialog to the Axes page

hfig = gcbf;
fig_data = get(hfig,'UserData');
blk = fig_data.block;

% Open to Axes tab, tab number 2
bd = get_param(blk,'UserData');
bd.param_dlg.tabNum = 2;
set_param(blk,'UserData',bd);

DisplayParameters(hcb, eventStruct, hfig);

% -------------------------------------------------------------------------
function update_axis_labels(bd)
% Setup axis labels and color

% Axis color
%
% Use an invisible text control, and try to set color into it
% 
% First, try to evaluate string-literal:
fig_data = get(bd.hfig,'UserData');
hax = bd.haxis;
htxt = fig_data.testtext;
try
    % '[1 1 0]' or 'w'
    clr = eval(bd.params.AxisColor);
    set(htxt,'foregr', clr);
catch
    clr = [1 1 1];  % white
end
set(hax, 'color', clr);

xLabel = bd.params.YLabel;  % yes, yes, X- and Y- are purposefully reversed
if ~ischar(xLabel), xLabel = 'X-Axis'; end
hxLabel = get(hax, 'XLabel');
xlim=get(hax,'xlim');
set(hxLabel, 'String', xLabel, ...
    'rot',90, ...
    'horiz','center', ...
    'buttondownfcn', @bd_AxisLabels);

yLabel = bd.params.XLabel;
if ~ischar(yLabel), yLabel='Y-Axis'; end
hyLabel = get(hax,'YLabel');
set(hyLabel, ...
    'String', yLabel, ...
    'buttondownfcn', @bd_AxisLabels);

zLabel = bd.params.ZLabel;
if ~ischar(yLabel), zLabel='Z-Axis'; end
hzLabel = get(hax,'ZLabel');
set(hzLabel, 'rot',0, ...
    'String', zLabel, ...
    'buttondownfcn', @bd_AxisLabels);



% -------------------------------------------------------------------------
function update_colormap(bd)
% Update colormap for plot
set(bd.hfig, ...
    'colormap', feval(bd.params.CMapStr, bd.params.NumTraces));


% =========================================================================
% Status bar handling
% =========================================================================

% -------------------------------------------------------------------------
function UpdateStandardStatusText(hfig)
% Setup some status bar text, indicating
% current scope state
%
fd = get(hfig,'UserData');
blk = fd.block;
bd = get_param(blk,'UserData');
optSuspend = get_param(blk,'Suspend');
optSnap    = get_param(blk,'Snapshot');
if strcmp(optSuspend,'on'),
    str = 'Suspend';  % mutually exclusive options
elseif strcmp(optSnap,'on'),
    str = 'Snapshot';
elseif simIsRunning(bd.bdroot),
    str = 'Running';
else
    str = 'Stopped';
end
UpdateStatusText(bd.hfig,str);


% -------------------------------------------------------------------------
function UpdateStatusText(hfig,str)
% Set arbitrary text into status region

if isempty(hfig), return; end
fd = get(hfig,'UserData');
set(fd.hStatusBar.StatusText,'string',str);


% -------------------------------------------------------------------------
function UpdateDataSizesReadout(blkh)
% Formulate "data sizes" text readoutk
%   "N:# U:# H:#"
% where:
%   N = # elements in input vector
%   U = update interval
%   H = # traces in history buffer
%
% could consider:
%   T = # traces in waterfall

bd = get_param(blkh,'UserData');
fd = get(bd.hfig,'UserData');
N = max(bd.indims);
U = bd.params.UpdateInterval;
H = bd.params.HistoryLength;
% T = bd.params.NumTraces;
str = sprintf('N:%d U:%d H:%d',N,U,H);
set(fd.hStatusBar.DataSizes,'string',str);

% ---------------------------------------------------------------
function UpdateXformModeReadout(blkh)
% Update the transform mode readout on the status bar

bd = get_param(blkh,'UserData');
fd = get(bd.hfig,'UserData');

% Setup status bar entry for transform-mode:
isXform = ~strcmp(bd.params.XformMode,'None');
if isXform,
    str = 'Transform';
else
    str = '';
end

% Setup transform-mode tooltip for status bar
switch lower(bd.params.XformMode)
    case 'user-defined fcn'
        tip = ['Fcn: ' bd.params.XformFcn];
    case 'user-defined expr'
        tip = ['Expr: ' bd.params.XformExpr];
    otherwise,
        tip = bd.params.XformMode;
end
set(fd.hStatusBar.XformMode, ...
    'string',str, 'tooltip',tip);


% -------------------------------------------------------------------------
function bd_XformModeReadout(hcb, eventStruct)
% ButtonDownFcn for transform readout
% Opens the param dialog to the Transform page

hfig = gcbf;
fig_data = get(hfig,'UserData');
blk = fig_data.block;

% Open to Transforms tab, tab number 5
bd = get_param(blk,'UserData');
bd.param_dlg.tabNum = 5;
set_param(blk,'UserData',bd);

DisplayParameters(hcb, eventStruct, hfig);


% ---------------------------------------------------------------
function HideStatusBar(hfig,state)
% Hide the status bar
% in preparation for printing

fd = get(hfig,'UserData');
hAll  = [fd.hStatusBar.All ...
         fd.hStatusBar.Region ...
         fd.hStatusBar.StatusText];
if state, vis='off'; else vis='on'; end
set(hAll,'vis',vis);


% =========================================================================
% SNAPSHOT/SUSPEND FUNCTIONS
% =========================================================================

% -------------------------------------------------------------------------
function bd = HistorySuspendRec(blk, bd)
% Disable history record
% We cache away the history rec fcn
if isempty(bd.HistoryRecFcn_suspend),
    % Disable history recording:
    bd.HistoryRecFcn_suspend = bd.HistoryRecFcn;
    bd.HistoryRecFcn         = @history_rec_skip;
    set_param(blk,'UserData',bd);
end

% -------------------------------------------------------------------------
function bd = HistoryResumeRec(blk, bd)
% Resume history record and enable display updates:
if ~isempty(bd.HistoryRecFcn_suspend),
    bd.HistoryRecFcn         = bd.HistoryRecFcn_suspend;
    bd.HistoryRecFcn_suspend = [];
    set_param(blk,'UserData',bd);
end

% -------------------------------------------------------------------------
function bd = update_suspend_state(blk, bd)
% Should be callable from a block with scope still closed

if strcmp(bd.params.Suspend,'on'),
    % So we *want* to be in suspend mode
    % But have we transitioned our functionality to suspend mode yet?
    %  (remember, the changing of the block mask is "asynchronous" to the
    %   action of reconfiguring ourselves to be in suspend mode itself)
    if isempty(bd.HistoryRecFcn_suspend),
        % We have not yet suspended history record
        %   (scope should be in suspend mode, but is not)
        
        % First, disable snapshot when suspend invoked
        SnapshotControlsEnable(bd.hfig,0); % Disable
        SuspendControlsEnable(bd.hfig,1); % Enable
        % We made sure the suspend control was enabled as well.
        % Why? If the snapshot control was turned on just before
        % we hit suspend mode (eg, automatic via Suspend-on-buffer-full),
        % then the suspend control was disabled and now BOTH
        % controls are disabled.  That would be bad news.
        
        bd = HistorySuspendRec(blk,bd);
        bd = DisplayDisable(blk, bd);
    
        % Perform Synchronized Snapshots, if SyncSnapshots turned on.
        % Only invoke this if user pressed button on our own GUI
        % How do we know this currently?
        %   Minimal notion: our GUI must be open
        %   Better: record action in state info, unset it when done
        %           (eg, prevent infinite recursions)
        if ~isempty(bd.hfig) && bd.params.SyncSnapshots,
            SnapshotSvc('syncupdate',blk, 'Suspend','on');
        end
    end
else
    % Suspend parameter is turned off
    % That means we do not *want* to be in suspend mode
    % But have we actually turned off suspend mode yet?
    
    if ~isempty(bd.HistoryRecFcn_suspend),
        % We have not yet turned off snapshot mode
        
        bd = HistoryResumeRec(blk, bd);
        bd = DisplayEnable(blk, bd);
        
        % When re-enabling display, send history back to newest data
        % (While in snapshot mode, user may have scrolled back in the
        % history buffer.)
        HistoryControlsSetToNewest(bd.hfig);
        
        if ~isempty(bd.hfig) && bd.params.SyncSnapshots,
            SnapshotSvc('syncupdate',blk, 'Suspend','off');
        end
        
        % Last, enable snapshot when suspend turned off
        SnapshotControlsEnable(bd.hfig,1); % Enable
    end

    % We process Suspend with priority over Snapshot
    if strcmp(bd.params.Snapshot,'on'),
        % Want snapshot engaged
        if ~bd.Snapshot_engaged,
            % First, disable suspend when snapshot invoked
            SuspendControlsEnable(bd.hfig,0); % Disable
            SnapshotControlsEnable(bd.hfig,1); % Enable
            
            bd = DisplayDisable(blk, bd);
            if ~isempty(bd.hfig) && bd.params.SyncSnapshots,
                SnapshotSvc('syncupdate',blk, 'Snapshot','on');
            end
            
            % Snapshot now engaged:
            bd.Snapshot_engaged = 1;
            set_param(blk,'UserData',bd);
        end
    else
        % Want snapshot disengaged
        if bd.Snapshot_engaged,
            bd = DisplayEnable(blk, bd);
            
            % When re-enabling display, send history back to newest data
            % (While in snapshot mode, user may have scrolled back in the
            % history buffer.)
            HistoryControlsSetToNewest(bd.hfig);
            
            % xxx
            % now, must update the enable-state of the history controls
            % they're not being updated at present (eg, still on!)
            
            if ~isempty(bd.hfig) && bd.params.SyncSnapshots,
                SnapshotSvc('syncupdate',blk, 'Snapshot','off');
            end
            % Last, enable suspend when snapshot turned off
            SuspendControlsEnable(bd.hfig,1); % Enable
            
            % Snapshot now disengaged:
            bd.Snapshot_engaged = 0;
            set_param(blk,'UserData',bd);
        end
    end
    
end

% ---------------------------------------------------------------
function SnapshotDisplay(hcb,eventStruct,hfig,opt)
% Toggle display freeze setting
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<4, opt='toggle'; end
if nargin<3, hfig=gcbf; end

fig_data  = get(hfig, 'UserData');
blk       = fig_data.block;
hopt      = fig_data.menu.snapshot;

if strcmp(opt,'toggle'),
	% toggle current setting:
	if strcmp(get(hopt,'Checked'),'on'),
		opt='off';
	else
		opt='on';
	end
end

% Update block dialog setting, so param is recorded in model
% This will indirectly update the param structure, via the
% mask dialog callbacks and the automatic call to DialogApply.
%
% Don't change dirty status with changes to Snapshot mode:
bd = get_param(blk,'UserData');
dirty = get_param(bd.bdroot,'dirty');
set_param(blk, 'Snapshot', opt);
set_param(bd.bdroot,'dirty',dirty);

% ---------------------------------------------------------------
function SuspendDataCapture(hcb,eventStruct,hfig,opt)
% Toggle suspend setting
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<4, opt='toggle'; end
if nargin<3, hfig=gcbf; end

if isempty(hfig),
    % GUI not open
    % most likely scenario: suspend-mode hit while scope was closed
    % ALT:
    %   blk = get_param(gcbh,'UserData'); % get parent block handle
    %
    blk = eventStruct;  % mdlUpdate sets this to blk when it calls
    hopt = [];        % turn on suspend mode
else
    fig_data  = get(hfig, 'UserData');
    blk       = fig_data.block;
    hopt      = fig_data.menu.suspend;
end

if strcmp(opt,'toggle'),
	% toggle current setting:
	if strcmp(get(hopt,'Checked'),'on'),
		opt='off';
	else
		opt='on';
	end
end

% Update block dialog setting, so param is recorded in model
% This will indirectly update the param structure, via the
% mask dialog callbacks and the automatic call to DialogApply.
%
% Don't change dirty status with changes to Suspend mode:
bd = get_param(blk,'UserData');
dirty = get_param(bd.bdroot,'dirty');
set_param(blk, 'Suspend', opt);
set_param(bd.bdroot,'dirty',dirty);

% ---------------------------------------------------------------
function SnapshotControlsEnable(hfig,state)
% Just enables/disables snapshot button, not suspend button
%
% State: 0=disable, 1=enable
% Does *not* turn controls on or off, just enables/disables them

% when closing a running scope, we get here with hfig empty:
if isempty(hfig), return; end
fig_data = get(hfig,'UserData');
h = [fig_data.menu.buttons.Snapshot fig_data.menu.snapshot];
if ~state, str='off';
else       str='on';
end
set(h,'enable',str);


% ---------------------------------------------------------------
function SuspendControlsEnable(hfig,state)
% Just enables/disables suspend button, not snapshot button
%
% State: 0=disable, 1=enable
% Does *not* turn controls on or off, just enables/disables them

% when closing a running scope, we get here with hfig empty:
if isempty(hfig), return; end
fig_data = get(hfig,'UserData');
h = [fig_data.menu.buttons.Suspend fig_data.menu.suspend];
if ~state, str='off';
else       str='on';
end
set(h,'enable',str);


% ---------------------------------------------------------------
function SnapshotSuspendControlsEnable(hfig,state)
% Enable/disable BOTH snapshot and suspend buttons
%
% State: 0=disable, 1=enable
% Does *not* turn controls on or off, just enables/disables them

SnapshotControlsEnable(hfig,state);
SuspendControlsEnable(hfig,state);

% ---------------------------------------------------------------
function LinkScopes(hcb,eventStruct,hfig,opt)
% Toggle setting of link scopes (synchronization)
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<4, opt='toggle'; end
if nargin<3, hfig=gcbf; end

fig_data  = get(hfig, 'UserData');
blk       = fig_data.block;
hopt      = fig_data.menu.buttons.LinkScopes;

opt = get(hopt,'State');

% if strcmp(opt,'toggle'),
% 	% toggle current setting:
% 	if strcmp(get(hopt,'State'),'on'),
% 		opt='off';
% 	else
% 		opt='on';
%     end
% end

% Update block dialog setting, so param is recorded in model
% This will indirectly update the param structure, via the
% mask dialog callbacks.
set_param(blk, 'SyncSnapshots', opt);


% =========================================================================
% CREATE DISPLAY
% =========================================================================

% ---------------------------------------------------------------
function bd = setup_axes(blkh)
% Initialize viewer axes
%
% Need to put the following "updates" here and not in DialogApply
% because the block could start off with a state that affects these
% modes, without a DialogApply event being generated, and the user
% expects the appropriate actions to occur.
%
% DialogApply does call this code, so this point is an appropriate "bottleneck"
% to handle these states:
bd = get_param(blkh,'UserData');
update_axis_labels(bd);
update_colormap(bd);
grid(bd.haxis, bd.params.AxisGrid);

% Set up the axis so that the cameratools won't suddenly
% make a change to the aspect ratio, etc:
axis(bd.haxis,'vis3d');
set(bd.haxis,'warptofill','off');  % xxx 'on'

update_xlim([bd.params.YMin bd.params.YMax], blkh);
bd = update_num_traces(bd.params.NumTraces, blkh);
bd = update_indims(bd.indims, blkh);
bd = update_suspend_state(blkh, bd);
update_history_controls(blkh);


% -------------------------------------------------------------------------
function ScopeKeypress(hcb, eventStruct, hfig, key)
% Handle keypresses in main scope window

if nargin<3, 
    hfig = gcbf;
end
if nargin<4, 
    key = get(hfig, 'CurrentChar');
end

fig_data = get(hfig,'UserData');
bd       = get_param(fig_data.block,'UserData');

if ~isempty(key), % unix keyboard has an empty key
    switch key
        case char(13) % Enter
            % Open parameters dialog
            DisplayParameters(hfig, [], hfig);
            
        case ' ' % space
            % Turn off highlighted trace
            discontig_update_hilite(fig_data, -1);
            
        case char(28) % left
            % Move selected trace one farther back in history
            % If no selected trace, select first one
            patch_offset = bd.SelectedTrace;
            if patch_offset > -1,
                patch_offset = patch_offset-1;
            end
            if patch_offset == -1,
                patch_offset = bd.params.NumTraces-1;
            end
            discontig_update_hilite(fig_data, patch_offset);
            
        case char(29) % right
            % Move selected trace one nearer in history
            % If no selected trace, select last visible one
            patch_offset = bd.SelectedTrace;
            patch_offset = patch_offset+1;
            if patch_offset == bd.params.NumTraces,
                patch_offset = 0;
            end
            discontig_update_hilite(fig_data, patch_offset);
            
        case {char(30),char(31)} % up, down
            % Move history slider up one farther or one closer in history
            % Only if sim stopped or suspend is on
            if IsHistorySliderInteractive(hfig),
                offset = round(get(fig_data.history.slider,'value'));
                if strcmp(key,char(30)),
                    if offset < bd.HistoryLengthActual,
                        offset = offset + 1;
                    end
                else
                    if offset > 0,
                        offset = offset - 1;
                    end
                end
                set(fig_data.history.slider,'value',offset);
                HistorySliderUpdateAndDisplay(hfig, offset);            
            end
    end
end

% ---------------------------------------------------------------
function ResizeFcn(hcb, eventStruct)
% Figure resize function
% Goal:
% 1 - move slider into appropriate position
% 2 - gracefully handle narrowness w.r.t. status text
%     what to keep?
% 3 - keep history slider and readout area at bottom right

fd = get(hcb,'UserData');  % hcb = hfig
hAll  = [ fd.hStatusBar.All ...
          fd.history.frame ...
          fd.history.slider ...
          fd.history.labels];

% Get positions and compute resize offsets:
fig_pos   = get(hcb,'pos');
frame_pos = get(fd.hStatusBar.Region,'pos');
frame_rt  = frame_pos(1)+frame_pos(3)-2;
%frame_top = frame_pos(2)+frame_pos(4)-1;
%frame_bot = frame_pos(2);
%delta = [fig_pos(3)-frame_rt fig_pos(4)-frame_top];
delta = fig_pos(3)-frame_rt;

% Adjust positions:
for i=1:length(hAll),
    pos = get(hAll(i),'pos');
    pos(1) = pos(1) + delta;
    set(hAll(i),'pos',pos);
end

% Separately adjust hStatusBar.Region
% Grow it wider, don't move it:
pos = frame_pos;
pos(3)=pos(3)+delta;
set(fd.hStatusBar.Region,'pos',pos);


% ---------------------------------------------------------------
function HideSliderReadouts(hfig,state)
% Hide the history slider & readouts
% in preparation for printing

fig_data = get(hfig,'UserData');
hAll  = [fig_data.history.slider ...
         fig_data.history.labels ...
         fig_data.history.frame];
if state, vis='off'; else vis='on'; end
set(hAll,'vis',vis);


% =========================================================================
% Printing-related functions
% =========================================================================

% ---------------------------------------------------------------
function PageSetup(hcb, eventStruct)
pagesetupdlg(gcbf);

% -------------------------------------------------------------------------
function PrintSetup(hcb, eventStruct)
printdlg('-setup', gcbf)

% -------------------------------------------------------------------------
function PrintWindow(hcb, eventStruct, printFcn)

% make readouts, etc, invisible in original window
hfig = gcbf;
HideSliderReadouts(hfig,1);
HideStatusBar(hfig,1);

newfig = copyobj(hfig,0);  % Make a copy of this revised window
set(newfig, ...
   'DeleteFcn',   '', ...
   'ResizeFcn',   '', ...
   'KeyPressFcn', '', ...
   'vis','off');

% Delete all items that have visibility turned off
% We don't want these controls to show up by definition
% However, the print mechanism may show these widgets
% depending on circumstances.
h=findobj(newfig,'vis','off');
delete(h(2:end));  % 1st entry is figure window

% restore vis of sliders, etc, in original figure
HideSliderReadouts(hfig,0);
HideStatusBar(hfig,0);

% Execute print function, and wait (block) until user
% presses OK or cancel.  This way, the main GUI does
% not continue running/taking inputs
%
%   ex: printpreview, printdlg
p = feval(printFcn,newfig);
if ~isempty(p), uiwait(p); end

% Delete hidden print window
delete(newfig);


% =========================================================================
% Main GUI construction
% =========================================================================

% ---------------------------------------------------------------
function ScopeToolbarCB(hcb, eventStruct)
% Callback from scope toolbar visibility menu item
% changes block data

hfig = get(hcb,'UserData'); % userdata of "toolbar" uimenu is hfig
ScopeToolbarVis(hfig);  % toggle toolbar visibility


% ---------------------------------------------------------------
function bd = ScopeToolbarVis(hfig,state)
% Set state of Scope toolbar visibility
% state: 'toggle','on','off'
% If omitted, state defaults to 'toggle'

if nargin<2, state='toggle'; end

fig_data = get(hfig,'UserData');  % hcb = uimenu
hMenu    = fig_data.menu.Toolbar;  % handle to toolbar menu item
hBar     = fig_data.menu.buttons.Toolbar;  % handle to toolbar
blk      = fig_data.block;
bd       = get_param(blk,'UserData');

switch state
    case 'toggle'
        if strcmp(bd.ScopeToolbarVis,'on'),
            newState='off';
        else
            newState='on';
        end
    otherwise
        newState = state;
end
set(hMenu, 'checked', newState);
set(hBar, 'vis', newState);

% Update block state:
bd.ScopeToolbarVis = newState;
set_param(blk,'UserData', bd);


% ---------------------------------------------------------------
function fig_data = create_scope(blk, params)
% CREATE_SCOPE Create new scope GUI

% Initialize empty settings:
fig_data.main  = [];  % until we move things here
fig_data.menu  = [];

% Must set renderer mode specifically to OpenGL
% Reason: if transparency of patches are all set to 1 (opaque),
% renderer mode switches to painters if left at default
% We want to keep opengl
%
% Also, don't use drawmode=fast, because it specifically turns
% off sorting in 3-D transparency mode, and the curves will
% render incorrectly from some view angles

bgc = [1 1 1]*7/8;

if ispc,
    renderType = 'opengl';
else
    renderType = 'zbuffer';
end
hfig = figure('numbertitle', 'off', ...
   'name',         getfullname(blk), ...
   'position',     params.FigPos, ...
   'nextplot',     'add', ...
   'color',        bgc, ...
   'integerhandle','off', ...
   'doublebuffer', 'off', ...
   'DeleteFcn',    @FigDelete, ...
   'ResizeFcn',    @ResizeFcn, ...
   'KeyPressFcn',  @ScopeKeypress, ...
   'PaperPositionMode', 'auto', ...
   'vis',          'off', ...
   'renderer',     renderType, ...
   'HandleVisibility','callback');


% Turn off just the general figure toolbar, but not the menu system
% domymenu('menubar','toggletoolbar',gcbf);
%
hTB = findall(hfig,'Tag','FigureToolBar');
set(hTB,'vis','off');

% Delete a bunch of default menus
set(0,'showhid','on');
h=findobj(hfig,'type','uimenu','label','&Insert'); delete(h);
h=findobj(hfig,'type','uimenu','label','&File'); delete(h);
h=findobj(hfig,'type','uimenu','label','&Edit'); delete(h);
h=findobj(hfig,'type','uimenu','label','&Tools'); delete(h);
h=findobj(hfig,'type','uimenu','label','&Help'); delete(h);
set(0,'showhid','off');

% Axis for the image:
hax = axes('Parent',hfig, ...
   'DrawMode','normal', ...
   'Box','off');
 %  'ticklength',[0 0]);

% Create a context menu:
mContext = uicontextmenu('parent',hfig);

% Establish settings for all structure fields:
fig_data.block = blk;
fig_data.hfig  = hfig;

% Store major settings:
fig_data.main.haxis   = hax;
fig_data.menu.context = mContext;

% -------------------------------------------------
% Define FILE menu:
%
labels = {'&File', ...
        '&Close', ...
        '&Export', ...
        'Pa&ge Setup...', ...
        'Print Set&up...', ...
        'Print Pre&view...', ...
        '&Print...'};

mFile = uimenu(hfig,'Label',labels{1},'position',1);
%
% File submenu items:
%
uimenu(mFile, ...
    'label',labels{2}, ...
    'Accel','W', ...
	'callback',@FigDelete);

mExport = uimenu(mFile, ...
    'separator', 'on', ...
    'label',labels{3});

uimenu(mFile, 'label',labels{4}, ...
	'separator','on', ...
	'callback',@PageSetup);
uimenu(mFile, 'label',labels{5}, ...
	'callback',@PrintSetup);
uimenu(mFile, 'label',labels{6}, ...
	'callback',{@PrintWindow,@printpreview});
uimenu(mFile, 'label',labels{7}, ...
	'accel','P', ...
	'callback',{@PrintWindow,@printdlg});
%
% File->Export submenu items:
%
labels = {'Export to &Workspace', ...
          'Export to &SPTool'};
% - Create Export to Workspace item
fig_data.menu.workspace = uimenu(mExport, 'label',labels{1}, ...
   'callback', @WorkspaceExport, ...
   'Accel','1');
% - Create SPTool Export item
fig_data.menu.sptool = uimenu(mExport, 'label',labels{2}, ...
   'callback', @SPToolExport, ...
   'Accel','2');


% -------------------------------------------------
% Define Options menu:
%
labels = {'&Edit', ...
        'S&tart/Stop Simulation', ...
        'Scope param&eters...'};

% Create figure Options menu
% top-level Axes menu in figure
i=1;
mAxes = uimenu(hfig, ...
    'Position', 2, ...
    'Label', labels{i});

% Options submenu items:
% - Create start/stop simulation
i=i+1;
fig_data.menu.start = uimenu(mAxes, 'label',labels{i}, ...
   'callback', @CtrlT, ...
   'Accel','T');

% - Create Parameters item
i=i+1;
fig_data.menu.params = uimenu(mAxes, 'label',labels{i}, ...
   'callback', @DisplayParameters, ...
   'Accel','E');



% -------------------------------------------------
% Extend View menu:
%
% First, find the View menu:
viewLabel = {'&View'};
set(0,'showhid','on');
mView = findobj(hfig,'label',viewLabel{1});
set(0,'showhid','off');

% New submenu item:
labels = {'&Scope Toolbar', ...
        'Show &grid', 'Suspen&d', '&Snapshot', 'Rescale &amplitude','&Fit to view'};

i=1;
mToolbar = uimenu(mView, ...
    'label', labels{i}, ...
    'callback', @ScopeToolbarCB, ...
    'userdata', hfig);

% - Create Axis Grid item
i=i+1;
fig_data.menu.axisgrid = uimenu(mView, 'Label', labels{i}, ...
    'Accel','g', ...
    'separator','on', ...
    'Callback', @AxisGrid);
% - Create suspend item
i=i+1;
fig_data.menu.suspend = uimenu(mView, 'Label', labels{i}, ...
    'Accel','D', ...
    'Callback', @SuspendDataCapture);
% - Create snapshot item
i=i+1;
fig_data.menu.snapshot = uimenu(mView, 'Label', labels{i}, ...
    'Accel','S', ...
    'Callback', @SnapshotDisplay);
% - Create Autoscale item
i=i+1;
fig_data.menu.autoscale = uimenu(mView, 'label',labels{i}, ...
   'accel','A', ...
   'callback', @Autoscale);
% - Create fit-to-view item
i=i+1;
fig_data.menu.fittoview = uimenu(mView, 'label',labels{i}, ...
   'accel','F', ...
   'callback', @FitToView);


% -------------------------------------------------
% Define HELP menu:
%
labels = {'&Help', ...
          '&Waterfall Block Help', ...
          '&Demos', ...
          '&About Signal Processing Blockset'};

mHelp = uimenu(hfig,'Label',labels{1});
%
% submenu items:
uimenu(mHelp, 'label',labels{2}, ...
	'callback','doc dspblks/waterfall');
uimenu(mHelp, 'label',labels{3}, ...
	'callback','demo blocksets dsp');
uimenu(mHelp, 'label',labels{4}, ...
	'callback','aboutdspblks;');

% -------------------------------------------------------
% Context menus:

% Store all top-level menu items in one vector
fig_data.menu.top = mAxes;

% Copy menu items in common to both single- and multi-line context menus:
%

% Copy Parameters, SaveFigPos, Export menus
cParams = copyobj(fig_data.menu.params, mContext);
cSPTool = copyobj(fig_data.menu.sptool, mContext);
cWkspc  = copyobj(fig_data.menu.workspace, mContext);

% Copy AxisGrid, Snapshot, Zoom menus
cAxisGrid  = copyobj(fig_data.menu.axisgrid,  mContext);
cSuspend   = copyobj(fig_data.menu.suspend,   mContext);
cSnapshot  = copyobj(fig_data.menu.snapshot,  mContext);
cAutoscale = copyobj(fig_data.menu.autoscale, mContext);

% Assign context menu to the axis, lines, and grid:
%
set([hfig fig_data.main.haxis], ...
   'UIContextMenu', mContext);

% Collect menu items that appear in multiple places
% *and* that require toggle state
%
fig_data.menu.axisgrid = [fig_data.menu.axisgrid cAxisGrid];
fig_data.menu.snapshot = [fig_data.menu.snapshot cSnapshot];
fig_data.menu.suspend  = [fig_data.menu.suspend  cSuspend];


% --------------------------------------------------------
% Waterfall-specific button bar:

% Load icons from file:
persistent icons
if isempty(icons),
    icons = load('sdspwfall_icons.mat');
end

hbar=uitoolbar('parent',hfig');

hb.Toolbar = hbar;  % record toolbar handle

% Params/save/recall buttons:
%
hb.Params = uipushtool('parent',hbar, ...
    'tooltip','Scope parameters... (Ctrl+E)', ...
    'cdata',icons.params, ...
    'clickedcallback',@DisplayParameters);
hb.FigPos = uipushtool('parent',hbar, ...
    'tooltip','Save scope position and view', ...
    'cdata', icons.saveAxis, ...
    'clickedcallback',@SaveAxesToBlock);
hb.FigRestore = uipushtool('parent',hbar, ...
    'tooltip','Restore scope position and view', ...
    'cdata', icons.restoreAxis, ...
    'clickedcallback',@RestoreAxesFromBlock);

% 3-D View buttons:
%
hb.MouseArrow = uitoggletool('parent', hbar, ...
    'separator', 'on', ...
    'tooltip', 'Select', ...
    'cdata', icons.arrow, ...
    'clickedcallback', @MouseArrowModeCB);
hb.MouseOrbit = uitoggletool('parent', hbar, ...
    'tooltip', 'Orbit camera', ...
    'cdata', icons.camorbit, ...
    'clickedcallback', @MouseOrbitModeCB);
hb.MouseZoom = uitoggletool('parent', hbar, ...
    'tooltip', 'Zoom camera', ...
    'cdata', icons.camzoom, ...
    'clickedcallback', @MouseZoomModeCB);
% Keep handles to all 3-D view buttons in each button
hAllMouse = [hb.MouseArrow hb.MouseOrbit hb.MouseZoom];
set(hAllMouse,'UserData', hAllMouse);

% Snapshot/Suspend buttons:
%
CR = sprintf('\n');
hb.LinkScopes = uitoggletool( ...
    'parent',hbar, ...
    'separator','on', ...
    'tooltip',['Link suspend/snapshot' CR 'to all scopes.'], ...
    'cdata', icons.linked, ...
    'clickedcallback', @LinkScopes);
hb.Suspend = uitoggletool( ...
    'parent',hbar, ...
    'tooltip','Suspend data capture', ...
    'cdata', icons.run_rec, ...
    'clickedcallback',@SuspendDataCapture);
hb.Snapshot = uitoggletool( ...
    'parent',hbar, ...
    'tooltip','Snapshot display', ...
    'cdata', icons.snapshot, ...
    'clickedcallback',@SnapshotDisplay);

% Export buttons:
%
hb.Workspace = uipushtool('parent', hbar, ...
    'tooltip','Export to Workspace (Ctrl+1)', ...
    'separator','on', ...
    'cdata', icons.export_workspace, ...
    'clickedcallback',@WorkspaceExport);
hb.Export = uipushtool('parent', hbar, ...
    'tooltip','Export to SPTool (Ctrl+2)', ...
    'cdata', icons.export_sptool, ...
    'clickedcallback',@SPToolExport);

% Grid/zoom buttons:
%
hb.AxisGrid = uitoggletool( ...
    'parent',hbar, ...
    'separator','on', ...
    'tooltip','Show grid', ...
    'cdata', icons.grid_clear, ...
    'clickedcallback',@AxisGrid);
hb.Autoscale = uipushtool('parent',hbar, ...
    'tooltip','Rescale amplitude (Ctrl+A)', ...
    'cdata',icons.rescale_amplitude, ...
    'clickedcallback',@Autoscale);
hb.Aspect = uipushtool('parent',hbar, ...
    'tooltip','Fit to view (Ctrl+F)', ...
    'cdata',icons.fit_to_view, ...
    'clickedcallback',@FitToView);

% Find block button
%
hb.FindBlock = uipushtool('parent',hbar, ...
    'tooltip','Go to scope block', ...
    'cdata',icons.find_block, ...
    'clickedcallback',@HiliteBlock);

fig_data.menu.Toolbar = mToolbar;
fig_data.menu.icons   = icons;
fig_data.menu.buttons = hb;

% --------------------------------------------------------
% History buffer scroll-back:

% bgc=[1 1 1]*.8;
% bgc = get(hfig,'color');
% Background frame to prevent graph from poking in too closely
fig_pos = get(hfig,'pos');
x0 = fig_pos(3)-36;  % fig_dx - 40
hFrame = uicontrol('parent',hfig, ...
    'units','pix', ...
    'style','frame', ...
    'tooltip', '', ...
    'foregr',bgc, ...
    'backgr',bgc, ...
    'pos', [x0+0 22 37 202]);  % left side
% Set slider to non-interruptible, so that while we're
% scrolling the data, we don't get new data pushing in
% without our knowing it.
hSlider = uicontrol('parent',hfig, ...
    'style','slider', ...
    'callback', @HistorySliderCB, ...
    'units','pix', ...
    'sliderstep',[.1 .25], ...
    'interruptible', 'on', ...
    'pos',[x0+10 40 16 165]);
% Label bottom: Prior
tip='Oldest input';
hHist(1) = uicontrol('parent',hfig, ...
    'units','pix', ...
    'style','text', ...
    'tooltip', tip, ...
    'string','Old', ...
    'horiz','center', ...
    'backgr',bgc, ...
    'pos',[x0+2 206 32 15]);
% Label top:  Latest
tip='Latest input';
hHist(2) = uicontrol('parent',hfig, ...
    'units','pix', ...
    'style','text', ...
    'tooltip', tip, ...
    'string','New', ...
    'horiz','left', ...
    'backgr',bgc, ...
    'pos',[x0+14 24 16 15]);

fig_data.history.slider = hSlider;
fig_data.history.labels = hHist;
fig_data.history.frame  = hFrame;

% ----------------------------
% Status bar at bottom of GUI

% Status region frame
bg = [1 1 1]*.8;
pos=[0 0 params.FigPos(3)+2 22];
hStatusBar.Region = uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos, ...
    'backgr', bg, ...
    'foregr', [1 1 1]);

% Render right after background frame, so when resizing occurs,
% this will be "overwritten" by other data
hStatusBar.StatusText = uicontrol('parent',hfig, ...
    'style','text', ...
    'units','pix', ...
    'pos',[2 1 100 16], ...
    'string','Ready', ...
    'horiz','left', ...
    'backgr',bg, ...
    'foregr','k');

% Indents for display/trace timing
pos1 = [pos(3)-112 1 110 17];
[hStatusBar.TraceInfo, hAll1] = makeStatusBarIndent(hfig,bg,pos1);
set(hStatusBar.TraceInfo,'string','u[0] : 0', ...
    'tooltip' ,['u[Data history index] : Time of data']);

pos2 = [pos(3)-225 1 110 17];
[hStatusBar.DataSizes, hAll2] = makeStatusBarIndent(hfig,bg,pos2);
set(hStatusBar.DataSizes,'string','N:0 U:0 H:0', ...
    'tooltip', ['N:Input elements' CR 'U:Update interval' CR 'H:History buffer']);

pos2 = [pos(3)-180-109 1 60 17];
[hStatusBar.XformMode, hAll3] = makeStatusBarIndent(hfig,bg,pos2);
set(hStatusBar.XformMode,'string','(XformMode)', ...
    'buttondownfcn', @bd_XformModeReadout, ...
    'tooltip', '(XformModeTip)');
set(hAll3,'buttondownfcn',@bd_XformModeReadout);

% Group all status bar widget handles together, for resizing:
hStatusBar.All = [hAll1 hAll2 hAll3];

fig_data.hStatusBar = hStatusBar;


% ----------------------------
% Invisible control for color testing
fig_data.testtext = uicontrol('parent', hfig, ...
    'vis','off', ...
    'style','text', ...
    'pos', [1 1 1 1]);

% ----------------------------
% Finish up:

% Record figure data:
set(hfig, 'UserData', fig_data);

% Resize 3-D display axes - leave bottom rectangle
set(hax,'pos',[0 0.1 1 .9]);

% First-time setup for attributes that normally only
% save/restore with the axis save/restore buttons
% (eg, special-case updating)
%
update_cam_view(hfig,params);
SetCurrentMouseMode(hfig,params);

% Make figure visible:
set(hfig,'vis','on');


% -------------------------------------------------------------------------
function [h, hall] = makeStatusBarIndent(hfig,bg,pos1)
hall(1)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos1, ...
    'backgr', bg, ...
    'foregr', [1 1 1]*.4);

pos2=pos1;
pos2(4)=1;
hall(2)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos2, ...
    'backgr', [1 1 1], ...
    'foregr', [1 1 1]);
pos2=[pos1(1)+pos1(3)-1 pos1(2) 1 pos1(4)];
hall(3)=uicontrol('parent',hfig, ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos2, ...
    'backgr', [1 1 1], ...
    'foregr', [1 1 1]);

hall(4) = uicontrol('parent',hfig, ...
    'style','text', ...
    'units','pix', ...
    'horiz','left', ...
    'fontweight','light', ...
    'fontsize',8, ...
    'pos',pos1+[2 2 -3 -3], ...
    'string', 'test', ...
    'backgr', bg, ...
    'foregr', [0 0 0]);
h=hall(4);  % main text widget

% ---------------------------------------------------------------
function [bd, fig_data] = verify_scope_figure(blk)
% VERIFY_SCOPE_FIGURE  Check existing scope window, bring it forward

% We want to confirm to a reasonable probability that
% the existing scope window is valid and can be restarted.
% Check data structures, handle validity, etc.
%
% On failure, resets figure handle in user data.
bd   = get_param(blk,'UserData');
hfig = bd.hfig;
try
   % Try to bring window forward
   % Error if hfig=[] or an invalid handle
   figure(hfig); 
   
   % Get the figure data - note that this will NOT fail,
   % even if hfig=[]
   fig_data = get(hfig,'UserData');
   
catch
   % Something failed - reset hfig to indicate error during restart:
   fig_data      = [];
   bd.hfig       = [];
   bd.hsurf      = [];
   bd.hdiscontig = [];
   set_param(blk, 'UserData', bd);
end


% =========================================================================
% Mouse modes: Select/Orbit/zoom
% Portions of code taken from cameratoolbar.m
% =========================================================================

% ---------------------------------------------------------------
function SetCurrentMouseMode(hfig,params)
% Given MouseMode state (Arrow|Orbit|Zoom),
% setup buttons and callbacks appropriately

switch params.MouseMode
    case 'Arrow',
        i=1;                  % index for turning on proper button
        MouseArrowMode(hfig); % install windowbutton callbacks
    case 'Orbit',
        i=2;
        MouseOrbitMode(hfig);
    case 'Zoom',
        i=3;
        MouseZoomMode(hfig);
end
fd = get(hfig,'userdata');
h = [fd.menu.buttons.MouseArrow  ...
     fd.menu.buttons.MouseOrbit ...
     fd.menu.buttons.MouseZoom];
set(h(i),'State','on');  % this one on
h(i)=[];
set(h,'State','off');    % all others off


% ---------------------------------------------------------------
function mode = GetGUIMouseMode(hfig)
% Determine which mouse-mode button is currently on
% (Ignores the dialog parameter setting)
fd = get(hfig,'UserData');
modeArrow = get(fd.menu.buttons.MouseArrow,'state');
modeOrbit = get(fd.menu.buttons.MouseOrbit,'state');
modeZoom  = get(fd.menu.buttons.MouseZoom, 'state');
if strcmp(modeArrow,'on')
    mode='Arrow';
elseif strcmp(modeOrbit,'on')
    mode='Orbit';
else
    mode='Zoom';
end

% ---------------------------------------------------------------
function MouseArrowModeCB(hcb, eventStruct)
hAllButtons=get(gcbo,'UserData');
set(hAllButtons(1),'state','on');  % don't allow un-clicking
set(hAllButtons(2:3),'state','off');
MouseArrowMode(gcbf);

function MouseArrowMode(hfig)
set(hfig,'WindowButtonDownFcn', '', ...
    'WindowButtonMotionFcn',    '', ...
    'WindowButtonUpFcn',        '');

% ---------------------------------------------------------------
function MouseOrbitModeCB(hcb, eventStruct)
hAllButtons=get(gcbo,'UserData');
set(hAllButtons(2),'state','on');
set(hAllButtons([1 3]),'state','off');
MouseOrbitMode(gcbf);

function MouseOrbitMode(hfig)
set(hfig,'WindowButtonDownFcn', {@CameraModeDown,1}, ...
    'WindowButtonMotionFcn', '', ...
    'WindowButtonUpFcn', '');

% ---------------------------------------------------------------
function MouseZoomModeCB(hcb, eventStruct)
hAllButtons=get(gcbo,'UserData');
set(hAllButtons(3),'state','on');
set(hAllButtons(1:2),'state','off');
MouseZoomMode(gcbf);

function MouseZoomMode(hfig)
set(hfig,'WindowButtonDownFcn', {@CameraModeDown,2}, ...
    'WindowButtonMotionFcn', '', ...
    'WindowButtonUpFcn', '');

% ---------------------------------------------------------------
function CameraModeDown(hcb, eventStruct, mode)
% mode 1=orbit, 2=zoom
hfig=gcbf;
set(hfig,'units','pixels');
pt = get(hfig, 'currentpoint'); pt = pt(1,1:2);
Udata.figStartPoint = pt;
Udata.figLastPoint  = pt;
Udata.buttondown = 1;
setappdata(hfig,'camera',Udata);
set(hfig, ...
    'WindowButtonMotionFcn', {@CameraModeMotion,mode}, ...
    'WindowButtonUpFcn',     {@CameraModeUp,mode});

% ---------------------------------------------------------------
function CameraModeMotion(hcb, eventStruct, mode)
% mode 1=orbit, 2=zoom

hfig=gcbf;
Udata=getappdata(hfig,'camera');
set(hfig,'units','pixels');
pt = get(hfig, 'currentpoint'); pt = pt(1,1:2);
deltaPix  = pt-Udata.figLastPoint;
deltaPixStart  = pt-Udata.figStartPoint;
Udata.figLastPoint = pt;
setappdata(hfig,'camera',Udata);

haxes=get(hfig,'CurrentAxes');
if mode==1,
	orbitGca(haxes,deltaPix);
else
	zoomGca(haxes,deltaPix);
end

% ---------------------------------------------------------------
function CameraModeUp(hcb, eventStruct, mode)
% mode 1=orbit, 2=zoom
set(gcbf,'WindowButtonDownFcn', {@CameraModeDown,mode}, ...
    'WindowButtonMotionFcn', '', ...
    'WindowButtonUpFcn',     '');

% ---------------------------------------------------------------
function orbitGca(haxes,xy)
xy = -xy;
d = [1 0 0];
up = camup(haxes);
upsidedown = (up(1) < 0);
if upsidedown,
    xy(1) = -xy(1);
    d = -d;
end
if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
    camup(haxes,d)
end
if sum(abs(xy))> 0,
    camorbit(haxes,xy(1), xy(2),'data','x');
    drawnow expose
end

% ---------------------------------------------------------------
function zoomGca(haxes,xy)
q = max(-.9, min(.9, sum(xy)/70));
camzoom(haxes,1+q);
drawnow expose

% ---------------------------------------------------------------
function c=crossSimple(a,b)
c(3) = b(2)*a(1) - b(1)*a(2);
c(2) = b(1)*a(3) - b(3)*a(1);
c(1) = b(3)*a(2) - b(2)*a(3);


% =========================================================================
% SAVE/RESTORE DISPLAY PROPERTIES
% =========================================================================

% ---------------------------------------------------------------
function cam_stuff = GetCamViewFromParams(params)
% Get the current camera view from param structure passed in to function
% If empty, default values are substituted.

if ~isempty(params),
    pu = params.CameraView;
else
    pu = [];
end

% cam_stuff = [cam_pos cam_tgt cam_up cam_view dar]
%   cam_pos: 3-element position
%   cam_tgt: 3-element target vector
%   cam_up: 3-element vector
%   cam_view: scalar
%   dar: data aspect ratio, scalar
if ~all(size(pu)==[1 13]),
    error('Default camera view not found');
end
cam_stuff = pu;


% -------------------------------------------------------------------------
function update_cam_view(hfig,params)
% Setup axis for 3-D view

fig_data = get(hfig,'UserData');
if nargin<2,
    % If params not supplied explicitly, take it from
    % the block's data cache:
    blk = fig_data.block;
    block_data = get_param(blk, 'UserData');
    params = block_data.params;
end

cam_stuff = GetCamViewFromParams(params);
set(fig_data.main.haxis, ...
     'cameraposition',       cam_stuff(1:3), ...
     'cameratarget',    cam_stuff(4:6), ...
     'cameraupvector',        cam_stuff(7:9), ...
     'cameraviewangle',      cam_stuff(10), ...
     'dataaspectratio', cam_stuff(11:13));

% ---------------------------------------------------------------
function SaveAxesToBlock(hcb, eventStruct)
% Save figure position and 3-D view to block dialog

hfig = gcbf;
SaveFigPosToBlock(hfig);
SaveCamViewToBlock(hfig);
SaveDimsHintToBlock(hfig);
SaveMouseModeToBlock(hfig);

% ---------------------------------------------------------------
function RestoreAxesFromBlock(hcb, eventStruct)
% Restore figure position and 3-D view from 
% the current block settings, overriding any
% manual (and unsaved) changes the user may have made
% to the display

hfig     = gcbf;
fig_data = get(hfig,'UserData');
blk      = fig_data.block;
params   = getWorkspaceVarsAsStruct(blk);
set(hfig, 'Position', params.FigPos);
update_cam_view(hfig,params);
SetCurrentMouseMode(hfig,params);

% No need to restore dimensions hint ... it's just used
% from the params entry as needed


% ---------------------------------------------------------------
function SaveMouseModeToBlock(hfig)
% Record the current mouse mode selection of the GUI
% into the block's mask
%
% One of the three buttons must be on,
% 'Arrow', 'Orbit', or 'Zoom'
if nargin<1, hfig = gcbf; end
fig_data = get(hfig,'UserData');
if isempty(fig_data), return; end

blkh = fig_data.block;
display_mode = GetGUIMouseMode(hfig);
dialog_mode = get_param(blkh,'MouseMode');

if ~isequal(display_mode, dialog_mode),
    set_param(blkh,'MouseMode',display_mode);
end

% ---------------------------------------------------------------
function SaveFigPosToBlock(hfig)
% Record the current position of the figure
% into the block's mask

% Get the block's name:
if nargin<1, hfig = gcbf; end

fig_data = get(hfig,'UserData');
if hfig ~= fig_data.hfig,
   error('Figure handle consistency error.');
end

% Get the fig position in pixels, as a string
fig_pos = mat2str(get(hfig,'Position'));

% Record the figure position, as a string, into the appropriate mask dialog:
blk = fig_data.block;
dialog_pos = get_param(blk,'FigPos');
if ~isequal(fig_pos, dialog_pos),
    % Record new position
    set_param(blk, 'FigPos', fig_pos);
end

% ---------------------------------------------------------------
function SaveCamViewToBlock(hfig)
% Record the current camera view into the block's mask

if nargin<1, hfig = gcbf; end

% Get the block's name:
fig_data = get(hfig,'UserData');

% If the figure was closed manually, and an unapplied
% change was pending, we might end up here with an
% empty figure handle:
if isempty(fig_data), return; end

blk = fig_data.block;
block_data = get_param(blk,'UserData');

% Get current camera view in axis:
hax = fig_data.main.haxis;

display_cam = get(hax, ...
    {'cameraposition','cameratarget','cameraupvector','cameraviewangle', 'dataaspectRatio'});
display_cam = cat(2,display_cam{:});

% Get last camera view from dialog:
dialog_cam = block_data.params.CameraView;

% Record the camera view, as a string, into the appropriate mask dialog:
if ~isequal(display_cam, dialog_cam),
    set_param(blk,'CameraView',mat2str(display_cam));
end


% ---------------------------------------------------------------
function SaveDimsHintToBlock(hfig)

if nargin<1, hfig = gcbf; end

% Get the block's name:
fig_data = get(hfig,'UserData');

% If the figure was closed manually, and an unapplied
% change was pending, we might end up here with an
% empty figure handle:
if isempty(fig_data), return; end

blk = fig_data.block;
block_data = get_param(blk,'UserData');

% Retrieve most recent history data
% Could be empty if model hasn't run yet
rec = HistorySvc('retrieve', block_data.HistoryID, 0);
if isempty(rec{1}),
    history_dims = [0 0];
else
    history_dims = size(rec{1}.Values);
end

% Get last dims hint from block:
dialog_dims = block_data.params.InportDimsHint;

% Record the dimensions hint into mask dialog:
if (prod(history_dims)~=0) && ~isequal(history_dims, dialog_dims),
    % History exists - extract and store dimensions
    set_param(blk,'InportDimsHint',mat2str(history_dims));
end


% =========================================================================
% BLOCK/DISPLAY MANAGEMENT
% =========================================================================

% ---------------------------------------------------------------
function BlockNameChange
% In response to the name change, we must do the following:
%
% (1) find the old figure window, only if the block had a GUI 
%     associated with it.
%     NOTE: Current block is parent of the S-function block
blk = gcbh;
bd = get_param(blk, 'UserData');
full_name = getfullname(blk);

% System might never have been run since loading.
% Therefore, block_data might be empty:
if ~isempty(bd.hfig),
   % (2) change name of figure window (cosmetic)
   set(bd.hfig, 'name', full_name);
   
   % (3) update figure's userdata so that the new blockname
   %     can be used if the figure gets deleted
   fig_data = get(bd.hfig,'UserData');
   fig_data.block = blk;
   set(bd.hfig,'UserData',fig_data);
end


% ---------------------------------------------------------------
function CloseFigure(hco, eventStruct, blk)
% Manual (programmatic) closing of the figure window
% Called by:
%      FigDelete   - user hit "x" on scope, manual close
%      BlockDelete - block deleted, not an explicit manual close of scope

block_data = get_param(blk,'UserData');
hfig       = block_data.hfig;
fig_data   = get(hfig,'UserData');

% Close parameter dialog, if open:
sdspwfall_params('CloseDialog',[],[],blk,1); % changes block_data
block_data = get_param(blk,'UserData');

% Don't reset the history recording function,
% we want to keep recording inputs
% block_data.HistoryRecFcn = @history_rec_skip;

% Reset the block's figure handle:
block_data.hfig          = [];
block_data.UpdateFcn     = @no_display_updates;
set_param(blk, 'UserData',block_data);

% Delete the window:
set(hfig,'DeleteFcn','');  % prevent recursion
delete(hfig);


% ---------------------------------------------------------------
function FigDelete(hcb,eventStruct,hfig)
% Callback from figure window
% Called when the figure is closed via the scope "x" button,
% or the scope "file->close" command, e.g., by manual, explicit
% closing by the user.  This signifies a change in state for the
% next time the model is loaded.
%
% We record this as an action not to open automatically when next
% the model loads.  That is, if the user saves the model after closing
% the block.  However, if the model is closed, the figure also
% receives a close command, but this time the user did not
% explicitly close the scope first, and we record that we
% wish to re-open the scope when the model loads next time.

if nargin<3, hfig = gcbf; end
fig_data = get(hfig,'UserData');
if isempty(fig_data) || (hfig ~= fig_data.hfig),
   error('Figure handle consistency error.');
end

% Close the figure window
CloseFigure([],[],fig_data.block);

% Update the block state so that it won't open the next time:
blk = fig_data.block;
bd = get_param(blk,'UserData');
dirty = get_param(bd.bdroot,'dirty');
set_param(blk,'OpenScopeAtSimStart','off');
set_param(bd.bdroot,'dirty',dirty);


% ---------------------------------------------------------------
function BlockDelete
% Block is being deleted from the model

% clear out figure's close function
% delete figure manually
blkh = gcbh;
block_data = get_param(blkh,'UserData');
if isstruct(block_data),
   CloseFigure([],[],blkh);
   
   % Tear down history service
   % If block never opened, field doesn't exist:
   HistorySvc('delete', block_data.HistoryID);
   
   % Remove all block data:
   set_param(blkh,'UserData', []);
end


% ---------------------------------------------------------------
function BlockCopy
% Block is being copied from the model


blkh = gcbh;
bd = get_param(blkh,'UserData');

if ~isempty(bd),
    % Lose any connection with source block's
    %   figure and param windows
    %
    % Only do this if bd was not empty.  If it was empty,
    % this code might have executed due to a copy of the 
    % original block from main library.  If we set just
    % these properties, some "isempty" tests may fail (in DialogApply,
    % for example), causing errors.
    bd.hfig           = [];
    bd.param_dlg.hfig = [];
    bd.HistoryID      = [];
    set_param(blkh, 'UserData', bd);
end

% ---------------------------------------------------------------
function bd = BlockLoad(blkh)
% Block is being loaded into model

if nargin<1, blkh = gcbh; end

% Initialize block data if this is not a library block
% Also initialize data for underlying s-function block
%
% NOTE: block_data not yet in place, no cached value of bdroot
isLibrary = strcmp(get_param(bdroot(blkh),'blockdiagramtype'),'library');
if isLibrary,
    bd=[];
    return;
end

bd = init_block_data(blkh);
bd.LoadPhase = 1;  % Loading
set_param(blkh,'UserData', bd);

% If block is to be opened at re-load, do it now:
if bd.params.OpenScopeAtSimStart,
    % we check for empty block_data, so we can distinguish the *first*
    % call (open scope at initial load time), from subsequent calls to
    % dialogapply from other changes to dialog.  Without the isempty
    % check, we would OpenScope for every mask change.
    OpenScope(blkh);
    
    % Get block data, which is empty if block never ran yet
    % Note: if scope was just opened, block data has changed,
    %       so do this after the call to OpenScope
    bd = get_param(blkh, 'UserData');
end
drawnow;  % must keep this or rendering will fail

bd.LoadPhase = 2;  % Loaded
set_param(blkh,'UserData', bd);

% ---------------------------------------------------------------
function BlockOpen
% Block was double-clicked, open scope

OpenScope(gcbh);


% ---------------------------------------------------------------
function BlockUndoDelete
% Block is being "reinstated" back into the model

BlockLoad(gcbh);


% =========================================================================
% Export and misc tools (zoom, grid, etc)
% =========================================================================

% ---------------------------------------------------------------
function AxisGrid(hcb,eventStruct,hfig,opt)
% Toggle setting of axis grid
%
% opt is a string option and may be one of the following:
%     'toggle', 'on', 'off'
% If not passed, default is 'toggle'.
%
% hfig is the figure handle
% if missing, it is set to gcbf

if nargin<4, opt='toggle'; end
if nargin<3, hfig=gcbf; end

fig_data  = get(hfig, 'UserData');
blk       = fig_data.block;
hopt      = fig_data.menu.axisgrid;

if strcmp(opt,'toggle'),
	% toggle current setting:
	if strcmp(get(hopt,'Checked'),'on'),
		opt='off';
	else
		opt='on';
    end
end

% Update block dialog setting, so param is recorded in model
% This will indirectly update the param structure, via the
% mask dialog callbacks.
set_param(blk, 'AxisGrid', opt);


% ---------------------------------------------------------------
function [data, sel_index] = GetExportDataset(blk)
% GetExportDataset
%   Returns with data set according to logging mode
%   sel_index is the column index into data corresponding
%     to the currently selected trace; if none is selected,
%     sel_index=1.  Depending on the logging mode, we may need
%     history offset and/or display offset to determine this.
%
%   LOGGING_MODE:
%     1: return all history data
%     2: return all visible data, that is, all data
%        visible in the current display, which may be
%        offset from 0 based on history slider
%     3: return single "leading" visible trace, which
%        may be offset from 0 based on history slider

% Get data:
bd = get_param(blk,'UserData');
fig_data = get(bd.hfig,'UserData');

% Determine start of display relative to history
history_offset = round(get(fig_data.history.slider, 'value'));

% Determine selected patch - if none selected, assume first
patch_offset = bd.SelectedTrace;
if patch_offset == -1,
    patch_offset=0;
end

switch bd.params.ExportMode
    case 'All history',
        % Get all history
        % First trace will be latest data
        %
        data = getProcessedHistoryValues(blk, bd);
        data = fliplr(cat(2,data{:}));
        
        % Returning all history
        % offset is history_offset plus display_offset
        sel_index = 1 + patch_offset + history_offset;
        
    case 'All visible',
        % Get all visible:
        %
        s = bd.hsurf;
        x = get(s,'xdata'); % get data from all traces
        data = cat(2,x{:});  % concatenate into matrix of data
        % Remove artificial "display" endpoints from data:
        data = data(2:end-1,:);
        
        sel_index = 1 + patch_offset;
        
    case 'Selected',
        % Get selected trace
        %
        selected_index = bd.SelectedTrace;
        if selected_index == -1,
            selected_index = 0;  % no selection? take first visible
        end
        s = bd.hsurf;
        x = get(s,'xdata'); % get data from all traces
        data = x{selected_index+1}; % convert from 0-based offset
        % Remove artificial "display" endpoints from data:
        data = data(2:end-1,:);
        
        sel_index = 1;
        
    otherwise
        error('Unsupported option: %s', bd.params.ExportMode);
end


% ---------------------------------------------------------------
function full_name = GetExportName(blkh)
% Compute variable name for export
% Used for SPTool and for MATLAB workspace
%
% Algorithm 1:
%       - take block name (not full Simulink path, just block)
%       - replace spaces and separator chars with underscores
%       - prepend the prefix chars from block mask
%       - if this is not legal, substitute a default name
%
% Algorithm 2:
%       - use user-supplied name as-is (not a prefix)

bd = get_param(blkh,'UserData');
user_name = deblank(bd.params.MLExportName);
alg = 2;

switch alg
    case 1,
        % Append block name to (base) variable name supplied by user
        %
        % Make valid variable name out of Simulink block name
        [z,block_name] = fileparts(getfullname(blkh));
        idx = find( (block_name==filesep) || isspace(block_name));
        block_name(idx) = '_';
        full_name = [user_name block_name];
    case 2,
        % Use user-supplied name as the variable name, as-is
        % Do not append the block name
        full_name = user_name;
end

% If name is not a valid variable, substitute a known (legal) default
% variable name:
if ~isvarname(full_name),
    full_name = 'DefaultExportVar';  % pick something legal
end

% Cannot check name for uniqueness here, since we don't know where it is
% being exported (MATLAB workspace, SPTool data manager, etc)


% ---------------------------------------------------------------
function SPToolExport(hcb, eventStruct, newName)
% Export data to SPTool Signal Browser

% Get the block's name:
hfig = gcbf;
fig_data = get(hfig,'UserData');
if hfig ~= fig_data.hfig,
   error('Figure handle consistency error.');
end
blk = fig_data.block;

UpdateStatusText(hfig,'Exporting...');

[data, sel_idx]  = GetExportDataset(blk);
label = GetExportName(blk);
Fs    = 1;  % assume 1 sample per sec within each trace

% Try invoking SPTool:
try
    % Load data into SPTool:
    %
    [sig_struc,sig_idx] = sptool('load','Signal',data,Fs,label);
    
    % Find sptool and sigbrowse, if open:
    %
    shh = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');
    sb_fig = findobj(0,'Tag','sigbrowse');
    sp_fig = findobj(0,'Tag','sptool');
    set(0,'showhiddenhandles',shh);
    
    % Open SigBrowse only if closed
    %
    % Repeated attempts will throw an error
    if isempty(sb_fig),  % sigbrowse not open
        sigbrowse('action','view');  % Alt: sptool('verb',1,1);
        sb_fig = findobj(0,'Tag','sigbrowse');
    end
    
    % Make sure exported signal is selected for display in SigBrowse
    % Several cases:
    %  1 - we just exported signal for the first time
    %      it's automatically selected
    %  2 - we re-exported signal, and it's still viewed
    %  3 - user selected one or more signals to view
    %      instead of or in addition to this one
    %  We make sure that the signal is selected
    %  If it is, we leave the display as-is and just get the
    %  signal index.  If it's not displayed, we select just this
    %  signal
    %
    % Turns out that we cannot allow an update to the signal
    % if it is selected along with other signals.  Bug occurs
    % where old signal *and* new signal appear.  So not only
    % must sig_idx be present in selected_signals, but it must
    % be the ONLY signal selected:
    [s,selected_signals] = sptool('Signals');
    if (length(selected_signals)~=1) || ~any(selected_signals == sig_idx),
        % Manually select signal
        ud = get(sp_fig,'userdata');
        component = 1;  % 'Signal' is always 1st component
        set(ud.list(component),'value',sig_idx);
        sptool('list', 0);
    end
    
    % If user has selected more than one signal to view in
    % sigbrowser, we want to be sure to select the right one.
    % Normally, our call to sigbrowse below wants a "relative"
    % index, that is, 1 would indicate the "first selected signal"
    % and 2 would indicate the "second selected signal".  But we
    % don't know which signals the user has selected.  Instead, we
    % send an "absolute" index, that is, the index of the signal
    % in the Signals object list.  To disambiguate these two cases,
    % we send negative values for absolute indices.
    if isempty(sig_idx),
        % First time viewer was opened, only one signal being viewed
        sig_idx = 1;
    else
        sig_idx = -sig_idx;
    end
    sigbrowse('show_ith_array_signal', sb_fig, sig_idx, sel_idx);

catch
    % Likely to be an invalid block name for variable
    err = lasterror;
    msg = err.message;
    i=find(msg==sprintf('\n'));
    if ~isempty(i),
        msg=msg(i+1:end);
    end
    errordlg(msg,'Export to SPTool','modal');
end

UpdateStandardStatusText(hfig);


% ---------------------------------------------------------------
function WorkspaceExport(hcb, eventStruct, blkh)
% Export data to MATLAB workspace

if nargin<3,
    % Determine block handle:
    hfig = gcbf;
    fig_data = get(hfig,'UserData');
    if hfig ~= fig_data.hfig,  % xxx Debug
        error('Figure handle consistency error.');
    end
    blkh = fig_data.block;
else
    bd = get_param(blkh,'UserData');
    hfig = bd.hfig;
end

UpdateStatusText(hfig,'Exporting...');

data = GetExportDataset(blkh);  % get dataset
varname = GetExportName(blkh);  % get variable name

% Check varname for uniqueness

assignin('base',varname,data);   % send it to base workspace

UpdateStandardStatusText(hfig);


% ---------------------------------------------------------------
function Autoscale(hcb, eventStruct, hfig)
%   Compute the min/max of all data in the history buffer,
%   and use it to reset the display limits.

if nargin<3, hfig=gcbf; end
fig_data = get(hfig, 'UserData');
blk = fig_data.block;
block_data = get_param(blk,'UserData');

% cell array of all data in history buffer:
y = getProcessedHistoryValues(blk, block_data);
y = cat(1,y{:});  % one long vector
ymin = min(y); ymin=ymin-.10*abs(ymin);  % 10% below
ymax = max(y); ymax=ymax+.10*abs(ymax);  % 10% above

if isnan(ymin),
    % No point trying to autoscale data if it's all NaN
    return;
end

% Protect against horizontal lines:
if (ymax==ymin),
   ymin=floor(ymin-.5);
   ymax=ceil(ymax+.5);
end

% Set new axis limits:
set_param(blk, ...
    'YMin',mat2str(ymin), ...
    'YMax',mat2str(ymax));
drawnow;
pause(0);
FitToView([],[],hfig);

% ---------------------------------------------------------------
function FitToView(hcb, eventStruct, hfig)

if nargin<3, hfig=gcbf; end
fig_data = get(hfig, 'UserData');
blk = fig_data.block;
bd = get_param(blk,'UserData');
hax = bd.haxis;

pbaspect(hax,'auto'); daspect(hax,'auto'); 
axis(hax,'vis3d')  % sets camva, pbaspect, and daspect to manual
camtarget(hax,[mean(get(hax,'xlim')) mean(get(hax,'ylim')) mean(get(hax,'zlim'))])
camva(hax,'auto');
camzoom(hax,0.875); % Zoom out a bit, compensating for the automatic axis defaults

% Always reset the camera orientation so X is up
% campos(hax,[1 0 0]);
% camup([1 0 0]);
% view([-90 -140]);


% ---------------------------------------------------------------
function HiliteBlock(hcb, eventStruct)
% Highlight the scope block in the model

hfig = gcbf;
fig_data = get(hfig,'UserData');
blkh = fig_data.block;

% I'd like to leave the block highlighted, then rely on Simulink
% to implement the usual de-select mechanism employed for the 
% "go to library block" functionality.  Currently, it's inaccessible.
%
% As a workaround, just blink the block a few times:
mode={'find','none'};
for i=0:5,
    s = mode{1+rem(i,2)};
    hilite_system(blkh,s);
    t0 = clock;
    while etime(clock,t0) < 0.125, end
end

% =========================================================================
% HISTORY / DATA LOGGING FUNCTIONS
% =========================================================================

% -------------------------------------------------------------------------
function y = SuppressTimeReadout(bd)
% Returns true if the time readout should be suppressed
% Rules:
%   - if simulation is running, suppress time readout,
%     it costs too much to update
%   - if sim stopped, or if suspend is on, don't suppress readout

sim_running = strcmp(get_param(bd.bdroot,'SimulationStatus'),'running');
suspend_on = strcmp(bd.params.Suspend,'on');
y = sim_running && ~suspend_on;


% -------------------------------------------------------------------------
function discontig_update_hilite(fig_data, patch_offset)
% patch_offset:
%   0, 1, 2, ... = Offset of selected patch, 0=newest
%  -1 = none selected (or de-select all)
%  if omitted, patch_offset defaults to currently selected patch
%
% discontig patches have UserData loaded with an integer
% index indicating patch offset from "latest", where latest = 0
% patch_offset = get(hpatch,'UserData');  % which patch, 0-based
% hpatch: handle to corresponding discontig patch (ribbon patch)


% patch_offset indicates the waterfall patch to highlight
% Find handle to surf corresponding to clicked patch
blk = fig_data.block;
bd = get_param(blk,'UserData');

% Set all waterfall surfs to normal linewidth to reset hilite:
set(bd.hsurf,'EdgeAlpha',.2,'linewidth',1);

if nargin<2,
    patch_offset = bd.SelectedTrace;
end

% Get history slider value, 0-based:
history_offset = round(get(fig_data.history.slider, 'value'));
hfirst = bd.hsurf(1);  % first trace of history displayed is here, by definition

% Set selected trace to a wide linewidth
%
if patch_offset>=0,  % -1 indicates no trace selected
    % Set selected trace to a wide linewidth
    hcurrent = bd.hsurf(patch_offset+1);
    set(hcurrent,'EdgeAlpha',1,'linewidth',1.5);
else
    hcurrent = bd.hsurf(1); % take 1st patch as default selected
end

if patch_offset >= 0,
    % display both Selected
    select_offset = -(patch_offset + history_offset);
    if SuppressTimeReadout(bd)
        readout_str = sprintf('u[%d]', select_offset);
        tip = ['Selected Trace' sprintf('\n') 'u[index]'];
    else
        select_time = get(hcurrent,'UserData');
        readout_str = sprintf('u[%d] : %g', ...
            select_offset, select_time);
        tip = ['Selected Trace' sprintf('\n') 'u[index] : time'];
    end
else
    % display first trace
    first_offset = -history_offset;
    if SuppressTimeReadout(bd)
        readout_str = sprintf('u[%d]', first_offset);
        tip = ['Display Offset' sprintf('\n') 'u[index]'];
    else
        first_time = get(hfirst,'UserData');
        readout_str = sprintf('u[%d] : %g', ...
            first_offset, first_time);
        tip = ['Display Offset' sprintf('\n') 'u[index] : time'];
    end
end
set(fig_data.hStatusBar.TraceInfo, ...
    'string',readout_str, ...
    'tooltip', tip);

% Update block_data to have selected trace:
bd.SelectedTrace = patch_offset;
set_param(blk,'UserData', bd);


% -------------------------------------------------------------------------
function discontig_buttondown(hpatch, eventStruct)
% hpatch: discontiguous-marker patch clicked by user
% Do several things here:
%    - highlight trace corresponding to selection
%    - highlight discontig patch
%    - display absolute time of trace
%
% Also, disables any current window[button/motion] functions,
% such as the camera menu callbacks, replacing it with its own.

hfig = gcbf;

% Quickly cache the old window[button/motion]fcns, and replace\
props = {'windowbuttondownfcn', ...
        'windowbuttonmotionfcn', ...
        'windowbuttonupfcn'};
newCallbacks = {'', @discontig_buttonmotion, @discontig_buttonup};
windowFcnsCache = get(hfig,props);
set(hfig, props, newCallbacks);  % set new properties

% Store old window*fcns in fig_data
fig_data = get(hfig, 'UserData');
fig_data.WindowFcnsCache = windowFcnsCache;
set(hfig,'UserData', fig_data);

% Is trace already selected?
% If not, select it - otherwise, de-select it
%
% discontig patches have UserData loaded with an integer
% index indicating patch offset from "latest", where latest = 0
patch_offset = get(hpatch,'UserData');  % which patch, 0-based
bd = get_param(fig_data.block,'UserData');
if bd.SelectedTrace == patch_offset,
    patch_offset = -1;  % same selected again -- de-select all
end
discontig_update_hilite(fig_data, patch_offset);

% debug: xxx
%cp = get(fig_data.main.haxis,'CurrentPoint');
%zcoord = cp(1,3);
%patchNum = round(zcoord);
%fprintf('down: z=%f, patchNum=%d, patch_offset=%d\n', ...
%    zcoord, patchNum, patch_offset);


% -------------------------------------------------------------------------
function discontig_buttonmotion(hcb, eventStruct)

hfig = hcb;
fig_data = get(hfig,'UserData');

%   what patch are we over?
%   likely not the original one we clicked on...
cp = get(fig_data.main.haxis,'CurrentPoint');
zcoord = cp(1,3);

% Convert between z-coord and corresponding patch
% Turns out, there's one patch per z-coord
% just "round"
patchNum = round(zcoord);

% Get discontig patch handles:
blk = fig_data.block;
bd = get_param(blk,'UserData');

% User is clicking anywhere along z-axis, including out-of-bounds
% Limit patch number to legal range:
numPatches = length(bd.hdiscontig);
if patchNum < 1,
    patchNum = 1;
elseif patchNum > numPatches,
    patchNum = numPatches;
end

% Get handle to corresponding discontig patch:
% Send it to hilite function:
hpatch = bd.hdiscontig(patchNum);
patch_offset = get(hpatch,'UserData');  % which patch, 0-based
discontig_update_hilite(fig_data, patch_offset);

% xxx debug
%fprintf('motion: z=%f, patchNum=%d, patch_offset=%d\n', ...
%    zcoord, patchNum, patch_offset);


% -------------------------------------------------------------------------
function discontig_buttonup(hpatch, eventStruct)

hfig = gcbf;
fig_data = get(hfig,'UserData');

% Grab the cached fcn callbacks:
windowFcnsCache = fig_data.WindowFcnsCache;

% clear out the cache so we maintain consistency/error checking:
fig_data.WindowFcnsCache = [];

% Restore old window*fcns in fig_data
props = {'windowbuttondownfcn', ...
        'windowbuttonmotionfcn', ...
        'windowbuttonupfcn'};
set(hfig,  ...
    props, {'','',''}, ...
    'UserData', fig_data);

% NOTE: Blank out the motion/up window fcns, and only
% reinstall the down function.  The down fcn is the only
% one that should have been installed, but since we 'snapped'
% the cache at the buttondown fcn, the windowbuttondown fcn
% already executed, populating the motion and up fcns.
set(hfig, props, {windowFcnsCache{1}, '', ''});


% -------------------------------------------------------------------------
function y = shouldEnableHistoryControl(blk, bd)
% Determines if history review controls (slider, etc)
%  should be enabled

isRunning = simIsRunning(bd.bdroot);
isSuspend = strcmp(bd.params.Suspend,'on');
isSnapshot = strcmp(bd.params.Snapshot,'on');
isOverwrite = strcmp(bd.params.HistoryFull,'Overwrite');
isSpecialSnapshot = isSnapshot && ~isOverwrite;

y  = ~isRunning || isSuspend || isSpecialSnapshot;

% If we're entering Special Snapshot mode,
%   clear out slider userdata, as it's used as a quick-and-dirty
%   index time-stamp to track time
% xxx

bd.isSpecialSnapshot = isSpecialSnapshot;
set_param(blk,'UserData', bd);

if isSpecialSnapshot,
    fig_data = get(bd.hfig,'UserData');
    pos = HistorySvc('getPos', bd.HistoryID);  % block
          HistorySvc('getPos', bd.HistoryID);  % unblock
          
    % pos is next available index
    set(fig_data.history.slider,'UserData', pos);
    
end


% -------------------------------------------------------------------------
function y = shouldVisibleHistoryControl(blk, block_data)
% Determines if history review controls (slider, etc)
%  should be visible in GUI

isNonzeroHistory = (block_data.HistoryLengthActual ~= 0);
y = isNonzeroHistory;


% -------------------------------------------------------------------------
function bd = setup_history_service(blkh, flushHistory)
% Setup history service
%
% Do this prior to calling starting_controls, because it
% ultimately causes a history lookup

if nargin<2,
    flushHistory = 1;  % assume flush (re-init)
end
bd = get_param(blkh,'UserData');

% Initialize "working" history length.  If we're opening the gui
% for the first time, and extend mode is on, then we preserve
% the current history length.  mdlInitializeSizes forces this to reset.
%
if isempty(bd.HistoryLengthActual) || ~strcmp(bd.params.HistoryFull,'Extend'),
    % not in extend mode, or first call
    % setup actual history length
    bd.HistoryLengthActual = bd.params.HistoryLength;
end

% Setup history-full function:
bd = set_buffer_full_fcn(blkh, bd);

% Setup/re-initialize history service and retain ID number:
% On scope-open event with running sim, we do NOT want to clear
% (eg, reinitialize) history info.
if isempty(bd.HistoryID) || flushHistory,
    % Total history length to record
    %    = # traces in one display
    %    + initial "excess" history length
    total_history = bd.params.NumTraces + bd.HistoryLengthActual;
    bd.HistoryID = HistorySvc('initialize', blkh, total_history);
end

% Reset transformed-input dimensions "hint" (indims)
%
% Get the latest dimensions from history data and put into
% block_data.indims, but only if there was actually some data.
% Otherwise, the existing defaults are still our best guess:
%
% Retrieve most recent history data
rec = HistorySvc('retrieve', bd.HistoryID, 0);
if isempty(rec) || isempty(rec{1});
    %  use last saved dims as a hint
    history_dims = bd.params.InportDimsHint;
else
    history_dims = size(rec{1}.Values);
end
bd.indims = history_dims;
set_param(blkh, 'UserData', bd);


% =========================================================================
% History-buffer full management
% =========================================================================

% --------------------------------------------------------------------
function bd = set_buffer_full_fcn(blkh, bd, history_full_setting)
% Setup fcn pointer to handle "history buffer full" condition

if nargin<2,
    bd = get_param(blkh,'UserData');
end
if nargin<3,
    % In case we're driving fcn directly from DialogApply,
    % we won't have bd.params set appropriately yet.  Instead
    % it's passed in as an arg:
    history_full_setting = bd.params.HistoryFull;
end
switch history_full_setting
    case 'Overwrite'
        fcn = @BufferFullOverwrite;
    case 'Extend'
        fcn = @BufferFullExtend;
    case 'Suspend'
        fcn = @BufferFullSuspend;
end
bd.BufferFullFcn = fcn;
set_param(blkh,'UserData', bd);

% --------------------------------------------------------------------
function BufferFullOverwrite(blkh)
% Allow circular buffering to overwrite old data
% (nothing to do!)

% --------------------------------------------------------------------
function BufferFullExtend(blkh)
% Extend history allocation when buffer fills
%
% Assumes buffer has reached full when called

% Extend the total history allocation
% Note that the total history allocation is the sum
% of numTraces and HistoryLengthActual, so we back-compute
% the new HistoryLengthActual from the total allocation size
% returned by HistorySvc.
%
% refresh block data, since we will re-save it shortly and
% don't want stale .LastTimeStamp data, etc:
bd = get_param(blkh,'UserData');
newLen = HistorySvc('extend', bd.HistoryID, bd.params.NumTraces);
bd.HistoryLengthActual = newLen - bd.params.NumTraces;
set_param(blkh, 'UserData', bd);
HistoryControlsSetLimits(blkh);

% --------------------------------------------------------------------
function BufferFullSuspend(blkh)
% Suspend history recording when buffer fills
%
% Assumes buffer has reached full when called

% pass blkh as eventStruct
% function will use that if GUI is not open
bd = get_param(blkh,'UserData');
SuspendDataCapture([],blkh,bd.hfig,'on')

% when suspend invoked due to buffer full,
% do not allow triggering to turn recording
% back on:
turn_off_triggering(blkh);

% =========================================================================
% end of buffer full functions
% =========================================================================


% --------------------------------------------------------------------
function [rec, buffer_filled] = history_rec_skip(blk, t, u)
% Do not record data - nop
rec = {[]};
buffer_filled = 0;

% --------------------------------------------------------------------
function [rec, buffer_filled] = history_rec(blk, t, u)
% Note: changes block_data

bd = get_param(blk,'UserData');

% Constructs a scalar record, rec
rec.Values = u;
rec.Time   = t;

% Determine which "set" of contiguous data to associate this input with
% Two sets, either the data is contiguous with the last input seen,
% or it is not.  We toggle the color of the contiguous patches when a
% newly discontiguous sequence is detected.
%
% The two sets are indexed by 1 and 2
if bd.Ts==-1,   % triggered system - always toggle the discontiguous set
    toggleDiscontigSet = 1;
else
    % discontiguous only if difference in time between
    % last time stamp and this one differs from Ts by
    % more than N*eps, where N is somewhat arbitrary:
    toggleDiscontigSet = ...
        abs((rec.Time - bd.LastTimeStamp) - bd.Ts) > rec.Time*eps;
end

if toggleDiscontigSet,
    % toggle set index from 1 to 2 or from 2 to 1
    rec.Discontig = 3 - bd.LastDiscontigSet;
    % Update block cache accordingly:
    bd.LastDiscontigSet = rec.Discontig;
else
    % Maintain same set index:
    rec.Discontig = bd.LastDiscontigSet;
end

% Update cache of last history time stamp:
bd.LastTimeStamp  = rec.Time;
set_param(blk, 'UserData', bd);

% Will be wrapped into a cell-array, even a scalar rec, before storing:
buffer_filled = HistorySvc('append', bd.HistoryID, rec);

rec = {rec};  % wrap for possible LHS return


% ---------------------------------------------------------------
function [rec,buffer_filled] = first_history_rec(blk, t, u)
% Check data, update dimensions, flush history
%
% If performing both first-history and first-display updates,
% do this first, so history will be setup prior to opening
% the display
%
% Note that we never display without record, so the checks
% for input port attributes and input dimensions changes
% only need to be present here, and not in first_display_update.
%
% Note: changes block_data

bd = get_param(blk,'UserData');

if ~isequal(bd.indims, size(u)),
    bd = update_indims(size(u), blk);
end

% Determine if input port is connected
% pc = get_param(blk,'portconnectivity');
% if pc.SrcBlock == -1,
%     % Block not connected
%     % xxx
%     UpdateStatusText(bd.hfig,'Scope not connected.');
% end

% Record dimensions of data coming into input port
% Not the history-input data dims ... that could differ
% due to the data transformation engine, etc.
block_dims = get_param(blk,'CompiledPortDimensions');
dimsStruct = block_dims.Inport;  % [numDims dim1 dim2 ...]
inNumDims = dimsStruct(1);
inDims    = dimsStruct(2:end);
if inNumDims==1,
    % 1-D input: make this a column vector for use in
    %   MATLAB code, i.e., force it to be Nx1 instead of N.
    %   Why? Many MATLAB fcns like "zeros(dims)" would produce
    %   an NxN result instead of Nx1, an incorrect interpretation.
    %   This is fundamentally because MATLAB does not have 1-D
    %   representations, while Simulink does.
    inDims = [inDims 1];
end
bd.InputPortDims = inDims;
bd.IsScalarInput = (prod(inDims)==1);

% Reset from special-case "first" to "normal" history record function
bd.HistoryRecFcn = @history_rec;

% Record sample time of block, removing offset to make it a scalar
Ts = get_param(blk,'CompiledSampleTime');
bd.Ts = Ts(1);

% Setup cache of latest history data, for quick recall:
% First recording of history will appear as discontiguous
bd.LastTimeStamp    = t;
bd.LastDiscontigSet = 1;  % index 1 or 2

set_param(blk, 'UserData', bd);  % Update block_data

if CheckInportAttributes(bd.InputPortDims),
    bd = DisplayDisable(blk, bd);
end

% Clear the history values:
% Do this before primary_open, since primary_open will update display based
% on stored history
HistorySvc('flush', bd.HistoryID);

% Record first data set in history buffer
[rec, buffer_filled] = history_rec(blk, t, u);


% -------------------------------------------------------------------------
function recs = getProcessedHistoryRecs(blk, block_data, buffIdx)
% Process uninitialized history items, marked as [], with vector of NaNs
% Returns a cell-array of structures (records)

% process history data
% basically, convert all []'s in history to vectors of NaNs

if nargin<3,
    % Get all history
    recs = HistorySvc('retrieve', block_data.HistoryID);
else
    % Get specific history items
    recs = HistorySvc('retrieve', block_data.HistoryID, buffIdx);
end

% Find all rec entries that are set to [] instead of an
% actual record/structure
empty_entries = cellfun('isempty',recs);
empty_idx     = find(empty_entries);

% any empties to process?
% If not, we're done!
if ~isempty(empty_idx),
    % there are entries that are empty
    
    % Determine a default for Values fields
    % Take the size of another non-empty rec, if one is available
    nonempty_idx = find(~empty_entries);   % are there non-empty entries?
    if isempty(nonempty_idx),
        % no non-empty records - take best-guess for dims
        def_siz = block_data.indims;
    else
        % at least one non-empty cell - take its dims
        def_siz = size(recs{nonempty_idx(1)}.Values);
    end
    
    % Construct default record to replace empty entries:
    default_rec.Time      = -Inf;
    default_rec.Values    = NaN*ones(def_siz);
    default_rec.Discontig = 1;
    
    % Replace empty-data entries with default:
    recs(empty_idx) = {default_rec};
end

% -------------------------------------------------------------------------
function data = getProcessedHistoryValues(varargin)
%
% getProcessedHistoryValues(blk, block_data)
% getProcessedHistoryValues(blk, block_data, buffIdx)

% Returns a cell-array of data entries
% No structures/records returned

rec = getProcessedHistoryRecs(varargin{:});
data = cell(1,length(rec));
for i = 1:length(rec),
    data{i} = rec{i}.Values;
end

% ---------------------------------------------------------------
function HistoryControlsSetToNewest(hfig)
% Set history slider to "newest" data
% Update display appropriately
%
% Value denotes number of inputs behind current input
% that first slice of display represents.  Zero is "latest."

if ~isempty(hfig),  % in case this gets called for a "closed scope"
    fig_data = get(hfig,'UserData');
    set(fig_data.history.slider,'value',0);
    HistorySliderUpdateAndDisplay(hfig, 0);
end

% ---------------------------------------------------------------
function HistorySliderCB(hcb, eventStruct)
% Manual interaction with slider
% hcb = gcbo: handle to current slider
HistorySliderUpdateAndDisplay(gcbf);

% ---------------------------------------------------------------
function HistorySliderUpdateAndDisplay(hfig, offset)
% Assume slider is already where it should be
% offset is a non-positive integer value (0, -1, -2, ...) indicating
% historical input relative to the most recent input.
%
% Update the slider tooltip, and then update the display
% corresponding to the appropriate history data

fig_data = get(hfig, 'UserData');

if nargin<2,
    % If an offset has not been passed, get latest from history slider:
    offset = round(get(fig_data.history.slider,'value'));
end

set(fig_data.history.slider, ...
       'tooltip', ['Display' sprintf('\n') 'Offset: ' num2str(-offset)]);
blk = fig_data.block;

% If snapshot is on, and we're not in wrap-mode (eg, extend or suspend),
% then we have enabled on the history slider - and this is a bit different
% in terms of "where to go next" when the slider is moved.
% Explanation:
%   In Suspend mode:
%      no more data is coming in, and offset 0 is the latest data
%      as we scroll, we are indexing the data relative to this stationary
%      point (stationary because no new data is coming in)
%
%   In "special snapshot" mode (eg, snapshot when not wrapping):
%      data is coming in, and offset 0 is now "travelling with the new
%      data".  Hence, a scroll change of even zero units (not that it
%      can happen) would cause the display to update, and all newest
%      data will enter the display.  Not what we want.  Instead, we want
%      a time-stationary scroll to occur.  Hence, we must compute how
%      many time instants have passed since the last display update,
%      then index into the data that far *just to achieve stationarity*.
%
%   Hence, we compute a make_up_time offset to fix this:
if nargin<2,
    % Only called from HistorySliderCB with one arg
    % xxx cache the "special_snapshot" mode flag, too intensive to compute
    %
    bd = get_param(blk,'UserData');
    %isSnapshot = strcmp(bd.params.Snapshot,'on');
    %isOverwrite = strcmp(bd.params.HistoryFull,'Overwrite');
    %isSpecialSnapshot = isSnapshot && ~isOverwrite;
    % if isSpecialSnapshot,
    if bd.isSpecialSnapshot,
        % We store a quick copy of the current history index
        % in the slider's user data ... note that when "special snapshot"
        % mode is entered/re-entered, this value must be reset to zero.
        
        % xxx
        % First, "block" any subsequent history append operations
        %    on this HistoryID
        pos = HistorySvc('getPos', bd.HistoryID);  % blocks thread
        orig_pos = get(fig_data.history.slider,'UserData');
        delta_time = pos-orig_pos;
        new_pos = offset+delta_time;
        UpdateDisplayWithHistory(blk, new_pos);  % zero=current, +ve=older
        pos = HistorySvc('getPos', bd.HistoryID);  % unblocks thread
    else
        UpdateDisplayWithHistory(blk, offset);
    end
else
    UpdateDisplayWithHistory(blk, offset);
end



% ---------------------------------------------------------------
function UpdateDisplayWithHistory(blk, offset)

% Retrieve most recent N data items from history
bd = get_param(blk, 'UserData');
fig_data = get(bd.hfig,'UserData');

if nargin<2,
    % If an offset has not been passed, get latest from history slider:
    offset = round(get(fig_data.history.slider,'value'));
end
recs = getProcessedHistoryRecs(blk, bd, ...
                           offset : offset+bd.params.NumTraces-1 );
update_wfall(blk, recs);

% Update readout:
discontig_update_hilite(fig_data);


% ---------------------------------------------------------------
function y = IsHistorySliderInteractive(hfig)
% The history slider is "interactive", i.e., capable of being
% manipulated manually, if it is visible and enabled:

fig_data = get(hfig,'UserData');
vals = get(fig_data.history.slider,{'visible','enable'});
y = all(strcmp('on',vals));


% ---------------------------------------------------------------
function HistoryControlsVisible(hfig,state)
% State: 'off' or 0: invisible,
%         'on' or 1: visible

% However, controls could still be DISABLED

fig_data = get(hfig,'UserData');
if ~ischar(state),
    if ~state, state='off';
    else       state='on';
    end
end
h=[fig_data.history.slider fig_data.history.labels fig_data.history.frame];
set(h,'visible',state);

% ---------------------------------------------------------------
function HistoryControlsSetLimits(blk)
% re-establish slider control limits
% does not change block data

bd   = get_param(blk,'userdata');
hfig = bd.hfig;

% If scope not open, get out:
if isempty(hfig), return; end

fig_data = get(hfig,'userdata');
value = get(fig_data.history.slider,'value');
% smax is not total buffer length, just "excess" history beyond NumTraces
smax  = bd.HistoryLengthActual; 
smin  = 0;
zero_history = (smax == 0);

% Need to reset slider value if 
%   sliderOffset (0,1,2,...) > new_HistoryLen (0,1,2,...)
%   or if history set to zero
if zero_history || (value > smax),
    HistoryControlsSetToNewest(hfig);
end

if ~zero_history,
    % Update and re-label slider:
    step = min([1 bd.params.NumTraces]./smax, 1);
    set(fig_data.history.slider, ...
        'min',smin, ...
        'max',smax, ...
        'sliderstep',step);
    set(fig_data.history.labels(1), 'string', num2str(smax));  % old
    set(fig_data.history.labels(2), 'string', num2str(smin));  % new
end


% ---------------------------------------------------------------
function HistoryControlsEnable(hfig,state)
% State: 'off' or 0: disable,
%         'on' or 1: enable

fig_data = get(hfig,'UserData');
if ~ischar(state),
    if ~state, state='off';
    else       state='on';
    end
end

%   - when stopping sim, history slider frame reappears
%       HG bug: enable frame off, then on with foregr=backgr=[.8 .8 .8]
%               if you set enable of frame on, foregr of frame goes to black
%               once you click slider(!), foregr of frame goes back to desired
%
% xxx Bug fix: don't include frame in enable code,
%     due to black-border problem
% h=[fig_data.history.slider fig_data.history.labels fig_data.history.frame];
h=[fig_data.history.slider fig_data.history.labels];
set(h,'enable',state);


% ------------------------------------------------------------
function update_history_controls(blkh)
% Update visiblity of history review scrollbar,
%   and the history record functions:

bd = get_param(blkh,'UserData');
HistoryControlsVisible(bd.hfig, shouldVisibleHistoryControl(blkh, bd));
HistoryControlsEnable( bd.hfig, shouldEnableHistoryControl( blkh, bd));


% ------------------------------------------------------------
function DisplayParameters(hcb, eventStruct, hfig)
% Bring up parameter dialog
% accessed from figure, so gcbf is valid

if nargin<3, hfig=gcbf; end
fig_data = get(hfig, 'UserData');
blk = fig_data.block;

sdspwfall_params('openDialog', blk);


% ------------------------------------------------------------
function CtrlT(hcb, eventStruct, bd)
% Ctrl+T pressed in GUI
% Send message back to Simulink window

if nargin<3,
    hfig = gcbf;
    fig_data = get(hfig,'UserData');
    blk = fig_data.block;
    bd = get_param(blk, 'UserData');
end

sys = bd.bdroot;
status = get_param(sys,'SimulationStatus');

% SimulationCommand options:
%   start, stop, pause, continue

switch status
    case 'stopped'
        set_param(sys,'SimulationCommand', 'start');
        
    case 'running'
        % Stop simulation
        set_param(sys,'SimulationCommand', 'stop');

  % case 'paused'
        % Simulink does not have Ctrl+T unpause a sim,
        % so we won't do that here:
        % set_param(sys,'SimulationCommand', 'continue');
end

% =========================================================================
% Triggering functions
% =========================================================================

% -------------------------------------------------------------------------
function turn_off_triggering(blkh)

bd = get_param(blkh,'UserData');
bd.TriggerFcn = @trigger_nop;
set_param(blkh,'UserData', bd);

% -------------------------------------------------------------------------
function suspend = set_trigger_start_fcn(blkh)
% Determine which triggering function to use
% in update loop.
%
% Returns flag indicating whether scope should startup
% in suspend mode

suspend = 1;
bd = get_param(blkh,'UserData');
switch bd.params.TrigStartMode
    case 'Immediately'
        % No begin-trigger
        suspend=0;
        sfcn = @trigger_nop;  % dummy entry
        
    case 'After T seconds'
        sfcn = @trigger_start_T;
        % Don't suspend if zero time/count:
        suspend = (bd.params.TrigStartT > 0);
        
    case 'After N inputs'
        sfcn = @trigger_start_N;
        suspend = (bd.params.TrigStartN > 0);
        
    case 'User-defined'
        bd.TriggerData.UserFcn = str2func(bd.params.TrigStartFcn);
        sfcn = @trigger_start_fcn;
end
t0 = get_param(bd.bdroot,'SimulationTime');
bd.TriggerFcn = sfcn;
bd.TriggerData.Cnt = 0;
bd.TriggerData.LastTimeStamp = t0;
set_param(blkh,'UserData', bd);

if ~suspend,
    % no start trigger, make sure a stop trigger doesn't get ignored
    set_trigger_stop_fcn(blkh,t0);
end

% -------------------------------------------------------------------------
function trigger_init(blkh)
% Initialize/setup trigger callback functions
if set_trigger_start_fcn(blkh),
    SuspendDataCapture([],blkh,[],'on');
end

% -------------------------------------------------------------------------
function trigger_nop(blkh,t,u)
% no trigger

% -------------------------------------------------------------------------
function set_trigger_stop_fcn(blkh,t)
bd = get_param(blkh,'UserData');
switch bd.params.TrigStopMode
    case 'Never'
        sfcn = @trigger_nop;
    case 'After T seconds'
        if isinf(bd.params.TrigStopT),
            sfcn = @trigger_nop;
        else
            sfcn = @trigger_stop_T;
        end
    case 'After N inputs'
        if isinf(bd.params.TrigStopN),
            sfcn = @trigger_nop;
        else
            sfcn = @trigger_stop_N;
        end
    case 'User-defined'
        bd.TriggerData.UserFcn = str2func(bd.params.TrigStopFcn);
        sfcn = @trigger_stop_fcn;
end
bd.TriggerFcn = sfcn;
bd.TriggerData.LastTimeStamp = t;
bd.TriggerData.Cnt = 0;
set_param(blkh,'UserData',bd);

% -------------------------------------------------------------------------
function trigger_start_T(blkh,t,u)

bd = get_param(blkh,'UserData');
if t >= bd.TriggerData.LastTimeStamp + bd.params.TrigStartT,
    set_trigger_stop_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'off');
    UpdateStandardStatusText(bd.hfig);
end

% -------------------------------------------------------------------------
function trigger_start_N(blkh,t,u)

bd = get_param(blkh,'UserData');
bd.TriggerData.Cnt = bd.TriggerData.Cnt + 1;
set_param(blkh,'UserData', bd);

if bd.TriggerData.Cnt >= bd.params.TrigStartN,
    set_trigger_stop_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'off');
    UpdateStandardStatusText(bd.hfig);
end

% -------------------------------------------------------------------------
function trigger_start_fcn(blkh,t,u)

bd = get_param(blkh,'UserData');
if feval(bd.TriggerData.UserFcn, blkh, t, u),
    set_trigger_stop_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'off');
    UpdateStandardStatusText(bd.hfig);
end

% -------------------------------------------------------------------------
function set_trigger_rearm_fcn(blkh,t)

bd = get_param(blkh,'UserData');
switch bd.params.TrigRearmMode
    case 'Never'
        sfcn = @trigger_nop;
    case 'After T seconds'
        if isinf(bd.params.TrigRearmT),
            sfcn = @trigger_nop;
        else
            sfcn = @trigger_rearm_T;
        end
    case 'After N inputs'
        if isinf(bd.params.TrigRearmN),
            sfcn = @trigger_nop;
        else
            sfcn = @trigger_rearm_N;
        end
    case 'User-defined'
        bd.TriggerData.UserFcn = str2func(bd.params.TrigRearmFcn);
        sfcn = @trigger_rearm_fcn;
end
bd.TriggerFcn = sfcn;
bd.TriggerData.LastTimeStamp = t;
bd.TriggerData.Cnt = 0;
set_param(blkh,'UserData', bd);

% -------------------------------------------------------------------------
function trigger_stop_T(blkh,t,u)

bd = get_param(blkh,'UserData');
if t >= bd.TriggerData.LastTimeStamp + bd.params.TrigStopT,
    set_trigger_rearm_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'on');
end

% -------------------------------------------------------------------------
function trigger_stop_N(blkh,t,u)

bd = get_param(blkh,'UserData');
bd.TriggerData.Cnt = bd.TriggerData.Cnt + 1;
set_param(blkh,'UserData', bd);

if bd.TriggerData.Cnt >= bd.params.TrigStopN,
    set_trigger_rearm_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'on');
end

% -------------------------------------------------------------------------
function trigger_stop_fcn(blkh,t,u)

bd = get_param(blkh,'UserData');
if feval(bd.TriggerData.UserFcn, blkh, t, u),
    set_trigger_rearm_fcn(blkh,t);
    SuspendDataCapture([],blkh,[],'on');
end

% -------------------------------------------------------------------------
function trigger_rearm_T(blkh,t,u)

bd = get_param(blkh,'UserData');
if t >= bd.TriggerData.LastTimeStamp + bd.params.TrigRearmT,
    if ~set_trigger_start_fcn(blkh);
        SuspendDataCapture([],blkh,[],'off');
    end
end

% -------------------------------------------------------------------------
function trigger_rearm_N(blkh,t,u)

bd = get_param(blkh,'UserData');
bd.TriggerData.Cnt = bd.TriggerData.Cnt + 1;
set_param(blkh,'UserData', bd);

if bd.TriggerData.Cnt >= bd.params.TrigRearmN,
    if ~set_trigger_start_fcn(blkh),
        SuspendDataCapture([],blkh,[],'off');
    end
end

% -------------------------------------------------------------------------
function trigger_rearm_fcn(blkh,t,u)

bd = get_param(blkh,'UserData');
if feval(bd.TriggerData.UserFcn, blkh, t, u),
    if ~set_trigger_start_fcn(blkh,t),
        SuspendDataCapture([],blkh,[],'off');
    end
end

% -------------------------------------------------------------------------
function y = trigger_options_changed(bd, params)
% Determine if any triggering options have changed

%        .TrigStartMode: popup, literal
%               'Immediately|After T seconds|After N inputs|User-defined'
%        .TrigStartT     edit box, eval
%        .TrigStartN     edit box, eval
%        .TrigStartFcn   edit box, literal
%        .TrigStopMode   popup, literal
%               'Never|After T seconds|After N inputs|User-defined'
%        .TrigStopT      edit box, eval
%        .TrigStopN      edit box, eval
%        .TrigStopFcn    edit box, literal
%        .TrigRearmMode  popup, literal
%               'Never|After T seconds|After N inputs|User-defined'
%        .TrigRearmT      edit box, eval
%        .TrigRearmN      edit box, eval
%        .TrigRearmFcn    edit box, literal

% Get field names of dialog parameters structure
f = fieldnames(bd.params);

% Detect differences between all other fields
idx = strmatch('Trig', f);  % trig-related fields all start with "Trig"
TrigOpts = f(idx);          % cell array of trigger-related fields

% Remove TriggerProperties field, since a change in this
% "display tab/checkbox" does not influence triggering
idx = strmatch('TriggerProperties',TrigOpts);
TrigOpts(idx)=[];

y = 0;  % assume no differences between params and bd.params
for i=1:length(TrigOpts),
    v1 = bd.params.(TrigOpts{i});
    v2 = params.(TrigOpts{i});
    if ~isequal(v1,v2),
        y=1;
        return
    end
end


% =========================================================================
% Data transformation services
% =========================================================================

% -------------------------------------------------------------------------
function bd = xform_init(blkh, isRunning)
% Initialize/setup data transformation callback function
% Note that this could change the (transformed) data dimensions

bd = set_xform_fcn(blkh);

% Now check for a run-time change in dims out of the XformFcn
if isRunning,
    s=warning;
    warning off
    inU  = zeros(bd.InputPortDims);  % synthetic input data
    outU = feval(bd.XformFcn, inU);  % mimic mdlUpdate invocation
    if size(outU,1)==1, outU=outU(:); end
    warning(s);
    
    % .indims caches the dimensions of the data entering
    % the history rec function ... hence, it is the dimensions
    % of the data output from the transformation function itself
    if ~isequal(bd.indims, size(outU)),
        % update display for change in data dims
        disp('Transformed data dimensions have changed.');  % xxx
        
        % Need to call this explicitly, even though setup_axes is next
        % That's because we want to clear the history, change .indims, etc
        update_indims(size(outU),blkh);
        % update_status_bar - no need if followed by setmenuchecks
        % set_param(blk,'userdata',bd);
    end
end


% -------------------------------------------------------------------------
function y = xform_options_changed(bd, params)
% Determine if any transform options have changed

y = 0;
if ~isequal(bd.params.XformMode, params.XformMode),
    y=1; return;
end
if strcmp(params.XformMode,'User-defined fcn');
    if ~isequal(bd.params.XformFcn, params.XformFcn),
        y=1; return;
    end
end
if strcmp(params.XformMode,'User-defined expr');
    if ~isequal(bd.params.XformExpr, params.XformExpr),
        y=1; return;
    end
end

% -------------------------------------------------------------------------
function bd = set_xform_fcn(blkh)
% Set appropriate transformation function

bd = get_param(blkh,'UserData');
switch bd.params.XformMode
    case 'None'
        bd.XformFcn = @no_xform_fcn;
    case 'Amplitude->dB'
        bd.XformFcn = @xform_cplx_mag_db;
    case 'Complex->Mag Lin'
        bd.XformFcn = @xform_cplx_mag_lin;
    case 'Complex->Mag dB'
        bd.XformFcn = @xform_cplx_mag_db;
    case 'Complex->Angle'
        bd.XformFcn = @xform_cplx_angle;
    case 'FFT->Mag Lin Fs/2'
        bd.XformFcn = @xform_fft_mag_lin;
    case 'FFT->Mag dB Fs/2'
        bd.XformFcn = @xform_fft_mag_db;
    case 'FFT->Angle Fs/2'
        bd.XformFcn = @xform_fft_angle;
    case 'Power->dB'
        bd.XformFcn = @xform_pwr_db;
        
    case 'User-defined fcn'
        % Get function handle and validate that function exists:
        % Checking done in CheckParams
        bd.XformFcn = str2func(bd.params.XformFcn);
        
    case 'User-defined expr'
        % Create inline function from expression
        % Checking done in CheckParams
        %
        % Inline functions don't handle indexing, such as "u(1:2:end)"
        % bd.XformFcn = inline(bd.params.XformExpr);
        %
        % EvalExpr objects handle indexing:
        bd.XformFcn = evalExpr(bd.params.XformExpr);
end

set_param(blkh,'UserData', bd);


% -------------------------------------------------------------------------
function y = no_xform_fcn(u)
% No data transformation
y=u;

% -------------------------------------------------------------------------
function y = xform_cplx_mag_lin(u)
y = abs(u);

% -------------------------------------------------------------------------
function y = xform_cplx_mag_db(u)
% 20*log10(x) = 20*log2(x)/log2(10) = 6.02*log2(x)
y = 6.02059991327962 .* log2(abs(u));

% -------------------------------------------------------------------------
function y = xform_cplx_angle(u)
y = angle(u);

% -------------------------------------------------------------------------
function y = xform_fft_mag_lin(u)
% View FFT results, positive spectrum only, in dB
% 20*log10(x) = 20*log2(x)/log2(10) = 6.02*log2(x)
y = abs(u(1:floor(length(u)/2+1)));

% -------------------------------------------------------------------------
function y = xform_fft_mag_db(u)
% View FFT results, positive spectrum only, in dB
% 20*log10(x) = 20*log2(x)/log2(10) = 6.02*log2(x)
y = 6.02059991327962 .* log2(abs(u(1:floor(length(u)/2+1))));

% -------------------------------------------------------------------------
function y = xform_fft_angle(u)
% View FFT results, positive spectrum only, in radians
y = angle(u(1:floor(length(u)/2+1)));

% -------------------------------------------------------------------------
function y = xform_pwr_db(u)
% 10*log10(x) = 10*log2(x)/log2(10) = 3.01*log2(x)
y = 3.01029995663981 .* log2(abs(u));

% =========================================================================
% Custom color maps
% =========================================================================
function rgb = red(N)
rgb = repmat([1 0 0],N,1);

function rgb = white(N)
rgb = repmat([1 1 1],N,1);

% ------------------------------------------------------------
% [EOF] $File: $
