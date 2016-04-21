function  [sys, x0, str, ts]  = eyediasi2(t,x,u,flag,...
    timeRange, time_offset, boundary, storeLength, diagType, ...
        eyeLine, scatterLine, twoDLine)
%EYEDIASI2 Simulink eye diagram and scatter plot.
%   [SYS, X0, STR, TS]  = ...
%       EYEDIASI2(T,X,U,FLAG,TIMERANGE,BOUNDARY,STORELENGTH,EYELINE,SCATTERLINE,TWODLINE)
%
%   This M-file is designed to be used in a Simulink S-function block.
%   It plots an eye diagram against time and the scatter plot.
%   The parameter for the block of this figure are:
%
%   timeRange     Time range ( and offset if it is a two element variable)
%   boundary     Lower and upper boundary of the Y axis.
%   storeLength  Keep number of traces in storage for print purpose.
%   eyeLine      Line type for eye-pattern diagram (0 for no such plot)
%   scatterLine  Symbol type for scatter plot (0 for no such plot)
%   twoDLine     Line type for 2-D trace plot (for 2-D signal only, 0 for no such plot)
%
%   This file takes scalar input and trigger signal input
%   or a 2 dimensional vector input and trigger signal input.
%
%   Set this M-file up in an S-function block.
%   Set the function parameter up as a four element vector
%   which defines the axis of the graph. The line type must be in
%   quotes.
%
%   See also PLOT, SFUNYST, SFUNXY, EYESAMPL

%       Copyright 1996-2003 The MathWorks, Inc.
%       $Revision: 1.1.8.2 $ $Date: 2004/04/12 23:02:35 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
  [sys,x0,ts] = mdlInitializeSizes(...
      timeRange, boundary, storeLength, eyeLine, scatterLine, twoDLine);
  SetBlockCallbacks(gcbh);
  str = '';
  
  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
  sys = mdlUpdate(t,x,u,...
      timeRange, time_offset, boundary, storeLength, diagType, eyeLine, scatterLine, twoDLine);

  %%%%%%%%%%%%%%%%%%%
  % Next Sample Hit %
  %%%%%%%%%%%%%%%%%%%
  case 4,
  sys = mdlGetTimeOfNextVarHit(t, x, u);

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case {1, 3, 9 }
    sys=[];

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

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
  if ischar(flag),
    errmsg=sprintf('Unhandled flag: '' 	%s''', flag);
  else
    errmsg=sprintf('Unhandled flag: 	%d', flag);
  end

  error(errmsg);

end

% end eyediasi2

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,ts] = mdlInitializeSizes(...
	timeRange, boundary, storeLength, eyeLine, scatterLine, twoDLine);

%
% call simsizes for a sizes structure, fill it in and convert it to a sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 3;   % 3 discrete states
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;  % dynamically sized input vector
sizes.DirFeedthrough = 0;   % the meter does not have direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

%
% initialize the initial condition
%
x0 = [0, 0, 0]; 			% figure handle, u[last] input, last_mod_time

% x(1), the figure handle.
ts = [-1, 0];

%
% str is always an empty matrix
%
str = [];

% end mdlInitializeSizes

%
%============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block. Note that the result
% is absolute time.
%============================================================================
%
function sys = mdlGetTimeOfNextVarHit(t, x, u);

sys = [];

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys = mdlUpdate(t,x,u,...
   timeRange, time_offset, boundary, storeLength, ...
    diagType, eyeLine, scatterLine, twoDLine);

sys = x;
%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
figureHandle = GetEyediasiFigure(gcbh);
if ~ishandle(figureHandle)
  return;
end;


% Determine which of the plots is to be created
switch (diagType)
case 'Eye Diagram'
    scatterLine(1) = 0;   % Don't do scatter plot
    twoDLine(1) = 0;     % Don't do xy plot
    if(eyeLine(1) == '0')
        error('Line type for eye diagram cannot be ''0''.');
    end

case 'Scatter Diagram'
    eyeLine(1) = 0;      % Don't do eye plot
    twoDLine(1) = 0;     % Don't do xy plot
    if(scatterLine(1) == '0')
        error('Line type for scatter diagram cannot be ''0''.');
    end

case 'Eye and Scatter Diagrams'
    twoDLine(1) = 0;     % Don't do xy plot
    if(eyeLine(1) == '0')
        error('Line type for eye diagram cannot be ''0''.');
    end
    if(scatterLine(1) == '0')
        error('Line type for scatter diagram cannot be ''0''.');
    end

case 'X-Y Diagram'
    eyeLine(1) = 0;      % Don't do eye plot
    scatterLine(1) = 0;   % Don't do scatter plot
    if(twoDLine(1) == '0')
        error('Line type for X-Y diagram cannot be ''0''.');
    end

case 'Eye and X-Y Diagrams'
    scatterLine(1) = 0;   % Don't do scatter plot
    if(eyeLine(1) == '0')
        error('Line type for eye diagram cannot be ''0''.');
    end
    if(twoDLine(1) == '0')
        error('Line type for X-Y diagram cannot be ''0''.');
    end

otherwise
    error('Illegal option selected for Diagram Type.');
end

% flatten boundary
sizeb = size(boundary);
if(sizeb(1) == 1)
    if(sizeb(2) ~= 2)
        error('The vector containing lower and upper bounds must have length 2.');
    end
else
    if((sizeb(1) ~= 2) | (sizeb(2) ~= 1))
        error('The vector containing lower and upper bounds must have length 2.');
    end
	boundary = boundary';
end

threshold = .2;
eye_plot = ~((eyeLine(1)==0) + (eyeLine(1)=='0'));
scatter_plot = ~((scatterLine(1)==0) + (scatterLine(1) == '0'));
two_d_plot = ~((twoDLine(1)==0) + (twoDLine(1) == '0'));
len_u = length(u)-1;

if two_d_plot & (len_u ~= 2)
  sl_name = get_param(0,'CurrentSystem');
  sl_name_gcs = sl_name;
  block = get_param(sl_name, 'CurrentBlock');
  error(['Please set 2-D plot line type to be zero in block ',...
	  sl_name, '/', block]);
  if len_u > 2
    error('The input signal length is limited to two.')
  end;
end;

plot_type = eye_plot + scatter_plot + two_d_plot;
% in case of no plot
if plot_type <= 0
  return;
end;

if(time_offset < 0)
     error('The Trace offset parameter must be greater than zero.');
end
timeRange(2) = rem(rem(time_offset, timeRange(1)) + timeRange(1), timeRange(1));

% initialize the figure
if x(1) == 0
  h_fig = x(1);
  % Initialize graph
  sl_name = gcs;
  block = get_param(sl_name,'CurrentBlock');
  sl_name_gcs = sl_name;
  if ~isempty(find(sl_name=='/'))
    sl_name = sl_name(find(sl_name=='/')+1 : length(sl_name));
  end;

  [n_b, m_b]= size(block);
  if n_b < 1
    error('Cannot delete block while simulating.');
  elseif n_b > 1
    error('Something wrong in get_param, You don''t have the current Simulink.')
  end;

  %  generate a new figure here.
  x(1) = figureHandle;
    allch = allchild(x(1));
    for idx = (1:length(allch))
        chType = get(allch(idx),'Type');
        if (~strcmp('uitoolbar',chType) & ~strcmp('uimenu',chType))
            delete(allch(idx));
        end
    end
  if plot_type == 1
    %open a single window figure
    figurePosition = get(x(1),'Position');
    figurePosition(3) = 360;
    set(x(1), ...
	'Visible','on',...
	'Position', figurePosition );
%    set(x(1),'MenuBar','figure');
    plt(1) = axes('Unit','norm',...
	'Pos',[.08, .08 .87,.87],...
	'Clipping', 'on',...
	'Parent', x(1),...
	'NextPlot','Add' ,...
	'HandleVisibility', 'off');
  elseif plot_type == 2
    % open a double window figure
    figurePosition = get(x(1),'Position');
    figurePosition(3) = 660;
    set(x(1), ...
	'Visible','on',...
	'Position', figurePosition );
    plt(1) = axes('Unit','norm',...
	'Pos',[.08, .08 .8/2,.87],...
	'Clipping', 'on',...
	'Parent', x(1),...
	'NextPlot','Add',...
	'HandleVisibility', 'Off');
    plt(2) = axes('Unit','norm',...
	'Pos',[.08+.5, .08 .8/2,.87],...
	'Parent', x(1),...
	'NextPlot','Add',...
	'HandleVisibility', 'Off');
  elseif plot_type == 3
    % open a three window figure
    figurePosition = get(x(1),'Position');
    figurePosition(3) = 960;
    set(x(1), ...
	'Visible','on',...
	'Position', figurePosition );
    plt(1) = axes('Unit','norm',...
	'Pos',[.04, .08 .79/3,.87],...
	'Parent', x(1), ...
	'Clipping', 'on',...
	'NextPlot','Add',...
	'HandleVisibility', 'Off');
    plt(2) = axes('Unit','norm',...
	'Parent', x(1), ...
	'Pos',[.04+1/3, .08 .79/3,.87],...
	'NextPlot','Add',...
	'HandleVisibility', 'Off');
    plt(3) = axes('Unit','norm',...
	'Parent', x(1), ...
	'Pos',[.04+2/3, .08 .79/3,.87],...
	'NextPlot','Add',...
	'HandleVisibility', 'Off');
  end;

  i = 1;
  if eye_plot
    eye_plot = plt(i);
    i = i+1;
    set(x(1),'CurrentAxes',eye_plot);
    ax = [];
    lines = eyeLine;
    for j = 1:len_u+1;
      [col, lines] = strtok(lines, '/');
      if length(col) <= 1
    	col = 'k-';
      end;
      if lower(col(1)) == 'n'
    	ax(j) = 0
      else
    	[linest, markst] = LineTypeSeparation(col(2:length(col)));
    	ax(j) = plot(0,0,col,...
    	    'Erasemode','none',...
    	    'Color',col(1),...
    	    'Parent', eye_plot, ...
    	    'LineStyle',linest,...
    	    'Marker', markst);
    	set(ax(j), 'XData', [],...
    	    'YData', []);
      end;
    end;

    set(eye_plot,'Xlim',...
	[rem(timeRange(2)/timeRange(1),1)*timeRange(1),...
	    timeRange(1)+timeRange(2)], ...
	'Ylim',[boundary(1), boundary(2)],...
	'Clipping', 'on');
    set(eye_plot,'UserData',[ax, 0  ]);
    %                        |   | |==>space for time points
    %                        |   |==> number of NaN added
    %                        |===> have size of length(u)
  end;
  if (scatter_plot)
    scatter_plot = plt(i);
    i = i + 1;
    set(x(1),'CurrentAxes',scatter_plot);
    ax = [];
    lines = scatterLine;
    for j = 1:len_u
      [col, lines] = strtok(lines, '/');
      if length(col) <= 1
	col = 'k-';
      end;
      if ((len_u == 2) & (j == 2))
	ax(j) = 0;
      else
	if lower(col(1)) == 'n'
	  ax(j) = 0
	else
	  [linest, markst] = LineTypeSeparation(col(2:length(col)));
	  ax(j) = plot(0,0,col,...
	      'Erasemode','none',...
	      'Parent', scatter_plot, ...
	      'Color',col(1),...
	      'LineStyle',linest,...
	      'Marker', markst);
	  if col(2) == '.'
	    set(ax(j), 'MarkerSize', 10);
	  end;
	  set(ax(j), 'XData', [], 'YData', []);
	end;
      end;
    end;
    if len_u == 2
      set(scatter_plot,...
	  'Xlim',[boundary(1), boundary(2)], ...
	  'Ylim',[boundary(1), boundary(2)]);
    else
      set(scatter_plot,...
	  'Xlim',[-1, 1],...
	  'Ylim',[boundary(1), boundary(2)]);
    end;
    set(scatter_plot,...
	'UserData',[ax, abs(scatterLine)]);
  end;
  if two_d_plot
    two_d_plot = plt(i);
    % This case, length(u) must be 3
    set(x(1),'CurrentAxes',two_d_plot);
    set(two_d_plot,'Xlim',[boundary(1), boundary(2)], ...
	'Ylim',[boundary(1), boundary(2)]);
    [col, lines] = strtok(twoDLine, '/');
    if length(col) <= 1
      col = 'k-';
    end;
    [linest, markst] = LineTypeSeparation(col(2:length(col)));
    ax = plot(0,0,col,...
	'Erasemode','none',...
	'Parent', two_d_plot,...
	'Color',col(1),...
	'Marker', markst, ...
	'LineStyle',linest);
    set(two_d_plot,...
	'Xlim',[boundary(1), boundary(2)], ...
	'Ylim',[boundary(1), boundary(2)]);
    set(ax, 'XData', [], 'YData', []);
    set(two_d_plot,'UserData',[ax, 0 abs(twoDLine)]);
  end;
  set(x(1),'UserData',[eye_plot, scatter_plot, two_d_plot, timeRange, boundary, abs(eyeLine)]);
  %                    1         2             3           4           6         8
  tud = get_param(sl_name_gcs, 'userdata');
  tud.figureHandle = x(1);
  set_param(sl_name_gcs, 'userdata', tud);
elseif x(1) < 0
  % figure has been closed.
  return;
end;

plot_flag_test = allchild(0);
if isempty(plot_flag_test)
  return;
elseif isempty(find(plot_flag_test == x(1)))
  x(1) = -1;
  return;
end;

handles = get(x(1), 'UserData');
len_u = length(u) - 1;
changed_boundary   = 0;
if max(boundary ~= handles(6:7)) > 0
  changed_boundary = 1;
end;

triggered = 0;
if (u(len_u+1) >= threshold) & (x(2) < threshold)
  triggered = 1;
end;
x(2) = u(len_u+1);

if handles(1) & eye_plot
  %eye_pattern plot
  sub_han = get(handles(1),'UserData');
  changed_timeRange = 0;
  if max(timeRange ~= handles(4:5)) > 0
    changed_timeRange = 1;
  end;
  if changed_boundary
    set(handles(1), 'Ylim', boundary);
  end;
  if changed_timeRange
    %this is a complicated process. Deal it later.
  end;
  len_h_userdata = length(handles);
  changed_line_type = 0;
  if (length(eyeLine) ~= len_h_userdata-7)
    changed_line_type = 1;
  elseif max(abs(eyeLine) ~= handles(8:len_h_userdata))
    changed_line_type = 1;
  else
    changed_line_type = 0;
  end;
  if changed_line_type
    lines = eyeLine;
    for i = 1 : len_u+1
      [col, lines] = strtok(lines, '/');
      if length(col) <= 1
	col = 'k-';
      end;
      if sub_han(i)
	[linest, markst] = LineTypeSeparation(col(2:length(col)));
	set(sub_han(i),...
	    'Color', col(1),...
	    'LineStyle', linest,...
	    'Marker', markst);
      end;
    end;
    set(x(1),'UserData',[handles(1:7), abs(eyeLine)]);
  end;
  mod_time = rem((t - timeRange(2))/timeRange(1), 1) ...
      * timeRange(1) + timeRange(2);
  last_time = x(3);
  if ~handles(3)
    x(3) = mod_time;
  end;
  if (mod_time < last_time)
    if storeLength <= 0
      storeLength = 1;
    end
    %hit the boundary of switching point.
    pre_point = mod_time + timeRange(1);
    aft_point = mod_time;
    ind = [];
    if sub_han(len_u+2) >= storeLength
      ind = find(isnan(sub_han(len_u+3:length(sub_han))));
      sub_han(len_u+3:ind(max(1, length(ind)-storeLength))) = [];
      sub_han(len_u+2) = sum(isnan(sub_han(len_u+3:length(sub_han))));
    end;
    sub_han(len_u + 2) = sub_han(len_u + 2) + 1;
    sub_han = [sub_han t NaN t];
    set(handles(1),'UserData',sub_han);
    for i = 1 : len_u
      if sub_han(i)
	tmp_x = get(sub_han(i), 'XData');
	tmp_y = get(sub_han(i), 'YData');
	if ~isempty(ind)
	  tmp_x(1:ind(max(1, length(ind)-storeLength))-len_u-2) = [];
	  tmp_y(1:ind(max(1, length(ind)-storeLength))-len_u-2) = [];
	end;
	set(sub_han(i), 'XData',[tmp_x, pre_point, NaN, aft_point],...
	    'YData',[tmp_y, u(i),      NaN, u(i)]);
      end;
    end;
  else
    set(handles(1), 'UserData',[get(handles(1), 'UserData') t])
    for i = 1 : len_u
      if sub_han(i)
	set(sub_han(i), 'XData', [get(sub_han(i), 'XData'), mod_time], ...
	    'YData', [get(sub_han(i), 'YData'), u(i)]);
      end;
    end;
  end;

  if triggered & sub_han(len_u) & (t > 0)
    if storeLength <= 0
      storeLength = 1;
    end
    tmp_x = get(sub_han(len_u + 1), 'XData');
    tmp_y = get(sub_han(len_u + 1), 'YData');
    if length(tmp_x) > 3*storeLength
      tmp_x(1:3) = [];
      tmp_y(1:3) = [];
    end;
    tmp_x = [tmp_x, mod_time, mod_time, NaN];
    tmp_y = [tmp_y, get(handles(1), 'YLim'), NaN];
    set(sub_han(len_u + 1), 'XData', tmp_x, 'YData', tmp_y);
  end;
end;

if handles(2) & triggered & (t>0) & scatter_plot
  if storeLength <= 0
    storeLength = 1;
  end
  %scatter plot
  sub_han = get(handles(2), 'UserData');
  if changed_boundary
    set(handles(2), 'Ylim', boundary);
    if len_u == 2
      set(handles(2), 'Xlim', boundary);
    end;
  end;
  len_h_userdata = length(sub_han);
  changed_line_type = 0;
  if (length(scatterLine) ~= len_h_userdata - len_u)
    changed_line_type = 1;
  elseif max(abs(scatterLine) ~= sub_han(len_u+1:len_h_userdata))
    changed_line_type = 1;
  end;
  if changed_line_type
    lines = scatterLine;
    for i = 1 : len_u
      [col, lines] = strtok(lines, '/');
      if length(col) <= 1
	col = 'k-';
      end;
      if ~((i == 2) & (len_u == 2))
	[linest, markst] = LineTypeSeparation(col(2:length(col)));
	set(sub_han(i),...
	    'Color',col(1),...
	    'LineStyle', linest,...
	    'Marker', markst);
	if col(2) == '.'
	  set(sub_han(i), 'MarkerSize', 10);
	else
	  set(sub_han(i), 'MarkerSize', 6);
	end;
      end;
    end;
    set(handles(2), 'UserData',[sub_han(1:len_u), abs(scatterLine)]);
  end;
  if len_u == 2
    tmp_x = get(sub_han(1), 'XData');
    tmp_y = get(sub_han(1), 'YData');
    if length(tmp_x) > 2*storeLength
      tmp_x(1:2) = [];
      tmp_y(1:2) = [];
    end;
    tmp_x = [tmp_x, u(1)];
    tmp_y = [tmp_y, u(2)];
    set(sub_han(1), 'XData', tmp_x, 'YData', tmp_y);
  else
    for i = 1 : len_u
      tmp_x = get(sub_han(i), 'XData');
      tmp_y = get(sub_han(i), 'YData');
      if length(tmp_x) > 2*storeLength
	tmp_x(1:2) = [];
	tmp_y(1:2) = [];
      end;
      tmp_x = [tmp_x, 0];
      tmp_y = [tmp_y, u(i)];
      set(sub_han(i), 'XData', tmp_x, 'YData', tmp_y);
    end;
  end;
end;

if handles(3) & two_d_plot
  %2-d eye_plot
  sub_han = get(handles(3), 'UserData');
  if changed_boundary
    set(handles(3), 'Xlim', boundary, 'Ylim', boundary);
  end;
  len_h_userdata = length(sub_han);
  changed_line_type = 0;
  if (length(twoDLine) ~= len_h_userdata - 2)
    changed_line_type = 1;
  elseif max(abs(twoDLine) ~= sub_han(3:len_h_userdata))
    changed_line_type = 1;
  end;
  if changed_line_type
    [col, lines] = strtok(twoDLine, '/');
    if length(col) <= 1
      col = 'k-';
    end;
    [linest, markst] = LineTypeSeparation(col(2:length(col)));
    set(sub_han(1),...
	'Color',col(1),...
	'LineStyle',linest,...
	'Marker', markst);
    set(handles(3), 'UserData',[sub_han(1:2), abs(twoDLine)]);
  end;
  mod_time = rem((t - timeRange(2))/timeRange(1),1)...
      * timeRange(1) + timeRange(2);
  last_time = x(3);
  x(3) = mod_time;
  if mod_time < last_time
    if storeLength <= 0
      storeLength = 1;
    end
    tmp_x = get(sub_han(1),'XData');
    tmp_y = get(sub_han(1),'YData');
    if sub_han(2) >= storeLength
      ind = find(isnan(tmp_x));
      tmp_x(1:ind(1)) = [];
      tmp_y(1:ind(1)) = [];
    end;
    tmp_x = [tmp_x u(1) NaN u(1)];
    tmp_y = [tmp_y u(2) NaN u(2)];
    set(handles(3),'UserData',[sub_han(1) sum(isnan(tmp_x)) abs(twoDLine)])
    set(sub_han(1),'XData',tmp_x,'YData',tmp_y);
  else
    set(sub_han(1), 'XData', [get(sub_han(1), 'XData'), u(1)], ...
	'YData', [get(sub_han(1), 'YData'), u(2)]);
  end;
  drawnow;
end;
sys = x;

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
close(gcbf);

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
figureHandle = GetEyediasiFigure(gcbh);
if ~ishandle(figureHandle),
  figureHandle = CreateEyediasiFigure;
end

ud = get(figureHandle,'UserData');
set(figureHandle,'UserData',ud);

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
figureHandle=GetEyediasiFigure(gcbh);
if ishandle(figureHandle),
  %
  % Get UserData of the figure.
  %
  ud = get(figureHandle,'UserData');
  % Currently do nothing in LocalBlockStopFcn

end

% end LocalBlockStopFcn

%
%=============================================================================
% LocalBlockNameChangeFcn
% Function that handles name changes on the Continuous Eye-Scatter.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% the figure handle is stored in the block's UserData
%
figureHandle = GetEyediasiFigure(gcbh);
if ishandle(figureHandle),
  set(figureHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% Function that initializes the Continuous Eye-Scatter's UserData when it is
% loaded from an mdl file and when it is copied.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetEyediasiFigure(gcbh,[]);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% Function that handles the Continuous Eye-Scatter's deletion from a block
% diagram.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% the figure handle is stored in the block's UserData
%
figureHandle = GetEyediasiFigure(gcbh);
if ishandle(figureHandle),
  delete(figureHandle);
  SetEyediasiFigure(gcbh,[]);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% GetEyediasiFigure
% Retrieves the figure window associated with this S-function Continuous Eye-Scatter
% from the block's parent subsystem's UserData.
%=============================================================================
%
function figureHandle=GetEyediasiFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud = get_param(block,'UserData');
if ishandle(ud)
   figureHandle = ud;
else
  if isempty(ud)
    ud.figureHandle = [];
    set_param(block,'UserData', ud);
  end;
  figureHandle = ud.figureHandle;
end;

if isempty(figureHandle),
  figureHandle = -1;
end

% end GetEyediasiFigure

%
%=============================================================================
% SetEyediasiFigure
% Stores the figure window associated with this S-function Continuous Eye-Scatter
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetEyediasiFigure(block,figureHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud = get_param(block,'UserData');
ud.figureHandle = figureHandle;
set_param(block,'UserData',ud);

% end SetEyediasiFigure

%
%=============================================================================
% CreateEyediasiFigure
% Creates the figure window associated with this S-function Continuous Eye-Scatter.
%=============================================================================
%
function figureHandle=CreateEyediasiFigure

%
% create the figure and the axes
%

a = allchild(0);
b = findobj(a, 'Name', get_param(gcbh,'Name'));
if isempty(b)
   figureHandle = figure(...
      'Units',        'points',...
      'Position',     [10 10 360 350],...
      'NumberTitle',  'off',...
      'Name',         get_param(gcbh,'Name'),...
      'Visible',      'off', ...
      'DeleteFcn',    'eyediasi2([],[],[],''DeleteFigure'')'...
      );
else
  figureHandle = b;
end;
set(0, 'CurrentFigure', figureHandle);

%
% store the block's handle in the figure's UserData
%
ud.Block = gcbh;
%ud.figureHandle = figureHandle;

%
% squirrel the figure handle away in the current block, and put the
% various handles into the figure's UserData
%
SetEyediasiFigure(gcbh,figureHandle);
set(figureHandle,'HandleVisibility','callback','UserData',ud);

% end CreateEyediasiFigure

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
%  warnmsg=sprintf(['The Eye-Pattern diagram block ''%s'' should be replaced with a ' ...
%                   'new version from the com_sour block library'],...
%                   block);
%  warning(warnmsg);

  callbacks={
    'CopyFcn',       'eyediasi2([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'eyediasi2([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'eyediasi2([],[],[],''LoadBlock'')' ;
    'StartFcn',      'eyediasi2([],[],[],''Start'')' ;
    'StopFcn'        'eyediasi2([],[],[],''Stop'')' ;
    'NameChangeFcn', 'eyediasi2([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks)
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2})
      set_param(block,callbacks{i,1},callbacks{i,2});
    end
  end
end

% end SetBlockCallbacks

%
%===============================================================
% Local Function
% This is used to separate the line type and mark type.
%===============================================================
%
function [linest, markst] = LineTypeSeparation(linetype)

% take out the marks
linest = linetype;
linidx = [findstr(linetype, '.'), ...
          findstr(linetype, 'o'), ...
          findstr(linetype, 'x'), ...
          findstr(linetype, '+'), ...
          findstr(linetype, '*'), ...
          findstr(linetype, 's'), ...
          findstr(linetype, 'd'), ...
          findstr(linetype, 'v'), ...
          findstr(linetype, '^'), ...
          findstr(linetype, '<'), ...
          findstr(linetype, '>'), ...
          findstr(linetype, 'p'), ...
          findstr(linetype, 'h')];
markst = 'none';
if ~isempty(linidx)
  markst = linetype(linidx);
  linest(linidx) = [];
end;
if isempty(linest)
  linest = 'none';
end;

%%%%%%%%%%%%%%%%%%%%%%%%
%   End of eyediasi2.M  %
%%%%%%%%%%%%%%%%%%%%%%%%
