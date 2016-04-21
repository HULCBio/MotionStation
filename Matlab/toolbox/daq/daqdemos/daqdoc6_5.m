function daqdoc6_5
%DAQDOC6_5 Analog output documentation example.
% 
%    DAQDOC6_5 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Outputting data
%      5. Cleaning up
%
%    DAQDOC6_5 demonstrates how to:
%      - Configure basic setup properties
%      - Use callback properties and functions
%      - Queue data in the engine with PUTDATA
%
%    DAQDOC6_5 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:59 $

%1. Create a device object - Create the analog output object AO for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AO = analogoutput('winsound');
%AO = analogoutput('nidaq',1);
%AO = analogoutput('mcc',1);

%2. Add channels - Add one channel to AO.
chan = addchannel(AO,1);
%chan = addchannel(AO,0); % For NI and MCC

%3. Configure property values - Specify daqdoc6_5disp as the M-file callback function 
%to execute when the start, trigger, and stop events occur, generate data to be 
%queued, and queue the data with one call to putdata.
set(AO,'SampleRate',8000)
ActualRate = get(AO,'SampleRate');
set(AO,'StartFcn',@daqdoc6_5disp)
set(AO,'TriggerFcn',@daqdoc6_5disp)
set(AO,'StopFcn',@daqdoc6_5disp)
data = sin(linspace(0,2*pi*500,ActualRate));
data = [data data data];
time = (length(data)/AO.SampleRate);
putdata(AO,data')

%4. Output data - Start AO.
start(AO)
waittilstop(AO,5) %five second max timeout
%5. Clean up - When you no longer need AO, you should remove it from memory and 
%from the MATLAB workspace.
delete(AO)
clear AO

function daqdoc6_5disp(obj, event)
%DAQDOC6_5DISP Analog output documentation example.
% 
%    DAQDOC6_5DISP demonstrates how to construct a callback function.
% 
%    You should feel free to modify this file to suit your specific needs.

EventType = event.Type;
EventData = event.Data;
EventDataTime = EventData.AbsTime;
EventDataSample = EventData.RelSample;
t = fix(EventDataTime);
disp([EventType,' event occurred at ', sprintf('%d:%d:%d', t(4),t(5),t(6))])