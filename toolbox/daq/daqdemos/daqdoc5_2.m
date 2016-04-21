function daqdoc5_2
%DAQDOC5_2 Analog input documentation example.
% 
%    DAQDOC5_2 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_2 demonstrates how to:
%      - Configure basic setup properties
%      - Poll the SamplesAcquired property
%      - Use PEEKDATA
%      - Use GETDATA
%      - Efficiently display previewed data
%
%    DAQDOC5_2 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:48 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound');
%AI = analoginput('nidaq',1);
%AI = analoginput('mcc',1);

%2. Add channels - Add one hardware channel to AI.
chan = addchannel(AI,1);
%chan = addchannel(AI,0); % For NI and MCC

%3. Configure property values - Define a 10 second acquisition, set up the plot, 
%and store the plot handle in the variable P. The amount of data to display is 
%given by preview.
duration = 10; % Ten second acquisition
set(AI,'SampleRate',8000)
ActualRate = get(AI,'SampleRate');
set(AI,'SamplesPerTrigger',duration*ActualRate)
preview = duration*ActualRate/100;
subplot(211)
set(gcf,'doublebuffer','on')
P = plot(zeros(preview,1)); grid on
title('Preview Data')
xlabel('Samples')
ylabel('Signal Level (Volts)')

%4. Acquire data - Start AI and update the display using peekdata every time an 
%amount of data specified by preview is stored in the engine by polling 
%SamplesAcquired. The drawnow command forces MATLAB to update the plot. After all 
%data is acquired, it is extracted from the engine. Note that whenever peekdata is 
%used, all acquired data may not be displayed.
start(AI)
while AI.SamplesAcquired < preview
end
while AI.SamplesAcquired < duration*ActualRate
   data = peekdata(AI,preview);
	set(P,'ydata',data)
   drawnow
end
%Extract all the acquired data from the engine, and plot the data.
data = getdata(AI);
subplot(212), plot(data), grid on
title('All Acquired Data')
xlabel('Samples')
ylabel('Signal level (volts)')

%5. Clean up - When you no longer need AI, you should remove it from memory and 
%from the MATLAB workspace.
delete(AI)
clear AI