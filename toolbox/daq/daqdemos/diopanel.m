function diopanel(varargin)
%DIOPANEL Display digital I/O panel.
%
%    DIOPANEL displays a panel for writing values to and reading values
%    from a digital I/O object.  
%
%    The panel is divided into four sections.  The top section contains
%    two popup menus for selecting the hardware to be used and the port 
%    to write/read.  All lines from the selected port will be added to
%    the digital I/O object.  Only those lines that are writable will 
%    be written to.
%
%    The second section from the top contains controls for specifying
%    the range of data that is to be written to the lines.  Data can be
%    specified as either decimal values or as binvec values.  The digital 
%    I/O object will contain at most eight lines.  Therefore, the maximum
%    value that can be written is 255.  The second section also contains
%    a Start pushbutton which starts writing the data to the digital I/O
%    lines and a reset button which resets the panel to its default
%    state.
%
%    The third section from the top contains controls for each line which
%    indicates whether a line is just readable (Input) or can be written
%    and read from (Output).  If the selected port contains unidirectional
%    lines, the Input or Output controls cannot be modified.
%
%    The bottom section contains controls for each line indicating the
%    current value of that line.  A selected control indicates a value
%    of 1 while a non-selected control indicates a value of 0.
%
%    This demo requires hardware which supports digital I/O.
%
%    See also DIGITALIO, ADDLINE, DAQSCHOOL, DAQHELP.
% 

%    MP 3-30-99
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.8.2.7 $  $Date: 2004/03/30 13:03:57 $

% Error if an output argument is supplied.
if nargout > 0
   error('Too many output arguments.');
end

% Based on the number of input arguments call the appropriate 
% local function.
switch nargin
case 0
   % Create figure.
   data = localInitFig;
   hFig = data.handle.figure;
case 1
   error('No inputs required to run DIOPANEL.');
case 2
   % Initialize variables.
   action=varargin{1};
   hFig=varargin{2};
   data=get(hFig,'UserData');
   
   % Call the appropriate function based on the action.
   switch action
   case 'adaptor'
      data = localAdaptor(data);
   case 'port'
      data = localPort(data);
   case {'decimal', 'binvec'}
      data = localDecBinVec(data, action);
   case 'min'
      data = localMin(data, action);
   case 'max'
      data = localMax(data,action);
   case 'reset'
      data = localReset(data);
   case 'start'
      data = localStart(data);
   case 'stop'
      data = localStop(data);
   case 'close'
      localClose(data);
   case 'helpDioPanel'
      localHelpDioPanel;
   case 'helpdaq'
      localHelpDaq;
   end
case 3
   % Initialize variables.
   [action, hFig, selected] = deal(varargin{:});
   data = get(hFig, 'UserData');
   switch action
   case 'Input'
      data = localInput(data, selected);
   case 'Output'
      data = localOutput(data, selected);
   end    
case 4
   [obj, action, hFig] = deal(varargin{:});
   data = get(hFig, 'UserData');
   switch action
   case 'timer'
      data = localTimer(obj,data);
   end
otherwise
   error('Wrong number of input arguments for DIOPANEL.');
end

% Update the figure's UserData.
if ~isempty(hFig) && ishandle(hFig),
   set(hFig,'UserData',data);
end

% *******************************************************************  
% Change the Ports listed based on the item selected in the adaptor
% popup menu.
function data = localAdaptor(data)

if ~isempty(data.dio)
   % Determine which adaptor was selected.
   val = get(data.handle.popup(1), 'Value');
   str = get(data.handle.popup(1), 'String');
   
   % str will be empty if no adaptors are registered.
   if ~isempty(str)
      adaptorStr = str{val};
      
      % Split the adaptor string into adaptor and id.
      index = find(adaptorStr == ' ');
      adaptor = adaptorStr(1:index-1);
      id = adaptorStr(index+1:end);
      
      % Delete the current digital I/O object and create the new 
      % digital I/O object with the above adaptor and id.
      delete(data.dio);
      
      %create a digital I/O object
      dio = digitalio(adaptor, id);
      
      % Get the port information for the supported adaptor.
      dioInfo = daqhwinfo(dio);
      
      % Determine the ports for the new adaptor.
      portIDs = [dioInfo.Port.ID];
      
      % Update the Port popup menu.
      set(data.handle.popup(2), 'String', num2cell(portIDs));
      set(data.handle.popup(2), 'Value', 1);
      
      % Update the data structure.
      data.dio = dio;
      data.portinfo = dioInfo.Port;
      data.port = portIDs(1);   % port selected.
      data.linesadded = 0;
      data.numlines = 0;
      data.output = [];
      delete(data.dio.Line);
      data.lines = [];
      
      % Update the radiobuttons.
      data = localReset(data);
      data = localUpdateButtons(data);
   end
end

% ***********************************************************************  
% Update the lines based on the port chosen.
function data = localPort(data)

if ~isempty(data.dio)
   % Delete the lines.
   delete(get(data.dio, 'Line'));
   
   % Determine which port was selected.
   val = get(data.handle.popup(2), 'Value');
   str = get(data.handle.popup(2), 'String');
   
   if ~isempty(str)
      data.port = str2num(str{val});
      
      % Update the data structure.
      data.linesadded = 0;
      data.numlines = 0;
      data.output = [];
      delete(data.dio.Line);
      data.lines = [];
      
      % Update the radio buttons.
      data = localUpdateButtons(data);
      data = localReset(data);
   end
end

% ***********************************************************************  
% Update the radiobuttons based on the port selected.  
function data = localUpdateButtons(data)

% Get the port structure for the port selected.
index = find(data.port == [data.portinfo.ID]);
portStruct = data.portinfo(index);
data.numlines = length(portStruct.LineIDs);

% Determine which lines are supported and configure the radio
% buttons.
totalLines = 1:8;
supported = portStruct.LineIDs+1;
unsupported = setdiff(totalLines, supported);

set(data.handle.state(supported), 'Enable', 'on');
set(data.handle.input(supported), 'Enable', 'on');
set(data.handle.output(supported), 'Enable', 'on');

set(data.handle.state(unsupported), 'Enable', 'off');
set(data.handle.input(unsupported), 'Enable', 'off');
set(data.handle.output(unsupported), 'Enable', 'off');

% Determine the direction of the lines and configure the input
% and output radio buttons.
switch portStruct.Direction
case 'in/out'
   set(data.handle.output, 'Value', 1);
   set(data.handle.input, 'Value', 0);
case 'out'
   set(data.handle.output, 'Value', 1, 'Enable', 'off');
   set(data.handle.input, 'Value', 0, 'Enable', 'off');
case 'in'
   set(data.handle.input, 'Value', 1, 'Enable', 'off');
   set(data.handle.output, 'Value', 0, 'Enable', 'off');
end

% If the lines are port configurable, store the information.
switch portStruct.Config
case 'line'
   data.portconfig = 0;
case 'port'
   data.portconfig = 1;
end

% Update the maximum value allowed.
data.absmax = 2^(max(supported))-1;

% Update the max and current text boxes.
if data.max > data.absmax
   data.max = data.absmax;
   if data.isbinvec
      set(data.handle.minmax(2),'String',num2str(dec2binvec(data.max,data.numlines)));
      set(data.handle.current,'String',num2str(dec2binvec(data.min,data.numlines)));
   else
      set(data.handle.minmax(2), 'String', num2str(data.max));
      set(data.handle.current, 'String', num2str(data.min));
   end
end


% ***********************************************************************  
% Toggle between decimal and binvec values.
function data = localDecBinVec(data, action)

switch action
case 'decimal'
   data.isbinvec = 0;
   val = get(data.handle.decbinvec(1), 'Value');
   switch val
   case 0
      set(data.handle.decbinvec(1), 'Value', 1);
   case 1
      set(data.handle.decbinvec(2), 'Value', 0);
      
      % Convert the binvecs to decimals.
      val1 = binvec2dec(str2num(get(data.handle.minmax(1), 'String')));
      val2 = binvec2dec(str2num(get(data.handle.minmax(2), 'String')));
      set(data.handle.minmax(1), 'String', num2str(val1));
      set(data.handle.minmax(2), 'String', num2str(val2));
      
      % Convert the current value to a decimal.
      val = binvec2dec(str2num(get(data.handle.current, 'String')));
      set(data.handle.current, 'String', num2str(val));      
   end
case 'binvec'
   data.isbinvec = 1;
   val = get(data.handle.decbinvec(2), 'Value');
   switch val
   case 0
      set(data.handle.decbinvec(2), 'Value', 1);
   case 1
      set(data.handle.decbinvec(1), 'Value', 0);
      
      % Convert the binvecs to decimals.
      val1 = dec2binvec(str2num(get(data.handle.minmax(1), 'String')),data.numlines);
      set(data.handle.minmax(1), 'String', num2str(val1));
      val2 = dec2binvec(str2num(get(data.handle.minmax(2), 'String')),data.numlines);
      set(data.handle.minmax(2), 'String', num2str(val2));
      
      % Convert the current value to a binvec value.
      val = dec2binvec(str2num(get(data.handle.current, 'String')),data.numlines);
      set(data.handle.current, 'String', num2str(val));
   end
end

% ***********************************************************************  
% Min range edit text box callback.
function data = localMin(data, action)

% Get the value entered as the minimum value.
minval = str2num(get(data.handle.minmax(1), 'String'));

if isempty(minval)
    errordlg('Field cannot be empty. Please enter a valid number', 'Empty Range Error', 'modal');
    if (data.isbinvec)
        set(data.handle.minmax(1), 'String', num2str(dec2binvec(0,data.numlines)));
        minval = dec2binvec(0,data.numlines);
    else
        set(data.handle.minmax(1), 'String', num2str(0));
        minval = 0;
    end
end

% If it is a binvec convert to a decimal and compare.
if data.isbinvec
   isbinvec = 1;
   minval = binvec2dec(minval);
end

% Negative values are not allowed.
if minval < 0
   minval = 0;
   if data.isbinvec
      set(data.handle.minmax(1), 'String', num2str(dec2binvec(minval,data.numlines)));
   else
      set(data.handle.minmax(1), 'String', num2str(minval));
   end
end

% Non-integer values are not allowed.
if fix(minval) ~= minval
   minval = fix(minval);
   if data.isbinvec
      set(data.handle.minmax(1), 'String', num2str(dec2binvec(minval,data.numlines)));
   else
      set(data.handle.minmax(1), 'String', num2str(minval));
   end
end

% If minimum value is greater than max value, set minimum
% value to one less than max.
if minval >= data.max
   minval = data.max - 1;
   if data.isbinvec
      set(data.handle.minmax(1), 'String', num2str(dec2binvec(minval,data.numlines)));
   else
      set(data.handle.minmax(1), 'String', num2str(minval));
   end
end

% Update the data structure.
data.min = minval;

% Update the current value if is not between the new range and 
% clear out the line state radio buttons.
if data.nextvalue < minval
   data.nextvalue = minval;
   if data.isbinvec
      set(data.handle.current, 'String', num2str(dec2binvec(minval,data.numlines)));
   else
      set(data.handle.current, 'String', num2str(minval));
   end
   set(data.handle.state, {'Value'}, {0;0;0;0;0;0;0;0});
   set(data.handle.button(1), 'String', 'Start');
end

% ***********************************************************************  
% Max range edit text box callback.
function data = localMax(data, action)

% Get the value entered as the maximum value.
maxval = str2num(get(data.handle.minmax(2), 'String'));

if isempty(maxval)
    errordlg('Field cannot be empty. Please enter a valid number', 'Empty Range Error', 'modal');
    if (data.isbinvec)
        set(data.handle.minmax(2), 'String', num2str(dec2binvec(data.absmax,data.numlines)));
        maxval = dec2binvec(data.absmax,data.numlines);
    else
        set(data.handle.minmax(2), 'String', num2str(data.absmax));
        maxval = data.absmax;
    end
end

% If it is a binvec convert to a decimal and compare.
if get(data.handle.decbinvec(2), 'Value') == 1
   maxval = binvec2dec(maxval);
end

% Values greater than absmax are not allowed.
if maxval > data.absmax
   maxval = data.absmax;
   if data.isbinvec
      set(data.handle.minmax(2), 'String', num2str(dec2binvec(maxval,data.numlines)));
   else
      set(data.handle.minmax(2), 'String', num2str(maxval));
   end
end

% Non-integer values are not allowed.
if fix(maxval) ~= maxval
   maxval = fix(maxval);
   if data.isbinvec
      set(data.handle.minmax(2), 'String', num2str(dec2binvec(maxval,data.numlines)));
   else
      set(data.handle.minmax(2), 'String', num2str(maxval));
   end
end

% If max is less than min make it one more than min.
if maxval <= data.min
   maxval = data.min+1;
   if data.isbinvec
      set(data.handle.minmax(2), 'String', num2str(dec2binvec(maxval,data.numlines)));
   else
      set(data.handle.minmax(2), 'String', num2str(maxval));
   end
end

% Update the data structure.
data.max = maxval;

% Update the current value if is not between the new range and 
% clear out the line state radio buttons.
if data.nextvalue > maxval
   data.nextvalue = data.min;
   if data.isbinvec
      set(data.handle.current,'String',num2str(dec2binvec(data.min,data.numlines)));
   else
      set(data.handle.current, 'String', num2str(data.min));
   end
   set(data.handle.state, {'Value'}, {0;0;0;0;0;0;0;0});
   set(data.handle.button(1), 'String', 'Start');
end

% ***********************************************************************  
% Input radiobuttons callback.
function data = localInput(data, selected)

% Set the corresponding Output radiobutton.
val = get(data.handle.input(selected), 'Value');

% Get the lines.
daqline = get(data.dio, 'Line');

% If the port is line configurable, just set the selected line.
% If the port is port configurable, need to set all the lines to
% the same value.
switch data.portconfig
case 0
   % Line configurable.
   switch val
   case 0
      set(data.handle.input(selected), 'Value', 1);
   case 1
      set(data.handle.output(selected), 'Value', 0);
   end   
   if ~isempty(daqline)
      set(daqline(selected), 'Direction', 'In');
   end
case 1
   % Port configurable.
   set(data.handle.output(:), 'Value', 0);
   set(data.handle.input(:), 'Value', 1);
   if ~isempty(daqline)
      set(daqline, 'Direction', 'In');
   end
end

% ***********************************************************************  
% Output radiobuttons callback.
function data = localOutput(data, selected)

% Set the corresponding Input radiobutton.
val = get(data.handle.output(selected), 'Value');

% Get the lines.
daqline = get(data.dio, 'Line');

% If the port is line configurable, just set the selected line.
% If the port is port configurable, need to set all the lines to
% the same value.

switch data.portconfig
case 0
   % Line configurable.
   switch val
   case 0
      set(data.handle.output(selected), 'Value', 1);
   case 1
      set(data.handle.input(selected), 'Value', 0);
   end 
   if ~isempty(daqline)
      set(daqline(selected), 'Direction', 'Out');
   end
case 1
   % Port configurable.
   set(data.handle.output(:), 'Value', 1);
   set(data.handle.input(:), 'Value', 0);
   if ~isempty(daqline)
      set(daqline, 'Direction', 'Out');
   end
end

% ***********************************************************************  
% Start the object.
function data = localStart(data)

if isempty(data.dio)
   % Occurs if no adaptors are registered.
   hWarn = findobj(findall(0), 'Tag', 'noAdaptorsRegisterDIO');
   if isempty(hWarn)
      hWarn = warndlg(['No adaptors which support digital I/O are registered.  Type ''daqhelp daqregister'' for more ',...
            'information on registering adaptors.'],'Data Acquisition Warning');
      set(hWarn, 'Tag', 'noAdaptorsRegisterDIO');
   else
      figure(hWarn(1));
   end
   return
elseif ~isvalid(data.dio)
   % daqreset may have been called.  Try to create object.
   data = localAdaptor(data);
   data.linesadded = 0;
   data.isrunning = 0;
end

% Determine which lines can be written to.
data.output = findobj(data.handle.output, 'Enable', 'On', 'Value', 1);
data.output = get(data.output, {'UserData'});
data.output = [data.output{:}];

% If the max value has been reached, restart at the min value.
if (data.nextvalue == data.max+1)
   data.nextvalue = data.min;
   if data.isbinvec
      % Binvec value.
      tempVal = dec2binvec(data.min,data.numlines);
      set(data.handle.current, 'String', num2str(tempVal));
   else
      set(data.handle.current, 'String', num2str(data.min));
   end
end

if ~data.isrunning
   % The object needs to be started.
   % Disable the Decimal/Binvec radiobuttons, the min and 
   % max range values and the popups.
   set(data.handle.decbinvec, 'Enable', 'off');
   set(data.handle.minmax, 'Enable', 'off');
   set(data.handle.popup, 'Enable', 'off');
   set(data.handle.input, 'Enable', 'off');
   set(data.handle.output, 'Enable', 'off');
   
   % Add the lines if they have not already been added.
   if ~data.linesadded
      % Create a matrix of 'Out'.
      linedir = repmat('Out', 8,1);
      
      % Determine the direction of the lines.
      direction = get(data.handle.input, 'Value');
      inputIndex = find([direction{:}]);
      
      % Replace the original Out direction the location of the In 
      % direction.
      linedir(inputIndex,:)= repmat('In ',length(inputIndex),1);
      linedir = cellstr(linedir)';
      
      addline(data.dio, 0:7, data.port, linedir);
      if ~isempty(inputIndex)
         set(data.dio.Line(inputIndex), 'Direction', 'In');
      end
     % addline(data.dio, 0:7, 0, linedir);
      data.linesadded = 1;
   end
   
   % Set up the line variable.
   data.line = get(data.dio, 'Line');
   
   % Put the first value and display if output lines are available
   if ~isempty(data.output)
	   val = dec2binvec(data.nextvalue, data.numlines);
	   putvalue(data.line(data.output), val(data.output));
	   
	   % Update the current value.
	   % If it is a binvec convert to a decimal, add one, and convert back
	   % to a binvec. 
	   if data.isbinvec
		   % Binvec value.
		   tempVal = dec2binvec(data.nextvalue,data.numlines);
		   data.nextvalue = binvec2dec(data.nextvalue)+1;
	   else
		   tempVal = data.nextvalue;
		   data.nextvalue = tempVal+1;
	   end
   	   
	   % Display value in Current box.
	   set(data.handle.current, 'String', num2str(tempVal));
   end
   
   % get the current value on the lines.
   actualVal = getvalue(data.dio);

   % Update the line state display.
   set(data.handle.state, {'Value'}, num2cell(actualVal'));

   % Initialize the TimerFcn.
   set(data.dio, 'TimerFcn', {@diopanel,'timer',data.handle.figure});
   set(data.dio, 'TimerPeriod', 0.5);
   
   % Set the button's string to stop.
   set(data.handle.button(1), 'String', 'Stop');
   
   % Update the data structure.
   data.isrunning = 1;
   
   % Start the object.
   start(data.dio)
else
   % Stop the object.
   data = localStop(data);
end

% ***********************************************************************  
% TimerFcn function.
function data = localTimer(obj,data)

% Get the current value.
if data.nextvalue <= data.max
   
   val = dec2binvec(data.nextvalue, data.numlines);
   putvalue(data.line(data.output), val(data.output));
   actualVal = getvalue(data.dio);

   % Update the current value.
   % If it is a binvec convert to a decimal, add one, and convert back
   % to a binvec. 
   if data.isbinvec
      % Binvec value.
      tempVal = dec2binvec(data.nextvalue,data.numlines);
   else
      tempVal = data.nextvalue;
   end

   set(data.handle.current, 'String', num2str(tempVal));

   % Update the line state display.
   set(data.handle.state, {'Value'}, num2cell(actualVal'));
   data.nextvalue = data.nextvalue+1;
else
   % Othersize max value has been reached and should stop.
   data = localStop(data);
end

% ***********************************************************************  
% Reset the digital I/O panel.
function data = localReset(data)

% Stop the object and reenable the controls.
if ~isempty(data.dio)
   data = localStop(data);
end

% Reset the controls to their default values.
set(data.handle.decbinvec, {'Value'}, {1;0});
set(data.handle.minmax, {'String'}, {'0'; num2str(data.absmax)});
set(data.handle.current, 'String', '0');
set(data.handle.button(1), 'String', 'Start');
set(data.handle.input, {'Value'}, {0;0;0;0;0;0;0;0});
set(data.handle.output, {'Value'}, {1;1;1;1;1;1;1;1});
set(data.handle.state, {'Value'}, {0;0;0;0;0;0;0;0});

% Update the data structure.
data.nextvalue = 0;
data.max = data.absmax;
data.min = 0;
data.isbinvec = 0;
data.isrunning = 0;
data.linesadded = 0;
data.numlines = 0;
data.output = [];
data.lines = [];
if ~isempty(data.dio)
    delete(data.dio.Line);
    data = localUpdateButtons(data);
end

% ***********************************************************************  
% Stop the object.
function data = localStop(data)

% Stop the object.
stop(data.dio);

% Enable the Decimal/Binvec radiobuttons, the min and max range
% values and the popups.
set(data.handle.decbinvec, 'Enable', 'on');
set(data.handle.minmax, 'Enable', 'on');
set(data.handle.popup, 'Enable', 'on');
set(data.handle.input, 'Enable', 'on');
set(data.handle.output, 'Enable', 'on');

% Set the pushbutton's string to Start.
if data.nextvalue < data.max
   set(data.handle.button(1), 'String', 'Continue');
else
   set(data.handle.button(1), 'String', 'Start');
end

% Update the data structure.
data.isrunning = 0;

% ***********************************************************************  
% Close the figure window.
function localClose(data)

% The object will not exist if no adpators are registered.
if ~isempty(data.dio)
   if isvalid(data.dio) && strcmp(get(data.dio, 'Running'), 'On')
      % Stop the device and delete it.
      stop(data.dio);
   end

   % Delete the object.
   delete(data.dio);
end

% Close the figure window.
delete(data.handle.figure);

% ***********************************************************************   
% Pull up the helpwindow for the Data Acquisition Toolbox.
function data = localHelpDaq(data)

helpwin('daq');

% ***********************************************************************  
% Pull up the helpwindow for fcngen.m
function data = localHelpDioPanel(data)

helpwin('diopanel');

% ***********************************************************************   
% Create the figure window.
function data = localInitFig

% Initialize variables.
btnColor=get(0,'DefaultUIControlBackgroundColor');

% Information for all handle graphics objects.
genInfo.HandleVisibility='off';
genInfo.Interruptible='off';
genInfo.BusyAction='queue';

% Position the GUI in the middle of the screen
screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=560;
figHeight=404;
figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
         figWidth                    figHeight];
   
% Create the figure window.
hFig=figure(genInfo,...                    
   'Color'             ,btnColor                        ,...
   'IntegerHandle'     ,'off'                           ,...
   'DeleteFcn'         ,'diopanel(''close'',gcbf)'      ,...
   'MenuBar'           ,'none'                          ,...
   'Name'              ,'Digital I/O Panel'             ,...
   'Tag'               ,'Digital I/O Panel'             ,...
   'NumberTitle'       ,'off'                           ,...
   'Units'             ,'pixels'                        ,...
   'Position'          ,figPos                          ,...
   'Resize'            ,'off'                           ,...
   'UserData'          ,[]                              ,...
   'Colormap'          ,[]                              ,...
   'Pointer'           ,'arrow'                         ,...
   'Visible'           ,'off'                            ...
   );

genInfo.Parent = hFig;

% Information for all uicontrols.
uiInfo=genInfo;
uiInfo.BackGroundColor=btnColor;
uiInfo.ForeGroundColor=[0 0 0];

% Create the frames.
uicontrol(uiInfo,...
   'Style', 'frame',...
   'Units', 'pixels',...
   'Position', [10 15 545 374]);

framePosY = [30 130 230 330];
framePosH = [85 85 85 45];
for i = 1:4
   uicontrol(uiInfo,...
      'Style', 'frame',...
      'Units', 'pixels',...
      'Position', [20 framePosY(i) 525 framePosH(i)]);
end

% Create the text labels - 'Device Name' and 'Port'.
textPosX = [25 258];
textLabels = {'Device Name:', 'Port:'};
for i = 1:2
   uicontrol(uiInfo,...
      'Style', 'text',...
      'HorizontalAlignment', 'Right',...
      'Units', 'pixels',...
      'Position', [textPosX(i) 340 77 20],...
      'String', textLabels{i});
end

% Get adaptor information:
% adaptorStr = list of adaptors for the popup = {'winsound0' 'nidaq1'}.
% dio = analoginput object constructed from adaptorStr{1}.
[adaptorStr, dio] = daqgate('privateGetAdaptor', 'digitalio');
if ~isempty(dio)
   portStruct = daqhwinfo(dio, 'Port');
   portIDs = [portStruct.ID];
else
   portStruct = [];
   portIDs = ' ';
end

% Create the popups (device and then port).
popPosX = [109 380];
popLabels = {adaptorStr, num2cell(portIDs)};
popCall = {'adaptor', 'port'};
for i = 1:2
   callbackStr = ['diopanel(''' popCall{i} ''',gcbf);'];
   hpop(i) = uicontrol(uiInfo,...
      'Style', 'popup',...
      'Units', 'pixels',...
      'Position', [popPosX(i) 335 147 30],...
      'String', popLabels{i},...
      'BackGroundColor', [1 1 1],...
      'Callback', callbackStr);
end

% Create the text labels - 'Specify values as:', 'Specify range from:'
% and 'Current value:'.
textPosX = [32 180 280];
alignX = {'Left', 'Left', 'Right'};
textLabels = {'Specify values as:', 'Specify range from:',...
      'Current value:'};
for i = 1:3
   uicontrol(uiInfo,...
      'Style', 'text',...
      'HorizontalAlignment', alignX{i},...
      'Units', 'pixels',...
      'Position', [textPosX(i) 290 100 20],...
      'String', textLabels{i});
end

% Create the decimal/binvec radionbutton selection.
radioPosY = [270 250];
radioLabels = {'Decimal', 'Binvec'};
radioValue = [1 0];
for i = 1:2
   callbackStr = ['diopanel(''' lower(radioLabels{i}) ''',gcbf);'];
   hradio(i) = uicontrol(uiInfo,...
      'Style', 'radiobutton',...
      'HorizontalAlignment', 'Left',...
      'Units', 'pixels',...
      'Position', [34 radioPosY(i) 100 20],...
      'Value', radioValue(i),...
      'String', radioLabels{i},...
      'Callback', callbackStr);
end

% Create the edit text boxes (min and then max).
editPosY = [274 236];
editLabels = {'0', '255'};
editCall = {'min', 'max'};
for i = 1:2
   callbackStr = ['diopanel(''' lower(editCall{i}) ''',gcbf);'];
   hedit(i) = uicontrol(uiInfo,...
      'Style', 'edit',...
      'HorizontalAlignment', 'Left',...
      'Units', 'pixels',...
      'Position', [170 editPosY(i) 120 20],...
      'String', editLabels{i},...
      'BackGroundColor', [1 1 1],...
      'Callback', callbackStr);
end

% Create the 'to' text string.
uicontrol(uiInfo,...
   'Style', 'text',...
   'HorizontalAlignment', 'Right',...
   'Units', 'pixels',...
   'Position', [225 258 12 15],...
   'String', 'to:');

% Create the current value text box.
hcurrent = uicontrol(uiInfo,...
   'Style', 'edit',...
   'HorizontalAlignment', 'Center',...
   'Units', 'pixels',...
   'Position', [315 274 120 20],...
   'String', '0',...
   'Enable', 'inactive');

% Create a frame around the Start and Stop pushbuttons.
uicontrol(uiInfo,...
   'Style', 'frame',...
   'Units', 'Pixels',...
   'Position', [450 238 85 70]);

% Create the Start and Stop pushbuttons.
pushPosY = [278 248];
pushLabels = {'Start', 'Reset'};
for i = 1:2
   callbackStr = ['diopanel(''' lower(pushLabels{i}) ''',gcbf);'];
   hpush(i) = uicontrol(uiInfo,...
      'Style', 'pushbutton',...
      'Units', 'pixels',...
      'Position', [462 pushPosY(i) 60 20],...
      'Callback', callbackStr,...
      'String', pushLabels{i});
end

% Create the text labels: 'Input:' and 'Output:'.
textPosY = [180 150];
textLabels = {'Input:', 'Output:'};
for i = 1:2
   uicontrol(uiInfo,...
      'Style', 'text',...
      'HorizontalAlignment', 'Right',...
      'Units', 'pixels',...
      'Position', [32 textPosY(i) 52 20],...
      'String', textLabels{i});
end

% Create the Input radiobuttons.
radioPosX = [102 157 211 266 321 375 430 485];
for i = 1:8
   callbackStr = ['diopanel(''Input'',gcbf,' num2str(i) ');'];
   input(i) = uicontrol(uiInfo,...
      'Style', 'radiobutton',...
      'Units', 'pixels',...
      'Position', [radioPosX(i) 182 30 20],...
      'UserData', i,...
      'Callback', callbackStr);
end

% Create the Output radiobuttons.
radioPosX = [102 157 211 266 321 375 430 485];
for i = 1:8
   callbackStr = ['diopanel(''Output'',gcbf,' num2str(i) ');'];
   output(i) = uicontrol(uiInfo,...
      'Style', 'radiobutton',...
      'Units', 'pixels',...
      'Position', [radioPosX(i) 150 30 20],...
      'Callback', callbackStr,...
      'UserData', i,...
      'Value', 1); 
end

% Create the text label: 'Line State:'.
uicontrol(uiInfo,...
   'Style', 'text',...
   'HorizontalAlignment', 'Right',...
   'Units', 'pixels',...
   'Position', [22 60 65 20],...
   'String', 'Line State:');

% Create the line state radiobuttons.
radioPosX = [102 157 211 266 321 375 430 485];
for i = 1:8
   state(i) = uicontrol(uiInfo,...
      'Style', 'radiobutton',...
      'Units', 'pixels',...
      'Position', [radioPosX(i) 62 30 20]);
end

% Create the text label: 'Line Number:'
uicontrol(uiInfo,...
   'Style', 'text',...
   'HorizontalAlignment', 'Right',...
   'Units', 'pixels',...
   'Position', [22 35 65 20],...
   'String', 'Line Number:');

% Create the line number text objects.
textPosX = [107 162 216 271 326 381 435 490];
for i = 1:8
   uicontrol(uiInfo,...
      'Style', 'text',...
      'Units', 'pixels',...
      'Position', [textPosX(i) 35 30 20],...
      'HorizontalAlignment', 'left',...
      'String', num2str(i));
end

% Create the menubar.
h1 = uimenu(genInfo,'Label', 'File');
h2 = uimenu(genInfo,'Label', 'Help');
h1(2) = uimenu(h1(1),...
   'Label'     ,'Close Digital I/O Panel'  ,...
   'Callback'  ,'diopanel(''close'', gcbf);');
h2(2) = uimenu(h2(1),...
   'Label'     ,'Digital I/O Panel'  ,...
   'Callback'  ,'diopanel(''helpDioPanel'', gcbf);');
h2(3) = uimenu(h2(1),...
   'Label'     ,'Data Acquisition'  ,...
   'Callback'  ,'diopanel(''helpdaq'',gcbf);');

% Create the data structure.
data.dio = dio;
data.lines = [];
data.portinfo = portStruct;
if isempty(portStruct),
    data.port = [];
else
    data.port = portStruct(1).ID;
end
data.portconfig = 0;
data.linesadded = 0;
data.numlines = 8;
data.nextvalue = 0;
data.max = 255;
data.min = 0;
data.absmax = 255;
data.isbinvec = 0;
data.isrunning = 0;
data.output = 0:7;
data.handle.figure = hFig;
data.handle.decbinvec = hradio;
data.handle.minmax = hedit;
data.handle.current = hcurrent;
data.handle.input = input;
data.handle.output = output;
data.handle.button = hpush;
data.handle.popup = hpop;
data.handle.state = state;

% Update the diopanel radiobuttons.
if ~isempty(data.dio)
   data = localReset(data);
   data = localUpdateButtons(data);
end

% Store the data matrix and display figure.
set(hFig,'Visible','on','UserData',data);
