function [sys, x0, str, ts] = sbiterr(t,x,u,flag, numLine, K, timeDelay, sampleTime)
% SBITERR: S-function for display symbol and bit error
% This M-file is designed to be used in a Simulink S-function block.
%
%WARNING: This is an obsolete function and may be removed in the future.

% [SYS, X0, STR, TS] = SBITERR(T, X, U, FLAG, NUMLINE, K, TIMEDELAY, SAMPLETIME)
%    NUMLINE:   number of lines on display.
%    K:         bit number. Input/Output are in the range (0, K-1)
%    TIMEDELAY: time delay from Input to Output
%    SAMPLETIME:sample time of the input signal
%
% See also: PlOT, SFUNYST, SFUNXY.

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.32 $
%   Original designed by Wes Wang 1/14/95
%   Rewritten by Jun Wu 09/16/97

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,ts]=mdlInitializeSizes(numLine, K, timeDelay, sampleTime);
    SetBlockCallbacks(gcbh);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,numLine, K, timeDelay, sampleTime);

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
      errmsg=sprintf('Unhandled flag: '' %s''', flag);
    else
      errmsg=sprintf('Unhandled flag: 	%d', flag);
    end

    error(errmsg);

end

% end sbiterr

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,ts]=mdlInitializeSizes(numLine, K, timeDelay, sampleTime)

% Keep number of states
numStates = max(0, ceil(timeDelay/sampleTime(1)*(1-10*eps))) + 1;

if timeDelay < 0
  error('Time delay cannot be negative.');
end;

if length(sampleTime) < 1
  error('Sample time cannot be empty.');
elseif length(sampleTime) == 1  
  sampleTime = [sampleTime, 0];
else
  sampleTime = sampleTime(:)';
  sampleTime = sampleTime(1:2);
end;

if rem( timeDelay + sampleTime(2), sampleTime(1) ) == 0
  sampleTime2 = [];
  numSampleTime = 1;
else
  sampleTime2 = [ sampleTime(1), rem( timeDelay + sampleTime(2), sampleTime(1) ) ];
  if sampleTime2(2) / sampleTime2(1) < sqrt(eps)
    sampleTime2(2) = 0;
  end;
  numSampleTime = 2;
  if ( abs(sampleTime(1) - sampleTime2(1)) < sqrt(eps) ) ...
	& ( abs(sampleTime(2) - sampleTime2(2)) < sqrt(eps) )
    numSampleTime = 1;
    sampleTime2 = [];
  end;
end;

%
% initialize the array of sample times
%
if sampleTime <= 0
  error('Sample Time for error rate meter has to be larger than zero.');
end;    
ts = [ sampleTime; sampleTime2 ];

%
% call simsizes for a sizes structure, fill it in and convert it to a sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = numStates + 6;
sizes.NumOutputs     = 0;
sizes.NumInputs      = -1;  % dynamically sized input vector
sizes.DirFeedthrough = 0;   % the meter does not have direct feedthrough
sizes.NumSampleTimes = numSampleTime;

sys = simsizes(sizes);

if isempty(sampleTime2)
  sampleTime2 = sampleTime;
end;

%
% initialize the initial condition
%
x0 = [0; numStates; 			% figure number. 0 indicates the first
    zeros(numStates, 1);
    numSampleTime; sampleTime(1);
    sampleTime(2); sampleTime2(2)]; 	% number of states

%
% str is always an empty matrix
%
str = [];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t, x, u, numLine, K, timeDelay, sampleTime)

sys = [];

%
% Locate the figure window associated with this block. If it's not a valid
% handle (it may have been closed by the user), then return.
%
figureHandle = GetSBiterrFigure(gcbh);
if ~ishandle(figureHandle)
  return;
end;  

%
%timing control.
%
colorMap = ['blue ';'black';'red  '];
positionNumSampleTime = x(2) + 3;
sampleTime1 = [ x( positionNumSampleTime + [1:2] ) ];

if x(positionNumSampleTime) == 1
  sampleTime2 = sampleTime1;
else
  sampleTime2 = [ x(positionNumSampleTime + [1;3]) ];
end;

relError = rem(t, sampleTime1(1)) / sampleTime1(1);
test1 = abs(relError - sampleTime1(2) /sampleTime1(1));
test2 = abs(relError - sampleTime1(2) /sampleTime1(1));

if (test1 < .0000001) | (abs(test1 - 1)< .0000001)
  % storage part
  if x(2) > 0
    x(3:2+x(2)) = [x(4:2+x(2)); u(1)];
  else
    x(3) = u(1);
  end;
  sys = x;
end;

% get the number of inputs.
inputLength = length(u);
if inputLength < 2
  error('Source or destination is empty.');
end;
if K == 1;
  bitLength = 3;
  hdlRcdLength = 2 * inputLength - 1;
else
  bitLength = 6;
  hdlRcdLength = 4 * inputLength - 2;
end;

% This part is only for giving user a warning about the size of the window
if x(1) == 0
  if numLine >= 40 | inputLength >= 7
    warnmsg=sprintf('Please resize your Bit Error Meter to get a better looking.');
    warning(warnmsg);
  end;
end;  

if (test2 < .0000001) | (abs(test2 - 1)< .0000001)
  % plot part
  if t < timeDelay
    sys = x;
    return;
  end;

  % initialize graph.
  if x(1) == 0  
    sl_name = gcs;
    block = get_param(sl_name, 'CurrentBlock');
    
    [n_b, m_b] = size(block);
    if n_b < 1
      error('Cannot delete block during simulation.')
    elseif n_b > 1
      error('Something wrong in get_param. You don''t have the current Simulink.')
    end;
    
    % test if figure exists
    allFiguresExist = allchild(0);
    new_figure = 1;
    i = 1;
    while ((new_figure) & (i <= length(allFiguresExist)))
      if strcmp(get(allFiguresExist(i), 'Type'), 'figure')
	if strcmp(get(allFiguresExist(i), 'Name'), sl_name)
	  figureHandle = allFiguresExist(i);
	  handles = get(figureHandle,'UserData');
	  new_figure = 0;
	  % refresh all handles.
	  if (length(handles) == 1+length(u) * (num_lin + 2) - ((K>1) + 1)*2)
	    %use the old one.
	    for ii = 3 : length(handles)
	      set(handles(ii), 'String', ' ');
	    end
	    current_point = 0;
	    if K == 1
	      h_sym_bit = handles(2 : length(u)*2);
	      handleRecord = handles(length(u)*2+1 : length(handleRecord));
	      for i = 1 : 2: length(u) * 2
		set(h_sym_bit(i) , 'UserData', 0);
	      end;
	    else
	      h_sym_bit = handles(2 : length(u)*4-1);
	      handleRecord = handles(length(u)*4 : length(handleRecord));
	      t_tras(1) = get(h_sym_bit, 'UserData') + 1;
	      t_tras(2) = get(h_sym_bit(length(u)*2), 'UserData') + K;
	    end;
	    set(figureHandle, 'UserData', [current_point, h_sym_bit, handleRecord]);
	    set_param(sl_name, 'userdata', figureHandle);
	  else
	    delete(get(figureHandle,'child'));
	    old_figure = 1;
	    new_figure = 1;
	  end;
	end;
      end;
      i = i + 1;
    end;
     
    % Input/Output
    if numLine < 0
      numLine = 0;
    end;
    totalLine = 1 + numLine + bitLength + 1;
    
    set(figureHandle, ...
	'Visible', 'on');    
    handleAxes = axes(...
	'position', [0 0 1 1],...
	'visible',  'off',...
	'Parent',   figureHandle...
	);
  
    tmp_x = [];
    tmp_y = [];
    for ii = 1 : totalLine
      tmp_x = [tmp_x            0             1   NaN];
      tmp_y = [tmp_y  ii/totalLine  ii/totalLine  NaN];
    end;
    
    linePlot = plot(...
	tmp_x, tmp_y, 'k-', ...
	'Parent', handleAxes,...
	'linewidth',1);
    set(handleAxes,...
	'Xtick',    [],...
	'Ytick',    []... 
	);
  
    for i = 1 : inputLength
      % title string
      if i == 1
	titleString = 'Sender';
      else
	% only display 8 digits of the amount of receivers      
	titleString = ['Receiver',num2str(i-1, 8)];
	if inputLength == 2
	  titleString = 'Receiver';
	end
	if numLine > 0
	  set(linePlot, ...
	      'XData', [get(linePlot, 'XData')    ...
		  [1 1]*(i-1)/inputLength           NaN],...
	      'YData', [get(linePlot, 'YData') ...
		  (totalLine-numLine-1)/totalLine 1 NaN]...
	      );
	end;
      end;
      
      % set up the title of both of sender and receivers    
      p_beg1 = (i - 1) / inputLength + .001;
      p_wid = 1 / inputLength - .002;
      uicontrol(...
	  figureHandle, ...
	  'Style',   'text', ...
	  'Horiz',   'center',...
	  'Unit',    'normalized',...
	  'position',[p_beg1, ...
	      (totalLine - 1)/totalLine+.001, p_wid, 1/totalLine-.002], ...
	  'String',  titleString);
      
      %space for list of transferred number.
      p_beg = (2*i - 1) / 2 / inputLength;
      if numLine > 0
	for ii = 1 : numLine
	  index = (ii-1) * inputLength;	
	  handleRecord(index + i) = text(...
	      p_beg, (2*totalLine - 2*ii - 1)/2/totalLine, ' ',...
	      'Parent', handleAxes);
	  set(...
	      handleRecord(index + i), ...
	      'FontSize', 9,...
	      'Color',[0 0 0],...
	      'HorizontalA','Center',...
	      'VerticalA',  'Middle');
	end;
	set(handleRecord(1), 'UserData',1);
      elseif numLine == 0
	handleRecord = [];
      end;
      
      % transfer error rate 
      if K > 1
	len_rate = 2;
      else
	len_rate = 1;
      end;
      kk = 0;
      for ii = 1 : len_rate
	if i == 1
	  if ii == 1
	    titleString = 'Symbol Transferred';
	    trsf = 1;
	    indx = 1;
	  else
	    titleString = 'Bit Transferred';
	    trsf = K;
	    indx = inputLength * 2;
	  end;
	  
	  % Symbol/bit transferred title
	  uicontrol(...
	      figureHandle, ...
	      'Style', 'text', ...
	      'Units', 'normalized',...
	      'Position',[0, ((len_rate - ii) * 3 + 2 + 1)/totalLine+.001,...
		  .499, 1/totalLine-.002],...
	      'String',titleString, ...
	      'BackgroundColor','yellow');
	  set(...
	      linePlot, ...
	      'XData', [get(linePlot, 'XData') .5 .5 NaN],...
	      'YData', [get(linePlot, 'YData'),...
		  ((len_rate - ii)* 3 + 2 + 1)/totalLine,...
		  ((len_rate - ii)* 3 + 3 + 1)/totalLine,...
		  NaN]...
	      );
	  
	  % Symbol/bit transferred data
	  h_sym_bit(indx) = text(...
	      .75, ...
	      ((len_rate-ii)*3*2 + 5 + 2)/2/totalLine,...
	      num2str(trsf, 8),...
	      'Parent', handleAxes);
	  set(h_sym_bit(indx),...
	      'FontSize', 9,...
	      'UserData', 0,...
	      'Color',[0 0 0],...
	      'HorizontalA','Center',...
	      'VerticalA',  'Middle');

	  % title for error number
	  uicontrol(figureHandle, ...
	      'Style', 'text', ...
	      'Units', 'normalized',...
	      'Position', [p_beg1,...
		  ((len_rate - ii) * 3 + 1 + 1)/totalLine+.001, ...
		  p_wid, 1/totalLine-.002],...
	      'String','Error Number'); 

	  % title for error rate
	  uicontrol(figureHandle,...
	      'Style', 'text',...
	      'Units', 'normalized',...
	      'Position', [p_beg1, ...
		  ((len_rate - ii) * 3 + 1)/totalLine+.001,...
		  p_wid, 1/totalLine-.002],...
	      'String','Error Rate'); 
	else
	  %error number
	  kk = (i-1)*2 + (inputLength * 2 - 1)*(ii - 1);
	  set(linePlot, ...
	      'XData', [get(linePlot, 'XData') [p_beg1 p_beg1]-.001 NaN],...
	      'YData', [get(linePlot, 'YData'),...
		  ((len_rate - ii)* 3 + 1)/totalLine,...
		  ((len_rate - ii)* 3 + 2 + 1)/totalLine,...
		  NaN]);
	  
	  h_sym_bit(kk) = text(p_beg, ...
	      ((len_rate-ii)*3*2 + 3 + 2)/2/totalLine,...
	      '0',...
	      'Parent', handleAxes);
	  set(h_sym_bit(kk), ...
	      'UserData', 0,...
	      'FontSize', 9,...
	      'Color',[0 0 0],...
	      'HorizontalA','Center',...
	      'VerticalA',  'Middle');

	  %error rate
	  h_sym_bit(kk+1) = text(p_beg, ...
	      ((len_rate-ii)*3*2 +1 + 2)/2/totalLine, ...
	      '0',...
	      'Parent', handleAxes);
	  set(h_sym_bit(kk+1), ...
	      'UserData', 0,...
	      'FontSize', 9,...
	      'Color',[0 0 0],...
	      'HorizontalA','Center',...
	      'VerticalA',  'Middle');
	end;
      end;
    end;
    set(handleAxes, 'Xlim',[0 1],...
	'Ylim',[0 1])
    current_point = 0;
    set(figureHandle, 'UserData', [current_point, h_sym_bit, handleRecord]);
    
    x(1) = figureHandle;
    tmp1 = uicontrol(...
	figureHandle,...
	'Style', 'pushbutton',...
	'Unit', 'normalized',...
	'Position', [0 0 .5 1/totalLine], ...
	'String', 'Reset error count',...
	'Callback',...
	['sbiterrs(gcbf,',num2str(len_rate),',',num2str(inputLength),')']);
    
    tmp1 = uicontrol(...
	figureHandle,...
	'Style', 'pushbutton',...
	'Unit', 'normalized',...
	'Position', [.5 0 .5 1/totalLine], ...
	'String', 'Close',...
	'Callback','close(gcbf)');
  elseif x(1) < 0
    %  figure has been closed
    return;
  end;
  
  plot_flag_test = allchild(0);
  if isempty(plot_flag_test)
    return;
  elseif isempty(find(plot_flag_test == x(1)))
    x(1) = -1;
    return;
  end;
  
  inputLength = inputLength;
  handles = get(x(1), 'UserData');
  figureHandle =  x(1);
  current_point = handles(1);
  if K == 1
    h_sym_bit = handles(2 : inputLength*2);
    handleRecord = handles(inputLength*2+1 : length(handles));
    t_tras = get(h_sym_bit(1), 'UserData') + 1;
    set(h_sym_bit(1), 'UserData', t_tras,...
	'String', num2str(t_tras, 8));
  else
    h_sym_bit = handles(2 : inputLength*4-1);
    handleRecord = handles(inputLength*4 : length(handles));
    t_tras(1) = get(h_sym_bit(1), 'UserData') + 1;
    t_tras(2) = get(h_sym_bit(inputLength*2), 'UserData') + K;
    set(h_sym_bit(1), 'UserData', t_tras(1), ...
	'String', num2str(t_tras(1),  8));
    set(h_sym_bit(inputLength*2), 'UserData', t_tras(2), ...
	'String', num2str(t_tras(2), 8));
  end;    
  if numLine > 0
    if current_point == 0
      set(handleRecord(1), 'UserData', rem(get(handleRecord(1), 'UserData') + 1, 2));
    end;
    col = colorMap(get(handleRecord(1), 'UserData') + 1, :);
    next_point = rem(current_point + 1, numLine);
    last_point = rem(current_point-1+numLine, numLine);
  else
    next_point = 0;
    last_point = 0;
  end;
  for i = 1 : inputLength
    if i == 1
      if numLine > 0
	set(handleRecord(current_point * inputLength + i), ...
	    'String', num2str(x(3), 8), 'Color',col);
      end;
    else
      if numLine > 0
	if u(i) == x(3)
	  set(handleRecord(current_point * inputLength + i), ...
	      'String', num2str(u(i), 8), 'Color',col);
	else
	  set(handleRecord(current_point * inputLength + i), 'String', ...
	      num2str(u(i), 8), 'Color',colorMap(3,:));
	end
      end;
      if u(i) ~= x(3)
	% in case of error
	% number of errors
	num = get(h_sym_bit((i-1)*2), 'UserData') + 1;
	set(h_sym_bit((i-1)*2), 'UserData', num, 'String', num2str(num, 8));
	% errors rate
	set(h_sym_bit((i-1)*2+1), 'String', num2str(num/t_tras(1), 8));
	if K > 1
	  % number
	  kk = (i-1)*2 + (inputLength * 2 - 1);
	  num = get(h_sym_bit(kk), 'UserData');
	  erb = sum(de2bi(flxor(x(3), u(i))));
	  erb = erb + num;
	  set(h_sym_bit(kk), 'UserData', erb, 'String', num2str(erb, 8));
	  % rate
	  set(h_sym_bit(kk+1), 'String', num2str(erb/t_tras(2),8));
	end;
      else
	tmp = get(h_sym_bit((i-1)*2), 'UserData');
	if tmp 
	  set(h_sym_bit((i-1)*2 + 1), 'String', ...
	      num2str(tmp / t_tras(1), 8));
	end;
	if K > 1
	  kk = (i-1)*2 + (inputLength * 2 - 1);
	  tmp = get(h_sym_bit(kk), 'UserData');
	  if tmp 
	    set(h_sym_bit(kk + 1), 'String', ...
		num2str(tmp / t_tras(2), 8));
	  end
	end;
      end;
    end
  end;
  current_point = next_point;
  sys = [figureHandle; x(2:length(x))];
  % save all the current displaying information in figureHandle  
  set(figureHandle, 'UserData', [current_point, h_sym_bit, handleRecord]);
  %second in User data is the current position for the line of handleRecord.
end;  

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
figureHandle = GetSBiterrFigure(gcbh);
if ~ishandle(figureHandle),
  figureHandle = CreateSBiterrFigure;
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
figureHandle=GetSBiterrFigure(gcbh);
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
% Function that handles name changes on the Bit-Error Meter.
%=============================================================================
%
function LocalBlockNameChangeFcn

%
% the figure handle is stored in the block's UserData
%
figureHandle = GetSBiterrFigure(gcbh);
if ishandle(figureHandle),
  set(figureHandle,'Name',get_param(gcbh,'Name'));
end

% end LocalBlockNameChangeFcn

%
%=============================================================================
% LocalBlockLoadCopyFcn
% Function that initializes the Bit-Error Meter's UserData when it is
% loaded from an mdl file and when it is copied.
%=============================================================================
%
function LocalBlockLoadCopyFcn

SetSBiterrFigure(gcbh,[]);

% end LocalBlockLoadCopyFcn

%
%=============================================================================
% LocalBlockDeleteFcn
% Function that handles the Bit-Error Meter's deletion from a block
% diagram.
%=============================================================================
%
function LocalBlockDeleteFcn

%
% the figure handle is stored in the block's UserData
%
figureHandle = GetSBiterrFigure(gcbh);
if ishandle(figureHandle),
  delete(figureHandle);
  SetSBiterrFigure(gcbh,[]);
end

% end LocalBlockDeleteFcn

%
%=============================================================================
% GetSBiterrFigure
% Retrieves the figure window associated with this S-function Bit-Error Meter
% from the block's parent subsystem's UserData.
%=============================================================================
%
function figureHandle=GetSBiterrFigure(block)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud = get_param(block,'UserData');
if ishandle(ud)
  figureHandle = ud;
else
  if isempty(ud)
    ud.figureHandle = [];
    set_param(block,'Userdata', ud);
  end;  
  figureHandle = ud.figureHandle;
end;

if isempty(figureHandle),
  figureHandle = -1;
end

% end GetSBiterrFigure

%
%=============================================================================
% SetSBiterrFigure
% Stores the figure window associated with this S-function Bit-Error Meter
% in the block's parent subsystem's UserData.
%=============================================================================
%
function SetSBiterrFigure(block,figureHandle)

if strcmp(get_param(block,'BlockType'),'S-Function'),
  block=get_param(block,'Parent');
end

ud = get_param(block,'UserData');
ud.figureHandle = figureHandle;
set_param(block,'UserData',ud);

% end SetSBiterrFigure

%
%=============================================================================
% CreateSBiterrFigure
% Creates the figure window associated with this S-function Bit-Error Meter.
%=============================================================================
%
function figureHandle=CreateSBiterrFigure

%
% create the figure and the axes
%
a = allchild(0);
b = findobj(a, 'Name', get_param(gcbh,'Name'));
if isempty(b)
  figureHandle = figure(...
      'Units',        'points',...
      'Position',     [10 20 350 400],...
      'NumberTitle',  'off',...
      'Visible', 'off', ...      
      'Name',         get_param(gcbh,'Name'),...
      'Color',	   [1 1 1],...		   
      'IntegerHandle','off',...
      'DeleteFcn',    'sbiterr([],[],[],''DeleteFigure'')'...
      );
else
  figureHandle = b;
end;
set(0, 'CurrentFigure', figureHandle);

%
% store the block's handle in the figure's UserData
%
ud.Block = gcbh;

%
% squirrel the figure handle away in the current block, and put the
% various handles into the figure's UserData
%
SetSBiterrFigure(gcbh,figureHandle);
set(figureHandle,'HandleVisibility','callback','UserData',ud);

% end CreateSBiterrFigure

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
%  warnmsg=sprintf(['The Bit-Error Meter block ''%s'' should be replaced with a ' ...
%                   'new version from the com_sour block library'],...
%                   block);
%  warning(warnmsg);

  callbacks={
    'CopyFcn',       'sbiterr([],[],[],''CopyBlock'')' ;
    'DeleteFcn',     'sbiterr([],[],[],''DeleteBlock'')' ;
    'LoadFcn',       'sbiterr([],[],[],''LoadBlock'')' ;
    'StartFcn',      'sbiterr([],[],[],''Start'')' ;
    'StopFcn'        'sbiterr([],[],[],''Stop'')' ;
    'NameChangeFcn', 'sbiterr([],[],[],''NameChange'')' ;
  };

  for i=1:length(callbacks)
    if ~strcmp(get_param(block,callbacks{i,1}),callbacks{i,2})
      set_param(block,callbacks{i,1},callbacks{i,2});
    end
  end
end

% end SetBlockCallbacks

%%%%%%%%%%%%%%%%%%%%%%%%
%   End of SBITERR.M   %
%%%%%%%%%%%%%%%%%%%%%%%%


