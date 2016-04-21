function daqfcngen(varargin)
%% DAQFCNGEN Example function generator for the Data Acquisition Toolbox.
%
%    DAQFCNGEN creates a function generator window which can be used with 
%    the Data Acquisition Toolbox's analog output objects.
%
%    The function generator window is divided into three sections.  
%
%    The top section contains a popup menu which displays the analog output
%    objects that currently exist in the data acquisition engine.  The 
%    selected analog output object's channels are listed in the listbox. 
%
%    The bottom section consists of a popup menu that has a list of the
%    supported waveforms.  These waveforms include sin, sinc, square, 
%    triangle, sawtooth, random, and chirp.   Waveform-specific information
%    such as frequency or amplitude can be entered for each waveform.  If
%    values are not entered, the default values displayed are used.  
%
%    The right section consists of three buttons which start/stop the 
%    selected analog output object, reset the function generator window
%    to its original state and close the function generator window.
%
%    The selected waveform can be sent to multiple channels of the same
%    analog output object.  Channels of the same object cannot be connected
%    to different waveforms.
%
%    Information on DAQFCNGEN and the Data Acquisition Toolbox are
%    available through the Help menu.
%
%    The daqfcngen window can be closed either by selecting the File menu 
%    and then selecting the Close Function Generator menu or by selecting
%    the "x" close button.  When the daqfcngen window is closed, the analog 
%    output object will be stopped, if it is running, and deleted.
%
%    See also DAQSCOPE
%

%    MP 11-05-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.6 $  $Date: 2004/03/30 13:03:52 $

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
   % Create figure.
   data = localInitFig;
   hFig = data.handle.figure;
   currentPointer = get(hFig, 'Pointer');
case 1
   error('No inputs required to run DAQFCNGEN.');
case 2
   % Initialize variables.
   action=varargin{1};
   hFig=varargin{2};
   data=get(hFig,'UserData');
   
   % Call the appropriate function based on the action.
   switch action
   case 'adaptor'
      data = localAdaptor(data);
   case 'changeChannal'
      data = localChangeChannel(data);
   case 'waveform'
      data = localWaveForm(data);
   case 'resubmit'
      data = localResubmit(data);
   case 'start'
      data = localStart(data);
   case 'reset'
      data = localReset(data);
   case 'close'
      localClose(data);
   case 'checkbox'
      data = localCheckBox(data);
   case 'sampleRate'
      data = localSampleRate(data);
   case 'Sine'
      data = localSine(data);
   case 'Sinc'
      data = localSinc(data);
   case 'Square'
      data = localSquare(data);
   case 'Triangle'
      data = localTriangle(data);
   case 'Sawtooth'
      data = localSawtooth(data);
   case 'Random'
      data = localRandom(data);
   case 'Chirp'
      data = localChirp(data);
   case 'helpFcngen'
      localHelpFcnGen;
   case 'helpdaq'
      localHelpDaq;
   end
case 4
   action = varargin{3};
   hFig = varargin{4};
   data = get(hFig, 'UserData');
   switch action
   case 'stopaction'
      data = localStop(data);
   end
otherwise
   error('Wrong number of input arguments for FCNGEN');
end

if data.errflag
   error(lasterr);
end

%%
% Update the figure's UserData and reset the figure's Pointer.
if ~isempty(hFig)&ishandle(hFig),
   set(hFig,'UserData',data);
end

%% *******************************************************************  
% Change the Channel names listed based on the item selected in the
% adaptor popup menu.
function data = localAdaptor(data)

%%
% Determine which adaptor was selected.
hpop = data.handle.config(1);
val = get(hpop, 'Value');
str = get(hpop, 'String');

%%
% str will not be a cell if no adaptors are registered.
if iscell(str)
   adaptorStr = str{val};
   
   % Split the adaptor string into adaptor and id.
   index = find(adaptorStr == ' ');
   adaptor = adaptorStr(1:index-1);
   id = adaptorStr(index+1:end);
   
   % Delete the current analog output object and create the new analog output
   % object with the above adaptor and id.
   delete(data.ao);
   ao = analogoutput(adaptor, id);
   
   if strcmp(lower(adaptor), 'winsound')
      set(ao, 'SampleRate', 44100);
   end
   
   % Determine the number of channels allowed for the selected adaptor.
   data.allchannel = daqhwinfo(ao, 'ChannelIDs');
   
   % Construct the names based off the hardware ids.
   names = makenames('Channel', [data.allchannel]);
   
   % Add the channels.
   addchannel(ao, data.allchannel, names);
      
   % Update the Channel listbox.
   set(data.handle.config(2),...
      'Value', 1,...
      'String', names);
   data.channel = 1;
   
   % Store the analog output object in data.
   data.ao = [];
   data.ao = ao;
   
   % Get the samplerate for the new object.
   data.SampleRate = get(ao, 'SampleRate');
   
   % Update the SampleRate display.
   set(data.handle.config(4), 'String', num2str(data.SampleRate));
end

%% *******************************************************************  
% Add the correct channels based on the channels selected.
function data = localAddChannel(data)

%%
% Delete the channels.
delete(get(data.ao, 'Channel'));

%%
% Determine which channels are selected and store in the data structure.
data = localChangeChannel(data);

%%
% Create the channels.
if findstr('winsound', lower(get(data.ao, 'Name')))
   addchannel(data.ao, [1 2]);
   if any(data.channel == 2)
      if length(data.channel) == 1
         data.winsound2 = 1;
      else
         data.winsound2 = 0;
      end
   else
      data.winsound2 = 0;
   end
else
   addchannel(data.ao, [data.allchannel(data.channel)]);
end

%% *******************************************************************  
% Update the channel(s) that are being plotted. 
function data = localChangeChannel(data)

%%
% Determine which channels are selected.
chan = get(data.handle.config(2), {'Value'});

%%
% Store the channels in the data structure.
data.channel = chan{:};

%% *******************************************************************  
% Allow users to modify sampleRate. 
function data = localCheckBox(data)

switch get(data.handle.config(5), 'Value')
case 0
   set(data.handle.config(4),...
      'Enable', 'off',...
      'BackGroundColor', get(data.handle.config(5), 'BackGroundColor'));
   
   % Resubmit the new waveform if the object is running.
   if data.State == 1
      data = localResubmit(data);
   end
case 1
   set(data.handle.config(4),...
      'Enable', 'on',...
      'BackGroundColor', [1 1 1]);
end

%% *******************************************************************  
% Update the channel(s) that are being plotted. 
function data = localSampleRate(data)

prevSampleRate = data.SampleRate;
data.SampleRate = str2num(get(data.handle.config(4), 'String'));

try
   data.SampleRate = setverify(data.ao, 'SampleRate', data.SampleRate);
   set(data.handle.config(4), 'String', num2str(data.SampleRate));
catch
   % Restore the old sampleRate value.
   set(data.handle.config(4), 'String', num2str(prevSampleRate));
   data.SampleRate = prevSampleRate;
   
   % Warn that the SampleRate specified is invalid.
   hWarn = findobj(findall(0), 'Tag', 'invalidSampleRate');
   if isempty(hWarn)
      hWarn = warndlg('Invalid SampleRate value for the current device.',...
         'Data Acquisition Warning');
      set(hWarn, 'Tag', 'invalidSampleRate');
   else
      figure(hWarn(1));
   end
end
data = localResubmit(data);

%% ***********************************************************************  
% Determine which wave form was selected and call the appropriate function.
function data = localWaveForm(data)

%%
% Determine which waveform was selected.
h = data.handle.config(3);
val = get(h, 'Value');
str = get(h, 'String');

%%
% Update the data structure.
data.CurrentWaveForm = str{val,:};

%%
% Call the appropriate local function to update the edit text and static
% text boxes.
daqfcngen(str{val,1},data.handle.figure);

%%
% If the object is running recalculate the wave and call putdata.
if data.State
   data = localResubmit(data);
end

%% ***********************************************************************   
% Toggle the start button between start and stop.
% Start and stop sending data to the specified analog output object.
function [data,errflag] = localStart(data)

%%
% Get the handle to the Start/Stop pushbutton.
h = data.handle.button(1);

%%
% If an object does not exist - no adaptors are registered - display
% a warning and set the state of the toggle button to 0.
if ~isempty(data.ao)
   
   % Toggle its state and update the data structure.
   if data.State == 0 
      
      % Call the appropriate wave function.
      wave = data.CurrentWaveForm;
      [data,out] = feval(['local' wave], data, data.SampleRate); 
      
      % Verifying waveform parameters.
      if (out == -1)
         if (isempty(data.value.frequency))
            localDispWaveFormEmptyWarning('Frequency');
            return;
         elseif (isempty(data.value.amplitude))
            localDispWaveFormEmptyWarning('Amplitude');
            return;
         elseif (isempty(data.value.offset))
            localDispWaveFormEmptyWarning('DC Offset');
            return;
         elseif (isempty(data.value.phase))
            localDispWaveFormEmptyWarning('Phase');
            return;
         elseif (isempty(data.value.cycle))
            localDispWaveFormEmptyWarning('Duty Cycle');
            return;
         elseif (isempty(data.value.width))
            localDispWaveFormEmptyWarning('Width');
            return;
         elseif (isempty(data.value.ttime))
            localDispWaveFormEmptyWarning('Target Time');
            return;
         elseif (isempty(data.value.initfreq))
            localDispWaveFormEmptyWarning('Initial Frequency');
            return;
         elseif (isempty(data.value.ttimefreq))
            localDispWaveFormEmptyWarning('Target Time Frequency');
            return;
         elseif (str2num(data.value.frequency) <= 0)
            localDispWaveFormLessWarning('Frequency');
            return;
         elseif (str2num(data.value.seed) < 0)
            localDispWaveFormLessWarning('Seed');
            return;
         elseif ((str2num(data.value.cycle) < 0) | (str2num(data.value.cycle) > 100))
            localDispWaveFormRangeWarning('Duty Cycle', 0, 100);
            return;
         elseif ((str2num(data.value.width) < 0) | (str2num(data.value.width) > 1))
            localDispWaveFormRangeWarning('Width', 0, 1);
            return;
         end
      end   
      
      % Error if no data was returned.
      if isempty(out)
         hWarn = findobj(findall(0), 'Tag', 'invalidFreq');
         if isempty(hWarn)
            hWarn = warndlg(['Invalid waveform frequency specified for ',...
                  'object frequency.'],'Data Acquisition Warning');
            set(hWarn, 'Tag', 'invalidFreq');
         else
            figure(hWarn(1));
         end
         return;
      end
      
      % Return if an error occurred while calculating the waveform.
      if data.errflag
         return;
      end
      
      % Set RepeatOutput to Inf. 
      set(data.ao, 'RepeatOutput', inf);
      data.SampleRate = setverify(data.ao, 'SampleRate', data.SampleRate);
      set(data.handle.config(4), 'String', num2str(data.SampleRate));
      set(data.ao, 'StopFcn', {@daqfcngen, 'stopaction',gcbf});
      
      % Add the channels based on those selected.
      data = localAddChannel(data);
      
      % Create the matrix for putdata.
      if (length(data.ao.Channel) ~= 1) & (length(data.channel)==1)
          allout = zeros(length(out),2);
          if data.winsound2
%              allout = zeros(length(out), 2);
             allout(:,2) = out';
         else
             allout(:,1) = out'; 
         end
      else
         allout = repmat(out',1,length(data.channel));
      end      
      
      % Put the data calculated from the local waveform function and start 
      % the device.
      putdata(data.ao, allout);
      
      try
         start(data.ao);
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
            error(lasterr);
         end
      end
      
      % Toggle the togglebutton and store the state.
      set(h, 'String', 'Stop');
      data.State = 1;
      
      % Disable the analog output popup and the channel listbox.
      set(data.handle.config(1:2), 'Enable', 'inactive');
      
      % Disable the SampleRate box.
      set(data.handle.config(4:5), 'Enable', 'inactive');
   else
      if ~isempty(data.ao)
         % Stop the device.
         stop(data.ao);
      end
      
      % Toggle the togglebutton and store the state.
      set(h, 'String', 'Start');
      data.State = 0;
      
      % Enable the analog output popup and the channel listbox.
      set(data.handle.config(1:2), 'Enable', 'on');
      
      % Enable the samplerate box.
      set(data.handle.config(4:5), 'Enable', 'on');
   end
else
   % Occurs if no adaptors are registered.
   set(h, 'Value', 0);
   hWarn = findobj(findall(0), 'Tag', 'noAdaptorsRegisterFCN');
   if isempty(hWarn)
      hWarn = warndlg(['No adaptors are registered.  Type ''daqhelp daqregister'' for more ',...
            'information on registering adaptors.'],'Data Acquisition Warning');
      set(hWarn, 'Tag', 'noAdaptorsRegisterFCN');
   else
      figure(hWarn(1));
   end
end

%% ***********************************************************************   
% Stop the device.
function data = localStop(data)

%%
% Get the handle to the Start/Stop pushbutton.
h = data.handle.button(1);

%%
% Toggle the togglebutton and store the state.
set(h, 'String', 'Start');

%%
% Enable the analog output popup and the channel listbox.
set(data.handle.config(1:2), 'Enable', 'on');
data.State = 0;

%% ***********************************************************************   
% This is called whenever one of the edit text boxes are updated.  The new
% signal will be calculated and the device will be stopped and started with
% the new data.
function data = localResubmit(data)

switch data.CurrentWaveForm
case {'Sine' 'Sinc'}
   data.value.frequency = get(data.handle.edit(1), 'String');
   data.value.amplitude = get(data.handle.edit(2), 'String');
   data.value.offset    = get(data.handle.edit(4), 'String');
   data.value.phase     = get(data.handle.edit(5), 'String');
case 'Square'
   data.value.frequency = get(data.handle.edit(1), 'String');
   data.value.amplitude = get(data.handle.edit(2), 'String');
   data.value.offset    = get(data.handle.edit(4), 'String');
   data.value.cycle     = get(data.handle.edit(5), 'String');
case 'Triangle'
   data.value.frequency = get(data.handle.edit(1), 'String');
   data.value.amplitude = get(data.handle.edit(2), 'String');
   data.value.offset    = get(data.handle.edit(4), 'String');
case 'Sawtooth'
   data.value.frequency = get(data.handle.edit(1), 'String');
   data.value.amplitude = get(data.handle.edit(2), 'String');
   data.value.offset    = get(data.handle.edit(4), 'String');
   data.value.width     = get(data.handle.edit(5), 'String');
case 'Random'
   data.value.amplitude = get(data.handle.edit(1), 'String');
   data.value.offset    = get(data.handle.edit(2), 'String');
   data.value.seed      = get(data.handle.edit(4), 'String');
case 'Chirp'
   val = get(data.handle.edit(1), 'Value');
   str = {'Linear'; 'Quad'; 'Log'};
   data.value.method    = str{val,:};
   data.value.ttime     = get(data.handle.edit(2), 'String');
   data.value.initfreq  = get(data.handle.edit(4), 'String');
   data.value.ttimefreq = get(data.handle.edit(5), 'String');
   data.value.phase     = get(data.handle.edit(6), 'String');
end

%%
% If the object is running calculate the new waveform and call putdata.
if data.State 
   % Call the appropriate wave function.
   wave = data.CurrentWaveForm;
   [data,out] = feval(['local' wave], data, data.SampleRate); 
   
   % Return if an error occurred while calculating the waveform.
   if data.errflag
      return;
   end
   
   % Determine which channel(s) were selected
   allchan = get(data.ao, 'Channel');
   val = data.channel;

   % Create the matrix for putdata.
   allout = zeros(length(out), length(allchan));
   for i = 1:length(val)
      allout(:,val(i)) = out';
   end

   % Stop the object, put the new data and start.
   temp = get(data.ao, 'StopFcn');
   set(data.ao, 'StopFcn', '');
   stop(data.ao)
   data.SampleRate = setverify(data.ao, 'SampleRate', data.SampleRate);
   set(data.handle.config(4), 'String', num2str(data.SampleRate));
   putdata(data.ao, allout);
   start(data.ao);
   set(data.ao, 'StopFcn', temp);
end

%%
% ***********************************************************************   
% Reset the function generator to its original state.
function data = localReset(data)

%%
% Stop the device if it exists.
if ~isempty(data.ao)
   stop(data.ao);
end

%%
% Update the adaptor popup menu.
set(data.handle.config(1),'Value', 1);
set(data.handle.config(2), 'Value', 1);
data = localAdaptor(data);

%%
% Reset the waveforms popup.
set(data.handle.config(3),'Value', 1);
data.CurrentWaveForm = 'Sine';
localSine(data);

%%
% Reset the Start/Stop pushbutton to start
set(data.handle.button(1),'String', 'Start', 'Value', 0);
data.State = 0;

%%
% Reset Frequency, Amplitude, Offset, Phase edit text boxes.
set(data.handle.edit([1:2 4:5]),...
   {'Style'}, {'edit'},...
   {'Enable'}, {'on'},...
   {'Visible'}, {'on'},...
   {'String'}, {'500';'1';'0';'0'});
set(data.handle.text([1:2 4:5]),...
   {'Visible'}, {'on'},...
   {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset';'Phase (deg)'});
set(data.handle.edit([3 6]),...
   {'Visible'}, {'off'},...
   {'Enable'}, {'on'});
set(data.handle.text([3 6]),...
   {'Visible'}, {'off'});

%%
% Enable the analog output popup and the channel listbox.
set(data.handle.config(1:2), 'Enable', 'on');

data.value.frequency = '500';
data.value.amplitude = '1';
data.value.offset = '0';
data.value.phase = '0';
data.value.cycle = '50';
data.value.width = '0.75';
data.value.seed = '';
data.value.method = 'Linear';
data.value.ttime = '1';
data.value.initfreq = '0';
data.value.ttimefreq = '100';

%% ***********************************************************************  
% Close the figure window.
function localClose(data)

%%
% The object will not exist if no adpators are registered.
if ~isempty(data.ao)
   if isvalid(data.ao) & strcmp(get(data.ao, 'Running'), 'On')
      % Stop the device and delete it.
      stop(data.ao);
   end

   % Delete the object.
   delete(data.ao);
end

%%
% Close the figure window.
delete(data.handle.figure);

%% ***********************************************************************   
function [data,waveData] = localSine(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Sine';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 1/64:1/64:6*pi;
   set(hPlot, 'XData', t, 'YData', sin(t));
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 1.25]);
   
  % Update the edit text boxes and static text boxes.
  v = data.value; 
  set(data.handle.edit([1:2 4:5]),...
     {'Style'}, {'edit'},...
     {'Visible'}, {'on'},...
     {'String'}, {v.frequency;v.amplitude;v.offset;v.phase});
  set(data.handle.text([1:2 4:5]),...
     {'Visible'}, {'on'},...
     {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset';'Phase (deg)'});
  set(data.handle.edit([3 6]),...
      {'Visible'}, {'off'});
  set(data.handle.text([3 6]),...
     {'Visible'}, {'off'});
  
case 2
   % Generate the signal.
   frequency  = str2num(get(data.handle.edit(1), 'String'));
   amplitude  = str2num(get(data.handle.edit(2), 'String'));
   offset     = str2num(get(data.handle.edit(4), 'String'));
   phase      = str2num(get(data.handle.edit(5), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(frequency) | isempty(amplitude) | isempty(offset) | isempty(phase) | (frequency <= 0)
      waveData = -1;
      return
   end   
   
   try
      % Determine if the SampleRate will have to be set to avoid aliasing.
      data = localAliasCheck(data, frequency, sampleRate);
      
      % Create the waveform.
      numPoints = data.SampleRate/frequency;
      t = linspace(0,2*pi,numPoints+1);
      t = t(1:end-1);
      waveData = offset + amplitude*cos(t+((phase*pi)/180));

   catch
      % Stop the device 
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localSinc(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Sinc';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 1/64:1/64:2*pi;
   y = 2*localWaveFormCalc('sinc',2*t);
   t1 = 1/64:1/64:6*pi;
   set(hPlot, 'XData', t1, 'YData', [y y y]);
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 2.25]);
   
  % Update the edit text boxes and static text boxes.
  v = data.value; 
  set(data.handle.edit([1:2 4:5]),...
     {'Style'}, {'edit'},...
     {'Visible'}, {'on'},...
     {'String'}, {v.frequency;v.amplitude;v.offset;v.phase});
  set(data.handle.text([1:2 4:5]),...
     {'Visible'}, {'on'},...
     {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset';'Phase (deg)'});
  set(data.handle.edit([3 6]),...
      {'Visible'}, {'off'});
  set(data.handle.text([3 6]),...
      {'Visible'}, {'off'});
  
case 2
   % Generate the signal.
   frequency  = str2num(get(data.handle.edit(1), 'String'));
   amplitude  = str2num(get(data.handle.edit(2), 'String'));
   offset     = str2num(get(data.handle.edit(4), 'String'));
   phase      = str2num(get(data.handle.edit(5), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(frequency) | isempty(amplitude) | isempty(offset) | isempty(phase) | (frequency <= 0)
      waveData = -1;
      return
   end   
   
   try
      % Determine if the SampleRate will have to be set to avoid aliasing.
      data = localAliasCheck(data, frequency, sampleRate);
      
      % Calculate the waveform.
      numPoints = data.SampleRate/frequency;
      t = linspace(0,2*pi,numPoints+1);
      t = t(1:end-1);
	  waveData = offset + amplitude*localWaveFormCalc('sinc',t+((phase*pi)/180));

   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localSquare(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Square';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 1/100:1/100:6*pi;
   set(hPlot, 'XData', t, 'YData', localWaveFormCalc('square', t, 50));
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 1.25]);
   
   % Update the edit text boxes and static text boxes.
   v = data.value;
   set(data.handle.edit([1 2 4 5]),...
      {'Style'}, {'edit'},...
      {'Visible'}, {'on'},...
      {'String'}, {v.frequency;v.amplitude;v.offset;v.cycle});
   set(data.handle.text([1 2 4 5]),...
      {'Visible'}, {'on'},...
      {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset';'Duty Cycle'});
   set(data.handle.edit([3 6]),...
      {'Visible'}, {'off'});
   set(data.handle.text([3 6]),...
      {'Visible'}, {'off'});
   
case 2
   % Generate the  signal.
   frequency  = str2num(get(data.handle.edit(1), 'String'));
   amplitude  = str2num(get(data.handle.edit(2), 'String'));
   offset     = str2num(get(data.handle.edit(4), 'String'));
   dutycycle  = str2num(get(data.handle.edit(5), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(frequency) | isempty(amplitude) | isempty(offset)...
         | isempty(dutycycle)|(frequency <= 0) | (dutycycle<0) | (dutycycle > 100)
         waveData = -1;
         return
   end      
   
   try
      % Determine if the SampleRate will have to be set to avoid aliasing.
      data = localAliasCheck(data, frequency, sampleRate);
      
      % Calculate the waveform.
      numPoints = sampleRate/frequency;
      t = linspace(0,2*pi,numPoints+1);
      t = t(1:end-1);
      waveData = offset + amplitude*localWaveFormCalc('square',t,dutycycle);
   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localTriangle(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Triangle';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 0:1/64:6*pi;
   set(hPlot, 'XData', t, 'YData', localWaveFormCalc('sawtooth',t,0.5));
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 1.25]);
   
   % Update the edit text boxes and the static text boxes.
   v = data.value;
   set(data.handle.edit([1 2 4]),...
      {'Style'}, {'edit'},...
      {'Visible'}, {'on'},...
      {'String'}, {v.frequency;v.amplitude;v.offset});
   set(data.handle.text([1 2 4]),...
      {'Visible'}, {'on'},...
      {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset'});
   set(data.handle.edit([3 5 6]),...
      {'Visible'}, {'off'});
   set(data.handle.text([3 5 6]),...
      {'Visible'}, {'off'});

case 2
   % Generate the signal.
   frequency  = str2num(get(data.handle.edit(1), 'String'));
   amplitude  = str2num(get(data.handle.edit(2), 'String'));
   offset     = str2num(get(data.handle.edit(4), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(frequency) | isempty(amplitude) | isempty(offset) | (frequency <= 0)
      waveData = -1;
      return
   end   
   
   try
      % Determine if the SampleRate will have to be set to avoid aliasing.
      data = localAliasCheck(data, frequency, sampleRate);
      
      % Calculate the waveform.
      numPoints = sampleRate/frequency;
      t = linspace(0,2*pi,numPoints+1);
      t = t(1:end-1);
      waveData = offset + amplitude*localWaveFormCalc('sawtooth',t,0.5);
   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localSawtooth(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Sawtooth';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 0:1/64:6*pi;
   set(hPlot, 'XData', t, 'YData', localWaveFormCalc('sawtooth',t,0.75));
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 1.25]);
   
   % Update the edit text boxes and the static text boxes.
   v = data.value;
   set(data.handle.edit([1 2 4 5]),...
      {'Style'}, {'edit'},...
      {'Visible'}, {'on'},...
      {'String'}, {v.frequency;v.amplitude;v.offset;v.width});
   set(data.handle.text([1 2 4 5]),...
      {'Visible'}, {'on'},...
      {'String'}, {'Frequency (Hz)';'Amplitude';'DC Offset';'Width'});
   set(data.handle.edit([3 6]),...
      {'Visible'}, {'off'});
   set(data.handle.text([3 6]),...
      {'Visible'}, {'off'});
   
case 2
   % Generate the signal.
   frequency  = str2num(get(data.handle.edit(1), 'String'));
   amplitude  = str2num(get(data.handle.edit(2), 'String'));
   offset     = str2num(get(data.handle.edit(4), 'String'));
   width      = str2num(get(data.handle.edit(5), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(frequency) | isempty(amplitude) | isempty(offset) | isempty(width)...
         | (frequency <= 0) | (width >1) | (width < 0)
      waveData = -1;
      return
   end   
   
   try
      % Determine if the SampleRate will have to be set to avoid aliasing.
      data = localAliasCheck(data, frequency, sampleRate);
      
      % Calculate the waveform.
      numPoints = sampleRate/frequency;
      t = linspace(0,2*pi,numPoints+1);
      t = t(1:end-1);
      waveData = offset + amplitude*localWaveFormCalc('sawtooth',t,width);
   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localRandom(data,varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Random';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 0:99;
   set(hPlot, 'XData', t, 'YData', rand(1,100));
   set(hAxes,...
      'XLim', [0 99],...
      'XTick', [],...
      'YLim', [-.25 1.25]);
   
   % Update the edit text boxes and the static text boxes.
   v = data.value;
   set(data.handle.edit([1 2 4]),...
      {'Style'}, {'edit'},...
      {'Visible'}, {'on'},...
      {'String'}, {v.amplitude;v.offset;v.seed});
   set(data.handle.text([1 2 4]),...
      {'Visible'}, {'on'},...
      {'String'}, {'Amplitude';'Offset';'Seed'});
   set(data.handle.edit([3 5 6]),...
      {'Visible'}, {'off'});
   set(data.handle.text([3 5 6]),...
      {'Visible'}, {'off'});
   
case 2
   % Generate the signal.
   amplitude  = str2num(get(data.handle.edit(1), 'String'));
   offset     = str2num(get(data.handle.edit(2), 'String'));
   seed       = str2num(get(data.handle.edit(4), 'String'));
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(amplitude) | isempty(offset) | (seed < 0)
      waveData = -1;
      return
   end   
   
   % Set the seed.
   if ~isempty(seed)
      rand('seed', seed);
   end
   
   try
      t = linspace(0, 2*pi,sampleRate);
      t = t(1:end-1);
      waveData = offset + amplitude*rand(1,length(t));
   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************   
function [data, waveData] = localChirp(data, varargin)

%%
% Initialize variables.
data.CurrentWaveForm = 'Chirp';
waveData = [];

switch nargin
case 1
   % Update the axes.
   hAxes = data.handle.axes(1);
   hPlot = data.handle.axes(2);
   t = 1/64:1/64:2*pi;
   y = localWaveFormCalc('chirp',t,0,1,1,'Linear',0);
   set(hPlot, 'XData', 1/64:1/64:6*pi, 'YData', [y y y]);
   set(hAxes,...
      'XLim', [0 6*pi],...
      'XTick', [],...
      'YLim', [-1.25 1.25]);
   
   % Update the edit text boxes and the static text boxes.
   v = data.value;
   set(data.handle.edit([1 2 4 5 6 ]),...
      {'Style'}, {'edit'},...
      {'Visible'}, {'on'},...
      {'String'}, {v.method;v.ttime;v.initfreq;v.ttimefreq;v.phase});
   set(data.handle.text([1 2 4 5 6 ]),...
      {'Visible'}, {'on'},...
      {'String'}, {'Method';'Target time (sec)';'Initial Freq (Hz)';'Target Time Freq (Hz)';'Phase (deg)'});
   set(data.handle.edit(3),...
      'Visible', 'off');
   set(data.handle.text(3),...
      'Visible', 'off');
   
   % Create the methods pop-up.
   set(data.handle.edit(1),...
      'Style','popup',...
      'Max', 3,...
      'Value',1,...
      'String', {'Linear';'Quad';'Log'});
   
   switch v.method
   case 'Linear'
      set(data.handle.edit(1), 'Value', 1);
   case 'Quad'
      set(data.handle.edit(1), 'Value', 2);
   case 'Log'
      set(data.handle.edit(1), 'Value', 3);
   end
   
case 2
   % Generate the signal.
   t1         = str2num(get(data.handle.edit(2), 'String'));
   f0         = str2num(get(data.handle.edit(4), 'String'));
   f1         = str2num(get(data.handle.edit(5), 'String'));
   phi        = str2num(get(data.handle.edit(6), 'String'));
   methodval  = get(data.handle.edit(1), 'Value');
   methodstr  = {'Linear';'Quadratic';'Logarithmic'};
   method     = methodstr{methodval,:};
   sampleRate = varargin{1};
   
   % Error checking on waveform values.
   if isempty(t1) | isempty(f0) | isempty(f1) | isempty(phi)
      waveData = -1;
      return
   end   
   
   try
     t = linspace(0,2*pi,sampleRate);
     waveData = localWaveFormCalc('chirp',t,f0,t1,f1,method,phi);
   catch
      % Stop the device.
      stop(data.ao);
      
      % Reset the togglebutton for starting.
      set(data.handle.button(1), 'String', 'Start', 'Value', 0);
      
      % Indicate that an error occurred in the data structure and return.
      data.errflag = 1;
      return;
   end
end

%% ***********************************************************************  
% Determine if aliasing may occur for the define signal.
function data = localAliasCheck(data, frequency, sampleRate)

%%
% Determine if the SampleRate will have to be set to avoid aliasing.
if frequency*10 > sampleRate & ~get(data.handle.config(5), 'Value')
   srinfo = propinfo(data.ao, 'SampleRate');
   maxSR = srinfo.ConstraintValue(2);
   if frequency*10 < maxSR
      sampleRate = frequency*10;
   else
      sampleRate = maxSR;
      % Warn that aliasing may occur for the specified frequency.
      hWarn = findobj(findall(0), 'Tag', 'aliasing');
      if isempty(hWarn)
         hWarn = warndlg('Aliasing may occur for the specified frequency.',...
            'Data Acquisition Warning');
         set(hWarn, 'Tag', 'aliasing');
      else
         figure(hWarn(1));
      end
   end
   data.SampleRate = sampleRate;
end

%% ***********************************************************************  
% Pull up the helpwindow for fcngen.m
function data = localHelpFcnGen(data)

doc('daqfcngen');

%% ***********************************************************************   
% Pull up the helpwindow for the Data Acquisition Toolbox.
function data = localHelpDaq(data)

doc('daq');

%% ***********************************************************************   
% Create the figure window.
function data = localInitFig

%%
% Initialize variables.
waveforms = {'Sine';'Sinc';'Square';'Triangle';'Sawtooth';'Random';'Chirp'};
btnColor=get(0,'DefaultUIControlBackgroundColor');
sampleRate = [];

%%
% Information for all handle graphics objects.m
genInfo.HandleVisibility='off';
genInfo.Interruptible='off';
genInfo.BusyAction='queue';

%%
% Position the GUI in the middle of the screen
screenUnits=get(0,'Units');
set(0,'Units','pixels');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=560;
figHeight=178;
figPos=[(screenSize(3)-figWidth)/2 (screenSize(4)-figHeight)/2  ...
      figWidth                    figHeight];

%%
% Create the figure window.
hFig=figure(genInfo,...                    
   'Color'             ,btnColor                        ,...
   'IntegerHandle'     ,'off'                           ,...
   'DeleteFcn'         ,'daqfcngen(''close'',gcbf)'     ,...
   'MenuBar'           ,'none'                          ,...
   'Name'              ,'An Example Function Generator' ,...
   'Tag'               ,'Function Generator'            ,...
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

%%
% Information for all uicontrols.
uiInfo=genInfo;
uiInfo.BackGroundColor=btnColor;
uiInfo.ForeGroundColor=[0 0 0];

%%
% Create the frames.
framePos = {[8 100 443 70],[115 7 336 90],[457 7 92 163]}; 
for i = 1:3
   uicontrol(uiInfo,...
      'Style'         ,'frame'          ,...
      'Units'         ,'pixels'         ,...
      'Position'      ,framePos{i});
end

%%
% Get adaptor information:
% adaptorStr = list of adaptors for the popup = {'winsound0' 'nidaq1'}.
% ai = analoginput object constructed from adaptorStr{1}.
% names = corresponding channel names to ai.
[adaptorStr, ao, names] = daqgate('privateGetAdaptor', 'analogoutput');

%%
% Create the analog output object popup.
h(1) = uicontrol(uiInfo,...
   'Style'            ,'popup'           ,...
   'Units'            ,'pixels'          ,...
   'Position'         ,[131 145 150 20]  ,...
   'BackGroundColor'  , [1 1 1]          ,...
   'String'           ,adaptorStr           ,...
   'Tag'              ,'ao_objects'      ,...
   'Value'            ,1                 ,...
   'Callback'         ,'daqfcngen(''adaptor'',gcbf)');

%%
% Create the listbox for the analog output channels.
h(2) =uicontrol(uiInfo,...
   'Min'              ,1                ,...
   'Max'              ,3                ,...
   'BackGroundColor'  ,[1 1 1]          ,...
   'String'           ,names            ,...
   'Style'            ,'listbox'        ,...
   'Units'            ,'pixels'         ,...
   'Position'         ,[286 113 150 53] ,...
   'Tag'              ,'ao_channels'    ,...
   'Callback'         ,'daqfcngen(''changeChannel'',gcbf);');

%%
% Create the popupmenu for the different waveforms.
h(3) = uicontrol(uiInfo,...
   'Style'            ,'popupmenu'       ,...
   'BackGroundColor'  , [1 1 1]          ,...
   'Units'            ,'pixels'          ,...
   'Position'         ,[9 75 100 22]   ,...
   'String'           ,waveforms         ,...
   'Tag'              ,'waveforms'       ,...
   'Callback'         ,'daqfcngen(''waveform'',gcbf);');

%%
% Create the SampleRate display.
sampleRate = get(ao, 'SampleRate');
h(4) = uicontrol(uiInfo,...
   'Style', 'edit',...
   'Units', 'pixels',...
   'Enable', 'off',...
   'Position', [131 110 50 20],...
   'HorizontalAlignMent','left',...
   'String', num2str(sampleRate),...
   'Callback', 'daqfcngen(''sampleRate'', gcbf);');

h(5) = uicontrol(uiInfo,...
   'Style', 'CheckBox',...
   'String', 'SampleRate (Hz)',...
   'Units', 'pixels',...
   'Position', [18 110 100 20],...  
   'HorizontalAlignment', 'left',...
   'Value', 0,...
   'Callback', 'daqfcngen(''checkbox'', gcbf);');

%%
% Create the label for selecting an analog output channel.
uicontrol(uiInfo,...
   'Style'                ,'text'           ,...
   'Units'                ,'Pixels'         ,...
   'Position'             ,[18 130 100 34]  ,...
   'Max'                  ,3                ,...
   'HorizontalAlignment'  ,'left'           ,...
   'String', 'Select an analog output channel:');

%%
% Create the edit text boxes.
ypos = [68 42 16];
initVal = [500 1 0];
for i = 1:3
   hedit(i) = uicontrol(uiInfo,...
     'Style'                ,'edit'                         ,...
     'BackGroundColor'      ,[1 1 1]                        ,...
     'Callback'             ,'daqfcngen(''resubmit'', gcbf);'  ,...
     'Enable'               ,'on'                           ,...
     'HorizontalAlignment'  ,'left'                         ,...
     'Max'                  ,1                              ,...
     'Min'                  ,1                              ,...
     'String'               ,num2str(initVal(i))            ,...       
     'Visible'              ,'off'                          ,...
     'Units'                ,'pixels'                       ,...
     'Position'             ,[124 ypos(i) 60 20]);
end

initVal = [0 0 0];
for i = 1:3
   hedit(i+3) = uicontrol(uiInfo,...
     'Style'                ,'edit'                         ,...
     'BackGroundColor'      ,[1 1 1]                        ,...
     'Callback'             ,'daqfcngen(''resubmit'', gcbf);'  ,...
     'Enable'               ,'on'                           ,...
     'HorizontalAlignment'  ,'left'                         ,...
     'Max'                  ,1                              ,...
     'Min'                  ,1                              ,...
     'String'               ,num2str(initVal(i))            ,...       
     'Visible'              ,'off'                          ,...
     'Units'                ,'pixels'                       ,...
     'Position'             ,[279 ypos(i) 60 20]);
end

%%
% Create the static text boxes.
textLabels = {'Frequency (Hz)';'Amplitude';'Methods'};
for i = 1:3
   hText(i) = uicontrol(uiInfo,...
      'Style'                ,'text'         ,...
      'HorizontalAlignMent'  ,'left'         ,...
      'String'               ,textLabels{i}  ,...
      'Visible'              ,'off'          ,...
      'Units'                ,'pixels'       ,...
      'Position'             ,[189 ypos(i) 80 20]);
end

textLabels = {'DC Offset';'Phase (deg)';'Phase (deg)'};
for i = 1:3
   hText(i+3) = uicontrol(uiInfo,...
      'Style'                ,'text'         ,...
      'HorizontalAlignMent'  ,'left'         ,...
      'String'               ,textLabels{i}  ,...
      'Visible'              ,'off'          ,...
      'Units'                ,'pixels'       ,...
      'Position'             ,[344 ypos(i) 104 20]);
end

set(hText([1:2 4:5]), 'Visible', 'On');
set(hedit([1:2 4:5]), 'Visible', 'On');

%%
% Create the axes.
hAxes = axes(genInfo,...
   'Units'                   ,'pixels'        ,...
   'Position'                ,[9 15 100 45]  ,...
   'Box'                     ,'On');

%%
% Plot a sine wave with amplitude one.
t = 0:1/64:6*pi;
hPlot = line('Parent', hAxes,...
   'XData', t,...
   'YData', sin(t),...
   'Color', [0 0 1]);
set(hAxes,...
   'XLim', [0 6*pi],...
   'XTick', [],...
   'YLim', [-1.25 1.25],...
   'YTick', []);

%%
% Create the pushbuttons.
ButtonStr = {'Start','Reset','Close'};
ButtonPos = {125,95,65};
   
for i = 1:3
   callbackStr = ['daqfcngen(''' lower(ButtonStr{i}) ''',gcbf);'];
   hpush(i) = uicontrol(uiInfo,...
      'Style'                ,'pushbutton'         ,...
      'Units'                ,'pixels'             ,...
      'Position'             ,[473 ButtonPos{i} 60 20]         ,...
      'String'               ,ButtonStr{i}         ,...
      'Tag'                  ,lower(ButtonStr{i})  ,...
      'Callback'             ,callbackStr);
end

%%
% Create the menubar.
h1 = uimenu(genInfo,'Label', 'File');
h2 = uimenu(genInfo,'Label', 'Help');
h1(2) = uimenu(h1(1),...
   'Label'     ,'Close Function Generator'  ,...
   'Callback'  ,'daqfcngen(''close'', gcbf);');
h2(2) = uimenu(h2(1),...
   'Label'     ,'Function generator Help'  ,...
   'Callback'  ,'daqfcngen(''helpFcngen'', gcbf);');
h2(3) = uimenu(h2(1),...
   'Label'     ,'Data Acquisition Help'  ,...
   'Callback'  ,'daqfcngen(''helpdaq'',gcbf);');

%%
% Create the data structure.
data.ao = ao;
data.channel = 1;
data.allchannel = [];
data.CurrentWaveForm = 'Sine';
data.handle.figure = hFig;
data.handle.axes = [hAxes hPlot];
data.handle.button = hpush;
data.handle.edit = hedit;
data.handle.text = hText;
data.handle.config = h;
data.SampleRate = sampleRate;
data.State = 0; % (Waiting to) Start.
data.errflag = 0;
data.winsound2 = 0;
data.value.frequency = '500';
data.value.amplitude = '1';
data.value.offset = '0';
data.value.phase = '0';
data.value.cycle = '50';
data.value.width = '0.75';
data.value.seed = '';
data.value.method = 'Linear';
data.value.ttime = '1';
data.value.initfreq = '0';
data.value.ttimefreq = '100';

if ~isempty(data.ao)
   data.allchannel = daqhwinfo(data.ao, 'ChannelIDs');
end   

%%
% Store the data matrix and display figure.
set(hFig,'Visible','on','UserData',data);

%% *************************************************************************
% Calculate the waveform.
function out = localWaveFormCalc(wave, varargin)

%%
% Initialize variables.
out = [];

switch wave
case 'sawtooth'
   % Initialize variables.
   t = varargin{1};
   width = varargin{2};
   
   % Check the given width.
   if (width > 1) | (width < 0),
      error('WIDTH parameter must be between 0 and 1.');
   end
   
   % Calculate the waveform.
   rt = rem(t,2*pi)*(1/2/pi);
   i1 = find( ((rt<=width)&(rt>=0)) | ((rt<width-1)&(rt<0)) );
   i2 = 1:length(t(:));
   i2(i1) = [];
   out = zeros(size(t));
   out(i1) = ( ((t(i1)<0)&(rt(i1)~=0)) + rt(i1) - .5*width)*2;
   if (width ~= 0),
      out(i1) = out(i1)*(1/width);
   end
   out(i2) = ( -(t(i2)<0) - rt(i2) + 1 - .5*(1-width))*2;
   if (width ~= 1),
      out(i2) = out(i2)*(1/(1-width));
   end

case 'sinc'
   % Initialize variables.
   x = varargin{1};
   
   % Cacluate the waveform.
   out=ones(size(x));
   i=find(x);
   out(i)=sin(pi*x(i))./(pi*x(i));
      
case 'square'
   % Initialize variables.
   t = varargin{1};
   duty = varargin{2};
   
   if any(size(duty)~=1),
      error('Duty parameter must be a scalar.')
   end

   tmp = mod(t,2*pi);
   w0 = 2*pi*duty/100;
   nodd = (tmp < w0);
   out = 2*nodd-1;
  
case 'chirp'
   % Initialize variables.
   [t,f0,t1,f1,method,phi] = deal(varargin{:});
   
   p=find(strcmp(method, {'Linear', 'Quadratic', 'Logarithmic'}));
   if p==3,
      % Logarithmic chirp:
      if f1<f0 
         error('Target Time Frequency > Initial Frequency is required for a log-sweep.');
      end
      beta = log10(f1-f0)/t1;
      out = cos(2*pi * ( (10.^(beta.*t)-1)./(beta.*log(10)) + f0.*t + phi/360));
   else
      % Polynomial chirp: p is the polynomial order
      beta = (f1-f0).*(t1.^(-p));
      out = cos(2*pi * ( beta./(1+p).*(t.^(1+p)) + f0.*t + phi/360));
   end
end

%% ***********************************************************************
% Display a warning dialog if the parameter is empty.
function localDispWaveFormEmptyWarning(name)

tagValue = ['wave' name];

hWarn = findobj(findall(0), 'Tag', tagValue);
if isempty(hWarn)
   hWarn = warndlg(['A waveform ' name ' must be specified.'],...
      'Data Acquisition Warning');
   set(hWarn, 'Tag', tagValue);
else
   figure(hWarn(1));
end

%% ***********************************************************************
% Display a warning dialog if the parameter is less than zero.
function localDispWaveFormLessWarning(name)

tagValue = ['wave' name 'less'];

hWarn = findobj(findall(0), 'Tag', tagValue);
if isempty(hWarn)
   hWarn = warndlg(['The ' name ' must be greater than zero.'],...
      'Data Acquisition Warning');
   set(hWarn, 'Tag', tagValue);
else
   figure(hWarn(1));
end

%% ***********************************************************************
% Display a warning dialog if the parameter is outside of valid range.
function localDispWaveFormRangeWarning(name, min, max)

tagValue = ['wave' name 'range'];

hWarn = findobj(findall(0), 'Tag', tagValue);
if isempty(hWarn)
   hWarn = warndlg(['The ' name ' must be range between ' num2str(min) ' and ' num2str(max) '.'],...
      'Data Acquisition Warning');
   set(hWarn, 'Tag', tagValue);
else
   figure(hWarn(1));
end
