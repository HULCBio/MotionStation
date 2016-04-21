function  [sys, x0, str, ts] = sfunpsd(t,x,u,flag,fftpts,npts,HowOften,...
                                       offset,ts,averaging)
%SFUNPSD an S-function which performs spectral analysis using ffts.
%   This M-file is designed to be used in a Simulink S-function block.
%   It stores up a buffer of input and output points of the system
%   then plots the power spectral density of the input signal.
%
%     The input arguments are:
%     npts:           number of points to use in the fft (e.g. 128)
%     HowOften:       how often to plot the ffts (e.g. 64)
%     offset:         sample time offset (usually zeros)
%     ts:             how often to sample points (secs)
%     averaging:      whether to average the psd or not
%
%   Two or three plots are given: the time history, the instantaneous psd
%   the average psd.
%
%   See also, FFT, SPECTRUM, SFUNTMPL, SFUNTF.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.31 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93, 8-17-93.
%   Revised Charlie Ko 9-26-96.


switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts] = mdlInitializeSizes(fftpts,npts,HowOften,offset,...
                                         ts,averaging);
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys = mdlUpdate(t,x,u,fftpts,npts,HowOften,offset,ts,averaging);

  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn

  %%%%%%%%%%%%%%
  % NameChange %
  %%%%%%%%%%%%%%
  case 'NameChange'
    LocalBlockNameChangeFcn

  %%%%%%%%%%%%%%%%%%%%%%%%
  % CopyBlock, LoadBlock %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case { 'CopyBlock', 'LoadBlock' }
    LocalBlockLoadCopyFcn

  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock'
    LocalBlockDeleteFcn

  %%%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%%
  case 'DeleteFigure'
    LocalFigureDeleteFcn

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 3, 9 }
    sys = []; %do nothing

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

  end

% end sfunpsd

%
%============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(fftpts,npts,HowOften,offset,...
                                              ts,averaging)

nstates = npts + 2 + averaging * round(fftpts/2) + 1; % No. of discrete states
initial_states = [1; zeros(nstates-1,1)]; 	      % Initial conditions
if HowOften > npts
  error('The number of points in the buffer must exceed the plot frequency')
end
initial_states(nstates) = 0;

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = nstates;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = initial_states;
str = [];
ts  = [ts offset];

% end mdlInitializeSizes

%
%===========================================================================
% mdlUpdates
% Compute Discrete State updates.
%===========================================================================
%
function [sys]=mdlUpdate(t,x,u,fftpts,npts,HowOften,offset,ts,averaging)

%
% Find the figure handle associated with this block. If the handle
% is not valid (i.e. - the user closed the figure during simulation),
% mdlUpdates performs no operations.
%
FigHandle = GetSfunPSDFigure(gcbh);
if ~ishandle(FigHandle)
  sys=[];
  return
end

%
% Initialize the return argument.
%
sys = x;

%
% Increment the counter and store the current input in the
% discrete state referenced by this counter.
%
x(1) = x(1) + 1;
sys(x(1)) = u;

if rem(x(1),HowOften)==0
  ud = get(FigHandle,'UserData');
  buffer = [sys(x(1)+1:npts+1);sys(2:x(1))];
  n = fftpts/2;
  freq = 2*pi*(1/ts); % Multiply by 2*pi to get radians
  w = freq*(0:n-1)./(2*(n-1));

  % Detrend the data: remove best straight line fit
  a = [(1:npts)'/npts ones(npts,1)];
  y = buffer - a*(a\buffer);

  % Hammining window to remove transient effects at the
  % beginning and end of the time sequence.
  nw = min(fftpts, npts);
  win = .5*(1 - cos(2*pi*(1:nw)'/(nw+1)));

  g = fft(win.*y(1:nw),fftpts);

  % Perform averaging with overlap if number of fftpts
  % is less than buffer
  ng = fftpts;
  while (ng <= (npts - fftpts))
    g = (g + fft(win.*y(ng+1:ng+fftpts),fftpts)) / 2;
    ng = ng + n; % For no overlap set: ng = ng + fftpts;
  end

  g = g(1:n);
  psd = (abs(g).^2)./norm(win)^2;

  tvec = (t - ts * npts + ts * (1:npts));
  % For Time History plot.
  set(ud.TimeHistoryAxis,...
      'Visible','on',...
      'Xlim',[min(tvec) max(tvec)],...
      'Ylim',[min(buffer*.99) max(buffer*1.01+eps)]);
  set(ud.TimeHistoryInputLine,...
      'XData',tvec,...
      'YData',buffer);
  set(ud.TimeHistoryTitle,...
      'String','Time history');
  xl = get(ud.TimeHistoryAxis,'Xlabel');
  set(xl,...
      'String','Time (secs)');

  if averaging
    cnt = sys(npts+2+n);		% Counter for averaging
    sys(npts+2:npts+1+n) = cnt/(cnt+1)*sys(npts+2:npts+1+n)+psd/(cnt+1);
    sys(npts+2+n) = sys(npts+2+n) + 1;
    psd = sys(npts+3:npts+1+n);
    tmp = 'Average Power Spectral Density';
  else
    tmp = 'Power Spectral Density';
    psd = psd(2:n);
  end
  ysc = psd(~isnan(psd));

  if isempty(ysc)
    ysc=[0 1];
  else
    ysc = sort([min(ysc*.99), max(ysc*1.01+eps)]);
  end;

  % For the PSD plot.
  set(ud.PSDAxis,...
      'Visible','on',...
      'Xlim',[min(w(2:n)), max(w(2:n))],...
      'Ylim',ysc);
  set(ud.PSDInputLine,...
      'XData',w(2:n),...
      'YData',psd);
  set(ud.PSDTitle,...
      'String', tmp);
  xl = get(ud.PSDAxis, 'Xlabel');
  set(xl,...
      'String','Frequency (rads/sec)')

  phase = (180/pi)*unwrap(atan2(imag(g),real(g)));
  phase = phase(2:n);
  ysc = phase(~isnan(phase));
  if isempty(ysc)
    ysc=[0 1];
  else
    ysc = sort([min(ysc*.99), max(ysc*1.01+eps)]);
  end;
  %For phase plot
  set(ud.PhaseAxis,...
      'Visible','on',...
      'Xlim',[min(w(2:n)) max(w(2:n))],...
      'Ylim',ysc);
  set(ud.PhaseInputLine,'XData',w(2:n),'YData',phase)
  set(ud.PhaseTitle, 'String',[tmp '(phase)'])
  xl = get(ud.PhaseAxis, 'Xlabel');
  set(xl, 'String', 'Frequency (rads/sec)')
  yl = get(ud.PhaseAxis, 'Ylabel');
  set(yl, 'String','Degrees')

  drawnow
end

%
% If the buffer is full, reset the counter. The counter is store in
% the first discrete state.
%
if sys(1,1) == npts
  x(1,1) = 1;
end
sys(1,1) = x(1,1);

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% XY Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn

%
% Retrieve the block's figure handle.
%
FigHandle = GetSfunPSDFigure(gcbh);
if isempty(FigHandle)
  FigHandle=-1;
end

if ~ishandle(FigHandle)
  FigHandle = CreateSfunPSDFigure;
end
ud = get(FigHandle,'UserData');
set(ud.TimeHistoryTitle,'String','Working - please wait');

% end LocalBlockStartFcn

%
%===========================================================================
% CreateSfunPSDFigure
% Creates the figure window that is associated with the PSD Block.
%===========================================================================
%
function FigHandle=CreateSfunPSDFigure

%
% The figure doesn't already exist, create one.
%
FigHandle = figure('Units',        'points',...
                   'Position',     [100 100 400 510],...
                   'MenuBar',      'none',...
                   'NumberTitle',  'off',...
                   'IntegerHandle','off',...
                   'Name',         get_param(gcbh,'Name'),...
		   'DeleteFcn',    'sfunpsd([],[],[],''DeleteFigure'')');

%
% Store the block's handle in the figure's UserData.
%
ud.Block=gcbh;

%
% Create the various objects within the figure.
%

% Subplot of the the time history data.
ud.TimeHistoryAxis = subplot(311);
set(ud.TimeHistoryAxis,'Position',[.13 .72 .77 .2]);
ud.TimeHistoryInputLine = plot(0,0,'m','EraseMode','None');
ud.TimeHistoryTitle = get(ud.TimeHistoryAxis,'Title');
set(ud.TimeHistoryAxis,'Visible','off');

% Subplot of the Power Spectral Density.
ud.PSDAxis = subplot(312);
set(ud.PSDAxis,'Position',[.13 .4 .77 .2]);
ud.PSDInputLine = plot(0,0,'EraseMode','None');
ud.PSDTitle = get(ud.PSDAxis,'Title');
set(ud.PSDAxis,'Visible','off');

% Subplot of the phase shift diagram.
ud.PhaseAxis = subplot(313);
set(ud.PhaseAxis,'Position',[.13 .08 .77 .2]);
ud.PhaseInputLine = plot(0,0,'EraseMode','None');
ud.PhaseTitle = get(ud.PhaseAxis,'Title');
set(ud.PhaseAxis,'Visible','off');

%
% Place the figure handle in the current block's UserData.  Then
% place the various object handles into the Figure's UserData.
%
SetSfunPSDFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','off','UserData',ud);

% end CreateSfunPSDFigure

%
%===========================================================================
% GetSfunPSDFigure
% Retrieves the figure handle that is associated with this block from the
% block's parent subsystem's UserData.
%===========================================================================
%
function FigHandle=GetSfunPSDFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunPSDFigure.

%
%===========================================================================
% SetSfunPSDFigure
% Stores the figure handle that is associated with this block into the
% block's UserData.
%===========================================================================
%
function SetSfunPSDFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

set_param(block,'UserData',FigHandle);

% end SetSfunPSDFigure.

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the PSD Graph scope block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% get the figure associated with this block, if it's valid, change
% the name of the figure
%
FigHandle = GetSfunPSDFigure(gcbh);
if ishandle(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the PSD block's CopyFcn and LoadFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunPSDFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the PSD block's DeleteFcn.  Delete the block's figure
% window, if present, upon deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that that function doesn't create the figure if it doesn't exist.
%
FigHandle=GetSfunPSDFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunPSDFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the PSD's figure window's DeleteFcn.  The figure window
% is being deleted, update the correlation block's UserData to
% reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunPSDFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% SetBlockCallbacks
% This sets the LoadFcn, CopyFcn and DeleteFcn of the block.
%=============================================================================
%
function SetBlockCallbacks(block)

%
% the actual source of the block is the parent subsystem
%
block=get_param(block,'Parent');

%
% if the block isn't linked, issue a warning, and then set the callbacks
% for the block so that it has the proper operation
%
if strcmp(get_param(block,'LinkStatus'),'none'),
  warnmsg=sprintf(['The Power Spectral Density Graph scope ''%s'' should ' ...
                   'be replaced with a new version from the ' ...
                   'simulink_extras block library'],...
                   block);
  warning(warnmsg);

  callbacks={
    'CopyFcn',       'sfunpsd([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sfunpsd([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sfunpsd([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sfunpsd([],[],[],''Start'')' ;
    'NameChangeFcn', 'sfunpsd([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
