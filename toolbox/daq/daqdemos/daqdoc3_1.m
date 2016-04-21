function daqdoc3_1
%DAQDOC3_1 Analog input documentation example.
% 
%    DAQDOC3_1 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC3_1 demonstrates how to:
%      - Configure basic setup properties
%      - Use GETDATA
%
%    DAQDOC3_1 can be used with any supported hardware.
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:44 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound'); 
%AI = analoginput('nidaq',1);
%AI = analoginput('mcc',1);

%2. Add channels - Add two channels to AI. 
addchannel(AI,1:2); 
%addchannel(AI,0:1); % For NI and MCC

%3. Configure property values - Configure the sampling rate to 11.025 kHz and 
%define a two second acquisition.
set(AI,'SampleRate',11025)
set(AI,'SamplesPerTrigger',22050)

%4. Acquire data - Start AI and extract all the data from the engine. Before 
%start is issued, you may want to begin inputting data from a microphone or a 
%CD player.
start(AI)
data = getdata(AI);
%Plot the data and label the figure axes.
plot(data)
xlabel('Samples') 
ylabel('Signal (Volts)')

%5. Clean up - When you no longer need AI, you should remove it from memory 
%and from the MATLAB workspace.
delete(AI)
clear AI