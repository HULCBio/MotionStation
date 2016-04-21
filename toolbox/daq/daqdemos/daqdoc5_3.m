function daqdoc5_3
%DAQDOC5_3 Analog input documentation example.
% 
%    DAQDOC5_3 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_3 demonstrates how to:
%      - Configure basic setup properties
%      - Configure a software trigger
%      - Use GETDATA to return sample-time pairs
%
%    DAQDOC5_3 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:49 $

%1. Create a device object - Create the analog input object AIVoice for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AIVoice = analoginput('winsound');
%AIVoice = analoginput('nidaq',1);
%AIVoice = analoginput('mcc',1);

%2. Add channels - Add one hardware channel to AIVoice.
chan = addchannel(AIVoice,1);
%chan = addchannel(AIVoice,0); % For NI and MCC

%3. Configure property values - Define a two second acquisition and configure a 
%software trigger. The source of the trigger is chan, and the trigger executes when 
%a rising voltage level has a value of at least 0.2 volts.
duration = 2; % two second acquisition
set(AIVoice,'SampleRate',44100)
ActualRate = get(AIVoice,'SampleRate');
set(AIVoice,'SamplesPerTrigger',ActualRate*duration)
set(AIVoice,'TriggerChannel',chan)
set(AIVoice,'TriggerType','Software')
set(AIVoice,'TriggerCondition','Rising')
set(AIVoice,'TriggerConditionValue',0.2)

%4. Acquire data - Start AIVoice, acquire the specified number of samples, and extract 
%the first 1000 samples from the engine as sample-time pairs. Display the number of 
%samples remaining in the engine.
start(AIVoice)
[data,time] = getdata(AIVoice,1000);
remsamp = num2str(AIVoice.SamplesAvailable);
disp(['Number of samples remaining in engine: ', remsamp])
%Plot all extracted data.
plot(time,data)
drawnow
xlabel('Time (sec.)')
ylabel('Signal Level (Volts)')
grid on
%Make sure AIVoice has stopped running before cleaning up the workspace.
waittilstop(AIVoice,2)
%5. Clean up - When you no longer need AIVoice, you should remove it from memory and 
%from the MATLAB workspace.
delete(AIVoice)
clear AIVoice