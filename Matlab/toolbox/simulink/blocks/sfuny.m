function [sys, x0, str, ts] = sfuny(t,x,u,flag,...
                                    axisLimits,lineStyles,varargin)
%SFUNY S-function scope using graph window.
%   This M-file is designed to be used in a Simulink S-function block.
%   It stores the last input point using discrete states and then plots
%   this against time.
%
%   S-function Syntax (see SFUNTMPL):
%     [SYS, X0]  = SFUNY(T,X,U,FLAG,AXISLIMITS,LTYPE,SAMPLETIME)
%   where:
%     AXISLIMITS - graph axis limits
%     LINESTYLES - line type (e.g. 'r','r-.','x') (See PLOT)
%     SAMPLETIME - the sample time for this block
%
%   Set the function parameter up as a four element vector
%   which defines the axis of the graph. The line type must be in
%   quotes.
%
%   See also PLOT, SFUNYST, SFUNXY.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.44 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(axisLimits,lineStyles,varargin{:});
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,axisLimits,lineStyles,varargin{:});

  %%%%%%%%%
  % Start %
  %%%%%%%%%
  case 'Start'
    LocalBlockStartFcn

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
    
  %%%%%%%%%%%%%
  % Load,Copy %
  %%%%%%%%%%%%%
  case { 'LoadBlock', 'CopyBlock' }
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

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case { 3, 9 }
    sys=[];

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

% end sfuny

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(axisLimits,lineStyles,varargin)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;  % dynamically sized input vector
sizes.DirFeedthrough = 1;   % the Graph scope does have direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0 = [];

%
% str is always an empty matrix
%
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

%
% squirrel away the axis limits in block's userdata
%
SetSfunYAxisLimits(gcbh,axisLimits)

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,axisLimits,lineStyles,dt)

sys = [];

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunYFigure(gcbh);
if ~ishandle(FigHandle),
  return
end

ud=get(FigHandle,'UserData');

%
% if the figure has just been initialized, create the lines for the first
% time
%
if ud.Init,
  for i=1:length(u),
    ud.Lines(i)=line('Parent',ud.Axis,...
                     'XData',[nan nan],...
		     'YData',[nan nan],...
		     'EraseMode','none');
    if i < length(ud.LineStyles)
      set(ud.Lines(i),ud.LineStyles{i,:})
    end
  end
  ud.Init=0;

  %
  % initialize/create the storage buffers
  %  
  ud.Time(1:1024)       =nan;
  ud.Y(1:1024,length(u))=nan;
  ud.Index = 0;

  ud.XMax = axisLimits(2);
  
  %
  % initialize the axis limits
  %
  axisLimits=GetSfunYAxisLimits(gcbh);
  set(ud.Axis,'XLim',axisLimits(1:2),'YLim',axisLimits(3:4));
end

%
% if the axis limits have changed, update them here
%
if any(GetSfunYAxisLimits(gcbh) ~= axisLimits),
  SetSfunYAxisLimits(gcbh,axisLimits)
  xlim=get(ud.Axis,'XLim');
  xlim(2)=xlim(1)+axisLimits(2);
  ud.XMax=xlim(2);
  set(ud.Axis,'XLim',xlim,'YLim',axisLimits(3:4));
end

%
% if the time has exceeded the XMax, then shift the axes
%
if t > ud.XMax,
  xlim=get(ud.Axis,'XLim');
  xlim=xlim+diff(xlim);
  set(ud.Axis,'XLim',xlim);
  ud.XMax=xlim(2);
  
  %
  % shift the buffers down
  %
  lastPoint=find(isnan(ud.Time));
  if ~isempty(lastPoint)
    lastPoint=lastPoint(1)-1;
  else
    lastPoint=length(ud.Time);
  end
  
  ud.Time(1)=ud.Time(lastPoint);
  ud.Y(1,:) =ud.Y(lastPoint,:);
  
  ud.Time(2:end)=nan;
  ud.Y(2,:)     =nan;
  
  ud.Index      =1;
end

%
% draw all the lines
%
discrete=any(get_param(gcbh,'CompiledSampleTime')~=0);
if ud.Index>0
  for i=1:length(u),
    if discrete,
      set(ud.Lines(i),...
	  'XData',[ud.Time(ud.Index) t                t],...
	  'YData',[ud.Y(ud.Index,i)  ud.Y(ud.Index,i) u(i)]);
    else
      set(ud.Lines(i),...
	  'XData',[ud.Time(ud.Index) t],...
	  'YData',[ud.Y(ud.Index,i)  u(i)]);
    end
  end
end

%
% if necessary, grow the storage buffers, and then store the
% current time and input in them
%
if ud.Index==size(ud.Y,1),
  ud.Y(end+1:end+1024,:) =nan;
  ud.Time(end+1:end+1024)=nan;
end
ud.Index=ud.Index+1;
ud.Y(ud.Index,:) =u';
ud.Time(ud.Index)=t;

%
% keep the user data current
%
set(FigHandle,'UserData',ud);

drawnow;

% end mdlUpdate

%
%=============================================================================
% LocalFigureDeleteFcn
% This is the Graph figure window's DeleteFcn.  The figure window is
% being deleted, update the Graph block's UserData to reflect the change.
%=============================================================================
%
function LocalFigureDeleteFcn

%
% Get the block associated with this figure and set it's figure to -1
%
ud=get(gcbf,'UserData');
SetSfunYFigure(ud.Block,-1)

% end LocalFigureDeleteFcn

%
%=============================================================================
% LocalBlockStartFcn
% Function that is called when the simulation starts.  Initialize the
% Graph scope figure.
%=============================================================================
%
function LocalBlockStartFcn

%
% get the figure associated with this block, create a figure if it doesn't
% exist
%
FigHandle = GetSfunYFigure(gcbh);
if ~ishandle(FigHandle),
  FigHandle = CreateSfunYFigure;
end

ud = get(FigHandle,'UserData');

ud.LineStyles=ParseLineStyles;

delete(ud.Lines);
ud.Lines=[];
ud.XMax =[];
ud.Time =[];
ud.Y    =[];
ud.Init = 1;

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

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
FigHandle=GetSfunYFigure(gcbh);
if ishandle(FigHandle),
  %
  % Get UserData of the figure.
  %
  ud=get(FigHandle,'UserData');

  %
  % determine where the data ends in the storage buffers, unused
  % entries are filled with nan's
  %
  lastPoint=find(isnan(ud.Time));
  if ~isempty(lastPoint)
    lastPoint=lastPoint(1);
  else
    lastPoint=length(ud.Time);
  end

  %
  % make the lines permanent
  %
  discrete=any(get_param(gcbh,'CompiledSampleTime')~=0);
  for i=1:length(ud.Lines),
    if discrete,
      [x,y]=stairs(ud.Time(1:lastPoint),ud.Y(1:lastPoint,i));
      set(ud.Lines(i),...
	  'XData',    x,...
	  'YData',    y,...
	  'EraseMode','normal');
    else
      set(ud.Lines(i),...
	  'XData',    ud.Time(1:lastPoint),...
	  'YData',    ud.Y(1:lastPoint,i),...
	  'EraseMode','normal');
    end
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
% the figure handle is stored in the block's UserData
%
FigHandle = GetSfunYFigure(gcbh);
if ishandle(FigHandle),
  set(FigHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% Function that initializes the Graph scope block's UserData when it is
% loaded from an mdl file and when it is copied.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSfunYFigure(gcbh,[]);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% Function that handles the Graph scope block's deletion from a block
% diagram.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% the figure handle is stored in the block's UserData
%
FigHandle = GetSfunYFigure(gcbh);
if ishandle(FigHandle),
  delete(FigHandle);
  SetSfunYFigure(gcbh,[]);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% GetSfunYFigure
% Retrieves the figure window associated with this S-function Graph scope block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function FigHandle=GetSfunYFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud=get_param(block,'UserData');

FigHandle=ud.FigHandle;
if isempty(FigHandle),
  FigHandle=-1;
end

% end GetSfunYFigure

%
%=============================================================================
% SetSfunYFigure
% Stores the figure window associated with this S-function Graph scope block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunYFigure(block,FigHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud=get_param(block,'UserData');
ud.FigHandle=FigHandle;
set_param(block,'UserData',ud);

% end SetSfunYFigure

%
%=============================================================================
% GetSfunYAxisLimits
% Retrieves the axis limits associated with this S-function Graph scope block
% from the block's parent subsystem's UserData.
%=============================================================================
%
function AxisLimits=GetSfunYAxisLimits(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud=get_param(block,'UserData');
AxisLimits=ud.AxisLimits;

% end GetSfunYAxisLimits

%
%=============================================================================
% SetSfunYAxisLimits
% Stores the axis limits associated with this S-function Graph scope block
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSfunYAxisLimits(block,AxisLimits)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud=get_param(block,'UserData');
ud.AxisLimits=AxisLimits;
set_param(block,'UserData',ud);

% end SetSfunYAxisLimits

%
%=============================================================================
% CreateSfunYFigure
% Creates the figure window associated with this S-function Graph scope block.
%=============================================================================
%
function FigHandle=CreateSfunYFigure

%
% create the figure and the axes
%
FigHandle = figure('Units',        'points',...
                   'Position',     [100 100 400 300],...
                   'MenuBar',      'none',...
                   'NumberTitle',  'off',...
                   'Name',         get_param(gcbh,'Name'),...
                   'IntegerHandle','off',...
                   'DeleteFcn',    'sfuny([],[],[],''DeleteFigure'')');

axisLimits = GetSfunYAxisLimits(gcbh);
ud.Axis=axes( ...
       'XLim', axisLimits(1:2),...
	     'XGrid','on',...
       'YLim', axisLimits(3:4),...
	     'YGrid','on',...
       'Box',  'on');

xLabel=get(ud.Axis,'XLabel');
set(xLabel,'String','Time (seconds)')

ud.Lines=[];

%
% store the block's handle in the figure's UserData
%
ud.Block     =gcbh;
ud.LineStyles=ParseLineStyles;
ud.Time      =[];
ud.Y         =[];

%
% squirrel the figure handle away in the current block, and put the
% various handles into the figure's UserData
%
SetSfunYFigure(gcbh,FigHandle);
set(FigHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSfunYFigure

%
%=============================================================================
% ParseLineStyles
% Parse the lineStyles parameter and return an array of line styles.  Each
% element of the line styles array is a cell array of propery/value pairs
% suitable for passing to set or line.
%=============================================================================
%
function styles=ParseLineStyles

try
  lineStyles = eval(get_param(gcbh,'color'));
catch
  values = get_param(gcbh,'MaskValues');
  lineStyles = eval(values{4});
end

styles = cell(0,6);

%
% each line style is separated by a '/'
%
while ~isempty(lineStyles),

  [style,lineStyles]=strtok(lineStyles,'/');

  %
  % extract the color
  %
  colorList={ 'red','green','blue','cyan','magenta','yellow','white','black',...
              'r','g','b','c','m','y','w',...
               };
  color='';
  for i=1:length(colorList),
    if ~isempty(strmatch(colorList{i},style))
      color=colorList{i};
      break;
    end
  end
  if isempty(color),
    color='black';
  else
    style(1:length(color))='';
  end
  
  %
  % extract the line style
  %
  lineStyleList={ '--', ':', '-.', '-' };
  lineStyle='';
  for i=1:length(lineStyleList)
    if ~isempty(strmatch(lineStyleList{i},style))
      lineStyle=lineStyleList{i};
      break;
    end
  end
  if isempty(lineStyle),
    lineStyle='none';
  else
    style(1:length(lineStyle))=[];
  end

  %
  % extract the marker setting
  %
  markerList={ '+', 'o', '*', '.', 'x', 'square', 'diamond',...
               'v', '^', '>', '<', 'pentagram', 'hexagram' };
  marker='';
  for i=1:length(markerList)
    if ~isempty(strmatch(markerList{i},style))
      marker=markerList{i};
      break;
    end
  end
  if isempty(marker),
    marker='none';
  end

  styles(end+1,:) = { 'Color',     color,...
                      'LineStyle', lineStyle,...
                      'Marker',    marker };
end

% end ParseLineStyles

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
  warnmsg=sprintf(['The Graph scope ''%s'' should be replaced with a ' ...
                   'new version from the com_sour block library'],...
                   block);
  warning(warnmsg);

  callbacks={
    'CopyFcn',       'sfuny([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sfuny([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sfuny([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sfuny([],[],[],''Start'')' ;
    'StopFcn'        'sfuny([],[],[],''Stop'')' 
    'NameChangeFcn', 'sfuny([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks),
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2}),
      set_param(block,callbacks{i,1},callbacks{i,2})

      % If the load callback is being set then call it too, since 
      % this is the first time the block is being updated
      if strcmp(callbacks{i,1}, 'LoadFcn')
        eval(callbacks{i,2})
      end
    
    end
  end

end

% end SetBlockCallbacks
