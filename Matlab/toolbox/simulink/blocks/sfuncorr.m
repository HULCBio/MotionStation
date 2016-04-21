function [sys,x0,str,ts]=sfuncorr(t,x,u,flag,...
                                  npts,HowOften,offset,ts,cross,biased)
%SFUNCORR an S-function which performs auto- and cross-correlation.
%   This M-file is designed to be used in a Simulink S-function block.
%   It stores up a buffer of input and output points of the system
%   then plots the power spectral density of the input signal.
%
%   The input arguments are:
%       npts:      number of points to use in the fft (e.g. 128)
%       HowOften:  how often to plot the ffts (e.g. 64)
%       offset:    sample time offset (usually zeros)
%       ts:        how often to sample points (secs)
%       cross:     set to 1 for cross-correlation 0 for auto
%       biased:    set to 'biased' or 'unbiased'
%
%   The cross correlator gives two plots: the time history,
%   and the auto- or cross-correlation.
%
%   See also, SFUNTMPL, XCORR, SFUNPSD.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.36 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(npts,HowOften,offset,ts,cross,biased);
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,npts,HowOften,offset,ts,cross,biased);

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
    sys = [];

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

% end of sfuncorr

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(npts,HowOften,offset,ts,cross,biased)

if HowOften > npts
  error(['The number of points in the buffer must be more '...
	 'than the plot frequency'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = (cross+1) * (npts+1);
sizes.NumOutputs     = 0;
sizes.NumInputs      = cross+1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = zeros(sizes.NumDiscStates,1);

str = [];

ts  = [ts, offset];

%
% the first discrete state is a counter, initialize it to 1
%
x0(1) = 1;

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,npts,HowOften,offset,ts,cross,biased)

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunCorrFigure(gcbh,cross);
if ~ishandle(FigHandle),
  sys=[];
  return
end

%
% initialize the return argument
%
sys = zeros(npts+1,1+cross);
sys(:) = x;

%
% increment the counter and store the current input in the discrete state
% referenced by this counter
%

% make sure the counter is real positive integer
x(1,1) = round(x(1,1));

x(1,1) = x(1,1) + 1;
sys(x(1,1),:) = u(:).';

if rem(x(1,1),HowOften)==0,

  ud = get(FigHandle,'UserData');
  lasta = [sys(x(1,1)+1:npts+1,1);sys(2:x(1,1),1)];
  if cross
    lastb = [sys(x(1,1)+1:npts+1,2);sys(2:x(1,1),2)];
    % Take real part to avoid small residual complex part
    y = real(xcorr(lasta,lastb,biased));
  else
    y = real(xcorr(lasta,biased));
  end

  tvec = (t - ts * sys(x(1,1)) + ts * (1:npts))';
  if cross
    set(ud.TimeHistoryAxis,...
        'Visible','on',...
        'Xlim', [min(tvec) max(tvec)],...
        'Ylim', [min(min([lasta;lastb])) max(max([lasta;lastb+eps]))]);
    set(ud.Input1Line,'XData',tvec,'YData',lasta);
    set(ud.Input2Line,'XData',tvec,'YData',lastb);
  else
    set(ud.TimeHistoryAxis,...
        'Visible','on',...
        'Xlim',[min(tvec)  max(tvec)],...
	'Ylim',[min(lasta) max(lasta+eps)]);
     set(ud.Input1Line,'XData',tvec,'YData',lasta)
  end

  set(ud.TimeHistoryTitle,'String','Time history')
  set(ud.AutoCorrLine,'XData',tvec,'YData',y(1:npts))
  xl = get(ud.TimeHistoryAxis,'Xlabel');
  set(xl,'String','Time (secs)')
  set(ud.AutoCorrAxis,...
      'Visible','on',...
      'Xlim',[min(tvec),max(tvec)],...
      'Ylim',[min(y(1:npts)) max(y(1:npts)+eps)]);

  if cross
    set(ud.AutoCorrTitle,'String',['Cross correlation (', biased, ')'])
  else
    set(ud.AutoCorrTitle,'String',['Auto correlation (',biased, ')'])
  end

  xl = get(ud.AutoCorrAxis,'Xlabel');
  set(xl,'String','Time (secs)')
  set(FigHandle,'Color',get(FigHandle,'Color'));

  drawnow
end

%
% if the buffer's full, then reset the counter (it's stored in the first
% discrete state)
%
if sys(1,1) == npts
  x(1,1) = 1;
end
sys(1,1) = x(1,1);

sys=sys(:);

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% Cross Correlation scope figure.
%=============================================================================
%
function LocalBlockStartFcn

FigHandle = GetSfunCorrFigure(gcbh);

if ~ishandle(FigHandle),
  FigHandle = CreateSfunCorrFigure;
end
ud = get(FigHandle,'UserData');
switch GetSfunCorrType(gcbh)

  case 'cross'
    set(ud.Input1Line,'XData',0,'YData',0,'Erasemode','none');
    set(ud.Input2Line,'XData',0,'YData',0,'Erasemode','none');

  case 'auto'
    set(ud.Input1Line,'XData',0,'YData',0,'Erasemode','none');

end
set(ud.TimeHistoryTitle,'String','Working - please wait');

% end LocalBlockStartFcn

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the cross correlation block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% the figure handle is stored in the block's UserData
%
FigHandle = GetSfunCorrFigure(gcbh);
if ~isempty(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the Auto Correlation or Cross Correlation block's CopyFcn and
% LoadFcn.  Initialize the block's UserData such that a figure is not
% associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunCorrFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the Auto Correlation or Cross Correlation block's
% DeleteFcn.  Delete the block's figure window, if present, upon
% deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that that function doesn't create the figure if it doesn't exist.
%
FigHandle=GetSfunCorrFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunCorrFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the Auto Correlation or Cross Correlation figure window's
% DeleteFcn.  The figure window is being deleted, update the correlation
% block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunCorrFigure(ud.Block,-1)

% end LocalBlockDeleteFcn

%
%=============================================================================
% GetSfunCorrType
% Retrieves the type of correlation block, 'cross' or 'auto'.
%=============================================================================
%
function corrType=GetSfunCorrType(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

maskType = get_param(block,'MaskType');

switch maskType,

  case 'Cross Correlator'
    corrType = 'cross';
 
  case 'Auto Correlator'
    corrType = 'auto';

  otherwise,
    error(['Undefined correlation type ''' maskType '''']);

end

% end GetSfunCorrType

%
%=============================================================================
% GetSfunCorrFigure
% Retrieves the figure window associated with this S-function correlation block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfunCorrFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunCorrFigure

%
%=============================================================================
% SetSfunCorrFigure
% Stores the figure window associated with this S-function correlation block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunCorrFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

set_param(block,'UserData',FigHandle);

% end SetSfunCorrFigure

%
%=============================================================================
% CreateSfunCorrFigure
% Creates the figure window associated with this S-function correlation block.
%=============================================================================
%
function FigHandle=CreateSfunCorrFigure

%
% the figure doesn't exist, create one
%
FigHandle = figure('Unit',         'pixel',...
                   'Position',     [100 100 500 400],...
                   'MenuBar',      'none',...
                   'NumberTitle',  'off',...
                   'Name',         get_param(gcbh,'Name'),...
                   'IntegerHandle','off',...
		   'DeleteFcn',    'sfuncorr([],[],[],''DeleteFigure'')');

%
% store the block's handle in the figure's UserData
%
ud.Block=gcbh;

%
% create the various objects in the figure
%
ud.TimeHistoryAxis = subplot(211);
switch GetSfunCorrType(gcbh),
  case 'cross',
    hold on
    ud.Input1Line = plot(0,0,'EraseMode','None');
    ud.Input2Line = plot(0,0,'EraseMode','None');
    hold off

  case 'auto'
    ud.Input1Line = plot(0,0,'EraseMode','None');
end
set(ud.TimeHistoryAxis,'Visible','off');
ud.TimeHistoryTitle = get(ud.TimeHistoryAxis,'Title');
set(ud.TimeHistoryTitle,'String','Working - please wait');

ud.AutoCorrAxis=subplot(212);
ud.AutoCorrLine = plot(0,0,'EraseMode','None');
ud.AutoCorrTitle = get(ud.AutoCorrAxis,'Title');
set(ud.AutoCorrAxis,'Visible','off');

%
% squirrel away the figure handle in the current block, and put the
% various handles into the figure's UserData
%
SetSfunCorrFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfunCorrFigure

%
%=============================================================================
% SetBlockCallbacks
% This sets the callbacks of the block if it is not a reference.
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
  warnmsg=sprintf(['The Cross Correlation scope ''%s'' should be replaced with a ' ...
                   'new version from the simulink_extras block library'],...
                   block);
  warning(warnmsg);

  callbacks={
    'CopyFcn',       'sfuncorr([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sfuncorr([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sfuncorr([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sfuncorr([],[],[],''Start'')' ;
    'NameChangeFcn', 'sfuncorr([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
