function varargout = dspblkbfftscope2(action, varargin)
% DSPBLKBFFTSCOPE2 Signal Processing Blockset Buffered FFT scope block helper function.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.8.4.4 $ $Date: 2004/04/12 23:06:02 $

% Params structure fields:
% ( 1) ScopeProperties: checkbox
%   2  Domain: 0=Time, 1=Frequency, 2=User Defined
%   3  HorizSpan: Horizontal time span (number of frames)
%   4 useBuffer: checkbox
%   5 BufferSize: edit box
%   6 Overlap: edit box
%   7 inpFftLenInherit: checkbox
%   8 FFTlength: edit box
%   9 NumAvg: edit obx
%
% (10) DisplayProperties: checkbox
%  11  AxisGrid: checkbox
%  12  Memory: checkbox
%  13  FrameNumber: checkbox
%  14  AxisLegend: checkbox
%  15  AxisZoom: checkbox
%  16  OpenScopeAtSimStart: checkbox
%  17  OpenScopeImmediately: checkbox
%  18  FigPos: figure position
%
% (19) AxisProperties: checkbox
%  20  XUnits:
%       User, Time: ignored
%       Freq: 0=Hz, 1=rad/sec
%  21  XRange:
%       User, Time: ignored
%       Freq: 0=[0,Fn] , 1=[-Fn,Fn], 2=[0, Fs]
%                 (Fn=Nyquist rate, Fs=Sample rate)
%  22  InheritXIncr: checkbox
%  23  XIncr: increment of x-axis samples, used for x-axis display
%       Time: ignored (assumes frame-based)
%       Freq: Only displayed if data was zero-padded
%       User: seconds per sample
%  24  XLabel:
%       Time, Frequency: ignored
%       User: displayed
%  25  YUnits:
%       User, Time: ignored
%       Freq: 0=Magnitude, 1=dB
%  26  YMin: minimum Y-limit
%  27  YMax: maximum Y-limit
%  28  YLabel:
%       Always used
%
% (29) LineProperties: checkbox
%  30  LineDisables: pipe-delimited string
%  31  LineStyles: pipe-delimited string
%  32  LineMarkers: pipe-delimited string
%  33  LineColors: pipe-delimited string


if nargin==0, action = 'dynamic'; end
blk = gcb;
domain = get_param(blk,'Domain');

switch action
case 'icon'
    
    if ~strcmp(domain,'Frequency'),
        error('Invalid domain for Spectrum Scope');
    end
    x = [0 NaN 100 NaN ...
            8 8 92 92 8 NaN 16 16 84 NaN 24 24 NaN 32 32 32 NaN ...
            40 40 NaN 48 48 NaN 56 56 NaN 64 64 NaN ...
            80 80 80 80 NaN 72 72 72];
    y = [0 NaN 100 NaN ...
            92 40 40 92 92 NaN 88 48 48 NaN 76 48 NaN 65 48 48 NaN ...
            79 48 NaN 60 48 NaN 58 48 NaN 64 48 NaN ...
            49 49 48 48 NaN 48 48 54];
    
    useBuffer = isOn(get_param(blk,'useBuffer'));
    if useBuffer,
        str='B-FFT';
    else
        str='FFT';
    end
    
    varargout(1:3) = {x,y,str};
    
case 'init'
    % Two steps:
    
    % 1. Copy and return all mask dialog entries as a structure

    s = getWorkspaceVarsAsStruct(blk);
    varargout{1} = s;
    sdspfscope2([],[],[],'DialogApply',s);
    
    % 2. Update checkbox for inheriting FFT size
    
    % Determine "Inherit FFT length" checkbox setting
    specifyFft_check = get_param(blk,'inpFftLenInherit');
    if isOn(specifyFft_check),
	    inhFft_check = 'off';
    else
        inhFft_check = 'on';
    end
    stfft_blk   = [blk '/Periodogram'];
    stfft_check = get_param(stfft_blk,'inheritFFT');
    
    changePending = ~strcmp(inhFft_check, stfft_check);
    if changePending,
        set_param(stfft_blk, 'inheritFFT', inhFft_check);
    end
    
    
case 'dynamic'
    
    opt = varargin{1};
    
    vis = get_param(blk,'maskvisibilities');
    orig_vis = vis;
    ena = get_param(blk,'maskenables');
    orig_ena = ena;
    prompts = get_param(blk,'maskprompts');
    orig_prompts = prompts;
    vals = get_param(blk,'maskvalues');
    orig_vals = vals;
    
    props = {'ScopeProperties','DisplayProperties','AxisProperties','LineProperties'};
    
    switch opt
    case 'FftLenCheckbox'
        vis = updateFFTLenState(vis,vals,blk);
        
    case 'useBuffer'
        vis = updateBufferState(vis,vals,blk);
        
    case props
        % Set visibility of scope properties:
        sw = strmatch(opt,props);
        [vis,vals] = openTabIfSelected(vis,vals,sw);
        
        % Update all other dependent items after switching tabs:
        vis           = updateFFTLenState(vis,vals,blk);
        vis           = updateBufferState(vis,vals,blk);
        [vis,prompts] = updateStandardStuff(vis,prompts,blk);
        
	case 'InheritXIncr'
		% Enable XIncr if InheritXIncr off (not checked)
		if strcmp(vals{22},'off'), sw='on'; else sw='off'; end
		ena{23} = sw;
		
    case 'OpenScope'
        % Open scope GUI in response to "immediate" toggle
        
        % Always attempt to open the scope whenever the block dialog
        % is opened.  The mask callback fcn for each and every dialog
        % entry is run whenever the dialog is reopened.  Thus, while
        % a model is running and the scope is closed, a simple double-click
        % on the block will open the display (and the block dialog).
        % NOTE: when the sim is not running, a new scope if not opened.
        
        % Toggle checkbox off to simulate a pushbutton:
        set_param(blk,'OpenScopeImmediately','off');
        % Open scope figure window:
        sdspfscope2([],[],[],'OpenScope',blk);
        
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

tab_checks = [1 10 19 29];
checked = isOn(vals(tab_checks(tabNum)));


% --------------------------------------------------------------------
function seeTab = tabContentsAreVisible(vis,tabNum)

% Are the contents of tab # (tabNum) visible?
%
% tab 1: already open if inpFftLenInherit (7) is visible
% tab 2: already open if AxisGrid (11) is visible
% tab 3: already open if XUnits (20) is visible
% tab 4: already open if LineDisables (30) is visible
%
open_checks = [7 11 20 30];
seeTab  = isOn(vis(open_checks(tabNum)));

% --------------------------------------------------------------------
function vis = closeTab(vis,tabNum)

tab_entries = {3:9, [11:16 18], 20:28, 30:33}; % don't show dialog #17 -> OpenScopeImmediately
vis(tab_entries{tabNum}) = {'off'};

% --------------------------------------------------------------------
function [vis,vals] = openTab(vis,vals,tabNum)

% Open tab number tabNum (1 thru 4)
% Only one tab should be open at a time

tab_checks = [1 10 19 29];
tab_entries = {3:9, [11:16 18], 20:28, 30:33}; % don't show dialog #17 -> OpenScopeImmediately

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
function vis = updateFFTLenState(vis,vals,blk)

% Set enabled state of FFT Length edit box
ScopeProps    = vals{1};  % ScopeProperties
specifyFFTLen = vals{7};  % inpFftLenInherit

if isOn(ScopeProps),
    vis(8) = {specifyFFTLen};  %  FFT Length
end


% --------------------------------------------------------------------
function [vis] = updateBufferState(vis,vals,blk)

% Set enabled state of FFT Length edit box
ScopeProps          = vals{1};  % ScopeProperties
useBuffer           = vals{4};  % usebuffer
if isOn(ScopeProps),
    vis([5 6]) = {useBuffer};  % BufferSize and Overlap
end


% --------------------------------------------------------------------
function [vis,prompts] = updateStandardStuff(vis,prompts,blk)

% Turn off several standard Frame-Scope options, since
% this scope only operates in the frequency domain:
vis([2 3 24]) = {'off'};  % Domain, HorizSpan, XLabel
% XIncr label:
prompts{23} = 'Sample time of original time series:';


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


% [EOF] dspblkbfftscope2.m
