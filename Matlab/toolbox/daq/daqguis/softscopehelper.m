function varargout = softscopehelper(obj, info, triggerPanel)
%SOFTSCOPEHELPER Helper function used by Data Acquisition Toolbox oscilloscope.
%
%   SOFTSCOPEHELPER helper function used by the Data Acquisition Toolbox
%   softscope. SOFTSCOPEHELPER is used to configure the analoginput
%   object that is being controlled by softscope.
%
%   This function should not be called directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 10-03-01
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.5.2.4 $  $Date: 2003/10/15 18:34:08 $

switch (nargin)
case 2
    % User added or removed hardware channels. Update the samplesAcquiredFcn
    % callback value to point to the new channels.
    localUpdateDataChannels(obj, info);    
    return;
end

% Stop the object before configuring.
set(obj, 'StopFcn', '');
stop(obj);

% Configure SamplesPerTrigger.
samplesPerTrigger = info.getSamplesPerTrigger;
switch samplesPerTrigger
case -1
    samplesPerTrigger = inf;
case -2
    samplesPerTrigger = get(obj, 'SampleRate')*info.getTimeInterval;
end
set(obj, 'SamplesPerTrigger', samplesPerTrigger);

% Define SamplesAcquiredFcnCount. It uses BufferingConfig to determine
% the amount of data that is streamed in at a time. 
buffer = get(obj, 'BufferingConfig');

numChannels = length(get(obj, 'Channel'));
if (numChannels >= 3)
    set(obj, 'BufferingConfig', [buffer(1)*numChannels*4 buffer(2)*4]);
end

totalAmtOfData = get(obj, 'SampleRate');
displayHalfValue = totalAmtOfData*info.getTimeInterval/2;

switch (info.getTypeOfTrigger)
case 'Continuous'
    if (totalAmtOfData/buffer(1) < 20)
        set(obj, 'SamplesAcquiredFcnCount', buffer(1));
    else
        while (totalAmtOfData/displayHalfValue) > 20
            displayHalfValue = displayHalfValue*2;
        end
        set(obj, 'SamplesAcquiredFcnCount', displayHalfValue);
    end
case {'One Shot', 'Sequence'}
    if (buffer(1) > samplesPerTrigger)    
        set(obj, 'SamplesAcquiredFcnCount', samplesPerTrigger);
    elseif (totalAmtOfData/buffer(1) < 20)
        set(obj, 'SamplesAcquiredFcnCount', buffer(1));
    else
        while (totalAmtOfData/displayHalfValue) > 20
            displayHalfValue = displayHalfValue*2;
        end
        set(obj, 'SamplesAcquiredFcnCount', displayHalfValue);
    end
end

% Configure TriggerType.
triggerType = info.getTriggerType;

% If TriggerType is software - configure Trigger properties.
if strcmp(triggerType, 'Software')
    % Software trigger type must be configured before TriggerCondition.
    set(obj, 'TriggerType', triggerType);
    set(obj, 'TriggerCondition', info.getTriggerCondition);
    set(obj, 'TriggerConditionValue', info.getTriggerConditionValue);
    triggerChannel = daqfind(obj, 'HwChannel', info.getTriggerChannelID);
    set(obj, 'TriggerChannel', triggerChannel{1});
    
    % Configure pretrigger.
    set(obj, 'TriggerDelayUnits', 'seconds');
    set(obj, 'TriggerDelay', -info.getTriggerDelay);
else
    % TriggerDelay cannot be negative for immediate trigger types.
    set(obj, 'TriggerDelay', 0);
    set(obj, 'TriggerType', triggerType);
end


% Configure TriggerRepeat.
triggerRepeat = info.getTriggerRepeat;
switch triggerRepeat 
case -1
    set(obj, 'TriggerRepeat', inf);
otherwise
    set(obj, 'TriggerRepeat', triggerRepeat);
end

% Configure the object's StopFcn and start the object.
switch (info.getAction)
case 'trigger'
    % One-shot data independent.
    set(obj, 'StopFcn', {@localRestartOnStop, triggerPanel})
    start(obj);
    trigger(obj);
case 'startOneShot'
    % One-shot data dependent.
    set(obj, 'StopFcn', {@localGetDataOnStop, triggerPanel})
    start(obj);
case 'start'
    % Continuous and sequence mode.
    set(obj, 'StopFcn', {@localStop, triggerPanel})
    start(obj);
end

% ---------------------------------------------------------------------
% Callback for the one-shot data independent trigger. Any data left in
% the buffer needs to be retrieved and sent to the oscilloscope. Since
% the object is in manual mode, the object is started and waits for the
% next trigger.
function localRestartOnStop(obj, event, triggerPanel)

if ~isvalid(obj)
    triggerPanel.enableAllComponentsCallback;
    return;
end

% Get data left in the buffer and plot the data.
if (obj.samplesAvailable > 0)
    data = getdata(obj, obj.SamplesAvailable);
    data(find(isnan(data(:,1))),:) = [];
    children = obj.UserData;
    for i=1:length(children)
        children(i).plot(data(:,i));
    end    
end

set(obj, 'BufferingMode', 'auto');

% Enable the triggerPanel controls.
triggerPanel.enableAllComponentsCallback;

start(obj);

% ---------------------------------------------------------------------
% Callback for the one-shot data dependent trigger. Any data left in the
% buffer needs to be retrieved and sent to the oscilloscope. Since the
% object has a software trigger, the object does not need to be restarted.
% It will restart when the user hits the Trigger button again.
function localGetDataOnStop(obj, event, triggerPanel)

if ~isvalid(obj)
    triggerPanel.enableAllComponentsCallback;
    return;
end

% Get data left in the buffer and plot the data.
if (obj.samplesAvailable > 0)
    data = getdata(obj, obj.SamplesAvailable);
    data(find(isnan(data(:,1))),:) = [];
    children = obj.UserData;
    for i=1:length(children)
        children(i).plot(data(:,i));
    end    
end

set(obj, 'BufferingMode', 'auto');

% Enable the triggerPanel controls.
triggerPanel.enableAllComponentsCallback;

% ---------------------------------------------------------------------
% Callback for a continuous or sequence trigger. Enable the oscilloscope
% components so that the user can define the next trigger.
function localStop(obj, event, triggerPanel)

set(obj, 'BufferingMode', 'auto');

% Enable the triggerPanel controls.
triggerPanel.enableAllComponentsCallback;


% ---------------------------------------------------------------------
% User added or removed a hardware channel. Those channels need to be added
% to the SamplesAcquiredFcn callback so that the data that is acquired is
% sent to the correct oscilloscope channel. UserData is defined so that
% the data can be sent to the appropriate channels on a stop.
function localUpdateDataChannels(obj, datachannels)

set(obj, 'SamplesAcquiredFcn', {@plotdata, [datachannels{:}]});
set(obj, 'UserData', [datachannels{:}]);

% ---------------------------------------------------------------------
% SamplesAcquiredFcn callback. Gets the data from the analoginput object
% and sends it to the correct oscilloscope channel.
function plotdata(ai, event, children) 

try
	[data, time] = getdata(ai, ai.SamplesAcquiredFcnCount);
	index = find(isnan(data(:,1)));
	
	if isempty(index)
        for i=1:length(children)
            children(i).plot(data(:,children(i).getChannelIndex), time(1));
        end
	else
        for i=1:length(children)
            children(i).plot(data(1:index-1,  children(i).getChannelIndex), time(1));
            children(i).plot(data(index+1:end,children(i).getChannelIndex), time(index+1));
        end
	end
catch
    if (isvalid(ai))
        if strcmp(ai.Running, 'on')
            stop(ai);
            warndlg(lasterr, 'Acquisition Error'); 
        end
    end
end











