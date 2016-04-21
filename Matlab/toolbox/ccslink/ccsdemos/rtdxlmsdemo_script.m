function rtdxlmsdemo_script(boardNum, procNum, varargin)
%RTDXLMSDEMO_SCRIPT Run RTDX(tm) automation demo.
%   RTDXLMSDEMO_SCRIPT(BOARD,PROC,FILTERORDER,FRAMESIZE,NUMFRAMES)
%   demonstrates the use of RTDX methods to transfer data between MATLAB and the
%   target TI(tm) DSP.  The target application adaptively cancels broadband 
%   noise by employing a normalized LMS algorithm.
%    
%   Unfiltered noise data along with the signal plus low-pass filtered noise 
%   data are transferred to the target DSP by employing RTDX object methods.
%   The target DSP applies the adaptive LMS algorithm and sends back to the 
%   MATLAB workspace the estimated low-pass filter taps at each iteration along 
%   with the streaming filtered time series data.
%
%   Plots include the incremental tap updates and frequency responses, and time
%   series data of signal, signal plus noise, and the filtered signal plus 
%   noise.
%
%   This function connects to the target DSP specified by the board number, 
%   BOARD, and processor number, PROC.  The lengths of the tapped delay lines 
%   for the low pass FIR and the nLMS filter are identically specified by 
%   FILTERORDER.  The frame size is specified by FRAMESIZE, and the number of 
%   frames to process by NUMFRAMES.
%
%   RTDXLMSDEMO_SCRIPT(BOARD,PROC,FILTERORDER,FRAMESIZE) is the same as 
%   the above calling syntax with NUMFRAMES defaulting to 1.
%
%   RTDXLMSDEMO_SCRIPT(BOARD,PROC,FILTERORDER) is the same as above with
%   FRAMESIZE defaulting to 256.
%
%   RTDXLMSDEMO_SCRIPT(BOARD,PROC) is the same as above with FILTERORDER
%   defaulting to 32.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.5 $  $Date: 2004/04/06 01:04:36 $


% Increase timeout if not enough. 
TimeOut = 50;   %in seconds

% Parse and validate the inputs
[errMsg, filterOrder, frameSize, numFrames] = ...
    parse_args(boardNum, procNum, varargin{:});
error(errMsg);

% ========================================================================
% Generate broadband noise vector (filter input)

% Following defaults apply, if not specified

% filterOrder = 32;
% frameSize = 256;
% numFrames = 2

% Create signal and noise vectors
startN(1) = 1;
startD(1) = 1;
stopN(1) = frameSize;
stopD(1) = frameSize+filterOrder-1;

for i=2:numFrames,
    startN(i) = stopN(i-1)+1;
    stopN(i) = startN(i)+frameSize-1;
    startD(i) = stopD(i-1)+1;
    stopD(i) = startD(i)+frameSize-1;
end

outBuf = frameSize;  % coeff buffer size
noise = randn(1,frameSize*numFrames);
maxVal = max([max(noise) abs(min(noise))]);
shiftBits = 15-nextpow2(maxVal)-2;
scale = 2^(shiftBits);

noise_int16 = double2int16(noise, scale);

% Filter broadband noise
cutOffFreq = 0.5;
filteredNoise = demo_fir(filterOrder, cutOffFreq, noise);
filteredNoise_int16 = double2int16(filteredNoise, scale);

% Generate 440 Hz pure tone signal
f=440; fs=8000; t=0:(frameSize*numFrames)+filterOrder-2;
CW = sin(2*pi*f*t/fs);
CW_int16 = double2int16(CW, scale);

% Signal + filtered noise
S_N = CW + filteredNoise;
S_N_int16 = double2int16(S_N, scale);

% Construct code composer/rtdx object
cc = ccsdsp('boardnum',boardNum,'procnum',procNum);

% Check if rtdx-capable before proceeding
if ~isrtdxcapable(cc)
    uiwait(msgbox({'RTDX is not supported for the selected board,  '; 
        'please select another board'},...
        'Selection Error','modal'));   
    clear cc;
    return
end

% Check if CCS Link supports RTDX on such processor
procname = getproc(cc);
if ~any(strcmpi(procname,{'c64x','c67x','c62x','c54x','c55x','c28x'})) % NOT c6x,c54x,c55x
    errordlg(['Demo does not run on the ' upper(procname) ' subfamily. Please select another processor.'],...
        'Processor Not Supported','modal');
    clear cc;
    return;
end

% GEL reset - warning
uiwait(msgbox({'You may need to manually load the appropriate GEL file ';...
    'in CCS (e.g. c5416_dsk.gel) before continuing with the demo.'}, ...
    'Warning: Reset GEL','modal'));
drawnow;

% Set up filter response window:
%-- [filtWin, hFig] = SetupFilterPlot(filterOrder); % 2d plotting
[x1,y1,z1,ss1,M1,N1,numSets1,totTraces1,xlim1,hfig_tapcoef] = ...
    Setup3dPlot(filterOrder,'filtercoeffs_win');
[x2,y2,z2,ss2,M2,N2,numSets2,totTraces2,xlim2,hfig_hfreq] = ...
    Setup3dPlot(length((0:127)/127*4000),'filterresp_win');

%-- pause(2.0);

% ========================================================================
% Processor specific files needed to run the demo
[hresult,projname,outFile,target_subdir,notReady,c5x,c2x] = GetTargetInfo(cc);
if hresult==0,
    clear cc;
    %-- close(hFig);
    close(hfig_tapcoef);
    close(hfig_hfreq);
    return
end

%===========================================================================

% Change directory to target demo directory and
%   Open target file
target_dir = fullfile(matlabroot,'toolbox','ccslink','ccsdemos','rtdxlms',...
    target_subdir);
cd(cc,target_dir)

fprintf('Loading COFF file to target DSP...\n');
try
    reset(cc);
    pause(0.5);
    load(cc,outFile,30);
catch
    % close Figure, and display error
    clear cc;
    close(hFig);
    errordlg({'There is a problem loading the COFF file for the selected processor.';...
            'You may need to rebuild project with appropriate linker command file.'},...
        'Load Error' , 'modal');
    return
end

% Configure channel buffers
cc.rtdx.configure(10000,4);   % define 4 channels buffers of 10000 bytes each

fprintf('Opening RTDX channels...\n');

% Open write channel
cc.rtdx.open('ichan0','w','ichan1','w');

% Open read channels
cc.rtdx.open('ochan0','r');

% Enable all open channels
cc.rtdx.enable('all');

% Enable RTDX
cc.rtdx.enable;

% Overwrite global timeout value
cc.rtdx.set('timeout', TimeOut)            % in seconds

% Display channel information
cc.rtdx

% Write to filter parameters to target DSP
fprintf('Writing filter parameters to target...\n\n');
filtParms = [filterOrder frameSize numFrames shiftBits];
cc.rtdx.writemsg('ichan0', int16(filtParms));

for ct = 1:numFrames,
    % Write to target DSP
    fprintf('Writing noise and signal + noise to target - frame %d...\n',ct);
    cc.rtdx.writemsg('ichan0', noise_int16(startN(ct):stopN(ct)));
    cc.rtdx.writemsg('ichan1', S_N_int16(startD(ct):stopD(ct)));
end
fprintf('\n');

% Run target
fprintf('Running target application...\n\n');
run(cc);

outError = zeros(1,frameSize);
s = PlotSignalIO(outError,CW,S_N);

yLines = [s.FiltOut s.SigPlusNoise s.Input];
allNaN = NaN*ones(1,frameSize);
set(yLines, ...
    'EraseMode', 'xor', ...
    'xdata',1:frameSize, ...
    'ydata',allNaN);

%--
% initialize pause value between traces
plotDelay=0;
%--

for ct = 1:numFrames,
    % Reset display to all NaN at start of each frame:
    set(yLines, 'ydata', allNaN);
    
    fprintf(['Reading coefficient updates and filtered results from '...
            'target - frame %d...\n'],ct);
    
    numPerBlock = outBuf/filterOrder;    %%% frameSize/filterOrder
    numBlocks   = frameSize/numPerBlock; %%% frameSize
    
    for i=1:numBlocks,
        % tic;
        
        lasterr('');
        try
            outCoeff_int16 = cc.rtdx.readmsg('ochan0', 'int16');
        catch
            disp(lasterr);
            if findstr(upper(lasterr),'TIMEOUT')
                displayError(cc.rtdx.timeout);
            end
            return
        end
        outCoeff = int16todouble(outCoeff_int16,scale);
        
        for j=1:numPerBlock,
            startIdx = (j-1)*filterOrder+1;
            endIdx = startIdx + filterOrder-1;
            hTaps_ydata = fliplr(outCoeff(startIdx:endIdx));
            %-- set(filtWin.hTaps, 'ydata',hTaps_ydata);
            
            ff = fft(fliplr(double(outCoeff(startIdx:endIdx))), 256);
            ff = 20*log10(abs(ff(1:128)));
            fmax = max(ff);
            hFreq_ydata = ff-fmax;
            %-- set(filtWin.hFreq, 'ydata', hFreq_ydata);

            % Start 3d plotting (some lines are commented for speed)
            % % determine pause value between traces for uniform display
            % % updates
            % RTDXperiod = toc;
            % plotDelay = plotDelay + RTDXperiod/M1;
            for traceCnt=1:M1,
                % refresh plot
                x1=get(ss1,'xdata'); % get data from all traces
                x1(2:totTraces1)=x1(1:totTraces1-1);  % move trace data back by one trace
                
                x1(1) = {[xlim1(1) hTaps_ydata xlim1(1)]};  % add endpoints
                set(ss1,{'xdata'},x1);
                drawnow;
                % pause(plotDelay);
                
                % refresh plot
                x2=get(ss2,'xdata'); % get data from all traces
                x2(2:totTraces2)=x2(1:totTraces2-1);  % move trace data back by one trace
                
                x2(1) = {[xlim2(1) hFreq_ydata xlim2(1)]};  % add endpoints
                set(ss2,{'xdata'},x2);
                drawnow;
                % pause(plotDelay);
            end
            
        end
        
         if ~c5x && ~c2x,
            % Update signal plots
            % a. Get signal indices:
            x=(i-1)*numPerBlock+1;
            y=(i-1)*numPerBlock+numPerBlock;
            xx = x + (ct-1)*frameSize;
            yy = y + (ct-1)*frameSize;
            % b. Update plot data: 
            yAll=get(yLines,'ydata');
            yAll{1}(x:y) = int16todouble(cc.rtdx.readmsg('ochan0', 'int16'),scale);
            yAll{2}(x:y) = S_N(xx:yy);
            yAll{3}(x:y) = CW(xx:yy);
            set(yLines,{'ydata'},yAll);
            drawnow;
        end
    end
    if c5x || c2x, % plot frame of time-series
        yAll=get(yLines,'ydata');
        yAll{1} = int16todouble(cc.rtdx.readmsg('ochan0', 'int16'),scale);
        yAll{2} = S_N(1:frameSize);
        yAll{3} = CW(1:frameSize);
        set(yLines,{'ydata'},yAll);
        drawnow;
    end
    pause(1);
    
end

% Disable all open channels
cc.rtdx.disable('all');

% Disable RTDX
cc.rtdx.disable;

% Close channels
cc.rtdx.close('all');

clear cc;   % Call destructors

fprintf('\n**************** Demo complete. ****************\n\n');


%--------------------------------------------------------------------------
function [errMsg, filterOrder, frameSize, numFrames] = ...
    parse_args(boardNum, procNum, varargin)
% Parse and validate the inputs
% 'msg' is empty if no error occurs.

filterOrder  = [];
frameSize    = [];
numFrames    = [];

errMsg = nargchk(2,5,nargin);
if ~isempty(errMsg), return; end

if ~(isnumeric(boardNum)&isreal(boardNum)&(boardNum>=0)),
    errMsg = 'Board number must be zero or a positive integer';
    return
end

if ~(isnumeric(procNum)&isreal(procNum)&(procNum>=0)),
    errMsg = 'Board number must be zero or a positive integer';
    return
end

if nargin >= 3,
    if (varargin{1} == 16)|(varargin{1} == 32)|(varargin{1} == 64),
        filterOrder = varargin{1};
    else
        errMsg = 'Filter order must be 16, 32, or 64';
    end
    if nargin >= 4,
        if (varargin{2} == 128)|(varargin{2} == 256)|(varargin{2} == 512),
            frameSize = varargin{2};
        else
            errMsg = 'Frame size must be 128, 256, or 512';
        end
        if nargin == 5,
            if (varargin{3} == 1)|(varargin{3} == 2)|(varargin{3} == 4),
                numFrames = varargin{3};
            else
                errMsg = 'Number of frames must be 1, 2, or 4';
            end
        else
            numFrames = 2;
        end
    else
        numFrames = 2;
        frameSize = 256;
    end
else
    numFrames = 2;
    frameSize = 256;
    filterOrder = 32;
end    

%--------------------------------------------------------------------------
function out = double2int16(data,scaleFactor);
out = int16(round(data*scaleFactor));

%--------------------------------------------------------------------------
function out = int16todouble(data,scaleFactor);
out = double(data)/scaleFactor;

%--------------------------------------------------------------------------
function out = demo_fir(order,cutoff,data);
coeff = fir1(order-1,cutoff);
out = conv(coeff,data);

%--------------------------------------------------------------------------
function displayError(timeout)
disp(sprintf(['%g seconds might not be enough time for reading the data messages.\n'...
        'Hit the ''view script'' button and increase the value of the ''TimeOut''\n'...
        'variable at the begining of the script.'],timeout));

%--------------------------------------------------------------------------
function [s, hFig] = SetupFilterPlot(filterOrder)
%SetupFilterResponse
% Returns a structure with:
%   .hTaps
%   .hFreq

% Check for existing figure window
filtTag = 'rtdxlmsdemo_filters';
signalTag = 'rtdxlmsdemo_signal';

s=[];

hFig = findobj('tag',filtTag);
if ~isempty(hFig),
    close(hFig);
end

hFig1 = findobj('tag',signalTag);
if ~isempty(hFig1),
    close(hFig1);
end

hFig = figure(...
    'numbertitle','off', ...
    'name','rtdxlmsdemo - Filter Results', ...
    'IntegerHandle','off', ...
    'units','normalized', ...
    'tag', filtTag, ...
    'pos',[0.01 0.47 0.35 0.45]);


% Setup tap axis
subplot(2,1,1); grid on;
title('Tap Coefficients');
s.hTaps=line;
set(s.hTaps, ...
    'erase','xor', ...
    'color','r');
a = gca;
set(a,'ylim',[-0.2 0.6]);
set(a,'xlim',[0 filterOrder]);

set(get(a,'title'),'fontsize',11);
set(a,'fontsize',8);
set(a,'fontweight','light') ;

% Setup freq axis
subplot(2,1,2); grid on;
title('Filter Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
s.hFreq=line;
set(s.hFreq, ...
    'erase','xor', ...
    'color','r');
b = gca;
set(b,'ylim',[-40 0]);
set(b,'xlim',[0 4000]);

set(get(b,'title'),'fontsize',11);
set(b,'fontsize',8);
set(b,'fontweight','light') ;
x = get(b,'xlabel');
set(x,'fontsize',8);
set(x,'fontweight','light');
y = get(b,'ylabel');
set(y,'fontsize',8);
set(y,'fontweight','light');

set(hFig,'userdata',s);  % Retain structure in figure's UserData field

% Initialize lines
set(s.hTaps, 'xdata',1:filterOrder,    'ydata',zeros(1,filterOrder));
set(s.hFreq, 'xdata',(0:127)/127*4000, 'ydata',zeros(1,128));

figure(hFig);
drawnow;


%--------------------------------------------------------------------------
function s = PlotSignalIO(outError, CW, S_N)
%PlotSignalIO

% Check for existing figure window
signalTag = 'rtdxlmsdemo_signal';
s = [];

hFig = findobj('tag',signalTag);
if ~isempty(hFig),
    close(hFig);
end

hFig = figure( ...
    'numbertitle','off', ...
    'name','rtdxlmsdemo - Signals', ...
    'IntegerHandle','off', ...
    'tag', signalTag, ...
    'units','normalized', ...
    'menubar','Figure', ...
    'pos', [0.37 0.28 0.44 0.64]); 
    %'pos', [0.1300    0.7012    0.7750    0.2238]); 
hax = axes('parent',hFig, ...
    'pos', [0.13 0.701222343126587 0.775 0.223777656873413], ...
    'xlim', [1 length(outError)], ...
    'ylim', [-2 2], ...
    'drawmode','fast', ...
    'xgrid', 'on', 'ygrid', 'on');

set(get(hax,'title'),'fontsize',11);
set(hax,'fontsize',8);
set(hax,'fontweight','light') ;
x = get(hax,'xlabel');
set(x,'fontsize',8);
set(x,'fontweight','light');
y = get(hax,'ylabel');
set(y,'fontsize',8);
set(y,'fontweight','light');

set(get(hax,'title'),'string','Input Signal');
set(get(hax,'ylabel'),'string','Amplitude');
s.Input = line('parent',hax, 'color','b');

hax = axes('parent', hFig, ...
    'pos', [0.13 0.405611171563293 0.775 0.223777656873413], ...
    'xlim', [1 length(outError)], ...
    'ylim', [-2 2], ...
    'drawmode','fast', ...
    'xgrid', 'on', 'ygrid', 'on');
set(get(hax,'title'),'string','Signal + Noise');
s.SigPlusNoise = line('parent',hax, 'color','b');

set(get(hax,'title'),'fontsize',11);
set(hax,'fontsize',8);
set(hax,'fontweight','light') ;
x = get(hax,'xlabel');
set(x,'fontsize',8);
set(x,'fontweight','light');
y = get(hax,'ylabel');
set(y,'fontsize',8);
set(y,'fontweight','light');

hax = axes('parent', hFig, ...
    'pos', [0.13 0.11 0.775 0.223777656873413], ...
    'xlim', [1 length(outError)], ...
    'ylim', [-2 2], ...
    'drawmode','fast', ...
    'xgrid', 'on', 'ygrid', 'on');
set(get(hax,'title'),'string','Filtered Output');
set(get(hax,'xlabel'),'string','Sample Number');
s.FiltOut = line('parent',hax, 'color','b');

set(get(hax,'title'),'fontsize',11);
set(hax,'fontsize',8);
set(hax,'fontweight','light') ;
x = get(hax,'xlabel');
set(x,'fontsize',8);
set(x,'fontweight','light');
y = get(hax,'ylabel');
set(y,'fontsize',8);
set(y,'fontweight','light');

set(hFig,'userdata',s);  % Retain structure in figure's UserData field

figure(hFig); 
drawnow;

%--------------------------------------------------------------------------
function [hresult,projname,outFile,target_subdir,notReady,c5x,c2x] = GetTargetInfo(cc)
ccInfo = info(cc);
board = GetDemoProp(cc,'rtdxlmsdemo');
if (isempty(board.rtdxdemosim) && isempty(board.rtdxdemo))
    uiwait(msgbox({'RTDX is not supported for the selected board,  '; 
        'please select another board'},...
        'Selection Error','modal'));   
    projname=[]; outFile=[]; target_subdir=[]; notReady=[]; c5x=[]; c2x=[];
    hresult = 0;
    return
elseif any(findstr('Simulator',ccInfo.boardname)) % simulator only
    projname = board.rtdxdemosim.projname;
    outFile = board.rtdxdemosim.loadfile;
    target_subdir = board.rtdxdemosim.dir; 
    notReady = 0;
    hresult = 1;
else
    projname = board.rtdxdemo.projname;
    outFile = board.rtdxdemo.loadfile;
    % just a hack for c5416, might or might not work
    if any(findstr('5416',ccInfo.boardname))
        outFile = 'rtdxdemo_5416.out';
    end
    target_subdir = board.rtdxdemo.dir;
    notReady = 0;        
    hresult = 1;
end
if any(strcmp(board.name,{'c54x','c55x'}))
    c5x = logical(1);
    c2x = logical(0);
elseif any(strcmp(board.name,{'c24x','c27x','c28x'}))
    c5x = logical(0);
    c2x = logical(1);
else
    c5x = logical(0);
    c2x = logical(0);
end

%--------------------------------------------------------------------------
function [x,y,z,s,M,N,numSets,totTraces,xlim,hfig] = Setup3dPlot(nylim,figtag)
% x - x data
% y - y data
% z - z data
% s - patches
% M - number of traces to plot a data set
% N - data points per trace
% numSets - number of traces (no. of patches/traces you see on the screen
%           at any given time)
% totTraces - total number of traces
% xlim - x-data limits
% hfig - figure created to hold plot

%-----------------------------------------------------------------------
if strcmp(figtag,'filtercoeffs_win')
    figname  = 'LMS Filter Coefficients';
    plotname = 'Tap Coefficients';
    xLabel   = 'Amplitude';
    yLabel   = 'Tap Position';
    zLabel   = '';
    nylim    = nylim;
    xlim     = [-0.3 0.6]; % data range
    figpos   = [12 555 408 268]; % figure position
    figpos   = [0.0107    0.6341    0.35    0.3177];
else
    figname  = 'LMS Filter Response';
    plotname = 'Filter Response';
    xLabel   = 'Magnitude(dB)';
    yLabel   = 'Frequency(Hz)';
    zLabel   = '';
    nylim    = nylim;
    xlim     = [-50 5]; % data range
    % figtag   = 'filterresp_win';
    figpos   = [12 240 408 270];
    figpos   = [0.0107    0.28    0.35    0.2917];
end
%-----------------------------------------------------------------------

% A time-domain example
M = 1; % 8;             % # traces
N = nylim; % 32;        % data points per trace for dummy data
numSets = 10; % 5;      % # of trace sets to plot
totTraces = M*numSets;

%-----------------------------------------------------------------------

% check if an active figure exists
hfig = findobj('tag',figtag);
if ~isempty(hfig),
    close(hfig);
end

% setup transparency factors
alpha=linspace(.5,.1,totTraces);           % identical translucency
edgealpha = linspace(0.65,.15,totTraces);  % decreasing edges

% setup patches
hfig = figure('numbertitle','off', ...
    'name',figname, ...
    'vis','off', ... % 'on' for debugging only
    'units','normalized',...
    'integerhandle','off', ...
    'tag', figtag,...
    'deletefcn', @DisableRTDX);

colormap(jet(totTraces))
hilite_idx=1;
if strcmp(figtag,'filtercoeffs_win')
    yval = [1 1:N N];
else
    yval = [0 (0:127)/127*4000 4000];
end
for i=1:totTraces,
    x=[xlim(1) zeros(1,N) xlim(1)];
    y=yval;
    z=i*ones(1,N+2);
    s(i)=patch(x,y,z,i, ...
        'cdatamapping','direct', ...
        'facealpha',alpha(i), ...
        'edgealpha',edgealpha(i));
    if i==hilite_idx,
        set(s(i), ...
            'edgealpha',1, ...
            'edgecolor',.15*[1 1 1]);
    end
end

% select camera view:
%   {cameraposition, cameraup}
cam_left = {[1 -22 -15], [1 0 0]};
cam_view = cam_left;

% setup view
if strcmp(figtag,'filtercoeffs_win')
    ylimval = [0 N+1];
else
    ylimval = [0 4000+1];
end
grid on;
set(gca, ...
    'xlim',xlim, ...
    'ylim',ylimval, ...
    'zlim',[1 totTraces], ...
    'pos', [.05 .05 .85 .95]);
set(gca,'cameraPosition',cam_view{1},'cameraupvector',cam_view{2})

% commented because cameratoolbar is showing up
% in main gui and messing up graphics
% ---------------------------------------------
% % turn on camera toolbar 
% set(0,'showhid','on');  % in case gca resolution fails
% cameratoolbar('NoReset');
% cameratoolbar('SetMode','orbit');
% cameratoolbar('SetCoordSys','x');  % or 'none'
% set(0,'showhid','off');

% draw labels
if strcmp(figtag,'filtercoeffs_win')
    xhpos = [0.4 19 -16];
    yhpos = [0 6 -18];
else
    xhpos = [0 4000 -30];
    yhpos = [0 -2000 -60];
end
xh = xlabel(xLabel);
yh = ylabel(yLabel);
zh = zlabel(zLabel);
set(xh,'position',xhpos);
set(yh,'position',yhpos);
set(zh,'position',[0 -22 6]);
set(zh,'rotation',0);
set(xh,'rotation',90);
set(xh,'fontweight','bold');
set(yh,'fontweight','bold');
set(zh,'fontweight','bold');

% insert title label
uicontrol('style','text', ...
    'units','norm', ...
    'fontsize',12, ...
    'fontweight','normal', ...
    'backgr',[.8 .8 .8], ...
    'pos',[0 .9 1 .1], ...
    'horiz','center', ...
    'string',plotname);

% Final tweaks:
axis('vis3d')
camzoom(.9);
set(gca,'pos',[0 0 .95 .95]);
set(hfig, ...
    'pos',figpos, ...
    'color',[.8 .8 .8], ...
    'vis','on');

% -------------------------------------------------------------------------
function DisableRTDX(hco, eventStruct)
% this function is called if the RTDX figure window is close by the user

% modelName = gcs;
% [boardNum, procNum] = getBoardProc(modelName);
% 
% % create CCSDSP object (call constructor)
% CCS_Obj = ccsdsp('boardnum',boardNum,'procnum',procNum);
% r = CCS_Obj.rtdx;
% 
% % disable RTDX
% try
%     r.disable('outTaps');
%     r.disable;
% catch
%     % if channels are not open, nothing to close
% end


% [EOF] rtdxlmsdemo_script.m
