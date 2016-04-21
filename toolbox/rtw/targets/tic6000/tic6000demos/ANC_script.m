function ANC_script(varargin)
%ANC_SCRIPT   Host-side processing for Adaptive Noise Canceler Demo.
%
%  See "RTDX Host-Side Processing" below for the RTDX-specific 
%       signal handling.
%
%  ANC_SCRIPT(ACTION) 
%       Performs requested ACTION, which can be
%       'run', 'rtdx', 'halt'.
%  ANC_SCRIPT(ACTION, NEWMU) 
%       ACTION = 'change_mu'; NEW_MU is a
%       numeric value defining LMS step size

% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:01:08 $
% Copyright 2001-2004 The MathWorks, Inc.

action = varargin{1};

% find desired board
modelName = gcs;
[boardNum,procNum] = c6000tgtpref('getBoardProcNums',modelName);

% create CCSDSP object (call constructor)
CCS_Obj = ccsdsp('boardnum',boardNum,'procnum',procNum);

hsrtdx = isUsingHighSpeedRTDX_TItarget;

switch lower(action)
    
    case 'run'
        disp('Starting demo...');
        
        CCS_Obj.visible(1);
        
        % construct full path name of demo
        fullModelName = fullfile('.', [modelName '_c6000_rtw'], modelName);
        
        if exist([fullModelName '.out']),
            CCS_Obj.reset;
            
            % save warning present state, and turn off warning
            saveState = warning;
            warning off
            try
                % reload previously generated project
                CCS_Obj.open([fullModelName '.pjt'],'project');
            catch
                % don't error if project does not exist
            end
            % restore warning state
            warning(saveState);
            
            CCS_Obj.load([fullModelName '.out'],100);
            pause(0.1);
            
            %run demo
            CCS_Obj.run;
            
        else % generate code and build target project
            load_system(modelName) 
            make_rtw
        end
        
    case 'rtdx',
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%  RTDX Host-Side Processing
        
        r = CCS_Obj.rtdx;
        
        % configure RTDX
        r.disable;
        r.open('outTaps', 'r');
        r.enable('outTaps');
        if hsrtdx,
            r.open('Err', 'r');
            r.enable('Err');
        end
        r.configure(64000,4,'non-continuous');
        r.enable;
        
        % set up 3-D waterfall plot
        if hsrtdx,
            M = 8;  % # traces
            N = 32; % data points per trace
            numSets = 2;  % # of trace sets to plot
            [s, xlim, hfig] = setupWFallPlot_hsrtdx(M,N,numSets);
            ap = setupAudioPlot_hsrtdx;
        else
            [x,y,z,s,M,N,numSets,totTraces,xlim,hfig] = setupPlot;
        end

 
        % Save handle to figure in block in model
        blk = gcb;
        set_param([bdroot(blk) '/HaltBlock'],'UserData', hfig);
       
        % initialize pause value between traces
        plotDelay=0;
        drawnow;
        
        while 1,
            try,
                for n = 1:numSets;
                    tic;
                    numMsgs = r.msgcount('outTaps');
                    if (numMsgs > 1),
                        % flush frames as necessary to maintain real-time display of taps
                        r.flush('outTaps',numMsgs-1);
                        plotDelay = 0;
                    end
                    
                    % get new RTDX data from DSP
                    data = r.readmsg('outTaps', 'single');
                    data = reshape(data,M,N);
                    
                    if ~hsrtdx,
                        % determine pause value between traces for uniform display
                        % updates
                        RTDXperiod = toc;
                        plotDelay = plotDelay + RTDXperiod/M;
                    end
                    
                    for i=1:M,
                        % refresh plot
                        x=get(s,'xdata'); % get data from all traces
                        if hsrtdx,
                            x(2:end)=x(1:end-1);  % move trace data back by one trace
                        else
                            x(2:totTraces)=x(1:totTraces-1);  % move trace data back by one trace
                        end
                        
                        x(1) = {[xlim(1) data(i,:) xlim(1)]};  % add endpoints
                        set(s,{'xdata'},x);
                        drawnow;
                        if hsrtdx
                            % update audio in/out from DSP
                            numMsgs = r.msgcount('Err');
                            if (numMsgs > 1),
                                % flush frames as necessary to maintain
                                %   real-time display
                                r.flush('Err', numMsgs-1);
                            end
                            dataErr = r.readmsg('Err', 'single');
                            set(ap.line(1),'ydata',dataErr);
                            
                        else
                            pause(plotDelay);
                        end
                    end
                end
            catch,
                % if any errors with plotting, disable RTDX
                r.disable('outTaps');
                if hsrtdx,
                    r.disable('Err');
                end
                r.disable;
                close all;
                return
            end
        end
        
    case 'change_mu',
        newMu = varargin{2}
        r = CCS_Obj.rtdx;
        
        try
            r.open('iMu','w');
            r.enable('iMu');
            r.enable;
        catch
            % must have configured it already
        end
        r.writemsg('iMu',single(newMu));
                
    case 'halt',

        disp('Ending demo...');
        hfig = get_param(gcbh, 'UserData');
        Terminate(hfig,[]);
        % clean up RTDX
        try
            r.disable('outTaps');
            if hsrtdx,
                r.disable('Err');
            end
            r.disable;
        catch
            % if channels are not open, nothing to close
        end
        CCS_Obj.reset;
        clear CCS_Obj;
        return
        
    otherwise,
        error('Unsupported callback');
end 


% -------------------------------------------------------------------------
function [x,y,z,s,M,N,numSets,totTraces,xlim,hfig] = setupPlot
% This function handles plotting for the Non-High-Speed RTDX version.

% A time-domain example
M=8;   % # traces
N=32;  % data points per trace for dummy data
numSets=5; % # of trace sets to plot
totTraces = M*numSets;
xlim = [-.3 .5];  % data range

% setup transparency factors
alpha=linspace(.5,.1,totTraces);         % identical translucency
edgealpha = linspace(0.65,.15,totTraces);  % decreasing edges

% setup patches
hfig = figure('numbertitle','off', ...
    'name','LMS Filter Coefficients', ...
    'vis','off', ...
    'integerhandle','off', ...
    'deletefcn', @DisableRTDX);
colormap(jet(totTraces))
hilite_idx=1;
for i=1:totTraces,
    x=[xlim(1) zeros(1,N) xlim(1)];
    y=[1 1:N N];
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
grid on;
set(gca, ...
    'xlim',xlim, ...
    'ylim',[0 N+1], ...
    'zlim', [1 totTraces], ...
    'pos', [.05 .05 .85 .95]);
set(gca,'CameraPosition',cam_view{1},'CameraUpVector',cam_view{2})

% turn on camera toolbar
set(0,'showhid','on');  % in case gca resolution fails
cameratoolbar('NoReset');
cameratoolbar('SetMode','orbit');
cameratoolbar('SetCoordSys','x');  % or 'none'
set(0,'showhid','off');

% draw labels
xh = xlabel('Amplitude');
yh = ylabel('Tap Position');
zh = zlabel('Frames');
set(xh,'position',[0.4 19 -16]);
set(yh,'position',[0 6 -18]);
set(zh,'position',[0 -22 6]);
set(zh,'rotation',0);
set(xh,'rotation',90);
set(xh,'fontweight','bold');
set(yh,'fontweight','bold');
set(zh,'fontweight','bold');

% insert title label
uicontrol('style','text', ...
'units','norm', ...
    'fontsize',14, ...
    'fontweight','bold', ...
    'backgr',[.8 .8 .8], ...
    'pos',[0 .9 1 .1], ...
    'horiz','center', ...
    'string','RTDX Tap Updates');

% Final tweaks:
axis('vis3d')
camzoom(.9);
set(gca,'pos',[0 0 .95 .95]);
set(hfig, ...
    'pos',[12 222 442 440], ...
    'color',[.8 .8 .8], ...
    'vis','on');


% -------------------------------------------------------------------------
function ap = setupAudioPlot_hsrtdx

ap.hfig = figure('numbertitle','off', ...
    'name','Audio Signals', ...
    'vis','off', ...
    'integerhandle','off', ...
    'pos', [463 223 560 440], ...
    'deletefcn', @DisableRTDX);

Nsigs = 1;
for i=1:Nsigs,
    ap.hax(i) = subplot(Nsigs,1,i);
    ap.line(i) = line('parent',ap.hax(i), ...
        'xdata', 1:256, ...
        'ydata', NaN*ones(1,256), ...
        'linewidth', 2, ...
        'erase','xor');
end
set(ap.hax, ...
    'drawmode','fast', ...
    'ylim',[-.5 .5], ...
    'xlim',[1 256]);
set(ap.hfig,'vis','on');
grid on
title('Audio Output Signal');
xlabel('Time (samples)');
ylabel('Amplitude');

% -------------------------------------------------------------------------
function [s,xlim,hfig] = setupWFallPlot_hsrtdx(M,N,numSets)

% A time-domain example
totTraces = M*numSets;
xlim = [-.3 .5];  % data range

% setup transparency factors
alpha=linspace(.5,.1,totTraces);         % identical translucency
edgealpha = linspace(0.65,.15,totTraces);  % decreasing edges

% setup patches
hfig = figure('numbertitle','off', ...
    'name','LMS Filter Coefficients', ...
    'vis','off', ...
    'integerhandle','off', ...
    'deletefcn', @DisableRTDX);
colormap(jet(totTraces))
hilite_idx=1;
for i=1:totTraces,
    x=[xlim(1) zeros(1,N) xlim(1)];
    y=[1 1:N N];
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
grid on;
set(gca, ...
    'xlim',xlim, ...
    'ylim',[0 N+1], ...
    'zlim', [1 totTraces], ...
    'pos', [.05 .05 .85 .95]);
set(gca,'CameraPosition',cam_view{1},'CameraUpVector',cam_view{2})

% turn on camera toolbar
set(0,'showhid','on');  % in case gca resolution fails
cameratoolbar('NoReset');
cameratoolbar('SetMode','orbit');
cameratoolbar('SetCoordSys','x');  % or 'none'
set(0,'showhid','off');

% draw labels
xh = xlabel('Amplitude');
yh = ylabel('Tap Position');
zh = zlabel('Frames');
% set(xh,'position',[0.4 19 -16]);
% set(yh,'position',[0 6 -18]);
% set(zh,'position',[0 -22 6]);
set(zh,'rotation',0);
set(xh,'rotation',90);
set(xh,'fontweight','bold');
set(yh,'fontweight','bold');
set(zh,'fontweight','bold');

% insert title label
uicontrol('style','text', ...
'units','norm', ...
    'fontsize',14, ...
    'fontweight','bold', ...
    'backgr',[.8 .8 .8], ...
    'pos',[0 .9 1 .1], ...
    'horiz','center', ...
    'string','RTDX Tap Updates');

% Final tweaks:
axis('vis3d')
camzoom(.9);
set(gca,'pos',[0 0 .95 .95]);
set(hfig, ...
    'pos',[12 222 442 440], ...
    'color',[.8 .8 .8], ...
    'vis','on');


% -------------------------------------------------------------------------
function DisableRTDX(hco, eventStruct)
% this function is called if the RTDX figure window is close by the user

modelName = gcs;
[boardNum,procNum] = c6000tgtpref('getBoardProcNums',modelName);

% create CCSDSP object (call constructor)
CCS_Obj = ccsdsp('boardnum',boardNum,'procnum',procNum);
r = CCS_Obj.rtdx;

% disable RTDX
try
    r.disable('outTaps');
    r.disable;
catch
    % if channels are not open, nothing to close
end


% -------------------------------------------------------------------------
function Terminate(hco, eventStruct)
% clean up end of demo

% close figure window
hfig = hco; % gcbf
if ishandle(hfig),
    set(hfig,'DeleteFcn','');
    close(hfig);
end
close all

% [EOF] ANC_script.m
