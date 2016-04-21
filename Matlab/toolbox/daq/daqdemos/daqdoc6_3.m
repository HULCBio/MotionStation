function daqdoc6_3
%DAQDOC6_3 Analog output documentation example.
% 
%    DAQDOC6_3 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Outputting data
%      5. Cleaning up
%
%    DAQDOC6_3 demonstrates how to:
%      - Configure basic setup properties
%      - Repeat the output
%      - Queue data in the engine multiple times with PUTDATA
%
%    DAQDOC6_3 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:57 $

%1. Create a device object - Create the analog output object AO for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AO = analogoutput('winsound');
%AO = analogoutput('nidaq',1);
%AO = analogoutput('mcc',1);

%2. Add channels - Add one channel to AO. 
chan = addchannel(AO,1);

%chans = addchannel(AO,0); % For NI and MCC

%3. Configure property values - Define an output time of one second, assign values 
%to the basic setup properties, generate data to be queued, and issue two putdata 
%calls. Since the queued data is repeated four times and two putdata calls are 
%issued, a total of 10 seconds of data is output.
duration = 1;
set(AO,'SampleRate',8000)
ActualRate = get(AO,'SampleRate');
len = ActualRate*duration;
set(AO,'RepeatOutput',4)
data = sin(linspace(0,2*pi*500,len))';
putdata(AO,data)
putdata(AO,data)

%4. Output data - Start AO and wait for the device object to stop running.
start(AO)
waittilstop(AO,11)

%5. Clean up - When you no longer need AO, you should remove it from memory and 
%from the MATLAB workspace.
delete(AO)
clear AO