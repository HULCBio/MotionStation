function  [sys,x0,str,ts]  = sfunyst(t,x,u,flag,ax,ltype,npts,dt)
%SFUNYST S-function storage scope using graph window.
%   SFUNYST is designed to be used in a Simulink S-function block.
%   It stores the previous input points using discrete states
%   and then plots this against time.
%
%     S-function Syntax (see SFUNTMPL):
%       [SYS, X0]  = SFUNYST(T,X,U,FLAG,AX,LTYPE,NPTS)
%     where:
%       AX - initial graph axis
%       LTYPE - line type (e.g. 'r','r-.','x') (See PLOT)
%       NPTS  - number of storage points
%
%   See also, PLOT, SFUNY, SFUNXY, LORENZ2.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.46 $
%  Andrew Grace 1-27-92.
%  Revised Wes Wang 4-28-93, 8-17-93, 12-6-93, 6-21-96.
%  Revised Charlie Ko 10/21/96.

if (nargin <= 7)
  dt = -1;
end

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(t,u,ax,ltype,npts,dt);
    if isempty(get_param(gcb,'DeleteFcn'))
      SetBlockCallbacks(gcb);
    end

  %%%%%%%%%%%%%%%%%%%%%
  % Update, Terminate %
  %%%%%%%%%%%%%%%%%%%%%
  case {2,9}
    sys=mdlUpdate(t,x,u,flag,ax,ltype,npts,dt);

  %%%%%%%%%%%%%%%%%%%%%%%
  % Derivatives, Output %
  %%%%%%%%%%%%%%%%%%%%%%%
  case {1,3}
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

% end of sfunyst


%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(t,u,ax,ltype,npts,dt)

% Return system sizes:

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 9; % 8th state stored figure handle; no longer needed.
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

if length(ax) ~= 4
  error('Axis limits was not set correctly')
end;

x0 = [0, -Inf, ax(1), ax(2), ax(3), ax(4), npts, 0, 0];

str = [];

ts = [dt, 0];

%
% If the simulation is initializing, then initialize the figure window
%
if strcmp(get_param(bdroot,'SimulationStatus'),'initializing')
  SfunYSTFigure('Initialize',t,ax,ltype);
end

% end mdlInitializeSizes


%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,ax,ltype,npts,dt)

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=SfunYSTFigure('Get');
if ~ishandle(FigHandle),
  sys=[];
  return
end
set(0,'CurrentFigure', FigHandle)

%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');

%
% Get the length of the input vector.
%
len_u = length(u);

%
% Create the lines if the simulation is just starting.
%
if isempty(ud.InitialTime)
cla;   
coll = ltype;
hold on;
  for k=1:len_u
    [col,coll] = strtok(coll,'/');
    if length(col) <= 1
      col = 'b-';
    end;
    ud.Line(k) = plot(0,0,col,'Erasemode','none','Color',...
                      col(1),'LineStyle',col(2:length(col)));               
    ud.Line2(k) = plot(0,0,col,'Erasemode','none','Color',...
                       col(1),'LineStyle',col(2:length(col)));
  end;
  set(ud.SysAxis,'Xlim',ax(1:2),'Ylim',ax(3:4));
  set(ud.SysAxis,'UserData',[]);
drawnow;
ud.InitialTime = t;
set(FigHandle,'UserData',ud);
end;


npts = x(7);  
if npts <=0
  npts = 1;
end;

len_u = length(u);

% Loop counter
x_m = x(1);
x(1) = x(1) + 1;

if x(1) > npts
  x(1) = x(1) - npts;
end;

sys = x;


% h_axis UserData saves the time
% h_plot UserData saves the previous input points
% Store last time and input point in circular buffer.
buffer_t = get(ud.SysAxis,'UserData');
len_b = length(buffer_t);
if len_b < npts
  buffer_t = [buffer_t; t];
else
  buffer_t(sys(1)) = t;
end;
set(ud.SysAxis,'UserData', buffer_t);

buffer_y = [];
for k=1:len_u
  tmp = get(ud.Line(k),'UserData');
  if len_b < npts
    tmp = [tmp; u(k)];
  else
    tmp(sys(1)) = u(k);
  end;
  set(ud.Line(k),'UserData',tmp);
  buffer_y = [buffer_y tmp];
end;

% If the input significantly exceeds the Y-axis
% then count how many times this happens.
if (1.1*u < sys(5)) | (1.1*u > sys(6))
  sys(9) = sys(9) + 1;
end

% If the time is greater than the X-axis or
% the input has exceeded the Y-axis more than 3 times
% or it is the end of simulation then rescale and replot.
if (t > sys(2)) | (sys(9) > 3) | (flag == 9)
  sys(9) = 0; % Set 'exceed Y-axis' counter to zero.
  if (sys(2) == -Inf) % Initial point
    if (flag == 9)
      sys = [];
    else
      sys(2) = ax(2);
    end
  return
  end

  newax = ax;
  if flag == 9
    factor = 1.2;
    sys(2) = t;
  elseif t > sys(2)
    % If time has exceeded axis limit then
    % be conservative in rescaling factor for Y axis:
    factor = 1.2;
    sys(2) = sys(2) + ax(2);
  else
    % otherwise double scaling:
    factor = 2;
  end
  newax(1,2) = sys(2);
  if ~isempty(buffer_t)
    newax(1,1) = min(buffer_t);
  end;

  % Work out new Y-axis ranges:
  minb = min(min(buffer_y));
  maxb = max(max(buffer_y));
  if ~isempty(minb)
    if minb < 0
      newax(1,3) = factor*minb;
    else
      newax(1,3) = (1/factor)*minb;
    end
    if maxb > 0
      newax(1,4) = factor*max(max(buffer_y));
    else
      newax(1,4) = (1/factor)*max(max(buffer_y));
    end
  else
    newax(1,3) = ax(3);
    newax(1,4) = ax(4);
  end;
  sys(5) = newax(1,3);
  sys(6) = newax(1,4);

  if newax(4) <= newax(3)
    if (newax(3) ~= 0)
      newax(4) = newax(3) * (1 + eps);
    else
      newax(4) = eps;
    end
  end;
  if newax(2) <= buffer_t(1)
    if (buffer_t(1) ~= 0)
      newax(2) = buffer_t(1) * (1 + eps);
    else
      newax(2) = eps;
    end
  end;
			
  len_b = length(buffer_t);
  if (sys(1) ~= len_b)  & (len_b == npts)
    tmp_t = [buffer_t(sys(1)+1:len_b); buffer_t(1:x(1))];
  else
    tmp_t = [buffer_t(1:len_b)];
  end;

  % Plot the stored points and the y=0 line:
  for k=1:len_u
    if (sys(1) ~= len_b) & (len_b == npts)
      tmp = [buffer_y(sys(1)+1:len_b,k); buffer_y(1:x(1),k)];
    else
      tmp = [buffer_y(1:len_b,k)];
    end;
    set(ud.Line2(k), 'XData', tmp_t, 'YData',tmp);
  end;
  set(ud.SysAxis,'Xlim',newax(1:2),'Ylim',newax(3:4));
  set(FigHandle  ,'Color',get(FigHandle,'Color'));

  len_b = length(buffer_t);
  if (sys(1,1) == 1) & (len_b < npts) % Is it first point in cycle
    % Use none as Erasemode for faster plotting
    for k=1:len_u
      set(ud.Line(k), 'XData',[t,t], 'YData',[u(k),u(k)]);
    end;
  else
    if x_m <= 0
      x_m = len_b;
    end;
    for k=1:len_u
      set(ud.Line(k),'XData',[buffer_t(x_m),t],'YData',[buffer_y(x_m,k),u(k)]);
    end
  end
  %
  % Make the axis visible.
  %
  set(ud.SysAxis,'Visible','on');
  
else
  if (sys(1) ~= len_b)  & (len_b == npts)
    tmp_t = [buffer_t(sys(1)+1:len_b); buffer_t(1:x(1))];
  else
    tmp_t = [buffer_t(1:len_b)];
  end;
 
  for k=1:len_u
    if (sys(1) ~= len_b) & (len_b == npts)
      tmp = [buffer_y(sys(1)+1:len_b,k); buffer_y(1:x(1),k)];
    else
      tmp = [buffer_y(1:len_b,k)];
    end;
    if x_m <= 0
       x_m = len_b;
    end;
    set(ud.Line2(k),'XData',tmp_t,'YData',tmp);
    set(ud.Line(k),'XData',[buffer_t(x_m),t],'YData',[buffer_y(x_m,k),u(k)]);  
  end;
 
  %
  % Make the axis visible.
  %
  set(ud.SysAxis,'Visible','on');
  
end

drawnow;

if (sys(1) == npts) | (sys(1) == (npts + 1))
  sys(1,1) = 0;
end
if flag == 9
  sys = [];
end

% end of mdlUpdate



%
%=============================================================================
% SfunYSTFigure
% Locates or creates the figure window associated with this S-function.
%=============================================================================
%
function FigHandle=SfunYSTFigure(action,t,ax,ltype)

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
      FigHandle = CreateSfunYSTFigure(t,ax);
    end
    ud = get(FigHandle,'UserData');
    %
    % Store the time value at the start of the simulation.
    %
    ud.InitialTime = t;
    set(FigHandle,'Userdata',ud);
   
  otherwise,
    error(['Unexpected action ' action])
end
  
% end SfunYSTFigure



%
%===========================================================================
% CreateSfunYSTFigure
% Creates the figure window that is associated with the this Block. 
%===========================================================================
%
function FigHandle=CreateSfunYSTFigure(t,ax)

%
% The name of the block is actually the parent SubSystem
%
sl_name = get_param(get_param(gcb,'Parent'),'Name');

%
% The figure doesn't already exist, create one.
%
FigHandle = figure('Unit','pixel',...
               'Pos',[100 100 400 300],...
               'Name',sl_name, 'Number','off');

%
% Store the block's handle in the figure's UserData.
%
ud.Block=get_param(gcb,'Handle');

%
% Create the axis and other objects within the figure.
% 
ud.SysAxis = subplot(1,1,1);
set(ud.SysAxis,'Box','on');
if length(ax) < 4
  disp('Axis not defined correctly; using current axis');
  ax = [0 1 0 1];
end
set(ud.SysAxis,'Xlim',ax(1:2),'Ylim',ax(3:4));
set(ud.SysAxis,'Visible','off');
set(ud.SysAxis,'XGrid','on','YGrid','on');
ud.AxisLimits = ax; 
ud.Xlabel = get(ud.SysAxis,'Xlabel');
set(ud.Xlabel,'String','Time (Seconds)');
%
% Set the title of the graph.
%
ud.Title = get(ud.SysAxis,'Title');
titl = strrep(bdroot,'_','\_');
set(ud.Title,'String',titl);
%
% Place the figure handle in the current block's UserData.  Then
% place the various object handles into the Figure's UserData.
%
SetSfunYSTFigure(gcb,FigHandle);
set(FigHandle,'HandleVisibility','on','UserData',ud);

% end CreateSfunYSTFigure.


%
%===========================================================================
% SetSfunYSTFigure
% Stores the figure handle that is associated with this block into the
% block's UserData. 
%===========================================================================
%
function SetSfunYSTFigure(block,FigHandle)

set_param(block,'UserData',FigHandle);

% end SetSfunYSTFigure.


%
%=============================================================================
% LocalCopyLoadBlock
% This is the Auto-Scale Graph Block's CopyFcn and LoadFcn
% Initialize the block's UserData such that a figure is not
% associated with the block.
%=============================================================================
%
function LocalCopyLoadBlock

SetSfunYSTFigure(gcb,-1);

% end LocalCopyLoadBlock

%
%=============================================================================
% LocalDeleteBlock
% This is the Auto-Scale Graph Block's DeletFcn.
% Delete the block's figure window, if present, upon
% deletion of the block.
%=============================================================================
%
function LocalDeleteBlock

%
% Get the figure handle, the second arg to SfunCorrFigure is set to zero
% so that that function doesn't create the figure if it doesn't exist.
%
FigHandle=SfunYSTFigure('Get');
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunYSTFigure(gcb,-1);
end

% end LocalDeleteBlock

%
%=============================================================================
% LocalDeleteFigure
% This is the Auto-Scale Graph Block's figure window's
% DeleteFcn.  The figure window is being deleted, update the correlation
% block's UserData to reflect the change.
%=============================================================================
%
function LocalDeleteFigure

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunYSTFigure(ud.Block,-1)

% end LocalDeleteBlock


%
%=============================================================================
% SetBlockCallbacks
% This sets the LoadFcn, CopyFcn and DeleteFcn of the block.
%=============================================================================
%
function SetBlockCallbacks(block)

set_param(block,   'CopyFcn', 'sfunyst([],[],[],''CopyBlock'')')
set_param(block,   'LoadFcn', 'sfunyst([],[],[],''LoadBlock'')')
set_param(block, 'DeleteFcn', 'sfunyst([],[],[],''DeleteBlock'')')

% end SetBlockCallbacks
