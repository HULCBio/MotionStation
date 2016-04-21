function daqdoc5_6
%DAQDOC5_6 Analog input documentation example.
% 
%    DAQDOC5_6 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_6 demonstrates how to:
%      - Configure a repeating trigger
%      - Use callback properties and functions
%
%    DAQDOC5_6 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.
%
%    See also DAQCALLBACK.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:52 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound');
%AI = analoginput('nidaq',1);
%AI = analoginput('mcc',1);

%2. Add channels - Add one hardware channel to AI.
chan = addchannel(AI,1);

%chan = addchannel(AI,0); % For NI and MCC

%3. Configure property values - Repeat the trigger three times, find the time for 
%the acquisition to complete, and define daqcallback as the M-file to execute when 
%a trigger, run-time error, or stop event occurs.
set(AI,'TriggerRepeat',3)
time = (AI.SamplesPerTrig/AI.SampleRate)*(AI.TriggerRepeat+1);
set(AI,'TriggerFcn',@daqcallback)
set(AI,'RuntimeErrorFcn',@daqcallback)
set(AI,'StopFcn',@daqcallback)

%4. Acquire data - Start AI and wait for it to stop running. The waittilstop 
%function blocks the MATLAB command line, and waits for AI to stop running.
start(AI)
waittilstop(AI,time)

%5. Clean up - When you no longer need AI, you should remove it from memory and 
%from the MATLAB workspace.
delete(AI)
clear AI