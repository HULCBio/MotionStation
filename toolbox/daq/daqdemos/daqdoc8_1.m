function daqdoc8_1
%DAQDOC8_1 Analog input documentation example.
% 
%    DAQDOC8_1 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC8_1 demonstrates how to:
%      - Configure basic setup properties
%      - Configure logging properties
%      - Use DAQREAD to read sample-time pairs from a log file
%
%    DAQDOC8_1 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.3.2.5 $  $Date: 2003/08/29 04:45:03 $

%1. Create a device object - Create the analog input object ai for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
ai = analoginput('winsound');
%ai = analoginput('nidaq',1);
%ai = analoginput('mcc',1);

%2. Add channels - Add two hardware channels to ai. 
ch = addchannel(ai,1:2);
%ch = addchannel(ai,0:1); % For NI and MCC

%3. Configure property values - Define a two second acquisition for each trigger, set 
%the trigger to repeat three times, and log information to the file file00.daq.
duration = 2; % Two seconds of data for each trigger
set(ai,'SampleRate',8000)
ActualRate = get(ai,'SampleRate');
set(ai,'SamplesPerTrigger',duration*ActualRate)
set(ai,'TriggerRepeat',3)
set(ai,'LogFileName','file00.daq')
set(ai,'LoggingMode','Disk&Memory')

%4. Acquire data - Start ai, wait for ai to stop running, and extract all the data 
%stored in the log file as sample-time pairs.
start(ai)
waittilstop(ai,10)
[data,time] = daqread('file00.daq');
%Plot the data and label the figure axes.
subplot(211), plot(data)
title('Logging and Retrieving Data')
xlabel('Samples'), ylabel('Signal (Volts)')
subplot(212), plot(time,data)
xlabel('Time (seconds)'), ylabel('Signal (Volts)')
%Make sure ai has stopped running before cleaning up the workspace.
waittilstop(ai,2)

%5. Clean up - When you no longer need ai, you should remove it from memory and 
%from the MATLAB workspace.
delete(ai)
clear ai