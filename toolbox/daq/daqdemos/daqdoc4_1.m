function daqdoc4_1
%DAQDOC4_1 Analog input documentation example.
% 
%    DAQDOC4_1 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC4_1 demonstrates how to:
%      - Configure basic setup properties
%      - Use GETDATA
%      - Perform an FFT on the acquired data
%
%    DAQDOC4_1 is constructed to be used with sound cards. 
%    You should feel free to modify this file to suit your specific needs.
%
%    See also DAQDOCFFT.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:45 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound');

%2. Add channels - Add one channel to AI.
chan = addchannel(AI,1);

%3. Configure property values - Assign values to the basic setup properties, and 
%create the variables blocksize and Fs, which are used for subsequent analysis. 
%The actual sampling rate is retrieved since it may be set by the engine to a 
%value that differs from the specified value.
duration = 1; %1 second acquisition
set(AI,'SampleRate',8000)
ActualRate = get(AI,'SampleRate');
set(AI,'SamplesPerTrigger',duration*ActualRate)
set(AI,'TriggerType','Manual')
blocksize = get(AI,'SamplesPerTrigger');
Fs = ActualRate;

%4. Acquire data - Start AI, issue a manual trigger, and extract all data from 
%the engine. Before trigger is issued, you should begin inputting data from the 
%tuning fork into the sound card.
start(AI)
trigger(AI)
data = getdata(AI);

%5. Clean up - When you no longer need AI, you should remove it from memory and 
%from the MATLAB workspace.
delete(AI)
clear AI

% Perform an FFT on data
[f,mag] = daqdocfft(data,Fs,blocksize);
% Plot data
plot(f,mag)
grid on 
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')
title('Frequency Components of Tuning Fork')
%Find the maximum value
[maxindex] = max(mag);
disp(['Maximum occurred at ', num2str(maxindex), ' Hz'])
