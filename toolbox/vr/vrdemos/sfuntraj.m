function [sys, x0, str, ts] = sfuntraj(t,x,u,flag,axes,Ts,mode)
%SFUNTRAJ S-function for Trajectory scope with setpoint editor.
%   This M-file is used as a Simulink S-function block. Block inputs
%   are X-Y coordinates which are used for plotting the trajectory.
%   By clicking the mouse inside the graph X-Y setpoint can be set 
%   which is the block output.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.6.4.3 $ $Date: 2004/03/30 13:18:15 $ $Author: batserve $

switch flag

% Initialization
  case 0
    if length (axes)~=4
      error('Axes limits must be defined.');
    end

    if ~strcmpi(vrgetpref('DataTypeBool'), 'logical')
      error('VR:incompatibledatatypepref', '%s\n%s', ...
            'The ''Bool'' VRML data type is set to ''char'' (backward compatibility mode).', ...
            'To use this demo, please set it to ''logical'' using VRSETPREF.');
    end

    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = 4;
    sizes.DirFeedthrough = 0;
    sizes.NumSampleTimes = 1;

    sys = simsizes(sizes);
    str = [];

    if ~isempty(Ts) > 0
      ts = [Ts(1) 0];
    else
      ts = [-1 0];
    end

    block=get_param(gcbh,'Parent');
    set_param(block,'CopyFcn','sfuntraj([],[],[],''CopyBlock'')');
    set_param(block,'DeleteFcn','sfuntraj([],[],[],''DeleteBlock'')');
    set_param(block,'LoadFcn','sfuntraj([],[],[],''LoadBlock'')');
    set_param(block,'StartFcn','sfuntraj([],[],[],''Start'')');
    set_param(block,'StopFcn','sfuntraj([],[],[],''Stop'')');
    set_param(block,'NameChangeFcn','sfuntraj([],[],[],''NameChange'')');

    setpoint = [(axes(1)+axes(2))/2 (axes(3)+axes(4))/2];
    set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);

    system_name=gcs;
    idx=find(system_name=='/');
    model_name=system_name(1:idx(1)-1);     % extract model name
    wh=vrworld(get_param([model_name '/VR Sink'], 'WorldFileName'));
    nh=vrnode(wh,'MouseSensor');
    sync(nh,'hitPoint_changed','on');
    sync(nh,'isActive','on');

    x0=[];


% Update
  case 2
    sys = mdlUpdate(t,x,u,flag,axes,Ts,mode);


  case 'Start'
    LocalBlockStartFcn

  case 'Stop'
    LocalBlockStopFcn

  case 'NameChange'
    LocalBlockNameChangeFcn

  case { 'CopyBlock', 'LoadBlock' }
    LocalBlockLoadCopyFcn

  case 'DeleteBlock'
    LocalBlockDeleteFcn

  case 'DeleteFigure'
    LocalFigureDeleteFcn

  case 'ButtonDown'
    set(gcbf, 'WindowButtonMotionFcn', 'sfuntraj([],[],[],''ButtonMove'')', ...
              'WindowButtonUpFcn',     'sfuntraj([],[],[],''ButtonUp'')' );
    LocalMouseFcn

  case 'ButtonUp'
    LocalMouseFcn
    set(gcbf, 'WindowButtonMotionFcn', '', ...
              'WindowButtonUpFcn',     '' );

  case 'ButtonMove'
    LocalMouseFcn

% Unused flags %
  case { 1, 3, 9 }
    sys = [];

% Other flags
  otherwise
    if ischar(flag),
      errmsg=sprintf('Unhandled flag: ''%s''', flag);
    else
      errmsg=sprintf('Unhandled flag: %d', flag);
    end

    error(errmsg);

end

% end sfuntraj


%
%=============================================================================
% mdlUpdate
%=============================================================================
%
function sys=mdlUpdate(t,x,u,flag,axes,Ts,mode)   %#ok unused parameters

sys=[];

FigHandle=GetSfuntrajFigure(gcbh);
if ~ishandle(FigHandle),
  if mode==2    % signal
    setpoint = [u(3) u(4)];
    set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);
  end
  if mode==3    % VR sensor
    system_name=gcs;
    idx=find(system_name=='/');
    model_name=system_name(1:idx(1)-1);     % extract model name
    wh=vrworld(get_param([model_name '/VR Sink'], 'WorldFileName'));
    nh=vrnode(wh,'MouseSensor');
    if getfield(nh,'isActive')                          %#ok this is overloaded GETFIELD
      setpoint = (getfield(nh,'hitPoint_changed'))';    %#ok this is overloaded GETFIELD
      setpoint=[setpoint(1) setpoint(3)];
      set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);
    end
  end
  return
end

%
% Get UserData of the figure.
%
ud = get(FigHandle,'UserData');
if isempty(ud.XData),
  x_data = [u(1) u(1)];
  y_data = [u(2) u(2)];
else
  x_data = [ud.XData(end) u(1)];
  y_data = [ud.YData(end) u(2)];
end

% plot the input lines
set(ud.XYAxes, ...
    'Visible','on',...
    'Xlim', axes(1:2),...
    'Ylim', axes(3:4));
set(ud.XYLine,...
    'Xdata',x_data,...
    'Ydata',y_data,...
    'LineStyle','-');
set(ud.XYTitle,'String','Trajectory Graph');
set(FigHandle,'Color',get(FigHandle,'Color'));

% update the setpoint

switch mode
 case 1                   % mouse
  set(FigHandle, 'WindowButtonDownFcn', 'sfuntraj([],[],[],''ButtonDown'')');
  if ~ud.SetpointInit
    set(ud.Setpoint,'Xdata',(axes(1)+axes(2))/2);
    set(ud.Setpoint,'Ydata',(axes(3)+axes(4))/2);
  end
  setpoint = [get(ud.Setpoint,'Xdata') get(ud.Setpoint,'Ydata')];
  set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);
  ud.SetpointInit=true;

case 2                    % signal
  set(FigHandle, 'WindowButtonDownFcn', 'drawnow');
  set(ud.Setpoint,'XData',u(3),'YData',u(4));
  setpoint = [u(3) u(4)];
  set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);
  ud.SetpointInit=true;

case 3                    % VR sensor
  set(FigHandle, 'WindowButtonDownFcn', 'drawnow');
  system_name=gcs;
  idx=find(system_name=='/');
  model_name=system_name(1:idx(1)-1);     % extract model name
  wh=vrworld(get_param([model_name '/VR Sink'], 'WorldFileName'));
  nh=vrnode(wh,'MouseSensor');
  if getfield(nh,'isActive')                          %#ok this is overloaded GETFIELD
    setpoint = (getfield(nh,'hitPoint_changed'))';    %#ok this is overloaded GETFIELD
    setpoint=[setpoint(1) setpoint(3)];
    set(ud.Setpoint,'XData',setpoint(1),'YData',setpoint(2));
    set_param([gcs '/Setpoint'],'Value',['[' num2str(setpoint) ']']);
    ud.SetpointInit=true;
  end
end


%
% update the X/Y stored data points
%
ud.XData(end+1) = u(1);
ud.YData(end+1) = u(2);
set(FigHandle,'UserData',ud);
drawnow

% end mdlUpdate

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% Trajectory Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn

%
% get the figure associated with this block, create a figure if it doesn't
% exist
%
FigHandle = GetSfuntrajFigure(gcbh);
if ~ishandle(FigHandle),
  FigHandle = CreateSfuntrajFigure;
end

ud = get(FigHandle,'UserData');
set(ud.XYLine,'Erasemode','normal');
set(ud.XYLine,'XData',[],'YData',[]);
set(ud.XYLine,'XData',0,'YData',0,'Erasemode','none');
ud.XData = [];
ud.YData = [];
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

FigHandle=GetSfuntrajFigure(gcbh);
if ishandle(FigHandle),
  %
  % Get UserData of the figure.
  %
  ud = get(FigHandle,'UserData');
  set(ud.XYLine,...
      'Xdata',ud.XData,...
      'Ydata',ud.YData,...
      'LineStyle','-');

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
FigHandle = GetSfuntrajFigure(gcbh);
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

SetSfuntrajFigure(gcbh,-1);

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
FigHandle=GetSfuntrajFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfuntrajFigure(gcbh,-1);
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
SetSfuntrajFigure(ud.Block,-1);

% end LocalFigureDeleteFcn

%
%=============================================================================
% LocalMouseFcn
% Sends mouse coordinates to block output.
%=============================================================================
%
function LocalMouseFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
mouse=get(get(ud.Setpoint,'Parent'),'CurrentPoint');
mouseX=mouse(1,1);
mouseY=mouse(1,2);
Xlim=get(ud.XYAxes,'Xlim');
Ylim=get(ud.XYAxes,'Ylim');
if (mouseX>=Xlim(1) && mouseX<=Xlim(2) && mouseY>=Ylim(1) && mouseY<=Ylim(2))
  set(ud.Setpoint,'XData',mouseX,'YData',mouseY);
end
drawnow;

% end LocalMouseFcn

%
%=============================================================================
% GetSfuntrajFigure
% Retrieves the figure window associated with this S-function XY Graph block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfuntrajFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

FigHandle=get_param(block,'UserData');
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfuntrajFigure

%
%=============================================================================
% SetSfuntrajFigure
% Stores the figure window associated with this S-function XY Graph block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfuntrajFigure(block,FigHandle)

if strcmp(get_param(bdroot,'BlockDiagramType'),'model'),
  if strcmp(get_param(block,'BlockType'),'S-Function'),
    block=get_param(block,'Parent');
  end

  set_param(block,'UserData',FigHandle);
end

% end SetSfuntrajFigure

%
%=============================================================================
% CreateSfuntrajFigure
% Creates the figure window associated with this S-function XY Graph block.
%=============================================================================
%
function FigHandle=CreateSfuntrajFigure

%
% the figure doesn't exist, create one
%
FigHandle = figure('Units',          'pixel',...
                   'Position',       [100 100 400 300],...
                   'Name',           get_param(gcbh,'Name'),...
                   'Tag',            'TRAJSCOPE',...
                   'NumberTitle',    'off',...
                   'IntegerHandle',  'off',...
                   'Toolbar',        'none',...
                   'Menubar',        'none',...
                   'DeleteFcn',      'sfuntraj([],[],[],''DeleteFigure'')');

%
% store the block's handle in the figure's UserData
%
ud.Block=gcbh;

%
% create various objects in the figure
%
ud.XYAxes   = axes;
h = plot(0,0,0,0,'or');
ud.XYLine   = h(1);
ud.Setpoint = h(2);
ud.SetpointInit = false;
set(ud.XYLine,'EraseMode','None');
set(ud.Setpoint,'EraseMode','xor');
ud.XYXlabel = xlabel('X Axis');
ud.XYYlabel = ylabel('Y Axis');
ud.XYTitle  = get(ud.XYAxes,'Title');
ud.XData    = [];
ud.YData    = [];
set(ud.XYAxes,'Visible','off');

%
% Associate the figure with the block, and set the figure's UserData.
%
SetSfuntrajFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfuntrajFigure

