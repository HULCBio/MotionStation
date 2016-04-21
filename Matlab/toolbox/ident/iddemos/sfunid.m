function  [sys, x0, str, ts]  = sfunid(t,x,u,flag,...
    order,npts,HowOften,offset,ts,method,mn,ph)
%SFUNID an S-function which performs system identification.
%   This M-file is designed to be used in a SIMULINK S-function block.
%   It stores up a buffer of input and output points of the system
%   and then uses the System Identification Toolbox to identify a linear
%   model.
%
%   The input arguments are
%     order:          the orders of the model (usually a vector)
%     npts:           number of points to use in the fft (e.g. 128)
%     HowOften:       how often to plot the ffts (e.g. 64)
%     offset:         sample time offset (usually zeros)
%     ts:             how often to sample points (secs)
%     method:         the method to use which may one of:
% 	              'ar', 'arx', 'oe', 'armax', 'bj', 'pem'.
%
%   The system id. block displays two plots: the time history of actual
%   data versus predicted data and the associated error terms.
%
%   See also SIMIDENT, SFUNTMPL.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $ $Date: 2004/04/10 23:16:10 $
%   Andrew Grace 5-30-91.
%   Charlie Ko 10-15-96.

switch flag,
    
    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes(npts,HowOften,offset,ts);
        
        %%%%%%%%%%
        % Update %
        %%%%%%%%%%
    case 2,
        sys=mdlUpdate(t,x,u,order,npts,HowOften,offset,ts,method,mn,ph);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Derivatives, Output, Terminate  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {1,3,9}
        sys = []; %do nothing
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        % CopyBlock, LoadBlock %
        %%%%%%%%%%%%%%%%%%%%%%%%
    case { 'CopyBlock', 'LoadBlock' }
        LocalCopyLoadBlock
        
        %%%%%%%%%%%%%%%
        % DeleteBlock %
        %%%%%%%%%%%%%%%
    case 'DeleteBlock'
        LocalDeleteBlock
        
        %%%%%%%%%%%%%%%%
        % DeleteFigure %
        %%%%%%%%%%%%%%%%
    case 'DeleteFigure'
        LocalDeleteFigure
        
    otherwise
        error(['unhandled flag = ',num2str(flag)]);
end

% end of sfunid



%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(npts,HowOften,offset,ts)

if HowOften > npts
    error(['The number of points in the buffer must be more '...
            'than the plot frequency'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 2*npts+2;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(2*npts+2,1);

str = [];
ts  = [ts offset];

%
% The first discrete state is a counter, initialize it to 1
%
x0(1) = 1;


%
% If the simulation is initializing, then initialize the figure window
%
if strcmp(get_param(bdroot,'SimulationStatus'),'initializing')
    SfunIDFigure('Initialize');
end

% end mdlInitializeSizes



%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,order,npts,HowOften,offset,ts,method,mn,ph)

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=SfunIDFigure('Get');
if ~ishandle(FigHandle),
    sys=[];
    return
end

%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');

%
% Reshape the discrete state vector.
%
x = reshape(x(1:2*(npts+1)),npts+1,2);

%
% initialize the return argument
%
sys = zeros(npts+1,2);
sys(:) = x;

%
% increment the counter and store the current input in the discrete state
% referenced by this counter
%
x(1,1) = x(1,1) + 1;
sys(x(1,1),:) = u(:)';

div = x(1,1)/HowOften;
if (div == round(div))
    u = [sys(x(1,1)+1:npts+1,1);sys(2:x(1,1),1)];
    y = [sys(x(1,1)+1:npts+1,2);sys(2:x(1,1),2)];
    %e = [sys(x(1,1)+1:npts+1,3);sys(2:x(1,1),3)];
    tvec = (t - ts * npts + ts * (1:npts));
    
    if length(method)==2 & all(method(1:2) == 'ar')
        u = [];
    end
    
    th = feval(method, [y u], order);
    if ~isempty(mn)
        temp = evalin('base',mn);
        temp = [temp;{t,th}];
        assignin('base',mn,temp)
    end
    if isinf(ph)
        yest = sim(u,th);
    else
        yest = predict([y u],th,ph);
    end
    if isempty(mn) % info to screen
        % Conversion to transfer function form:
        [A,B,C,D,F]=polyform(th);
        
        disp('')
        disp('Transfer function:')
        
        if ~isempty(F)
            d = conv(A,F);
        else
            d = [];
        end
        
        bl = length(B); dl = length(d);
        nl = max(bl,dl);
        num = [B zeros(1,nl-bl)];
        den = [d zeros(1,nl-dl)];
        if exist('printsys')	% If have control toolbox
            eval('printsys(num,den,''z'')');
        else
            num, den
        end
        %   if length(den)
        %     yest = filter(num,den,u);
        %   else
        %     yest = zeros(npts,1);
        %   end
        
        disp('')
        disp('Noise model:')
        d = conv(A,D);
        al = length(A);
        cl = length(C);
        dl = length(d);
        nl = max(al,dl);
        num = [C zeros(1,nl-cl)];
        den = [d zeros(1,nl-dl)];
        if exist('printsys')	% If have control toolbox
            eval('printsys(num,den,''z'')');
        else
            num, den
        end
    end
    
    
    % plot the inputs lines for the first subplot.
    if isinf(ph)
        str = 'Simulated';
    else
        str = 'Predicted';
    end
    set(ud.SysInputAxis,'Visible','on',...
        'Xlim',[min(tvec) max(tvec)],...
        'Ylim',[min(yest) max(yest)+eps]);
    set(ud.SysInputLine1,'Xdata',tvec,'Ydata',y,'LineStyle','-');
    set(ud.SysInputLine2,'Xdata',tvec,'Ydata',yest,'LineStyle','-');
    set(ud.SysInputTitle,'String',...
        ['Actual Output (Red Line) vs. The ',str,' Predicted Model output (Blue Line)']);
    
    % plot the error.
    err = yest-y;
    set(ud.SysErrorAxis,'Visible','on',...
        'Xlim',[min(tvec) max(tvec)],...
        'Ylim',[min(err) max(err)]);
    set(ud.SysErrorLine,'Xdata',tvec,'Ydata',err);
    set(ud.SysErrorTitle,'String',['Error In ',str,' Model']);
    
    drawnow
end

if sys(1,1) == npts
    x(1,1) = 1;
end

sys(1,1) = x(1,1);

%
% Reshape the (npts+1)x3 state matrix into a vector.
%
sys=sys(:);


%
%=============================================================================
% SfunIDFigure
% Locates or creates the figure window associated with this S-function
%=============================================================================
%
function FigHandle=SfunIDFigure(action)

%
% the figure handle is stored in the block's UserData
%
FigHandle = get_param(gcb,'UserData');
if isempty(FigHandle),
    FigHandle=-1;
end

%
% dispatch the action
%
switch action
    
    %%%%%%%
    % Get %
    %%%%%%%
    case 'Get',
        return;
        
        %%%%%%%%%%%%%%
        % Initialize %
        %%%%%%%%%%%%%%
    case 'Initialize',
        if ~ishandle(FigHandle),
            FigHandle = CreateSfunIDFigure;
        end
        ud = get(FigHandle,'UserData');
        set(ud.SysInputTitle,'String','Working - please wait');
        
    otherwise,
        error(['Unexpected action ' action])
        
end

% end SfunIDFigure



%
%===========================================================================
% CreateSfunIDFigure
% Creates the figure window that is associated with the System ID  Block.
%===========================================================================
%
function FigHandle=CreateSfunIDFigure

%
% The name of the block is actually the parent SubSystem
%
sl_name = get_param(get_param(gcb,'Parent'),'Name');

%
% The figure doesn't already exist, create one.
%
FigHandle = figure;

%
% Store the block's handle in the figure's UserData.
%
ud.Block=get_param(gcb,'Handle');

%
% Create the various objects within the figure.
%

% Subplot of the system input data.
ud.SysInputAxis = subplot(211);
ud.SysInputLine1 = plot(0,0,'m','EraseMode','None'); hold on;
ud.SysInputLine2 = plot(0,0,'m','EraseMode','None','color','b');
ud.SysInputXlabel= xlabel('Time (secs)');
ud.SysInputTitle = get(ud.SysInputAxis,'Title');
set(ud.SysInputAxis,'Visible','off');


% Subplot of the error in the predicted model.
ud.SysErrorAxis = subplot(212);
ud.SysErrorLine = plot(0,0,'EraseMode','None');
ud.SysErrorXlabel = xlabel('Time (secs)');
ud.SysErrorTitle = get(ud.SysErrorAxis,'Title');
set(ud.SysErrorAxis,'Visible','off');


%
% Place the figure handle in the current block's UserData.  Then
% place the various object handles into the Figure's UserData.
%

SetSfunIDFigure(gcb,FigHandle);
set(FigHandle,'HandleVisibility','on','UserData',ud);

% end CreateSfunIDFigure.



%
%===========================================================================
% SetSfunIDFigure
% Stores the figure handle that is associated with this block into the
% block's UserData.
%===========================================================================
%
function SetSfunIDFigure(block,FigHandle)

set_param(block,'UserData',FigHandle);

% end SetSfunIDFigure.


%
%=============================================================================
% LocalCopyLoadBlock
% This is the Sytem ID block's CopyFcn and LoadFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalCopyLoadBlock

SetSfunIDFigure(gcb,-1);

% end LocalCopyLoadBlock

%
%=============================================================================
% LocalDeleteBlock
% This is the System ID block's DeleteFcn.  Delete the block's figure
% window, if present, upon deletion of the block.
%=============================================================================
%
function LocalDeleteBlock

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that that function doesn't create the figure if it doesn't exist.
%
FigHandle=SfunIDFigure('Get');
if ishandle(FigHandle),
    delete(FigHandle);
    SetSfunIDFigure(gcb,-1);
end

% end LocalDeleteBlock

%
%=============================================================================
% LocalDeleteFigure
% This is the System ID block's figure window's DeleteFcn.  The figure window
% is being deleted, update the correlation block's UserData to
% reflect the change.
%=============================================================================
%
function LocalDeleteFigure

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunIDFigure(ud.Block,-1)

% end LocalDeleteBlock

























