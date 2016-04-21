%% Demonstrate the use of triggers.
%    DEMOAI_TRIG illustrates how data can be acquired using an immediate,
%    manual and software trigger.  The various triggering properties are
%    explored relative to each trigger type.  The trigger properties
%    demonstrated include: TriggerType, TriggerRepeat, TriggerDelay,
%    TriggerDelayUnits, TriggerChannel, TriggerCondition and 
%    TriggerConditionValue.
%    
%    See also ANALOGINPUT, ADDCHANNEL, DAQDEVICE/SET, DAQDEVICE/GET, 
%             GETDATA, DAQDEVICE/START, STOP, PROPINFO, DAQHELP.
%
%    MP 11-21-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:16 $

%%
% First find any open DAQ objects and stop them.
openDAQ = daqfind;
for i = 1:length(openDAQ),
  stop(openDAQ(i));
end

%% 
% In this demo, we are going to explore the properties 
% related to triggering and acquire 3000 samples of data 
% using an immediate, manual, and software triggers.

%%
% TRIGGERS.
% A trigger is defined as an event that initiates the logging  
% of data to memory and/or a disk file. The logging status 
% is indicated by the Logging property. When a trigger occurs,
% the Logging property is set to On. The destination for logged 
% data is indicated by the LoggingMode property. You can log  
% data to memory or a disk file. By default, the data is 
% logged to memory. 
% 
% An analog input object can log data using an immediate 
% trigger, a manual trigger, or a software trigger. The trigger 
% type is indicated by the TriggerType property. An immediate
% trigger is the default trigger type. 
% 
% IMMEDIATE TRIGGERS. 
% An immediate trigger begins logging data immediately after 
% the START command is issued.

%%
% First, let's create the analog input object ai and add two 
% channels to it. This will allow the winsound device to run in 
% stereo mode. The analog input object will be configured to 
% acquire 8000 samples per second.
ai = analoginput('winsound');
addchannel(ai, [1 2]);
set(ai, 'SampleRate', 8000);

%%
% The number of data samples that the trigger will acquire 
% is indicated by the SamplesPerTrigger property. The analog 
% input object will be configured to acquire 3000 samples per 
% trigger.
% The ai object is also configured to acquire data immediately.
set(ai, 'SamplesPerTrigger', 3000);
set(ai, 'TriggerType', 'immediate');

%% 
% As soon as the analog input object is started, the trigger  
% will occur. When the trigger executes, the number of samples 
% specified by the SamplesPerTrigger property is acquired for 
% each channel and stored in the data acquisition engine.
start(ai);

%%
% You can retrieve the data from the data acquisition engine 
% with the GETDATA function. 
%
% The size of data will be the number of samples per trigger 
% by the number of channels.
[data,time] = getdata(ai);
size(data)
%

%%
% The data can be plotted against time with the trigger 
% occurring at time = 0. As you can see, it took 0.375 
% seconds to acquire the data. This time is calculated by 
% taking the ratio SamplesPerTrigger/SampleRate.
plot(time,data);
zoom on;
title('Immediate Trigger');
xlabel('Relative time in seconds.');
ylabel('Data in volts');

%%
% REPEATING TRIGGERS.
% You can configure triggers to occur repeated times. Trigger  
% repeats are controlled by the TriggerRepeat property. When  
% the TriggerRepeat property is set to its default value of 0,
% the trigger will occur once when the trigger condition is   
% met. If the TriggerRepeat property is set to a positive  
% integer, then the trigger is repeated the specified number  
% of times when the trigger condition is met. If TriggerRepeat  
% is set to Inf, then the trigger repeats continuously when  
% the trigger condition is met and the data acquisition can  
% be stopped only with the STOP command.
% 
% With an immediate trigger, each trigger will occur   
% immediately after the previous trigger has finished 
% executing.

%%
% Let's configure the analog input object, ai, to acquire 
% 3000 samples with two immediate triggers.
% 
% And start the analog input object.
set(ai, 'TriggerType', 'immediate');
set(ai, 'SamplesPerTrigger', 1500);
set(ai, 'TriggerRepeat', 1);

start(ai);

%%
% You can retrieve the data from the data acquisition engine 
% with the GETDATA function.
% 
% The first command extracts the first 1500 samples from 
% the data acquisition engine.
%
% The second command extracts the second 1500 samples from 
% the data acquisition engine.
[data1,time1] = getdata(ai);

[data2,time2] = getdata(ai);

%%
% You can plot the data against time with the first  
% trigger occuring at time = 0.
plot(time1,data1, 'Color', 'red');
hold on
plot(time2,data2, 'Color', 'blue');
zoom on
title('Immediate Triggers - Using TriggerRepeat=1');
xlabel('Relative time in seconds.');
ylabel('Data in volts');
hold off

%%
% MANUAL TRIGGERS.
% A manual trigger begins logging data after you manually 
% issue the TRIGGER command.  
% 
% Let's configure the analog input object, ai, to acquire 
% 3000 samples at 8000 samples per second with one manual 
% trigger.
%
% And then start the analog input object with the START command.
set(ai, 'SamplesPerTrigger', 3000);
set(ai, 'SampleRate', 8000);
set(ai, 'TriggerType', 'manual');
set(ai, 'TriggerRepeat', 0);

start(ai);

%%
% The data acquisition engine will be running as soon as 
% the START command is issued.
% However, the data samples will not be stored in the data 
% acquisition engine until the TRIGGER command is issued.  
% Therefore, the number of samples available from the data 
% acquisition engine will be zero.
get(ai, 'Running')
get(ai, 'SamplesAvailable')
%

%%
% Now let's execute the manual trigger.
trigger(ai)

%%
% You can retrieve the 3000 data samples stored in the data 
% acquisition engine with the GETDATA command.
% 
% The data can be plotted against time. As you can see, 
% it took 0.375 seconds to acquire the data. This time is 
% calculated by taking the ratio SamplesPerTrigger/SampleRate.
[data,time] = getdata(ai);

plot(time,data);
zoom on;
title('Manual Trigger');
xlabel('Relative time in seconds.');
ylabel('Data in volts');

%%
% TRIGGER DELAYS. 
% Trigger delays allow you to control exactly when data is 
% logged after a trigger executes. You can log data either 
% before a trigger executes or after a trigger executes. 
% Trigger delays are specified with the TriggerDelay property.
% 
% Logging data before a trigger occurs is called pretriggering,  
% while logging data after a trigger occurs is called  
% postriggering. A pretrigger is specified by a negative  
% TriggerDelay property value, while a postrigger is specified 
% with a positive TriggerDelay property value.
% 
% You can delay triggers either in seconds or samples using 
% the TriggerDelayUnits property.

%%
% Let's configure the analog input object to acquire a total  
% of 3000 samples. 1000 samples will be acquired before the 
% manual trigger occurs and 2000 samples will be acquired 
% after the manual trigger occurs.
set(ai, 'TriggerType', 'manual');
set(ai, 'SamplesPerTrigger', 3000);
set(ai, 'TriggerDelay', -1000);
set(ai, 'TriggerDelayUnits', 'samples');

%%
% The analog input object is started and the data acquisition 
% engine will start running.
start(ai);
status = get(ai, 'Running')

%%
% Let's trigger the analog input object now.
trigger(ai);

%%
% You can retrieve the 3000 data samples stored in the data 
% acquisition engine with the GETDATA command.
%
% The data can be plotted against time with the trigger 
% occurring at time = 0. Therefore, the pretriggered data 
% will be plotted with a negative time value and the data 
% acquired after the trigger will be plotted with a positive
% time value.
[data,time] = getdata(ai);

plot(time,data);
zoom on;
title('Immediate Triggers');
xlabel('Relative time in seconds.');
ylabel('Data in volts');

%%
% SOFTWARE TRIGGERS.
% A software trigger begins logging data when a signal  
% satsifying the specified condition is detected on one 
% of the specified channels.
% 
% The channel used as the trigger source is defined by 
% the TriggerChannel property. The condition that must be 
% satisfied for a trigger to occur is specified by the 
% TriggerCondition property. You can set this property 
% to one of the following values:
% 
%   Rising   - The signal must be above the specified value
%              and rising.
%   Falling  - The signal must be below the specified value
%              and falling.
%   Leaving  - The signal must be leaving the specified range
%              of values.
%   Entering - The signal must be entering the specified range
%              of values.
% 
% The specified value or range that the trigger condition must 
% meet is indicated by the TriggerConditionValue property.

%%
% Let's configure the analog input object, ai, to acquire 
% 3000 samples at 8000 samples per second with one software 
% trigger. The trigger will occur when a signal on the first
% channel has a rising edge and passes through 0.013 volts. 
set(ai, 'TriggerType', 'software');
set(ai, 'TriggerRepeat', 0);
set(ai, 'TriggerCondition', 'rising');
set(ai, 'TriggerConditionValue', 0.013);
set(ai, 'TriggerChannel', ai.channel(1));

%%
% To capture one second worth of data before the trigger occurs
% The data acquisition engine will wait for 2 seconds for  
% this condition to be met before stopping.
% 
% Also start the analog input object.
set(ai, 'TriggerDelay', -1);
set(ai, 'TriggerDelayUnits', 'seconds');
set(ai, 'TimeOut', 2);

start(ai)

%%
% You can retrieve the 3000 data samples stored in the data 
% acquisition engine with the GETDATA command. If the trigger
% condition was not met, GETDATA will timeout after two seconds
% and no data will be returned.
% 
% The data is then plotted against time with the trigger 
% occurring at time = 0.
try
   clear data time;
   [data,time] = getdata(ai);
catch
   time = 0; data = 0;
   disp('A timeout occurred.');
end

plot(time,data);
zoom on;
title('Software Trigger');
xlabel('Relative time in seconds.');
ylabel('Data in volts');
%

%%
% Now delete the analog input object.
delete(ai)
