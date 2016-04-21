function daqscope(varargin)
%% DAQSCOPE Example oscilloscope for the Data Acquisition Toolbox.
%
%    DAQSCOPE creates an oscilloscope window for displaying the incoming 
%    signals which can be used with the Data Acquisition Toolbox's analog
%    input objects.
%
%    DAQSCOPE can run any registered adaptor that has an analog input 
%    subsystem.  The name of these adaptors and the adaptors' device 
%    identification number are displayed in the popup menu.  This allows, 
%    for example, multiple nidaq cards to be distinguished from each other
%    by their device identification number.  The listbox beneath the popup
%    menu contains a list of the channels that can be added to the selected
%    adaptor.  If all the channels were added to the analog input object, 
%    Channel1 would correspond to the first hardware channel that could be 
%    specified, Channel2 would correspond to the second hardware channel
%    that could be specified and so on.  A maximum of sixteen channels can
%    be selected and displayed.  If more than sixteen channels are selected,
%    a warning will occur and no channels will be displayed.
%
%    An analog input object is created from the selected adaptor, adaptor 
%    device identification number and the selected channels.  When the button 
%    with the triangle image is selected, the created analog input object is 
%    started with the start command and the selected channels' signal will 
%    be displayed in the daqscope axes.  While the analog input object is 
%    running, it is not possible to change the selected adaptor or the 
%    selected channels.  However, by selecting the pause button (the same 
%    button as the start button - toggled), the channels and adaptor 
%    selected can be modified. 
%
%    The time range or x-axis range can be modified while the object is 
%    running by moving the X-Axis range slider.  The volts per division (or 
%    the y-axis range) can be modified while the object is running by 
%    entering a value in the Volts Per Division edit text box.  The volts
%    per division can be calculated internally by selecting the Autoset
%    radiobutton to produce a usable display of the incoming signal.
%
%    A legend can be added to the axes window to distinguish between the 
%    channel signals plotted by selecting the View menu and then selecting 
%    the Legend menu.
%
%    Information on DAQSCOPE and the Data Acquisition Toolbox are available
%    through the Help menu.
%
%    The daqscope window can be closed either by selecting the File menu 
%    and then selecting the Close Oscilloscope menu or by selecting the 
%    "x" close button.  When the daqscope window is closed, the analog 
%    input object will be stopped, if it is running, and deleted.
%
%    See also DAQFCNGEN.
%

%    MP 11-05-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.6 $  $Date: 2004/03/30 13:03:53 $

%%
% Error if an output argument is supplied.
if nargout > 0
   error('Too many output arguments.');
end

%%
% Based on the number of input arguments call the appropriate 
% local function.
switch nargin
case 0
   % Create the figure and initialize variables.
   data = localInitFig;
   hFig = data.handle.figure;
case 1
   error('No inputs required to run DAQSCOPE.');
case 2
   % Initialize variables.
   action = varargin{1};
   hFig = varargin{2};
   data = get(hFig, 'UserData');
   
   % Call the appropriate local function based on the action.
   switch action
   case 'adaptor'
      data = localAdaptor(data);
   case 'axisrange'
      data = localAxisRange(data);
   case 'autoset'
      data = localAutoset(data);
   case 'changeChannel'
      data = localChangeChannel(data);
   case 'checkbox'
      data = localCheckBox(data);
   case 'close'
      localClose(data);
   case 'continue'
      data = localContinue(data);
   case 'daqhelp'
      localDaqHelp;
   case 'legend'
      data = localLegend(data);
   case 'oshelp';
      localOsHelp;
   case 'pause'
      data = localPause(data);
   case 'sampleRate'
      data = localSampleRate(data);
   case 'start'
      data = localStart(data);
   case 'startpause'
      data = localStartPause(data);
   case 'stop'
      data = localStop(data);
   case 'voltscheck'
      data = localVoltsCheck(data);
   case 'voltsrange'
      data = localVoltsRange(data);
   end
case 3
   % Action callback.
   obj = varargin{1};
   event = varargin{2};
   action = varargin{3};
   switch action
   case 'timeraction'
      data = localTimerAction(obj, event);
   end
   return;
case 4
   action = varargin{3};
   hFig = varargin{4};
   data = get(hFig, 'UserData');
   switch action
   case 'stopaction'
      data = localStop(data);
   end
otherwise
   error('Too many input arguments.');
end
   
% Update the figure's UserData.
if ~isempty(hFig)&ishandle(hFig),
   set(hFig,'UserData',data);
end

%%
% Store the data structure in the analog input object.
if ~isempty(data.ai) & isvalid(data.ai)
   set(data.ai, 'UserData', data);
end

%% *******************************************************************  
% Change the Channel names listed based on the item selected in the
% adaptor popup menu.
function data = localAdaptor(data)

%%
% Determine which adaptor was selected.
hpop = data.handle.uicontrol(1);
val = get(hpop, 'Value');
str = get(hpop, 'String');

%%
% Need to check if str is a space which occurs when no adaptors are
% registered.
if iscell(str)
   adaptorStr = str{val};
   
   % Split the adaptor string into adaptor and id.
   index = find(adaptorStr == ' ');
   adaptor = adaptorStr(1:index(1)-1);
   id = adaptorStr(index(1)+1:index(2)-1);
   
   if ~strcmp(lower(adaptor), 'winsound') 
       Input_type = adaptorStr(index(2)+2:end-1);
   end
   
   % Delete the current analog input object and create the new analog input
   % object with the above adaptor and id.
   delete(data.ai);
   ai = analoginput(adaptor, id);

   if strcmp(lower(adaptor), 'winsound')
      set(ai, 'SampleRate', 44100);
   end
   
   set(data.handle.uicontrol(6), 'String', num2str(get(ai, 'SampleRate')));
   
   % Determine the number of channels allowed for the selected adaptor.
   aiInfo = daqhwinfo(ai);
   
   % Construct the names based on the hardware.
   if strcmp(lower(adaptor), 'winsound')
       names = {'Channel1 (Left)';'Channel2 (Right)'};
       set(data.handle.uicontrol(3), 'String', 0.2);
   else
       if strcmp(Input_type, 'Differential')
           set(ai, 'InputType', 'Differential');
           data.allchannel = aiInfo.DifferentialIDs;
       elseif strcmp(Input_type, 'SingleEnded')
           set(ai, 'InputType', 'SingleEnded');
           data.allchannel = aiInfo.SingleEndedIDs;
       end
       names = makenames('Channel', data.allchannel);
       set(data.handle.uicontrol(3), 'String', 2);
   end   
   
   % Update the Channel listbox.
   set(data.handle.uicontrol(2),...
      'Value', 1,...
      'String', names);
  
   data = localChangeChannel(data);
   
   % Store the analog input object in data.
   data.ai = [];
   data.ai = ai;

   % Reset the Volts\Div and Autoset checkboxes.
   set(data.handle.uicontrol(8), 'Value', 1);
   set(data.handle.uicontrol(7), 'Value', 0);
      
   % Store the new state.
   data.state = 0;
   
   localUpdateRanges(data);
end

%% *******************************************************************  
% Add the correct channels based on the channels selected.
function data = localAddChannel(data)

%%
% Initialize variables.
updateLim = 1;

%%
% Delete the channels.
delete(get(data.ai, 'Channel'));

%%
% Determine which channels are selected and store in the data structure.
data = localChangeChannel(data);

%%
% Create the channels.
if findstr('winsound', lower(get(data.ai, 'Name')))
  updateLim = 0;
  if any(data.channel == 2)
      addchannel(data.ai, [1 2]); %channel 1 must be added before channel 2 when using device Winsound.
      if length(data.channel) == 1
         data.winsound2 = 1;
      else
         data.winsound2 = 0;
      end
  else
      addchannel(data.ai, 1);
      data.winsound2 = 0;
  end
else
   addchannel(data.ai, [data.allchannel(data.channel)]);
   data.winsound2 = 0;
end

%% *******************************************************************  
% Update the y-axis limits based on the incoming signal.
function data = localAutoset(data)

if strcmp(get(data.ai, 'Running'), 'Off')
   set(data.handle.uicontrol(7), 'Value', 0);
   hWarn = findobj(findall(0), 'Tag', 'notRunningCantAutoset');
   if isempty(hWarn)
      hWarn = warndlg('The analog input acquisition must be started.','Data Acquisition Warning');
      set(hWarn, 'Tag', 'notRunningCantAutoset');
   else
      figure(hWarn(1));
   end
   return;
else
   % Turn on the Autoset radiobutton - needed in case the radiobutton
   % is selected and is selected again.
   set(data.handle.uicontrol(7), 'Value', 1);   
   
   % Turn off the Volts/Div radiobutton.
   set(data.handle.uicontrol(8), 'Value', 0);
   set(data.handle.uicontrol(3), 'Enable', 'off');
   
   % Get some data to calculate the new range.
   pause(1);
   x = peekdata(data.ai, get(data.ai, 'SamplesPerTrigger'));
   ylower = min(x(:));
   yupper = max(x(:));
   
   % If Nans are returned base the limit off the other.
   if isnan(ylower) & isnan(yupper)
      ylower = -0.01;
      yupper = 0.01;
   elseif isnan(ylower)
      ylower = yupper - (abs(yupper)/2);
   elseif isnan(yupper)
      yupper = ylower + (abs(ylower)/2);
   end
   
   % Handle the case when the limits are equal.
   if ylower == yupper
      ylower = ylower - (abs(ylower)/2);
      yupper = yupper + (abs(yupper)/2);
   end
   
   % If they are still equal (if they both were zero).
   if ylower == yupper
      ylower = -0.01;
      yupper = 0.01;
   end
   
   set(data.handle.axes, 'YLim', [ylower yupper],...
      'YTick', linspace(ylower, yupper, 11),...
      'YTickLabel', {num2str(ylower,4), '','','', '','',...
         '','','','',num2str(yupper,4)});
   set(data.handle.uicontrol(3), 'String', num2str((yupper-ylower)/10,3));
   data.autoset = 1;
   drawnow;
end

%% *******************************************************************  
% Update the channel(s) that are being plotted. 
function data = localChangeChannel(data)

% If the line exists, delete it.
if ~isempty(data.handle.line)
   delete(data.handle.line);
   data.handle.line = [];
end

%%
% Determine which channels are selected.
chan = get(data.handle.uicontrol(2), {'Value'});
data.autoset = 0;

%%
% Reset the Volts\Div and Autoset checkboxes.
set(data.handle.uicontrol(8), 'Value', 1);
set(data.handle.uicontrol(7), 'Value', 0);

%%
% Clean up the legend.
if strcmp(get(data.handle.menu(4),'Checked'),'off'),
  set(data.handle.menu(4), 'Checked', 'On');
else,
  set(data.handle.menu(4), 'Checked', 'Off');
end
data=localLegend(data);

%%
% If more than sixteen channels were selected, create a dialog which 
% states only sixteen channels can be selected.
if length(chan{:}) > 16
   hWarn = findobj(findall(0), 'Tag', 'onlySixteenChannels');
   if isempty(hWarn)
      hWarn = warndlg('Only sixteen channels can be selected.','Data Acquisition Warning');
      set(hWarn, 'Tag', 'onlySixteenChannels');
   else
      figure(hWarn(1));
   end
   return;
else
   % Store the channels in the data structure.
   data.channel = chan{:};
end

%% *******************************************************************  
% Stop the object and close the figure window. 
function localClose(data)

%%
% If no adaptors are registered, ai will be empty.
if ~isempty(data.ai)
   % Stop the device if it is running.
   if isvalid(data.ai) & strcmp(lower(get(data.ai, 'Running')), 'on')
      stop(data.ai);
   end
   
   % Delete the object.
   delete(data.ai);
end

%%
% Close the figure window.
delete(data.handle.figure);

%% *******************************************************************  
% Continue running the object. 
function data = localContinue(data)

%%
% The channels and adaptor cannot be selected.
set(data.handle.uicontrol(1:2), 'Enable', 'off');

%%
%initialize the axis according to current volots/div setting
data=localVoltsRange(data);

%%
% Add the correct channels based on the channels selected in the listbox.
data = localAddChannel(data);

%%
% Start the object.
try
   start(data.ai);
catch
   error(lasterr);
end


trigger(data.ai);
d = getdata(data.ai, get(data.ai, 'SamplesPerTrigger'));

%%
% If winsound object and channel 2 was only selected, plot only the
% second column of data.
if data.winsound2 & length(data.channel) == 1
   d = d(:,2);
end

%%
% Delete the current lines - in case channels were removed from the list.
delete(data.handle.line);

%%
% Plot the new data.
hLine=[];


for i = 1:length(data.channel);
   hLine(i) = line('Parent', data.handle.axes,...
      'Xdata', 1:(length(d(:,1))),...
      'Ydata', d(:,i),...
      'Color', data.map(i,:),...
      'HandleVisibility', 'off');
end
drawnow;

%%
% Store the handle to the lines in the data structure.
data.handle.line = hLine;

%%
% Store the new state and set the CData to pause.
data.state = 1;
set(data.handle.uicontrol(9),'CData', data.cdata{2});

%% *******************************************************************  
% Help for the Data Acquisition Toolbox. 
function localDaqHelp

doc('daq');

%% *******************************************************************  
% Create a legend. 
function data = localLegend(data)

if strcmp(get(data.handle.menu(4),'Checked'),'off'),  %isempty(data.handle.legend) 
    
    % Plot the new data.
    if length(data.handle.line)~=length(data.channel),
        data.handle.line=[];
        for i = 1:length(data.channel);
            data.handle.line(i) = line('Parent', data.handle.axes,...
                'Xdata', 1,...
                'Ydata', 10000,...
                'Color', data.map(i,:),...
                'HandleVisibility', 'off');
        end
    end
    if ~isempty(data.handle.line) & ishandle(data.handle.line)
        try
            % Make the axes visible.
            set(data.handle.axes, 'HandleVisibility', 'on');
            set(data.handle.figure, 'HandleVisibility', 'on');
            
            % Create the strings for the legend.
            names = makenames('Channel', data.channel);
            data.handle.legend = legend(data.handle.axes,data.handle.line, names);
            set(data.handle.legend,...
                'Color', [0 0.5 0.0],...
                'ButtonDownFcn', '');
            set(data.handle.menu(4), 'Checked', 'On');
            
            % So that the legend cannot be moved.
            set(get(data.handle.legend, 'Children'), ...
                'ButtonDownFcn', '');
            
            % Make the axes invisible.
            set(data.handle.axes, 'HandleVisibility', 'off');
            set(data.handle.figure, 'HandleVisibility', 'off');
        catch
            % Make the axes invisible.
            set(data.handle.axes, 'HandleVisibility', 'off');
            set(data.handle.figure, 'HandleVisibility', 'off');
        end
    else
        hWarn = findobj(findall(0), 'Tag', 'startForLegend');
        if isempty(hWarn)
            hWarn = warndlg('The analog input acquisition needs to be started.','Data Acquisition Warning');
            set(hWarn, 'Tag', 'startForLegend');
        else
            figure(hWarn(1));
        end
    end
 else
        delete(data.handle.legend);
        data.handle.legend = [];
        set(data.handle.menu(4), 'Checked', 'Off');
end

%% *******************************************************************  
% Help for the oscilloscope. 
function localOsHelp

doc('daqscope');

%% *******************************************************************  
% Pause the object. 
function data = localPause(data)

%%
% Stop the object.
stop(data.ai);

%%
% Store the new state and set the CData to start.
data.state = 2;

set(data.handle.uicontrol(9),'CData', data.cdata{1});
drawnow;

%%
% The channels selected can be modified while pausing.
set(data.handle.uicontrol(2), 'Enable', 'on');

%% *******************************************************************  
% Intialize the object's properties and start the object. 
function data = localStart(data)

% initialize analog input if data.ai does not exist 
if ~isvalid(data.ai)  
    % Determine which adaptor was selected.
    hpop = data.handle.uicontrol(1);
    val = get(hpop, 'Value');
    str = get(hpop, 'String');
    
    % Need to check if str is a space which occurs when no adaptors are
    % registered.
    if iscell(str)
        adaptorStr = str{val};
        % Split the adaptor string into adaptor and id.
        index = find(adaptorStr == ' ');
        adaptor = adaptorStr(1:index(1)-1);
        id = adaptorStr(index(1)+1:index(2)-1);
        
        if ~strcmp(lower(adaptor), 'winsound') 
            Input_type = adaptorStr(index(2)+2:end-1);
        end
        
        % Create the new analog input object with the above adaptor and id.
        ai = analoginput(adaptor, id);
        
        % Construct the names based on the hardware.
        if strcmp(lower(adaptor), 'winsound')
            ;
        else
            if strcmp(Input_type, 'Differential')
                set(ai, 'InputType', 'Differential');
            elseif strcmp(Input_type, 'SingleEnded')
                set(ai, 'InputType', 'SingleEnded');
            end
        end   
        
        % Store the analog input object in data.
        data.ai = [];
        data.ai = ai;
        
        % Store the data structure in the object.
        set(data.ai, 'UserData', data);  
        data = localSampleRate(data);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%initialize the axis according to current volots/div setting
data=localVoltsRange(data);

%%
% Initialize variables.
sampleRate = get(data.ai, 'SampleRate');

%%
% The adaptor and channels selected cannot be modified while running.
set(data.handle.uicontrol(1:2), 'Enable', 'off');

%%
% Set the object to preview data only and plot every tenth of a second.
set(data.ai,...
   'TriggerRepeat', 1,...
   'TriggerType', 'Manual',...
   'SamplesPerTrigger', floor(sampleRate/10),...
   'TimerPeriod', 0.1,...
   'Timerfcn', @localTimerAction,...
   'Stopfcn', {'daqscope', 'stopaction', gcbf});

%%
% Add the correct channels based on the channels selected in the listbox.
data = localAddChannel(data);

%%
% Start the object and get the first samples.
try
   start(data.ai)
catch
   if findstr('device winsound', lower(lasterr))
      hWarn = findobj(findall(0), 'Tag', 'badSampleRateforDevice');
      if isempty(hWarn)
         warndlg(['The specified SampleRate is not supported for this soundcard''s',...
               ' configuration.  Try specifying a new',...
               ' SampleRate value.'], 'Data Acquisition error');
         set(hWarn, 'Tag', 'badSampleRateforDevice');
      else
         figure(hWarn(1));
      end
      return;
   else
      error(lasterr)
   end
end


trigger(data.ai)
d = getdata(data.ai, get(data.ai, 'SamplesPerTrigger'));

%%
% If winsound object and channel 2 was only selected, plot only the
% second column of data.
if data.winsound2 & length(data.channel) == 1
   d = d(:,2);
end

%%
% If the line exists, delete it - the line will exist if the object
% was stopped and started.
if ~isempty(data.handle.line)
   delete(data.handle.line);
   data.handle.line = [];
end

%%
% Plot the first samples.
hLine=[];

for i = 1:length(data.channel);
hLine(i) = line('Parent', data.handle.axes,...
   'Xdata', 1:(length(d(:,1))),...
   'Ydata', d(:,i),...
   'Color', data.map(i,:),...
   'HandleVisibility', 'off');
end
drawnow;

%%
% Store the new state and set the CData to pause.
data.state = 1;

set(data.handle.uicontrol(9),'CData', data.cdata{2});

%%
% Store the handle to the lines in the data structure.
data.handle.line = hLine;


%% *******************************************************************  
% Start or pause the object depending on the toggletool's State.
function data = localStartPause(data)

% data.state = 0: analog input object needs to be initialized - call start.
% data.state = 1: analog input object is running.
% data.state = 2: analog input object is paused.
% data.state = 3: analog input object is stopped.

% Based on the state, either start, continue or pause the analog input
% object.  If data.ai is empty, no adaptors are registered and a warning
% dialog will be displayed.

% initialize analog input if data.ai does not exist 
if ~isvalid(data.ai)  
    % Determine which adaptor was selected.
    hpop = data.handle.uicontrol(1);
    val = get(hpop, 'Value');
    str = get(hpop, 'String');
    
    % Need to check if str is a space which occurs when no adaptors are
    % registered.
    if iscell(str)
        adaptorStr = str{val};
        % Split the adaptor string into adaptor and id.
        index = find(adaptorStr == ' ');
        adaptor = adaptorStr(1:index(1)-1);
        id = adaptorStr(index(1)+1:index(2)-1);
        
        if ~strcmp(lower(adaptor), 'winsound') 
            Input_type = adaptorStr(index(2)+2:end-1);
        end
        
        % Create the new analog input object with the above adaptor and id.
        ai = analoginput(adaptor, id);
        
        % Construct the names based on the hardware.
        if strcmp(lower(adaptor), 'winsound')
            ;
        else
            if strcmp(Input_type, 'Differential')
                set(ai, 'InputType', 'Differential');
            elseif strcmp(Input_type, 'SingleEnded')
                set(ai, 'InputType', 'SingleEnded');
            end
        end   
        
        % Store the analog input object in data.
        data.ai = [];
        data.ai = ai;
        
        % Store the data structure in the object.
        set(data.ai, 'UserData', data);  
        data = localSampleRate(data);
    end

    % Initialize variables.
    sampleRate = get(data.ai, 'SampleRate');
    
    % Set the object to preview data only and plot every tenth of a second.
    set(data.ai,...
        'TriggerRepeat', 1,...
        'TriggerType', 'Manual',...
        'SamplesPerTrigger', floor(sampleRate/10),...
        'TimerPeriod', 0.1,...
        'Timerfcn', @localTimerAction,...
        'Stopfcn', {'daqscope', 'stopaction', gcbf});
end

if ~isempty(data.ai)
   autoset = data.autoset;
   switch (data.state)
   case 0
      data = localStart(data);
   case 1
      data = localPause(data);
   case 2
      data = localContinue(data);
   case 3
      data = localStart(data);
   end
   data.autoset = autoset;
else
   hWarn = findobj(findall(0), 'Tag', 'noAdaptorsRegistered');
   if isempty(hWarn)
      hWarn = warndlg(['No adaptors are registered.  Type ''daqhelp daqregister'' for more ',...
            'information on registering adaptors.'],'Data Acquisition Warning');
      set(hWarn, 'Tag', 'noAdaptorsRegistered');
   else
      figure(hWarn(1));
   end
   return;
end

%% *******************************************************************  
% Stop the analog input object.
function data = localStop(data)

% stop object only if data.ai does exist 
if isvalid(data.ai)  
    % Stop the object if it exists.
    if ~isempty(data.ai)
        stop(data.ai);
    end
    
    % The channels and adaptor can now be selected.
    set(data.handle.uicontrol(1:2), 'Enable', 'on');
    
    % Store the new state and set the CData to start.
    data.state = 3;
    
    set(data.handle.uicontrol(9), 'CData', data.cdata{1});
    set(data.handle.uicontrol(9), 'Value', 0);
end

%% *******************************************************************  
% Continuously plot the data. 
function data = localTimerAction(obj,event)

%%
% Get the data structure.
data = obj.UserData;

if data.state == 1
   % Get the handles.
   hLine = data.handle.line;
   
   % Execute a peekdata.
   x = peekdata(obj, obj.SamplesPerTrigger);
   
   % If winsound object and channel 2 was only selected, plot only the
   % second column of data.
   if data.winsound2 & length(data.channel) == 1
      x = x(:,2);
   end

   % Update the plot.
   set(hLine, 'Parent', data.handle.axes,...
      'Xdata', 1:length(x),...
      {'YData'}, num2cell(x,1)',...
      {'Color'}, num2cell(data.map(1:length(hLine),:),2));
   
   if data.autoset
      ymin = min(x(:)); 
      ymax = max(x(:));
      
      % If Nans are returned base the limit off the other.
      if isnan(ymin) & isnan(ymax)
         ymin = -0.01;
         ymax = 0.01;
      elseif isnan(ymin)
         ymin = ymax - (abs(ymax)/2);
      elseif isnan(ymax)
         ymax = ymin + (abs(ymin)/2);
      end
      
      % Handle the case when the limits are equal.
      if ymin == ymax
         ymin = ymin - (abs(ymin)/2);
         ymax = ymax + (abs(ymax)/2);
      end
   
      % If they are still equal (if they both were zero).
      if ymin == ymax
         ymin = -0.01;
         ymax = 0.01;
      end
      
      set(data.handle.axes, 'YLim', [ymin, ymax],...
         'YTick', linspace(ymin, ymax, 11),...
         'YTickLabel', {num2str(ymin,4), '','','', '','',...
            '','','','',num2str(ymax,4)});
      set(data.handle.uicontrol(3), 'String', num2str((ymax-ymin)/10,3));
   end
end
drawnow;

%% *******************************************************************  
% Update the axes range and slider range.
function localUpdateRanges(data)

% ai doesn't exist if no adaptors are registered.
if ~isempty(data.ai)
   
   sampleRate = get(data.ai, 'SampleRate');
   range = floor(sampleRate/10);
   
   % Update the axes to range from 0 to sampleRate/10.
   set(data.handle.axes,...
      'XLim'              ,[0 range]                              ,...
      'XTick'             ,linspace(0,range,9)                    ,...
      'XTickLabel'        ,{'0','','','','','','','',num2str(range)}); 
   
   % Update x-axis slider to range from 0 to sampleRate/10.
   set(data.handle.uicontrol(4),...
      'Max'               ,range,...
      'Value'             ,range);
   
   % Update the y-axis to have a range of the UnitsRange property.
   adaptor = daqhwinfo(data.ai, 'AdaptorName');

% initialize the axis according to current volots/div setting
      data=localVoltsRange(data);

end
   
%% *******************************************************************  
% Update the x-axis range. 
function data = localAxisRange(data)

%%
% Get the value of the slider.
val = get(data.handle.uicontrol(4), 'Value');

%%
% Set the x-axis upper limit to the slider value.
set(data.handle.axes,...
   'XLim', [0 val],...
   'XTick', linspace(0,val,9),...
   'XTickLabel', {'0','','','','','','','',num2str(val)});

%% *******************************************************************  
% Allow the volts per division to be specified. 
function data = localVoltsCheck(data)

%%
% Turn on the volts/div radiobutton.
set(data.handle.uicontrol(8), 'Value', 1);
set(data.handle.uicontrol(3), 'Enable', 'on');

%%
% Turn off the autoset radiobutton.
set(data.handle.uicontrol(7), 'Value', 0);

%%
% Update the data structure.
data.autoset = 0;

%% *******************************************************************  
% Update the y-axis range. 
function data = localVoltsRange(data)

%%
% Get the value of the edit text box.
val = str2num(get(data.handle.uicontrol(3), 'String'));

if val <= 0 
   hWarn = findobj(findall(0), 'Tag', 'voltsperdivision');
   if isempty(hWarn)
      hWarn = warndlg('Volts per division must be a positive number.','Data Acquisition Warning');
      set(hWarn, 'Tag', 'voltsperdivision');
   else
      figure(hWarn(1));
   end
   return;
end

%%
% Set the y-axis limits.
midYLim = 0;
yupper = 5*val+midYLim;
ylower = (-5*val)+midYLim;
set(data.handle.axes,...
   'YLim', [ylower yupper],...
   'YTick', linspace(ylower, yupper, 11),...
   'YTickLabel', {num2str(ylower,4), '','','','','',...
      '','','','',num2str(yupper,4)});

%% *******************************************************************  
% Allow users to modify sampleRate. 
function data = localCheckBox(data)

switch get(data.handle.uicontrol(5), 'Value')
case 0
   set(data.handle.uicontrol(6),...
      'Enable', 'off',...
      'BackGroundColor', get(data.handle.uicontrol(5), 'BackGroundColor'));
case 1
   set(data.handle.uicontrol(6),...
      'Enable', 'on',...
      'BackGroundColor', [1 1 1]);
   
end

%% *******************************************************************  
% Change the sampleRate. 
function data = localSampleRate(data)

sampleRate = str2num(get(data.handle.uicontrol(6), 'String'));

switch data.state
case 1
   try
      stop(data.ai);
      set(data.ai, 'SampleRate', sampleRate);
      data = localStartPause(data);
   catch
      error(lasterr);
   end
otherwise
   set(data.ai, 'SampleRate', sampleRate);
end

localUpdateRanges(data)

%% *******************************************************************  
% Initialize the scope window.
function data = localInitFig(data)

%%
% Initialize variables.
btnColor=get(0,'DefaultUIControlBackgroundColor');

%%
% Position the GUI in the middle of the screen
screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);

XOffset=25;
figWidth=580+XOffset;

YOffset=0;
figHeight=315+20;

figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
      figWidth                    figHeight];
  
%%   
% Information for all handle graphics objects.m
genInfo.HandleVisibility='off';
genInfo.Interruptible='off';
genInfo.BusyAction='queue';

%%
% Create the figure window.
hFig=figure(genInfo,...                    
   'Color'             ,btnColor                    ,...
   'DeleteFcn'         ,'daqscope(''close'', gcbf)',...
   'DoubleBuffer'      ,'on'                        ,...
   'IntegerHandle'     ,'off'                       ,...
   'MenuBar'           ,'none'                      ,...
   'Name'              ,'An Example Oscilloscope'   ,...
   'Tag'               ,'Oscilloscope'              ,...
   'NumberTitle'       ,'off'                       ,...
   'Units'             ,'pixels'                    ,...
   'Position'          ,figPos                      ,...
   'Resize'            ,'off'                        ,...
   'UserData'          ,[]                          ,...
   'Colormap'          ,[]                          ,...
   'Pointer'           ,'arrow'                     ,...
   'Visible'           ,'off'                        ...
   );

genInfo.Parent = hFig;

%%
% Information for all uicontrols.
uiInfo=genInfo;
uiInfo.BackGroundColor=btnColor;
uiInfo.ForeGroundColor=[0 0 0];

%%
% Create the axes.
axPos = [46+XOffset 26+YOffset 367 272];


scopeMap = [1.0000    1.0000         0;
    1.0000    1.0000    1.0000;
    1.0000    0.1000         0;
         0         0    1.0000;
         0    1.0000    1.0000;
    0.3000    0.2500    0.7000;
    1.0000    0.6000    0.2000;
    0.9000    0.1000    0.7000;
    0.2000    0.8000    1.0000;
    0.5000    0.2500    0.5000;
    1.0000    0.8000    0.8000;
    0.7333    0.2667    1.0000;
         0         0         0;
    0.8000    0.4000    0.2000;
    0.5000    0.7500    1.0000;
    1.0000    0.4000    0.2000];
   
hAxes = axes(genInfo,...
   'Units'             ,'pixels'                   ,...
   'Position'          ,axPos                      ,...
   'Box'               ,'On'                       ,...
   'TickLength'        ,[0 0]                      ,...
   'DrawMode'          ,'fast'                     ,...
   'Color'             ,[0 0.475 0]                  ,...
   'ColorOrder'        ,scopeMap                   ,...
   'XLim'              ,[0 512]                    ,...
   'XTick'             ,linspace(0,512,9)          ,...
   'XTickLabel'        ,{'0','','','','','','','','800'},...
   'YLim'              ,[-1 1]                     ,...
   'YTick'             ,linspace(-1,1,11)          ,...
   'YTickLabel'        ,{'-1','','','','','','','','','','1'},...
   'XGrid'             ,'on'                       ,...
   'YGrid'             ,'on'                       ,...
   'GridLineStyle'     ,':');

%%
% Create the frames.
framePos = {[420+XOffset 26+YOffset 158 272], [425+XOffset 75 148 60]};  

for i = 1:length(framePos)
   hFrame = uicontrol(uiInfo,...
      'Style'          , 'frame'     ,...
      'Units'          , 'pixels'    ,...
      'Position'       , framePos{i});
end

%%
% Get adaptor information:
% adaptorStr = list of adaptors for the popup = {'winsound0' 'nidaq1'}.
% ai = analoginput object constructed from adaptorStr{1}.
% names = corresponding channel names to ai.
[adaptorStr, ai, names] = daqgate('privateGetAdaptor', 'analoginput');

% Description of data.handle.uicontrol:
% 1: popup
% 2: listbox
% 3: edit text box - Volts\Div
% 4: slider
% 5: checkbox - SampleRate
% 6: edit text box - SampleRate
% 7: radiobutton - Autoset
% 8: radiobutton - Volts\Div.

%%
% Create the adaptor pop-up.
%83329%popPos = [430 266 138 22];  
popPos = [430+XOffset 266+YOffset 138 22];  

h(1) = uicontrol(uiInfo,...
   'Style'            ,'popup'      ,...
   'Units'            ,'pixels'     ,...
   'Position'         ,popPos       ,...
   'String'           ,adaptorStr   ,...
   'BackGroundColor'  ,[1 1 1]      ,...
   'Callback'         ,'daqscope(''adaptor'', gcbf);');

%%
% Create the channel listbox.
listPos = [430+XOffset 169+YOffset 138 87];    

h(2) = uicontrol(uiInfo,...
   'Style'           ,'listbox'        ,...
   'Max'             ,3                ,...
   'Min'             ,1                ,...
   'Units'           ,'pixels'         ,...
   'Position'        ,listPos          ,...
   'String'          ,names            ,...
   'BackGroundColor' ,[1 1 1]          ,...
   'Callback'        ,'daqscope(''changeChannel'', gcbf);');

%%
% Create the edit text box - Volts/Div.
EditPos = [508+XOffset 110+YOffset 60 20];

h(3) = uicontrol(uiInfo,...
   'Style'                ,'edit'      ,...
   'String'               ,.2          ,...
   'Units'                ,'pixels'    ,...
   'Position'             , EditPos  ,...
   'BackGroundColor'      ,[1 1 1]     ,...
   'HorizontalAlignment'  ,'left'      ,...
   'Callback'             ,'daqscope(''voltsrange'', gcbf);');

%%
% Label the radiobutton - Volts/Div.
textPos = [430+XOffset 110+YOffset 78 20];  

h(8) = uicontrol(uiInfo,...
   'Style'                ,'radiobutton' ,...
   'Value'                ,1             ,...
   'String'               ,'Volts/Div'   ,...
   'HorizontalAlignment'  ,'left'        ,...
   'Units'                ,'pixels'      ,...
   'Position'             ,textPos       ,...
   'Callback'             ,'daqscope(''voltscheck'', gcbf);');

%%
% Label the slider.
textPos = [430+XOffset 50+YOffset 124 20];

uicontrol(uiInfo,...
   'Style'                ,'text'                ,...
   'String'               ,'X-Axis Range'        ,...
   'HorizontalAlignment'  ,'left'                ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,textPos);

%%
% Create the slider.
sliderPos = [430+XOffset 35+YOffset 138 20];

h(4) = uicontrol(uiInfo,...
   'Style'                ,'slider'              ,...
   'Max'                  ,800                   ,...
   'Min'                  ,1                     ,...
   'Value'                ,800                   ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,sliderPos             ,...
   'Callback'             ,'daqscope(''axisrange'', gcbf);');

%%
% Create the SampleRate checkbox.
CheckBoxPos=[430+XOffset 140+YOffset 78 20];

h(5) = uicontrol(uiInfo,...
   'Style'                ,'checkbox'            ,...
   'Value'                ,0                     ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,CheckBoxPos           ,...
   'String'               ,'SampleRate'          ,...
   'HorizontalAlignment'  ,'left'                ,...
   'Callback'             ,'daqscope(''checkbox'', gcbf);');

%%
% Create the SampleRate edit text box.
sampleRate = get(ai, 'SampleRate');
EditPos=[508+XOffset 140+YOffset 60 20];

h(6) = uicontrol(uiInfo,...
   'Style'                ,'edit'                ,...
   'Enable'               ,'off'                 ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,EditPos               ,...
   'String'               ,num2str(sampleRate)   ,...
   'HorizontalAlignment'  ,'left'                ,...
   'Callback'             ,'daqscope(''sampleRate'', gcbf);');

%%
% Create the autoset radiobutton.
RadioPos=[430+XOffset 80+YOffset 124 20];

h(7) = uicontrol(uiInfo,...
   'Style'                ,'radiobutton'         ,...
   'Value'                ,0                     ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,RadioPos              ,...
   'String'               ,'Autoset'             ,...
   'Callback'             ,'daqscope(''autoset'', gcbf);');

%%
% Create the stop CData.
square = 0.7*ones(16,16,3);
square(4:12, 4:12, :) = 0;

%%
% Create the start CData.
triangle = 0.7*ones(16,16,3);
for i = 1:5
   for j = 1:2
      triangle(3+i:13-i,3+i+j,:)=0;
   end
end

%%
% Create the pause CData which will be stored in the data structure.
rect = 0.7*ones(16,16,3);
rect(4:12, 5:7,:) = 0;
rect(4:12, 9:11,:) = 0;

%%
% Create the togglebar.
h(9) = uicontrol(uiInfo,...
   'Style'                ,'togglebutton'         ,...
   'Value'                ,0                     ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,[8 315 20 20]              ,...
   'CData'                ,triangle       ,...
   'TooltipString'        ,'Start/Pause Acquisition'    ,...  
   'Callback'             ,'daqscope(''startpause'',gcbf);');

%%
%Create the stop bar 
h(10) = uicontrol(uiInfo,...
   'Style'                ,'pushbutton'         ,...
   'Units'                ,'pixels'              ,...
   'Position'             ,[28 315 20 20]              ,...
   'CData'                ,square         ,...   
   'TooltipString'        ,'Stop Acquisition'    ,...  
   'Callback'             ,'daqscope(''stop'', gcbf);');

%%
% Create the File menu.
menu(1) = uimenu('Label', 'File',...
   'Parent'             ,hFig);
menu(2) = uimenu(menu(1),...
   'Label'              ,'Close Oscilloscope'      ,...
   'Callback'           ,'daqscope(''close'', gcbf);');

%%
% Create the View menu.
menu(3) = uimenu('Label', 'View',...
   'Parent'             ,hFig);
menu(4) = uimenu(menu(3),...
   'Label'              ,'Legend'                  ,...
   'Callback'           ,'daqscope(''legend'',gcbf);');

%%
% Create the help menu.
menu(5) = uimenu('Label', 'Help',...
   'Parent'             ,hFig);
menu(6) = uimenu(menu(5),...
   'Label'              ,'Oscilloscope Help'     ,...
   'Callback'           ,'daqscope(''oshelp'', gcbf);');
menu(7) = uimenu(menu(5),...
   'Label'              ,'Data Acquisition Help' ,...
   'Callback'           ,'daqscope(''daqhelp'', gcbf);');

%%
% Create the data structure.
data.handle.figure = hFig;
data.handle.axes = hAxes;
data.handle.uicontrol = h;
data.handle.line = [];

data.handle.menu = menu;
data.handle.legend = [];
data.ai = ai;
data.channel = 1;
data.allchannel = [];
data.cdata = {triangle rect};
data.map = scopeMap;
data.state = 0;
data.winsound2 = 0;
data.autoset = 0;

%%
% Set the axes limits to be from 0 to the SampleRate.
localUpdateRanges(data)

if ~isempty(data.ai)
    aiInfo = daqhwinfo(data.ai);
    
    % Determine which adaptor was selected.
    hpop = data.handle.uicontrol(1);
    val = get(hpop, 'Value');
    str = get(hpop, 'String');

    % Need to check if str is a space which occurs when no adaptors are
    % registered.
    if iscell(str)
       adaptorStr1 = str{val};
       
       % Split the adaptor string into adaptor and id. Find adaptor and input type
       index = find(adaptorStr1 == ' ');
       adaptor = adaptorStr1(1:index(1)-1);
       if ~strcmp(lower(adaptor), 'winsound') 
           Input_type = adaptorStr1(index(2)+2:end-1);
           % Derermine the channel IDs. 
           if strcmp(Input_type, 'Differential')
               data.allchannel = aiInfo.DifferentialIDs;
           elseif strcmp(Input_type, 'SingleEnded')
               data.allchannel = aiInfo.SingleEndedIDs;
           end
           set(data.handle.uicontrol(3), 'String', 2);
       end
   end
end

%%
% Store the data structure and display figure.
set(hFig,'Visible','on','UserData',data);

%%
% Store the data structure in the object.
set(data.ai, 'UserData', data);
