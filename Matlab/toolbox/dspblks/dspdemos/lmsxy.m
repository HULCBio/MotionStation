function [sys, x0, str, ts] = lmsxy(t,x,u,flag,ax,varargin)
%LMSXY S-function that acts as an X-Y scope using MATLAB plotting functions.
%   This M-file is designed to be used in a Simulink S-function block.
%   It draws a line from the previous input point, which is stored using
%   discrete states, and the current point.  It then stores the current
%   point for use in the next invocation.

%   Copyright 1990-2004 The MathWorks, Inc.

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts] = mdlInitializeSizes(ax,varargin{:});
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys = mdlUpdate(t,x,u,flag,ax,varargin{:});

  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn(ax);

  %%%%%%%%
  % Stop %
  %%%%%%%%
  case 'Stop'
    LocalBlockStopFcn

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

% end sfunxy

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(ax,varargin)

if length (ax)<4
  error(['Axes limits must be defined.'])
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 8;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0 = [];

str = [];

%
% initialize the array of sample times, note that in earlier
% versions of this scope, a sample time was not one of the input
% arguments, the varargs checks for this and if not present, assigns
% the sample time to -1 (inherited)
%
if ~isempty(varargin) > 0
  ts = [varargin{1} 0];
else
  ts = [-1 0];
end

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,ax,varargin)

%
% always return empty, there are no states...
%
sys = [];

%
% Locate the figure window associated with this block.  If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunXYFigure(gcbh);
if ~ishandle(FigHandle),
   return
end

%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');
siz = size(ud.XData);
s2 = siz(2);
if isempty(ud.XData),
  for i=1:4
      x_data(i,:) = [u(2*i-1) u(2*i-1)];
      y_data(i,:) = [u(2*i) u(2*i)];
  end
else
  for i=1:4
      x_data(i,:) = [ud.XData(i,s2) u(2*i-1)];
      y_data(i,:) = [ud.YData(i,s2) u(2*i)];
  end
end

set(ud.XYAxes, ...
    'Visible','on',...
    'Xlim', ax(1:2),...
    'Ylim', ax(3:4));
for i=1:4
%     set(ud.XYLine(i),...
%     'Xdata',x_data(i,:),...
%     'YData',y_data(i,:),...
%     'Marker','.','Color','r');
    set(ud.XYLine(i),...
    'Xdata',x_data(i,:),...
    'YData',y_data(i,:),...
    'Color','r','LineStyle','-','LineWidth',2);
end
set(ud.XYTitle,'String','X Y Plot');
set(FigHandle,'Color',get(FigHandle,'Color'));

%
% update the X/Y stored data points
%
for i=1:4
    ud.XData(i,s2+1) = u(2*i-1);
    ud.YData(i,s2+1) = u(2*i);    
end
set(FigHandle,'UserData',ud);
drawnow

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% XY Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn(ax)

%
% get the figure associated with this block, create a figure if it doesn't
% exist
%
FigHandle = GetSfunXYFigure(gcbh);
if ~ishandle(FigHandle),
  FigHandle = CreateSfunXYFigure;
end

ud = get(FigHandle,'UserData');
set(ud.XYLineb,'Erasemode','normal');
set(ud.XYLineb,'XData',[],'YData',[]);
set(ud.XYLineb,'XData',nan,'YData',nan,'Erasemode','none');
for i=1:4
    %set(ud.XYLine(i),'Erasemode','normal');
    %set(ud.XYLine(i),'XData',[],'YData',[]);
    set(ud.XYLine(i),'XData',nan,'YData',nan,'Erasemode','none');    
end
Noise = randn(1,1000);
Noise = (Noise + ax(1)) * ax(2);    %(N+mean) * var
Noisef = filter(ax(3:4),1,Noise);
R = xcorr(Noise, 1);
R = R(2:3);
P = xcorr(Noise, Noisef, 1);
P = P(1:2);
D = var(Noisef);
[X Y] = meshgrid(ax(5):.1:ax(6), ax(7):.1:ax(8));
Z = D - 2*(P(1)*X+P(2)*Y) + 2*R(2)*X.*Y + R(1)*(X.*X+Y.*Y);
[c]=contourc(ax(5):.1:ax(6),ax(7):.1:ax(8),Z,7);
% k = 1;
% for i=-2:0.1:2
%     brt = sqrt(4*(R(2)*i-P(1))*(R(2)*i-P(1)) - 4*R(1)*(R(1)*i*i-2*P(2)*i)+D);
%     yd(k) = (-2*(R(1)*i-P(1)) + brt)/(2*R(1));   xd(k) = k;
%     yd(k+1) = (-2*(R(1)*i-P(1)) - brt)/(2*R(1)); xd(k+1) = k+1;
%     k = k+2;
% end
sz = size(c);
ud.XData = [];
ud.YData = [];
set(ud.Text(1), 'Position', [0, -0.07]); %lms
set(ud.Text(2), 'Position', [0, 1.03]);  %nlms
set(ud.Text(3), 'Position', [0.95, -0.07]);  %selms
set(ud.Text(4), 'Position', [0.95, 1.03]);   %sslms
set(ud.XYLineb,...
    'Xdata',c(1,:),...
    'Ydata',c(2,:),...
    'Marker','.','LineStyle','none');
ud.c = c;
set(FigHandle,'UserData',ud);

% end LocalBlockStartFcn

%
%=============================================================================
% LocalBlockStopFcn
% At the end of the simulation, set the line's X and Y data to contain
% the complete set of points that were acquire during the simulation.
% Recall that during the simulation, the lines are only small segments from
% the last time step to the current one.
%=============================================================================
%
function LocalBlockStopFcn

FigHandle=GetSfunXYFigure(gcbh);
if ishandle(FigHandle),
  %
  % Get UserData of the figure.
  %
  ud = get(FigHandle,'UserData');
  for i=1:4
%       set(ud.XYLine(i),...
%           'Xdata',ud.XData(i,:),...
%           'Ydata',ud.YData(i,:),...
%           'MArker','.', 'LineStyle','none');
    set(ud.XYLine(i),...
    'Xdata',ud.XData(i,:),...
    'YData',ud.YData(i,:),...
    'Color','r','LineStyle','-','LineWidth',2);
  end
end

% end LocalBlockStopFcn

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the Graph scope block.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% get the figure associated with this block, if it's valid, change
% the name of the figure
%
FigHandle = GetSfunXYFigure(gcbh);
if ishandle(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% This is the XYGraph block's LoadFcn and CopyFcn.  Initialize the block's
% UserData such that a figure is not associated with the block.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunXYFigure(gcbh,-1);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% This is the XY Graph block'DeleteFcn.  Delete the block's figure window,
% if present, upon deletion of the block.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% Get the figure handle associated with the block, if it exists, delete
% the figure.
%
FigHandle=GetSfunXYFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunXYFigure(gcbh,-1);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the XY Graph figure window's DeleteFcn.  The figure window is
% being deleted, update the XY Graph block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunXYFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% GetSfunXYFigure
% Retrieves the figure window associated with this S-function XY Graph block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfunXYFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunXYFigure

%
%=============================================================================
% SetSfunXYFigure
% Stores the figure window associated with this S-function XY Graph block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunXYFigure(block,FigHandle)

if strcmp(get_param(bdroot,'BlockDiagramType'),'model'),
  if strcmp(get_param(block,'BlockType'),'S-Function'),
    block=get_param(block,'Parent');
  end

  set_param(block,'UserData',FigHandle);
end

% end SetSfunXYFigure

%
%=============================================================================
% CreateSfunXYFigure
% Creates the figure window associated with this S-function XY Graph block.
%=============================================================================
%
function FigHandle=CreateSfunXYFigure

%
% the figure doesn't exist, create one
%
FigHandle = figure('Units',          'pixel',...
                   'Position',       [546 269 462 418],...
                   'Name',           get_param(gcbh,'Name'),...
                   'Tag',            'SIMULINK_XYGRAPH_FIGURE',...
                   'NumberTitle',    'off',...
                   'IntegerHandle',  'off',...
                   'Toolbar',        'none',...
                   'DeleteFcn',      'lmsxy([],[],[],''DeleteFigure'')');
%                   'Menubar',        'none',...                   
%
% store the block's handle in the figure's UserData
%
ud.Block=gcbh;

%
% create various objects in the figure
%

ud.XYAxes   = axes;
ud.XYLineb  = plot(nan,nan,'EraseMode','None');
hold on;
for i=1:4
    ud.XYLine(i)   = plot(nan,nan,'EraseMode','None');
end
ud.Text(1) = text(-3,4,'LMS', 'FontSize', 13);
ud.Text(2) = text(-3,4,'NLMS', 'FontSize', 13);
ud.Text(3) = text(-3,4,'SELMS', 'FontSize', 13);
ud.Text(4) = text(-3,4,'SSLMS', 'FontSize', 13);
hold off;
ud.XYXlabel = xlabel('X Axis');
ud.XYYlabel = ylabel('Y Axis');
ud.XYTitle  = get(ud.XYAxes,'Title');
ud.XData    = [];
ud.YData    = [];
ud.c = [];

set(ud.XYAxes,'Visible','off');

%
% Associate the figure with the block, and set the figure's UserData.
%
SetSfunXYFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfunXYFigure

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
  callbacks={
      'CopyFcn',       'lmsxy([],[],[],''CopyBlock'',[])' ;
      'DeleteFcn',     'lmsxy([],[],[],''DeleteBlock'',[])' ;
      'LoadFcn',       'lmsxy([],[],[],''LoadBlock'',[])' ;
      'StopFcn'        'lmsxy([],[],[],''Stop'',[])' 
      'NameChangeFcn', 'lmsxy([],[],[],''NameChange'',[])' ;
  };
%      'StartFcn',      'lmsxy([],[],[],''Start'',[])' ;
  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})
    end
  end
end

% end SetBlockCallbacks
