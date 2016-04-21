function daqdoc6_4
%DAQDOC6_4 Analog output documentation example.
% 
%    DAQDOC6_4 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Outputting data
%      5. Cleaning up
%
%    DAQDOC6_4 demonstrates how to:
%      - Configure basic setup properties
%      - Use callback properties and functions
%      - Queue data in the engine with PUTDATA
%
%    DAQDOC6_4 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:58 $

%1. Create a device object - Create the analog output object AO for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AO = analogoutput('winsound');
%AO = analogoutput('nidaq',1);
%AO = analogoutput('mcc',1);

%2. Add channels - Add two channels to AO.
chans = addchannel(AO,1:2);
%chans = addchannel(AO,0:1); % For NI and MCC

%3. Configure property values - Configrue the trigger to repeat four times, specify 
%daqdoc6_4disp as the callback function to execute whenever 8000 samples are 
%output, generate data to be queued, and queue the data with one call to putdata.
set(AO,'SampleRate',8000)
ActualRate = get(AO,'SampleRate');
set(AO,'RepeatOutput',4)
set(AO,'SamplesOutputFcnCount',8000)
freq = get(AO,'SamplesOutputFcnCount');
set(AO,'SamplesOutputFcn',@daqdoc6_4disp)
data = sin(linspace(0,2*pi*500,3*freq))';
putdata(AO,[data data])

%4. Output data - Start AO.
start(AO)

% wait for the acquisition to finish
waittilstop(AO,20)

%5. Clean up - When you no longer need AO, you should remove it from memory and 
%from the MATLAB workspace.
delete(AO)
clear AO

function daqdoc6_4disp(obj, event)
%DAQDOC6_4DISP Analog output documentation example.
% 
%    DAQDOC6_4DISP demonstrates how to construct a callback function.
% 
%    You should feel free to modify this file to suit your specific needs.
%

samp = obj.SamplesOutput;
disp([num2str(samp), ' samples have been output'])
