function daqdoc6_2
%DAQDOC6_2 Analog output documentation example.
% 
%    DAQDOC6_2 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Outputting data
%      5. Cleaning up
%
%    DAQDOC6_2 demonstrates how to:
%      - Configure basic setup properties
%      - Queue data in the engine with PUTDATA
%
%    DAQDOC6_2 is constructed to be used with National Instruments boards. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:56 $

%1. Create a device object - Create the analog output object AO for a National 
%Instruments board. The installed adaptors and hardware IDs are found with daqhwinfo.
AO = analogoutput('nidaq',1);

%2. Add channels - Add one channel to AO. 
chan = addchannel(AO,0);

%3. Configure property values - Define an output time of four seconds, assign values 
%to the basic setup properties, generate data to be queued, and queue the data with 
%one call to putdata.
duration = 4;
set(AO,'SampleRate',10000)
set(AO,'TriggerType','Manual')
ActualRate = get(AO,'SampleRate');
len = ActualRate*duration;
data = sin(linspace(0,2*pi*500,len))';
putdata(AO,data)

%4. Output data - Start AO, issue a manual trigger, and wait for the device object
%to stop running.
start(AO)
trigger(AO)
waittilstop(AO,5)

%5. Clean up - When you no longer need AO, you should remove it from memory and from 
%the MATLAB workspace.
delete(AO)
clear AO