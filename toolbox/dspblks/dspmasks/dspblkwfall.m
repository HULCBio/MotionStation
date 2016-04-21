function dspblkwfall(action, varargin)
% DSPBLKWFALL Signal Processing Blockset waterfall plot block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.4.2 $ $Date: 2004/04/12 23:07:43 $

% Params structure fields:
%
% (1) TraceProperties: checkbox
%  2  NumTraces: scalar, # of traces
%  3  CMapStr: colormap name (string)
%  4  TNewest: transparency of newest trace, fraction from 0 to 1
%                   0=opaque, 1=transparent
%  5  TOldest: transparency of oldest trace, fraction from 0 to 1
%  6  HistoryLength: scalar, # inputs to record
%  7  HistoryFull: popup, 'Overwrite','Suspend','Extend'
%  8  UpdateInterval: scalar, # of inputs to record before updating display
%  9  ExportMode: popup, 'All history', 'All visible', 'Selected'
% 10  MLExportName: edit box, variable name to use for MATLAB export
% 11  AutoExport: checkbox, automatic export to workspace at simulation end
%
%(12) DisplayProperties: checkbox
% 13  MouseMode: popup (Arrow|Orbit|Zoom)
% 14  AxisGrid: checkbox
% 15  Snapshot: checkbox
% 16  Suspend: checkbox
% 17  SyncSnapshots: checkbox
% 18  OpenScopeAtSimStart: checkbox
% 19  FigPos: figure position
% 20  CameraView: edit box
% 21  InportDimsHint: edit box
%
% (22) AxisProperties: checkbox
%  23  YMin: minimum Z-limit
%  24  YMax: maximum Z-limit
%  25  AxisColor: edit (literal)
%  26  XLabel
%  27  YLabel
%  28  ZLabel
%
% (29) TriggerProperties: checkbox
%  30 TrigStartMode: popup
%  31 TrigStartT: edit, eval
%  32 TrigStartN: edit, eval
%  33 TrigStartFcn: edit, literal
%  34 TrigStopMode: popup
%  35 TrigStopT: edit, eval
%  36 TrigStopN: edit, eval
%  37 TrigStopFcn: edit, literal
%  38 TrigRearmMode: popup
%  39 TrigRearmT: edit, eval
%  40 TrigRearmN: edit, eval
%  41 TrigRearmFcn: edit, literal
%
% (42) TransformProperties: checkbox
%  43 XformMode: popup, literal
%  44 XformFcn: edit, literal
%  45 XformExpr: edit, literal

blk = gcb;

switch action
    case 'dynamic'
        opt = varargin{1};
        
        % Get all mask states:
        %
        vis = get_param(blk,'maskvisibilities');
        orig_vis = vis;
        prompts = get_param(blk,'maskprompts');
        orig_prompts = prompts;
        vals = get_param(blk,'maskvalues');
        orig_vals = vals;
        ena = get_param(blk,'maskenables');
        orig_ena = ena;
        
        % Set visibility of scope properties:
        %
        props = {'TraceProperties','DisplayProperties','AxisProperties','TriggerProperties','XformProperties'};
        if ~any(strmatch(opt, props)),
            error('Unknown dynamic dialog callback');
        end
        sw = strmatch(opt,props);
        [vis,vals] = openTabIfSelected(vis,vals,sw);
        
        % Update all mask states:
        %
        if ~isequal(vis,orig_vis)
            set_param(blk, 'maskvisibilities',vis);
        end
        if ~isequal(prompts,orig_prompts)
            set_param(blk,'maskprompts',prompts);
        end
        if ~isequal(vals,orig_vals)
            set_param(blk,'maskvalues',vals);
        end
        if ~isequal(ena,orig_ena)
            set_param(blk,'maskenables',ena);
        end
end


% --------------------------------------------------------------------
function [vis,vals] = openTabIfSelected(vis,vals,tabNum)

if tabIsChecked(vals,tabNum),
    [vis,vals] = openTab(vis,vals,tabNum);
else
    if tabContentsAreVisible(vis,tabNum),
        vis = closeTab(vis,tabNum);
    end
    % Otherwise do nothing, as another tab must be open right now.
end


% --------------------------------------------------------------------
function checked = tabIsChecked(vals,tabNum)
% indices of properties tabs

tab_checks = [1 12 22 29 42];
checked = strcmp(vals(tab_checks(tabNum)),'on');


% --------------------------------------------------------------------
function seeTab = tabContentsAreVisible(vis,tabNum)

% Are the contents of tab # (tabNum) visible?
%
% tab 1: already open if NumTraces (2) is visible
% tab 2: already open if AxisGrid (13) is visible
% tab 3: already open if YMin (22) is visible
% tab 4: already open if TrigStartMode (29) is visible
% tab 5: already open if XformFcn (30) is visible
%
openChecks = [2 13 23 30 43];
seeTab  = strcmp(vis(openChecks(tabNum)),'on');


% --------------------------------------------------------------------
function vis = closeTab(vis,tabNum)

tab_entries = {2:11, 13:21, 23:28, 30:41, 43:45};
vis(tab_entries{tabNum}) = {'off'};


% --------------------------------------------------------------------
function [vis,vals] = openTab(vis,vals,tabNum)

% Open tab number tabNum (1 thru 5)
% Only one tab should be open at a time

tab_checks = [1 12 22 29 42];
tab_entries = {2:11, 13:21, 23:28, 30:41, 43:45};

% Determine indices of entries:
open_tab_checks = tab_checks(tabNum);
closed_tab_checks=tab_checks;
closed_tab_checks(tabNum)=[];

% Determine indices of main tab checks:
open_tab_entries   = tab_entries{tabNum};     % get the open tab entries into vector
closed_tab_entries = tab_entries;             % get all entries
closed_tab_entries(tabNum)=[];                % remove open tab from cell array
closed_tab_entries = [closed_tab_entries{:}]; % convert cell to vector

% Open and close the tab checks and the tab entries:
vis(closed_tab_entries) = {'off'};
vis(open_tab_entries)   = {'on'};
vals(closed_tab_checks) = {'off'};
vals(open_tab_checks)   = {'on'};

% [EOF] $File: $
