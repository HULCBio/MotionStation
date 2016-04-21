function daqdoc5_5
%DAQDOC5_5 Analog input documentation example.
% 
%    DAQDOC5_5 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_5 demonstrates how to:
%      - Configure basic setup properties
%      - Configure a software trigger
%      - Configure a repeating trigger
%      - Use two GETDATA calls to return sample-time pairs for both triggers
%
%    DAQDOC5_5 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:51 $

%1. Create a device object - Create the analog input object AIVoice for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AIVoice = analoginput('winsound');
%AIVoice = analoginput('nidaq',1);
%AIVoice = analoginput('mcc',1);

%2. Add channels - Add one hardware channel to AIVoice.
chan = addchannel(AIVoice,1);
%chan = addchannel(AIVoice,0); % For NI and MCC

%3. Configure property values - Define a one second total acquisition time and configure 
%a software trigger. The source of the trigger is chan, and the trigger executes when a 
%rising voltage level has a value of at least 0.2 volts. Additionally, the trigger is 
%repeated once when the trigger condition is met.
duration = 0.5; % One-half second acquisition for each trigger
set(AIVoice,'SampleRate',44100)
ActualRate = get(AIVoice,'SampleRate');
set(AIVoice,'Timeout',5)
set(AIVoice,'SamplesPerTrigger',ActualRate*duration)
set(AIVoice,'TriggerChannel',chan)
set(AIVoice,'TriggerType','Software')
set(AIVoice,'TriggerCondition','Rising')
set(AIVoice,'TriggerConditionValue',0.2)
set(AIVoice,'TriggerRepeat',1)

%4. Acquire data - Start AIVoice, acquire the specified number of samples, extract all 
%the data from the first trigger as sample-time pairs, and extract all the data from the 
%second trigger as sample-time pairs. Note that you can extract the data acquired from 
%both triggers with the command getdata(AIVoice,44100).
start(AIVoice)
[d1,t1] = getdata(AIVoice);
[d2,t2] = getdata(AIVoice);
%Plot the data for both triggers.
subplot(211), plot(t1,d1), grid on, hold on
axis([t1(1)-0.05 t1(end)+0.05 -0.8 0.8])
xlabel('Time (sec.)'), ylabel('Signal level (Volts)'),
title('Voice Activation First Trigger')
subplot(212), plot(t2,d2), grid on
axis([t2(1)-0.05 t2(end)+0.05 -0.8 0.8])
xlabel('Time (sec.)'), ylabel('Signal level (Volts)')
title('Voice Activation Second Trigger')
%Make sure AIVoice has stopped running before cleaning up the workspace.
waittilstop(AIVoice,2)

%5. Clean up - When you no longer need AIVoice, you should remove it from memory and 
%from the MATLAB workspace.
delete(AIVoice)
clear AIVoice