function daqdoc6_6
%DAQDOC6_6 Analog output documentation example.
% 
%    DAQDOC6_6 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Outputting data
%      5. Cleaning up
%
%    DAQDOC6_6 demonstrates how to:
%      - Configure basic setup properties
%      - Configure engineering units properties
%      - Repeat the output
%      - Queue data in the engine with PUTDATA
%
%    DAQDOC6_6 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:45:00 $

%1. Create a device object - Create the analog output object AO for a National 
%Instruments board. The installed adaptors and hardware IDs are found with daqhwinfo.
AO = analogoutput('nidaq',1);

%2. Add channels - Add one hardware channel to AO.
chan = addchannel(AO,0);   

%3. Configure property values - Create the data to be queued.
freq = 500;
w = 2*pi*freq;
t = linspace(0,2,20000);
data = 2*sin(w*t)';
%Configure the sampling rate to 5 kHz, configure the trigger to repeat two times, 
%and scale the data to cover the full output range of the D/A converter. Since the 
%peak-to-peak amplitude of the queued data is 4, UnitsRange is set to [-2 2], which 
%scales the output data to 20 volts peak-to-peak.
set(AO,'SampleRate',5000)
set(AO,'RepeatOutput',2)
set(chan,'UnitsRange',[-2 2])
%Queue the data with one call to putdata.
putdata(AO,data) 

%4. Output data - Start AO and wait until all the data is output.
start(AO)
waittilstop(AO,15)

%5. Clean up - When you no longer need AO, you should remove it from memory and 
%from the MATLAB workspace.
delete(AO)
clear AO