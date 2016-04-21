function sdspwfall_params(varargin)
%SDSPWFALL_PARAMS Waterfall display parameter dialog.
%   SDSPWFALL_PARAMS('openDialog', blk) opens the dialog,
%   where BLK is the current scope block.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/11/14 02:47:06 $


feval(varargin{:});

% Parameters in user data of parameter dialog figure window:
% -------------------------------------------------------------------------
%   fig_data.block
%   fig_data.hfig
%      handle to dialog figure window (duplicate of block_data.hfig)
%
%  handles to parameter dialog controls:
%   fig_data.hDlgs.NumTraces
%   fig_data.hDlgs.YMin
%   fig_data.hDlgs.YMax
%   fig_data.hDlgs.CMapStr
%                 .ExportMode
%                 .MLExportName (prefix)
%   fig_data.hDlgs.XLabel
%   fig_data.hDlgs.YLabel
%   fig_data.hDlgs.ZLabel
%   fig_data.hDlgs.HistoryLength
%                 .UpdateInterval
%   fig_data.hDlgs.SyncSnapshots
%   fig_data.hDlgs.TNewest
%   fig_data.hDlgs.TOldest
%   fig_data.hDlgs.Trig***
%
%   fig_data.transp.Slider_TOldest   handle to transparency
%           .transp.Slider_TNewest   sliders (two total)
%
%
% Parameters in block_data specific to parameter dialog:
% -------------------------------------------------------------------------
%   block_data.param_dlg.hfig
%      handle to dialog figure window (duplicate of fig_data.hfig)
%   block_data.param_dlg.pos
%   block_data.param_dlg.tabNum

% -------------------------------------------------------------------------
function openDialog(blk)
% Open or re-open dialog

% Construct new param dialog figure window, or bring up old one:

bd = get_param(blk, 'UserData');  % get block_data
hfig = bd.param_dlg.hfig;

if ~isempty(hfig),
    if ishandle(hfig),
        try,
            figure(hfig);  % bring dialog forward
            fig_data = get(hfig,'UserData');
        catch
            hfig = [];
            fig_data = [];
        end
    end
end

if isempty(hfig),
    % Initialize new figure window:
    % Create the dialog GUI
    fig_data = create_dialog_invis(blk);
    hfig = fig_data.hfig;
    reopen_existing = 0;
else
    reopen_existing = 1;
end

% Update dialog with current values:
refresh_dialog(hfig);  % handle to dialog figure

% Store persistent param-dialog data in block
% Dialg figure handle, and dialog position
%
bd.param_dlg.hfig = hfig;
set_param(blk, 'UserData', bd);  % Update block_data

if ~reopen_existing,
    % Need block data setup appropriately before proceeding

    % Set default values:
    bd.param_dlg.pos = GetParamWindowPos(blk);
    if bd.param_dlg.tabNum == -1,
        bd.param_dlg.tabNum = 1;
    end
    
    set_param(blk, 'UserData', bd);  % Update block_data
    
    % Update position
    set(hfig, 'pos', bd.param_dlg.pos);
    % We set the open tab later on in this fcn...
end

% Calling SetDialogTab doesn't make visible the tab contents
% the first time around.  tabdlg processes the change and determines
% that no change in tab occured, and thus doesn't kick off the
% callback function -- hence, no visibility of the tab (nor would
% we expect to find the right tab contents opened, either)
%
SetDialogTab(hfig,bd.param_dlg.tabNum);
set([fig_data.hPanels{:}],'vis','off'); % turn all tabs off
set(fig_data.hPanels{bd.param_dlg.tabNum},'vis','on');  % set one on
refresh_dialog_trigger(hfig,[],bd.param_dlg.tabNum); % handle dynamic dialog tabs
refresh_dialog_xform(  hfig,[],bd.param_dlg.tabNum); % handle dynamic dialog tabs

% Show the dialog:
set(hfig,'vis','on');


% ---------------------------------------------------------------
function CloseDialog(hco, eventStruct, blk, parentClose)
% Manual (programmatic) closing of the figure window
%
% NOTE: Could be called even when dialog not open

block_data = get_param(blk,'UserData');
hfig       = block_data.param_dlg.hfig;

if isempty(hfig),
    return  % dialog not open
end

% Reset the essential param window data:
block_data.param_dlg.hfig = [];  % no param figure anymore

% Note: do NOT clear out the param dialog position
%       when we close the param dialog.  We want to
%       keep the position for the next dialog opening.
%
%       * If parent is closing, flag is passed in.
%         Pos gets cleared only when the parent scope closes.
%       * When we close without the parent closing, update our position
%         so a re-open occurs wherever we've last left the dialog
%       
if nargin<4, parentClose=0; end
if parentClose,
    block_data.param_dlg.pos    = [];
    block_data.param_dlg.tabNum = -1;
else
    block_data.param_dlg.pos = get(hfig,'pos');
    % block_data.param_dlg.tabNum is always updated by callback
end
set_param(blk, 'UserData',block_data);

% Delete the window:
set(hfig,'DeleteFcn','');  % prevent recursion
delete(hfig);


% ---------------------------------------------------------------
function DialogDelete(hcb, eventStruct)
% Callback from figure window
% Called when the figure is closed or deleted

hfig = gcbf;
fig_data = get(hfig,'UserData');
if isempty(fig_data) || (hfig ~= fig_data.hfig),
   error('Figure handle consistency error.');
end

% Close the figure window
CloseDialog([],[],fig_data.block);


% -------------------------------------------------------------------------
function pos = GetParamWindowPos(blk, default)
% Determine the position for the parameter dialog
%
% Rules when re-opening the parameter dialog:
%   - default position is to center dialog over the scope window;
%     first time dialog is opened, it is in the default position
%   - if the user does not move the dialog, it stays in the position
%     it first opened as long as the parent scope remains open;
%     it does NOT "follow" the scope window (eg, dialog does not
%     re-open centered over the scope if the scope moved)
%   - if the dialog is moved, the new position is used for subsequent
%     opens of the dialog, as long as the parent remains open
%   - if parent scope is closed, dialog position returns to default
%     next time it is opened

% If default flag not passed in, assume that we're
% not resetting to the default position:
if nargin<2, default=0; end

block_data = get_param(blk,'userdata');

if default,
    % Calculate default position
    % dialog extent is [375 210]
    
    % Get scope window pos:
    scope_pos = get(block_data.hfig,'position');
    
    % Get current param window pos
    % We want the extent, not the origin:
    dialog_pos = get(block_data.param_dlg.hfig,'pos');
    
    % Now figure out new origin for dialog:
    scope_origin   = scope_pos(1:2);
    scope_delta    = scope_pos(3:4);
    scope_midpoint = scope_origin + scope_delta/2;
    dialog_delta   = dialog_pos(3:4);
    dialog_origin  = scope_midpoint - dialog_delta/2;

    pos = [dialog_origin dialog_delta];
    
else
    % Apply general rules
    
    % Check parent block's field
    pos = block_data.param_dlg.pos;
    if isempty(pos),
        % Get default state:
        pos = GetParamWindowPos(blk,1);
    end
end


% -------------------------------------------------------------------------
function DialogKeypress(hcb, eventStruct)
% Handle keypresses in dialog window

hfig = gcbf;  % handle to dialog
key = get(hfig, 'CurrentChar');

fig_data = get(hfig,'UserData');
bd = get_param(fig_data.block,'UserData');
currentTab = bd.param_dlg.tabNum;
numTabs = length(fig_data.tabStrings);

if ~isempty(key), % unix keyboard has an empty key
    switch key
        case char(13)  % Enter
            DialogDelete(hfig, eventStruct);  % Close dialog
            
        case {char(28), char(30)}, % left, up
            % Move to next tab to the left
            newTab = currentTab-1;
            if (newTab == 0) newTab=numTabs; end
            SetDialogTab(hfig, newTab);
            
        case {char(29), char(31)}, % right, down
            % Move to next tab to the right
            newTab = currentTab+1;
            if (newTab > numTabs), newTab=1; end
            SetDialogTab(hfig, newTab);
            
        case char(20),
            % Ctrl+T
            sdspwfall([],[],[],'CtrlT',[],[],bd);
            
        otherwise,
            % See if scope window handles this key
            % hFigScope = bd.hfig;  % figure to scope window
            % sdspwfall([],[],[],'ScopeKeypress',[],[],hFigScope,key);
            % fprintf('sdspwfall_params: keypress="%d"\n', key);
    end
end

% -------------------------------------------------------------------------
function refresh_dialog_from_blk(blk,varargin)
% Update param dialog, knowing handle to block
% Optionally pass params in manually, for reverting dialog, etc
%
% NOTE: Param dialog might not be open; if so, exit without update

bd = get_param(blk,'UserData');
refresh_dialog(bd.param_dlg.hfig, varargin{:});

% -------------------------------------------------------------------------
function params = getDialogParamsAsCell(hfig)
% Formulate cell array of parameters,
%   {'name1', value1, 'name2', value2, ...}
%
% Note on values:
%   We use the actual mask dialog to evaluate parameter values,
%   as it has the infrastructure necessary to evaluate params
%   in the context of the mask workspace.

fig_data = get(hfig,'UserData');
hDlgs = fig_data.hDlgs;  % get structure of handles
blk = fig_data.block;

% Formulate cell array of parameters,
%   {'name1', value1, 'name2', value2, ...}
dlg_names = fieldnames(hDlgs);
dlg_vals = {};
for i=1:length(dlg_names),
    param_name = dlg_names{i};
    hDlg = getfield(hDlgs, param_name);

    % Default dialog handler:
    switch get(hDlg,'style')
        case 'edit'
            x = get(hDlg, 'string'); % get string representation
            
        case 'popupmenu'
            v = get(hDlg, 'value');  % index
            s = cellstr(get(hDlg,'string'));
            x = s{v};  % get selected popup string
            
        case 'checkbox'
            v = get(hDlg,'value'); % value 0, 1, as a string
            if v==0, x='off';
            else x='on';
            end
            
        otherwise
            error('unhandled dialog style');
    end
    dlg_vals = [dlg_vals; {x}];
end
params = [dlg_names dlg_vals]';
params = params(:);


% -------------------------------------------------------------------------
function s = getDialogParamsAsStruct(hfig)

c = getDialogParamsAsCell(hfig);
p = c(1:2:end);
v = c(2:2:end);
s = cell2struct(v,p,2);


% -------------------------------------------------------------------------
function update_dialog(hcb,eventStruct,hfig)
% Respond to a change in parameter values made to the param dialog itself

if nargin<3, hfig=gcbf; end
fig_data = get(hfig,'UserData');
blk = fig_data.block;
pv  = getDialogParamsAsCell(hfig);
set_param(blk,pv{:});


% -------------------------------------------------------------------------
function refresh_dialog_xform(hfigDlg, eventStruct, tabNum)
% Dynamic dialog updates to Transforms panel
% Called from refresh_dialog

% No dialog to refresh?
if isempty(hfigDlg), return; end
dlg_fig_data = get(hfigDlg,'UserData');  % dialog figure data
bd = get_param(dlg_fig_data.block,'UserData');

% Are we on the Trigger page?
if nargin<3,
    tabNum = bd.param_dlg.tabNum;
end
if tabNum ~= 5, return; end

hd = dlg_fig_data.hDlgs;
hp = dlg_fig_data.hPrompts;

% Process dynamic dialog for TRANSFORM MODE
hModePrompts = [hp.XformFcn hp.XformExpr];
hModeDialogs = [hd.XformFcn hd.XformExpr];
switch bd.params.XformMode,
    case 'User-defined fcn', i=1;
    case 'User-defined expr', i=2;
    otherwise, i=0;
end
set(hModePrompts,'ena','off');     % Turn all Start-dialogs off
set(hModeDialogs,'ena','off');
if i>0,
    set(hModePrompts(i),'ena','on');   % Turn on one Mode-dialog pair
    set(hModeDialogs(i),'ena','on');
end


% -------------------------------------------------------------------------
function refresh_dialog_trigger(hfigDlg, eventStruct, tabNum)
% Dynamic dialog updates to Trigger panel
% Called from refresh_dialog, ultimately triggered by DialogApply 

% No dialog to refresh?
if isempty(hfigDlg), return; end
dlg_fig_data = get(hfigDlg,'UserData');  % dialog figure data
bd = get_param(dlg_fig_data.block,'UserData');

% Are we on the Trigger page?
if nargin<3,
    tabNum = bd.param_dlg.tabNum;
end
if tabNum ~= 4, return; end

hd = dlg_fig_data.hDlgs;
hp = dlg_fig_data.hPrompts;

%
% Process dynamic dialog for START trigger
%
hStartPrompts = [hp.TrigStartT hp.TrigStartN hp.TrigStartFcn];
hStartDialogs = [hd.TrigStartT hd.TrigStartN hd.TrigStartFcn];
switch bd.params.TrigStartMode
    case 'Immediately',     i=0;
    case 'After T seconds', i=1;
    case 'After N inputs',  i=2;
    case 'User-defined',    i=3;
    otherwise, error('Unrecognized trigger mode.');
end
set(hStartPrompts,'vis','off');     % Turn all Start-dialogs off
set(hStartDialogs,'vis','off');
if i>0,
    set(hStartPrompts(i),'vis','on');   % Turn on one Start-dialog pair
    set(hStartDialogs(i),'vis','on');
end

%
% Process dynamic dialog for STOP trigger
%
hStopPrompts = [hp.TrigStopT hp.TrigStopN hp.TrigStopFcn];
hStopDialogs = [hd.TrigStopT hd.TrigStopN hd.TrigStopFcn];
switch bd.params.TrigStopMode
    case 'Never',           i=0;
    case 'After T seconds', i=1;
    case 'After N inputs',  i=2;
    case 'User-defined',    i=3;
    otherwise, error('Unrecognized trigger mode.');
end
set(hStopPrompts,'vis','off');     % Turn all Stop-dialogs off
set(hStopDialogs,'vis','off');
if i>0,
    set(hStopPrompts(i),'vis','on');   % Turn on one Stop-dialog pair
    set(hStopDialogs(i),'vis','on');
end

%
% Process dynamic dialog for REARM trigger
%
hRearmPrompts = [hp.TrigRearmT hp.TrigRearmN hp.TrigRearmFcn];
hRearmDialogs = [hd.TrigRearmT hd.TrigRearmN hd.TrigRearmFcn];

% No need to enable trigger rearming if the
% acquisition never stops:
disable_rearm = strcmp(bd.params.TrigStopMode,'Never');
rearm_mode_text_and_popup = [dlg_fig_data.hDlgs.TrigRearmMode ...
                             dlg_fig_data.hPrompts.TrigRearmMode];

set(hRearmPrompts,'vis','off');     % Turn all Rearm-dialogs off
set(hRearmDialogs,'vis','off');

if disable_rearm,
    % Disable trigger rearm mode popup
    % and leave all rearm options invisible
    set(rearm_mode_text_and_popup,'enable','off');
else
    % Enable trigger stop mode popup
    set(rearm_mode_text_and_popup,'enable','on');
    % Make visible appropriate rearm options, if any:
    switch bd.params.TrigRearmMode
        case 'Never',           i=0;
        case 'After T seconds', i=1;
        case 'After N inputs',  i=2;
        case 'User-defined',    i=3;
        otherwise, error('Unrecognized trigger mode.');
    end
    if i>0,
        set(hRearmPrompts(i),'vis','on');   % Turn on one Rearm-dialog pair
        set(hRearmDialogs(i),'vis','on');
    end
end

% -------------------------------------------------------------------------
function refresh_dialog_core(hfig, params)
% Update param dialog, knowing handle to param dialog figure

% Loops over all entries of the parameter dialog
%
% Note that the handle to each control is named identically
% to the mask parameter variables in the block

if isempty(hfig), return; end

fig_data = get(hfig,'UserData');
hDlgs = fig_data.hDlgs;  % get structure of handles
blk   = fig_data.block;

% Get all block parameters
% Could have been manually passed in
if nargin<2,
    % Returns evaluated parameters where appropriate
    params = getWorkspaceVarsAsStruct(blk);
end

dlg_names = fieldnames(hDlgs);
for i=1:length(dlg_names),
    param_name = dlg_names{i};
    hDlg       = getfield(hDlgs, param_name);
    param_val  = getfield(params, param_name);
    
    % Default dialog handler:
    switch get(hDlg,'style')
        case 'edit'
            set(hDlg, 'string', mat2str(param_val));
        case 'popupmenu'
            all_strs = cellstr(get(hDlg,'string'));
            idx=strmatch(param_val,all_strs);
            if length(idx)~=1,
                idx=1;  % error('Invalid enum selected in dialog');
            end
            set(hDlg, 'value', idx);
        case 'checkbox'
            set(hDlg,'value',param_val);
        otherwise
            error('unhandled dialog style');
    end
end


% =========================================================================
%
% Above this line, the code is dialog-generic
% Below, it is dialog-specific
% The new tab dialog will need to modify the fcns below this line
%
% =========================================================================

% -------------------------------------------------------------------------
function fig_data = create_dialog_invis(blk)

% Setup following tab structure:
%       Display
%          Display Properties
%             Waterfall Traces
%             Update interval
%             Colormap
%          Trace Transparency
%             Newest
%             Oldest
%       Axes
%          Axis Properties
%             X Min
%             X Max
%             Axis color
%          Axis Labels
%             X Axis
%             Y Axis
%             Z Axis
%       Data I/O
%          Data Review
%             History length
%             History full
%             Automatic export to workspace
%          Export Options
%              Data logging: Selected|All visible|All history
%              Variable prefix
%       Triggering
%          Begin recording
%            Immediately
%            After T seconds
%            After N inputs
%            User-defined
%          End record mode
%            End record time, T
%            End record count, N
%            End record function
%          Re-enable record mode
%            Re-enable record time, T
%            Re-enable record count, N
%            Re-enable record function
%      Transforms
%          Function
%

% Create the tab dialog

block_name = getfullname(blk);
figName = ['Parameters: ' block_name];

% textExtent is just used to compute text extents during construction
% We allocate one only, then delete it for efficiency
tabStrings = {'Display', 'Axes', 'Data history','Triggering','Transforms'};
[hFig, textExtent] = create_tab_dialog(figName, tabStrings);
h{1} = CreateDisplayTab(hFig, textExtent);
h{2} = CreateAxesTab(hFig, textExtent);
h{3} = CreateDataIOTab(hFig, textExtent);
h{4} = CreateTriggerTab(hFig, textExtent);
h{5} = CreateTransformsTab(hFig, textExtent);
delete(textExtent);

% Merge the hDlgs parts of hDisplay, hAxes, and hDataIO into one struct:
fig_data.hDlgs = [];
% Add fields from hDisplay, hAxes, hDataIO, and hTrigger panel definitions
for i=1:length(h),
    c = struct2cell(h{i}.dlgs);
    f = fieldnames( h{i}.dlgs);
    for j=1:length(f),
        fig_data.hDlgs = setfield(fig_data.hDlgs,f{j},c{j});
    end
end

% Collect all handles to each tab in separate vectors
% to control "turning the page".  These are just simple vectors
% of handles, not structures with descriptive fields like
% .hDlgs contains.  Again, done for efficiency in turning on/off
% "everything" quickly:
for i=1:length(h),
    fig_data.hPanels{i} = h{i}.all;
end
%
% Next, we add the special slider handles to the Display panel list
%
% These are not on the "usual" list since the corresonding edit
% boxes are, and these edit boxes are the "primary" update mechanism.
% The sliders are a secondary/slaved control, even though they appear
% as "primary" to the user.
% Add in special elements of the Display panel (tab #1):
fig_data.hPanels{1} = [fig_data.hPanels{1} h{1}.transp.Slider_TOldest h{1}.transp.Slider_TNewest];

% Get all dynamic dialog prompts
%
fig_data.hPrompts = MergeStructs(h{4}.prompts, h{5}.prompts); % xxx

% Setup other data:
fig_data.transp = h{1}.transp;  % from Display tab (tab #1)
fig_data.tabStrings = tabStrings;
fig_data.hfig  = hFig;
fig_data.block = blk;

% For convenience:
%  bd = get_param(blk,'UserData');
%  fig_data.hfigScope = bd.hfig;

% Record figure data:
set(hFig, 'UserData', fig_data);


% -------------------------------------------------------------------------
function s1 = MergeStructs(s1,s2)
% xxx COMMON with sdspwfall, "relevant_params_changed"
%
% Return structure with fields from both structure s1 and s2
fields=fieldnames(s2);
s.type = '.';
for i=1:length(fields),
    s.subs=fields{i};
    subsasgn(s1,s,subsref(s2,s));
end

% -------------------------------------------------------------------------
function refresh_dialog(varargin)
% Update param dialog, knowing handle to param dialog figure
% args:
%    hFigDialog  - dialog figure handle

refresh_dialog_core(varargin{:})
refresh_dialog_trigger(varargin{:});
refresh_dialog_xform(varargin{:});
refresh_transp_gui(varargin{1});  % hfig


% --------------------------------------------------
function h=flattenStruct(s)
c=struct2cell(s);
h=[c{:}];

% --------------------------------------------
function handles = CreateDisplayTab(hFig, textExtent)

%if strcmp(get(hFig, 'Visible'), 'on')
%  set(hFig, 'DefaultUicontrolVisible', 'off');
%end

% Get spacing and color info:
bgc = get(hFig,'color');
ctxt = {'parent',hFig, ...
        'backgr', bgc, ...
        'style','text', ...
        'horiz','right'};
cedt = {'parent',hFig, ...
        'backgr', 'w', ...
        'style','edit', ...
        'callback', @update_dialog, ...
        'horiz','left'};
dy  = 18;
dye = 21;
CR=sprintf('\n');

% --- # Traces

% hStatic{1} = groupbox( ...
%     hFig, ...
%     [20 110 240 80], ...
%     'Waterfall Properties', ...
%     textExtent ...
%     );
hStatic{1} = groupbox( ...
    hFig, ...
    [20 98 245 96], ...
    'Display Properties', ...
    textExtent ...
    );

tip='Number of traces in waterfall display.';
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Display traces:', ...
    'tooltip',tip, ...
    'pos', [25+8 150+8 90 dy]);
hDlgs.NumTraces=uicontrol(cedt{:}, ...
    'string','(# traces)', ...
    'pos', [88+30+8 152+8 80 dye]);

tip=['Number of inputs to record' CR 'before updating the display.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Update interval:', ...
    'tooltip',tip, ...
    'pos', [25+8 124+8 90 dy]);
hDlgs.UpdateInterval=uicontrol(cedt{:}, ...
    'string','(UpdateInterval)', ...
    'pos', [88+30+8 126+8 80 dye]);

% --- Colormap

tip=['Colors used to fill' CR 'traces in waterfall.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Colormap:', ...
    'tooltip',tip, ...
    'pos', [25+8 124+8-26 90 dy]);
hDlgs.CMapStr=uicontrol('parent',hFig, ...
    'backgr', 'w', ...
    'style','popup', ...
    'string', 'autumn|gray|hot|pink|jet|copper|red|white', ...
    'callback', @update_dialog, ...
    'pos', [88+30+8 126+8-26 80 dye]);

% --- Trace Shading

% Enter transparency via edit boxes
%
% NOTE: We make these invisible, but use them for a common
%       infrastructure for updating the dialog parameters
%
hStatic{end+1} = groupbox( ...
    hFig, ...
    [20 18 245 65], ...
    'Transparency', ...
    textExtent ...
    );

tip=['Transparency of newest data slice.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Newest:', ...
    'tooltip',tip, ...
    'pos', [33 53-5 70 dy]);  % dx=90 would be aligned with above prompts
tip=['Transparency value of newest data slice.' CR ...
     '     0=Transparent, 1=Opaque'];
hDlgs.TNewest=uicontrol(cedt{:}, ...
    'callback', @change_transp_edit_boxes, ...
    'tooltip',tip, ...
    'string','(TNewest)', ...
    'enable','inactive', ...
    'pos', [126 56-5 70 dye-5]);
%    'callback', @update_dialog, ...

tip=['Transparency of oldest data slice.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Oldest:', ...
    'tooltip',tip, ...
    'pos', [33 27-5 70 dy]);
tip=['Transparency value of oldest data slice.' CR ...
     '     0=Transparent, 1=Opaque'];
hDlgs.TOldest=uicontrol(cedt{:}, ...
    'callback', @change_transp_edit_boxes, ...
    'tooltip',tip, ...
    'string','(TOldest)', ...
    'enable','inactive', ...
    'pos', [126 30-5 70 dye-5]);
%    'callback', @update_dialog, ...

% Sliders:
tip = 'Transparent < ---- > Opaque';
transp.Slider_TNewest=uicontrol('parent',hFig, ...
    'backgr', 'w', ...
    'tooltip', tip, ...
    'style','slider', ...
    'sliderstep', [0.05 0.25], ...
    'max', 1, 'min', 0, ...
    'callback', {@transp_slider_cb,1}, ...
    'pos', [116 56-5 90 17]);
transp.Slider_TOldest=uicontrol('parent',hFig, ...
    'backgr', 'w', ...
    'tooltip', tip, ...
    'style','slider', ...
    'sliderstep', [0.05 0.25], ...
    'max', 1, 'min', 0, ...
    'callback', {@transp_slider_cb,2}, ...
    'pos', [116 30-5 90 17]);


handles.dlgs = hDlgs;
handles.all  = [hStatic{:} flattenStruct(hDlgs)];
handles.transp = transp;  % transparency sliders

% --------------------------------------------
function handles = CreateAxesTab(hFig, textExtent)

%if strcmp(get(hFig, 'Visible'), 'on')
%  set(hFig, 'DefaultUicontrolVisible', 'off');
%end

% Get spacing and color info:
bgc = get(hFig,'color');
ctxt = {'parent',hFig, ...
        'backgr', bgc, ...
        'style','text', ...
        'horiz','right'};
cedt = {'parent',hFig, ...
        'backgr', 'w', ...
        'style','edit', ...
        'callback', @update_dialog, ...
        'horiz','left'};
dy  = 18;
dye = 21;
CR=sprintf('\n');

% --- Axis Limits

hStatic{1} = groupbox( ...
    hFig, ...
    [20 124 245 70], ...
    'Axis Properties', ...
    textExtent ...
    );

tip='Lower limit of Y-axis.';
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Y Min:', ...
    'tooltip',tip, ...
    'pos', [37 158 45 dy]);
hDlgs.YMin=uicontrol(cedt{:}, ...
    'string','(Y Min)', ...
    'pos', [85 160 40 dye]);

tip='Upper limit of Y-axis.';
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Y Max:', ...
    'tooltip',tip, ...
    'pos', [133 158 45 dy]);
%    'pos', [32+5 132 60 dy]);
hDlgs.YMax=uicontrol(cedt{:}, ...
    'string','(Y Max)', ...
    'pos', [180 160 40 dye]);
%    'pos', [95+5 134 40 dye]);

% -- Axis color

tip = ['Background color of scope axis.' char(13) ...
       'Enter a color abbreviation such as ''w'',' char(13) ...
       'or an RGB triple such as [1 1 0].'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Axis color:', ...
    'tooltip', tip, ...
    'pos', [37 132 60 dy]);
hDlgs.AxisColor = uicontrol(cedt{:}, ...
    'string','(AxisColor)', ...
    'pos', [100 134 120 dye]);

% -- Axis Labels

hStatic{end+1} = groupbox( ...
    hFig, ...
    [20 18 245 92], ...
    'Axis Labels', ...
    textExtent ...
    );
    
tip=['Label describing units of' CR 'samples in input vector.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','X Axis:', ...
    'tooltip',tip, ...
    'pos', [32+5 77 60 dy]);
hDlgs.XLabel=uicontrol(cedt{:}, ...
    'string','(X Label)', ...
    'pos', [95+5 79 120 dye]);

tip=['Label describing units' CR 'of data amplitude.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Y Axis:', ...
    'tooltip',tip, ...
    'pos', [32+5 51 60 dy]);
hDlgs.YLabel=uicontrol(cedt{:}, ...
    'string','(Y Label)', ...
    'pos', [95+5 53 120 dye]);

tip=['Label describing units' CR 'along time dimension.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Z Axis:', ...
    'tooltip',tip, ...
    'pos', [32+5 25 60 dy]);
hDlgs.ZLabel=uicontrol(cedt{:}, ...
    'string','(Z Label)', ...
    'pos', [95+5 27 120 dye]);

handles.dlgs = hDlgs;
handles.all  = [hStatic{:} flattenStruct(hDlgs)];


% --------------------------------------------
function handles = CreateDataIOTab(hFig, textExtent)

%if strcmp(get(hFig, 'Visible'), 'on')
%  set(hFig, 'DefaultUicontrolVisible', 'off');
%end

% Get spacing and color info:
bgc = get(hFig,'color');
ctxt = {'parent',hFig, ...
        'backgr', bgc, ...
        'style','text', ...
        'horiz','right'};
cedt = {'parent',hFig, ...
        'backgr', 'w', ...
        'style','edit', ...
        'callback', @update_dialog, ...
        'horiz','left'};
dy  = 18;
dye = 21;
CR=sprintf('\n');

hStatic{1} = groupbox( ...
    hFig, ...
    [20 126 245 68], ...
    'Data Review', ...
    textExtent ...
    );

% --- History Length

tip=['Number of inputs to record beyond end' CR ...
     'of display; use 0 to disable.  "Extend"' CR ...
     'mode automatically increases this initial' CR ...
     'allocation as needed.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','History traces:', ...
    'tooltip',tip, ...
    'pos', [33 158 90 dy]);  % 150+8
hDlgs.HistoryLength=uicontrol(cedt{:}, ...
    'string','(HistoryLength)', ...
    'pos', [126 160 95 dye]); % 152+8

tip=['Action to take when data buffer fills.' CR ...
     'Data buffer holds all display traces' CR ...
     'plus all history traces.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','When buffer is full:', ...
    'tooltip',tip, ...
    'pos', [25+8 150+8-24 90 dy]);  % 150+8
tip=[...
     'Overwrite: record new data over oldest history' CR ...
     'Suspend: go to suspend mode when full' CR ...
     'Extend: double history length and continue' ...
   ];
hDlgs.HistoryFull=uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string','Overwrite|Suspend|Extend', ...
    'pos', [88+30+8 152+8-24 95 dye]);

% tip = ['Synchronize "pause" action across all scopes' CR 'supporting Snapshot/Suspend capabilities.'];
% hDlgs.SyncSnapshots=uicontrol('parent',hFig, ...
%     'backgr', bgc, ...
%     'style','checkbox', ...
%     'horiz','right', ...
%     'callback', @update_dialog, ...
%     'string','Synchronize suspend/snapshot', ...
%     'tooltip', tip, ...
%     'pos', [56 112 180 dye]);

hStatic{end+1} = groupbox( ...
    hFig, ...
    [20 18 245 91], ...
    'Export Options', ...
    textExtent ...
    );

tip=['Selects data to be exported.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Data logging:', ...
    'tooltip',tip, ...
    'pos', [33 74 90 dy]);
tip=[...
     'Selected: currently selected trace only' CR ...
     'All visible: all data visible in display' CR ...
     'All history: all recorded data' ...
   ];
hDlgs.ExportMode=uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string','Selected|All visible|All history', ...
    'pos', [126 76 95 dye]);

tip=['Variable name used for export' CR ...
     'to MATLAB workspace and SPTool.'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Export variable:', ...
    'tooltip',tip, ...
    'pos', [33 46+4 90 dy]);
hDlgs.MLExportName=uicontrol(cedt{:}, ...
    'string','(MLExportName)', ...
    'pos', [126 48+4 95 dye]);

tip = ['Automatically export data to MATLAB workspace' CR ...
       'when simulation ends; export on demand is always' CR ...
       'available via the File menu or Ctrl+W.'];
hDlgs.AutoExport = uicontrol('parent',hFig, ...
    'backgr', bgc, ...
    'style','checkbox', ...
    'horiz','right', ...
    'callback', @update_dialog, ...
    'string','Export at end of simulation', ...
    'tooltip', tip, ...
    'pos', [62 102-76 180 dye]);


handles.dlgs = hDlgs;
handles.all  = [hStatic{:} flattenStruct(hDlgs)];


% -------------------------------------------------------------------------
function handles = CreateTriggerTab(hFig, textExtent)

%       Triggering
%          Begin record mode
%            Begin record time, T
%            Begin record count, N
%            Begin record function
%          End record mode
%            End record time, T
%            End record count, N
%            End record function
%          Re-enable record mode
%            Re-enable record time, T
%            Re-enable record count, N
%            Re-enable record function

% Get spacing and color info:
bgc = get(hFig,'color');

ctxt = {'parent',hFig, ...
        'backgr', bgc, ...
        'style','text', ...
        'horiz','right'};
cedt = {'parent',hFig, ...
        'backgr', 'w', ...
        'style','edit', ...
        'callback', @update_dialog, ...
        'horiz','left'};
dy  = 18;
dye = 21;
CR=sprintf('\n');

%
% TrigStartMode
%
tip=['When to begin/resume recording' CR 'input data (i.e., input trigger)'];
hPrompts.TrigStartMode = uicontrol(ctxt{:}, ...
    'string','Begin recording:', ...
    'tooltip',tip, ...
    'pos', [33 164 90 dy]);
tip = ['Immediately: no trigger delay' CR ...;
        'After T seconds: elapsed simulation time' CR ...
        'After N inputs: number of sequential inputs' CR ...
        'User-defined: M-file function name'];
hDlgs.TrigStartMode=uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string','Immediately|After T seconds|After N inputs|User-defined', ...
    'pos', [126 164 110 dye]);
% @update_dialog_trigger?

%
% TrigStartT - all 3 TrigStart params are positioned on top of each other
%
tip=['Number of simulation-time seconds' CR 'until data recording resumes.'];
% Note: we need the prompt-text to be dynamic, so it cannot be placed
%       in the usual "hStatic" array.
hPrompts.TrigStartT = uicontrol(ctxt{:}, ...
    'string','Time, T:', ...
    'tooltip',tip, ...
    'pos', [23 138 100 dy]);
hDlgs.TrigStartT=uicontrol(cedt{:}, ...
    'string','(TrigStartT)', ...
    'pos', [126 138 92 dye]);

%
% TrigStartN - all 3 TrigStart params are positioned on top of each other
%
tip=['Number of inputs to scope' CR 'until data recording resumes.'];
hPrompts.TrigStartN = uicontrol(ctxt{:}, ...
    'string','Count, N:', ...
    'tooltip',tip, ...
    'pos', [23 138 100 dy]);
hDlgs.TrigStartN=uicontrol(cedt{:}, ...
    'string','(TrigStartN)', ...
    'pos', [126 138 92 dye]);

%
% TrigStartFcn - all 3 TrigStart params are positioned on top of each other
%
tip=['Name of trigger function used to' CR ...
     'determine when to resume recording.' CR CR ...
     '   isTrigger = triggerFcn(block, time, data)'];
hPrompts.TrigStartFcn = uicontrol(ctxt{:}, ...
    'string','Function name:', ...
    'tooltip',tip, ...
    'pos', [23 138 100 dy]);
hDlgs.TrigStartFcn=uicontrol(cedt{:}, ...
    'string','(TrigStartFcn)', ...
    'pos', [126 138 92 dye]);

%
% TrigStopMode
%
tip=['When to suspend recording input' CR 'data and disarm trigger'];
hPrompts.TrigStopMode = uicontrol(ctxt{:}, ...
    'string','Stop recording:', ...
    'tooltip',tip, ...
    'pos', [23 104 100 dy]);
tip = ['Never: recording is not suspended by trigger' CR ...;
        'After T seconds: elapsed simulation time' CR ...
        'After N inputs: number of sequential inputs' CR ...
        'User-defined: M-file function name'];
hDlgs.TrigStopMode=uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string','Never|After T seconds|After N inputs|User-defined', ...
    'pos', [126 104 110 dye]);
% @update_dialog_trigger?

%
% TrigStopT - all 3 TrigStop params are positioned on top of each other
%
tip=['Number of simulation-time seconds' CR 'until data recording suspends.'];
hPrompts.TrigStopT = uicontrol(ctxt{:}, ...
    'string','Time, T:', ...
    'tooltip',tip, ...
    'pos', [23 78 100 dy]);
hDlgs.TrigStopT=uicontrol(cedt{:}, ...
    'string','(TrigStopT)', ...
    'pos', [126 78 92 dye]);

%
% TrigStopN - all 3 TrigStop params are positioned on top of each other
%
tip=['Number of inputs to scope' CR 'until data recording suspends.'];
hPrompts.TrigStopN = uicontrol(ctxt{:}, ...
    'string','Count, N:', ...
    'tooltip',tip, ...
    'pos', [23 78  100 dy]);
hDlgs.TrigStopN=uicontrol(cedt{:}, ...
    'string','(TrigStopN)', ...
    'pos', [126 78 92 dye]);

%
% TrigStopFcn - all 3 TrigStop params are positioned on top of each other
%
tip=['Name of trigger function used to' CR ...
     'determine when to suspend recording.' CR CR ...
     '   isTrigger = triggerFcn(block, time, data)'];
hPrompts.TrigStopFcn = uicontrol(ctxt{:}, ...
    'string','Function name:', ...
    'tooltip',tip, ...
    'pos', [23 78 100 dy]);
hDlgs.TrigStopFcn=uicontrol(cedt{:}, ...
    'string','(TrigStopFcn)', ...
    'pos', [126 78 92 dye]);

%
% TrigRearmMode
%
tip=['When to re-enable the "Begin" trigger' CR 'for repetitive triggering of the scope.'];
hPrompts.TrigRearmMode = uicontrol(ctxt{:}, ...
    'string','Re-arm trigger:', ...
    'tooltip',tip, ...
    'pos', [23 44 100 dy]);
tip = ['Never: trigger is one-shot / nonrepetitive' CR ...;
        'After T seconds: elapsed simulation time' CR ...
        'After N inputs: number of sequential inputs' CR ...
        'User-defined: M-file function name'];
hDlgs.TrigRearmMode=uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string','Never|After T seconds|After N inputs|User-defined', ...
    'pos', [126 44 110 dye]);
% @update_dialog_trigger?

%
% TrigRearmT - all 3 TrigRearm params are positioned on top of each other
%
tip=['Number of simulation-time seconds' CR 'until "Begin" trigger rearms.'];
hPrompts.TrigRearmT = uicontrol(ctxt{:}, ...
    'string','Time, T:', ...
    'tooltip',tip, ...
    'pos', [23 18 100 dy]);
hDlgs.TrigRearmT=uicontrol(cedt{:}, ...
    'string','(TrigRearmT)', ...
    'pos', [126 18 92 dye]);

%
% TrigRearmN - all 3 TrigRearm params are positioned on top of each other
%
tip=['Number of inputs to scope' CR 'until "Begin" trigger rearms.'];
hPrompts.TrigRearmN = uicontrol(ctxt{:}, ...
    'string','Count, N:', ...
    'tooltip',tip, ...
    'pos', [23 18  100 dy]);
hDlgs.TrigRearmN=uicontrol(cedt{:}, ...
    'string','(TrigRearmN)', ...
    'pos', [126 18 92 dye]);

%
% TrigRearmFcn - all 3 TrigRearm params are positioned on top of each other
%
tip=['Name of trigger function used to' CR ...
     'determine when "Begin" trigger rearms.' CR CR ...
     '   isTrigger = triggerFcn(block, time, data)'];
hPrompts.TrigRearmFcn = uicontrol(ctxt{:}, ...
    'string','Function name:', ...
    'tooltip',tip, ...
    'pos', [23 18 100 dy]);
hDlgs.TrigRearmFcn=uicontrol(cedt{:}, ...
    'string','(TrigRearmFcn)', ...
    'pos', [126 18 92 dye]);

hStatic = {};  % nothing was defined for this yet

handles.prompts = hPrompts;
handles.dlgs = hDlgs;
handles.all  = [hStatic{:} flattenStruct(hPrompts) flattenStruct(hDlgs)];



% --------------------------------------------
function handles = CreateTransformsTab(hFig, textExtent)

% Get spacing and color info:
bgc = get(hFig,'color');
ctxt = {'parent',hFig, ...
        'backgr', bgc, ...
        'style','text', ...
        'horiz','right'};
cedt = {'parent',hFig, ...
        'backgr', 'w', ...
        'style','edit', ...
        'callback', @update_dialog, ...
        'horiz','left'};
dy  = 18;
dye = 21;
CR=sprintf('\n');

% --- Transform

hStatic{1} = groupbox( ...
    hFig, ...
    [20 98 245 96], ...
    'Data Transformation', ...
    textExtent ...
    );

tip = ['Transformation to apply to source data' CR ...
       '    source  ->  transform' CR ...
       '    format         format'];
hStatic{end+1} = uicontrol(ctxt{:}, ...
    'string','Transform:', ...
    'tooltip',tip, ...
    'pos', [33 158 80 dy]);

tip = '';
str = ['None|' ...
       'Amplitude->dB|' ...
       'Complex->Mag Lin|Complex->Mag dB|Complex->Angle|' ...
       'FFT->Mag Lin Fs/2|FFT->Mag dB Fs/2|FFT->Angle Fs/2|' ...
       'Power->dB|' ...
       'User-defined fcn|User-defined expr'];
hDlgs.XformMode = uicontrol('parent', hFig, ...
    'backgr','w', ...
    'style','popup', ...
    'horiz','left', ...
    'callback', @update_dialog, ...
    'tooltip',tip, ...
    'string',str, ...
    'pos', [116 160 120 dye]);

tip = ['Vector transformation function' CR ...
        'accepting and returning a vector'];
hPrompts.XformFcn = uicontrol(ctxt{:}, ...
    'string','Function:', ...
    'tooltip',tip, ...
    'pos', [33 160-24 80 dy]);
hDlgs.XformFcn = uicontrol(cedt{:}, ...
    'string','(XformFcn)', ...
    'pos', [116 160-24 120 dye]);

tip = ['Vector transformation expression' CR ...
        'accepting and returning a vector,' CR ...
        'such as "u+1" or "x(1:2:end)"'];
hPrompts.XformExpr = uicontrol(ctxt{:}, ...
    'string','Expression:', ...
    'tooltip',tip, ...
    'pos', [33 160-48 80 dy]);
hDlgs.XformExpr = uicontrol(cedt{:}, ...
    'string','(XformExpr)', ...
    'pos', [116 160-48 120 dye]);

handles.prompts = hPrompts;
handles.dlgs = hDlgs;
handles.all  = [hStatic{:} flattenStruct(hPrompts) flattenStruct(hDlgs)];


% --------------------------------------------
function [DialogFig, textExtent] = create_tab_dialog(figName, tabStrings)

%
% Create constants based on current computer.
%

thisComputer = computer;

fontsize = get(0, 'FactoryUicontrolFontSize');
fontname = get(0, 'FactoryUicontrolFontName');

switch(thisComputer)
  case 'PCWIN',
    DialogUserData.popupBackGroundColor = 'w';
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontName  = 'Courier new';
    listboxFixedFontSize  = 9;
    lang = get(0, 'language');
    if strncmp(lang, 'ja', 2)
      listboxFixedFontName = 'FixedWidth';
	  listboxFixedFontSize  = 12;
    end

  case 'MAC2',
    DialogUserData.popupBackGroundColor = 'w';
    dividingLineStyle     = 'frame';
    dividingLineThickness = 3;
    listboxFixedFontName  = 'Courier';
    listboxFixedFontSize  = 10;

  otherwise,  % X
    DialogUserData.popupBackGroundColor = get(0, ...
	'FactoryUicontrolBackgroundColor');
    dividingLineStyle     = 'pushbutton';
    dividingLineThickness = 4;
    listboxFixedFontName  = 'FixedWidth';
    listboxFixedFontSize  = 9;
end

%
% Create an empty figure (we need it now for text extents).
%
DialogFig = figure( ...
    'Visible',                            'off', ...
    'DefaultUicontrolHorizontalAlign',    'left', ...
    'DefaultUicontrolFontname',           fontname, ...
    'DefaultUicontrolFontsize',           fontsize, ...
    'DefaultUicontrolUnits',              'pixels', ...
    'HandleVisibility',                   'callback', ...
    'Colormap',                           [], ...
    'Name',                               figName, ...
    'DeleteFcn',                          @DialogDelete, ...
    'KeyPressFcn',                        @DialogKeypress, ...
    'resize',                             'off', ...
    'menubar',                            'none', ...
    'nextplot',                           'add', ...
    'IntegerHandle',                      'off');

%
% Create a text object for text sizing.
%

textExtent = uicontrol( ...
    'Parent',     DialogFig, ...
    'Visible',    'off', ...
    'Style',      'text', ...
    'FontSize',   fontsize, ...
    'FontName',   fontname ...
    );


defaultPageNum  = 1;
defaultPageName = 'Display';

% ... tab dimensions

nTabs = length(tabStrings);
widths(nTabs) = 0;

for i=1:nTabs,
  set(textExtent, 'String', tabStrings{i});
  ext = get(textExtent, 'Extent');
  widths(i) = ext(3) + 6;
end

height  = ext(4) + 4;
tabDims = {widths, height};

% ... other tab dialog parameters

width = 275;
height = 200;
sheetDims = [width height];

sideEdge = 5;
topEdge = 5;
bottomEdge = 5;
offsets = [sideEdge topEdge sideEdge bottomEdge];

%
% ... create it.
%
callback  = @DialogChangeTab;
[DialogFig, sheetPos] = tabdlg('create', ...
    tabStrings, ...
    tabDims, ...
    callback, ...
    sheetDims, ...
    offsets, ...
    defaultPageNum, ...
    {}, ...
    DialogFig);


% For all children:
set(DialogFig,'DefaultUicontrolVisible','off');


% ---------------------------------
function DialogChangeTab(varargin)
% Automatically called by tabdlg
% varargin contains:
%              1) 'tabcallbk'     - a text flag
%              2) pressedTab      - the string of selected tab
%              3) pressedTabNum   - the number of the selected tab
%              4) previousTab     - the string of the previously selected tab
%              5) previousTabNum  - the number of the previously selected tab
%              6) hfig            - handle of the figure

pressedTabNum = varargin{3};
fig_data = get(varargin{6},'UserData');  % dialog figure handle
set(fig_data.hPanels{varargin{5}},'vis','off');   % previousTabNum
set(fig_data.hPanels{pressedTabNum},'vis','on');  % pressedTabNum

% Invoke dynamic dialog callbacks manually:
%
if pressedTabNum==4,  % trigger panel has dynamic dialogs
    refresh_dialog_trigger(varargin{6},[],pressedTabNum);
end
if pressedTabNum==5, % transforms panel has dynamic dialogs, too
    refresh_dialog_xform(varargin{6},[],pressedTabNum);
end

% Update cached value of current pageNum
blk = fig_data.block;
bd = get_param(blk, 'UserData');
bd.param_dlg.tabNum = pressedTabNum;
set_param(blk, 'UserData', bd);

% ------------------------------------------------------
function SetDialogTab(hfig,pageNum)
% Manually set the dialog to have a certain tab open

% Similar to clicking on tab of dialog
fig_data = get(hfig,'UserData');

% Check pageNum, should be in the range 1...N where N is the number of tab
% dialog pages.  If it's out of range, set to 1
numPages = length(fig_data.tabStrings);
if (pageNum > numPages) || (pageNum < 1),
    pageNum=1;
end

% Find pageName from pageNum:
pageName = fig_data.tabStrings{pageNum};

% Click the tab:
tabdlg('tabpress', hfig, pageName, pageNum);

% Update cached value of current pageNum
blk = fig_data.block;
bd = get_param(blk, 'UserData');
bd.param_dlg.tabNum = pageNum;
set_param(blk, 'UserData', bd);

% -------------------------------------------------------------------------
function GroupBox = groupbox(fig, pos, string, htextObj),
%GROUPBOX Create a frame with embedded text description.
%   GROUPBOX(fig, pos, string, htextObj), creates a frame and returns a vector 
%   of length 2:
%
%     [hFrame, hText].
%
%   fig      - desired parent of frame
%   pos      - position of frame: [left bottom width height]
%   string   - frame description
%   htextObj - handle of uicontrol text object for use in getting the text 
%              extent of the string.

%   Copied from Revision: 1.12 of private/groupbox

GroupBox(2) = 0;  % alloc vector
style = 'frame';

GroupBox(1) = uicontrol( ...
  'Parent',             fig, ...
  'Style',              style, ...
  'Enable',             'inactive', ...
  'Foreground',         [255 251 240]/255, ...
  'Position',           pos ...
);

set(htextObj, 'String', string);
ext = get(htextObj, 'Extent');

posText = [
  pos(1) + (ext(3)/length(string))
  pos(2) + pos(4) - (ext(4)/1.75)
  ext(3)
  ext(4)
];

GroupBox(2) = uicontrol( ...
  'Parent',             fig, ...
  'Style',              'text', ...
  'String',             string, ...
  'Position',           posText ...
);

% -------------------------------------------------------------------------
function refresh_transp_gui(hfig)
% Update the transparency GUI with current edit-box values
%
% NOTE:
%   - there is a visible GUI in param dialog so user can interact
%        with transparency settings
%   - there are two invisible edit boxes in parameter dialog
%     for uniformity, making it easy to update all params
%     in one group.
%   - there are two edit boxes in the mask dialog as well
%
% xxx - We're evaluating in a local context - beware!
% We should be fine, since a user should *not* be entering
% any information into the parameter dialog directly.
% Perhaps into the mask dialog, but that is fine since it
% evaluates in the proper context.

if isempty(hfig), return; end
fig_data = get(hfig,'UserData');

TOld = str2num(get(fig_data.hDlgs.TOldest,'string'));
set(fig_data.transp.Slider_TOldest, 'value', TOld);

TNew = str2num(get(fig_data.hDlgs.TNewest,'string'));
set(fig_data.transp.Slider_TNewest, 'value', TNew);


% -------------------------------------------------------------------------
function change_transp_edit_boxes(hcb,eventStruct)
% Respond to a manual change to the transparency edit boxes

hfig=gcbf;
refresh_transp_gui(hfig);
update_dialog(hcb,eventStruct,hfig);


% -------------------------------------------------------------------------
function transp_slider_cb(hcb,eventStruct,sliderNum)

hfig = gcbf;
fig_data = get(hfig,'UserData');

% Update edit boxes:
if sliderNum==1,  % slider for Newest trace
    val = get(fig_data.transp.Slider_TNewest, 'value');
    set(fig_data.hDlgs.TNewest, 'string', num2str(val));
else  % slider for Oldest trace
    val = get(fig_data.transp.Slider_TOldest, 'value');
    set(fig_data.hDlgs.TOldest, 'string', num2str(val));
end

% Trigger callbacks:
update_dialog(hcb,eventStruct,hfig);
drawnow;

% [EOF] $File: $
