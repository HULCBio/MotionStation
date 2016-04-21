function varargout = dspblkfscope2(action, varargin)
% DSPBLKFSCOPE2 Signal Processing Blockset vector scope block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.13.4.2 $ $Date: 2004/04/12 23:06:36 $

% Params structure fields:
% ( 1) ScopeProperties: checkbox
%   2  Domain: 0=Time, 1=Frequency, 2=User Defined
%   3  HorizSpan: Horizontal time span (number of frames)
%
% ( 4) DisplayProperties: checkbox
%   5  AxisGrid: checkbox
%   6  Memory: checkbox
%   7  FrameNumber: checkbox
%   8  AxisLegend: checkbox
%   9  AxisZoom: checkbox
%  10  OpenScopeAtSimStart: checkbox
%  11  OpenScopeImmediately: checkbox
%  12  FigPos: figure position
%
% (13) AxisProperties: checkbox
%  14  XUnits:
%       User, Time: ignored
%       Freq: 0=Hz, 1=rad/sec
%  15  XRange:
%       User, Time: ignored
%       Freq: 0=[0,Fn] , 1=[-Fn,Fn], 2=[0, Fs]
%                 (Fn=Nyquist rate, Fs=Sample rate)
%  16  InheritXIncr: checkbox
%  17  XIncr: increment of x-axis samples, used for x-axis display
%       Time: ignored (assumes frame-based)
%       Freq: Only displayed if data was zero-padded
%       User: seconds per sample
%  18  XLabel:
%       Time, Frequency: ignored
%       User: displayed
%  19  YUnits:
%       User, Time: ignored
%       Freq: 0=Magnitude, 1=dB
%  20  YMin: minimum Y-limit
%  21  YMax: maximum Y-limit
%  22  YLabel:
%       Always used
%
% (23) LineProperties: checkbox
%  24  LineDisables: pipe-delimited string
%  25  LineStyles: pipe-delimited string
%  26  LineMarkers: pipe-delimited string
%  27  LineColors: pipe-delimited string

if nargin==0, action = 'dynamic'; end
blk = gcb;

% is this callback for a vector scope or from the Eye Rendering or Scatter
% Rendering block
sfunname = 'sdspfscope2'; % default value for sfunction name
% find out if this is an eye diagram or scatter plot block so we can change the
% block name to the Vector scope block inside the system
block_type = getfromancestor(blk,'block_type_');
switch block_type,
case 'eye',
    if isempty(findstr('/Eye Rendering',blk)),
		blk = [blk '/Eye Rendering'];
    end
case 'scatter',
    if isempty(findstr('/Scatter Rendering',blk)),
		blk = [blk '/Scatter Rendering'];
    end
case 'xy',
    if isempty(findstr('/X-Y Rendering',blk)),
		blk = [blk '/X-Y Rendering'];
    end
otherwise,
end

domain = get_param(blk,'Domain');

switch action
case 'icon'
    
    inLibrary=strcmp(get_param(bdroot(blk),'BlockDiagramType'),'library');
    if inLibrary, domain='Vect'; end
    
    switch domain
    case {'Time','User-defined'}
        % Time domain:
        x = [ 0 NaN 100 NaN 8 8 92 92 8 NaN 16 16 84 NaN ...
                16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80];
        y = [ 0 NaN 100 NaN 92 40 40 92 92 NaN 88 48 48 NaN ...
                68 74 78 80 81 80 77 73 68 64 60 58 57 57 59 63 68];
        
    case 'Frequency'
        % Frequency domain:
        x = [0 NaN 100 NaN ...
                8 8 92 92 8 NaN 16 16 84 NaN 24 24 NaN 32 32 32 NaN ...
                40 40 NaN 48 48 NaN 56 56 NaN 64 64 NaN ...
                80 80 80 80 NaN 72 72 72];
        y = [0 NaN 100 NaN ...
                92 40 40 92 92 NaN 88 48 48 NaN 76 48 NaN 65 48 48 NaN ...
                79 48 NaN 60 48 NaN 58 48 NaN 64 48 NaN ...
                49 49 48 48 NaN 48 48 54];
    case 'Vect'
        % In block library:
        x = [ 0 NaN 100 NaN 8 8 92 92 8 NaN 16 16 84];
        y = [ 0 NaN 100 NaN 92 40 40 92 92 NaN 88 48 48];
    end
    str = domain(1:4);
    varargout(1:3) = {x,y,str};
    
    
case 'init'
    % Copy all mask dialog entries to a structure
    

    s = getWorkspaceVarsAsStruct(blk);
    varargout{1} = s;
    feval(sfunname,[],[],[],'DialogApply',s);  
    
case 'dynamic'
	% Update mask visibilities, etc, in response to dialog changes
    
    opt = varargin{1};
    
    vis = get_param(blk,'maskvisibilities');
    orig_vis = vis;
    prompts = get_param(blk,'maskprompts');
    orig_prompts = prompts;
    vals = get_param(blk,'maskvalues');
    orig_vals = vals;
    ena = get_param(blk,'maskenables');
    orig_ena = ena;
    
    props = {'ScopeProperties','DisplayProperties','AxisProperties','LineProperties'};
    
    switch opt
    case 'Domain'
        [vis,prompts] = updateDomainState(vis,vals,prompts,blk);
        
    case props
        % Set visibility of scope properties:
        sw = strmatch(opt,props);
        [vis,vals] = openTabIfSelected(vis,vals,sw);
        
        % Update all other dependent items after switching tabs:
        [vis,prompts] = updateDomainState(vis,vals,prompts,blk);
        
	case 'InheritXIncr'
		
		% Enable XIncr if InheritXIncr off (not checked)
		if strcmp(vals{16},'off'), sw='on'; else sw='off'; end
		ena{17} = sw;
		
    case 'OpenScope'
        % Open scope GUI in response to "immediate" toggle
        
        % Always attempt to open the scope whenever the block dialog
        % is opened.  The mask callback fcn for each and every dialog
        % entry is run whenever the dialog is reopened.  Thus, while
        % a model is running and the scope is closed, a simple double-click
        % on the block will open the display (and the block dialog).
        % NOTE: when the sim is not running, a new scope if not opened.
        
        % Toggle checkbox off to simulate a pushbutton:
        if strcmp(block_type,''),
            set_param(blk,'OpenScopeImmediately','off');
        end
        % Open scope figure window:
        feval(sfunname,[],[],[],'OpenScope',blk);    
        
    otherwise
        error('Unknown dynamic dialog callback');
    end
    
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

tab_checks = [1 4 13 23];
checked = isOn(vals(tab_checks(tabNum)));


% --------------------------------------------------------------------
function seeTab = tabContentsAreVisible(vis,tabNum)

% Are the contents of tab # (tabNum) visible?
%
% tab 1: already open if Domain (2) is visible
% tab 2: already open if AxisGrid (5) is visible
% tab 3: already open if YMin (20) is visible
% tab 4: already open if LineDisables (24) is visible
%
openChecks = [2 5 20 24];
seeTab  = isOn(vis(openChecks(tabNum)));

% --------------------------------------------------------------------
function vis = closeTab(vis,tabNum)

tab_entries = {2:3, [5:10 12], 14:22, 24:27}; % don't show dialog #11 -> OpenScopeImmediately
vis(tab_entries{tabNum}) = {'off'};

% --------------------------------------------------------------------
function [vis,vals] = openTab(vis,vals,tabNum)

% Open tab number tabNum (1 thru 4)
% Only one tab should be open at a time

tab_checks = [1 4 13 23];
tab_entries = {2:3, [5:10 12], 14:22, 24:27}; % don't show dialog #11 -> OpenScopeImmediately

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


% --------------------------------------------------------------------
function [vis,prompts] = updateDomainState(vis,vals,prompts,blk)

% Set enabled state of FFT Length edit box
ScopeProps = vals{1};
domain     = vals{2};
AxisProps  = vals{13};

if isOn(ScopeProps),
    switch domain
    case 'Time'
        vis{3}='on';
        prompts{3} = 'Time display span (number of frames):';
    case 'Frequency'
        vis{3}='off';
		prompts{16} = 'Inherit sample time from input';
        prompts{17} = 'Sample time of original time series:';
    otherwise
        % User defined:
        vis{3}='on';
        prompts{3}  = 'Horizontal display span (number of frames):';
		prompts{16} = 'Inherit sample increment from input';
        prompts{17} = 'Increment per sample in input frame:';
    end
end

if isOn(AxisProps),
    switch domain
    case 'Time'
        onList=[]; offList=14:19;
    case 'Frequency'
        onList=[14:17 19]; offList=18;
    otherwise,
        onList=[16:18 ]; offList=[14 15 19];
    end
    vis(onList)={'on'};
    vis(offList)={'off'};
end


% --------------------------------------------------------------------
function y = isOn(str)
y = strcmp(str,'on');


% --------------------------------------------------------------------
function s = getWorkspaceVarsAsStruct(blk)
% Get mask workspace variables:

ss = get_param(blk,'maskwsvariables');

% Only the first "numdlg" variables are from dialog;
% others are created in the mask init fcn itself.
dlg = get_param(blk,'masknames');
numdlg = length(dlg);
ss = ss(1:numdlg);

% Create a structure with:
%   field names  = variable names
%   field values = variable values
s = cell2struct({ss.Value}',{ss.Name}',1);

% [EOF] dspblkfscope2.m
