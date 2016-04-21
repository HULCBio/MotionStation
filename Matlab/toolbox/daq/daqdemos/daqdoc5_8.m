function daqdoc5_8
%DAQDOC5_8 Analog input documentation example.
% 
%    DAQDOC5_8 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_8 demonstrates how to:
%      - Configure engineering units properties
%
%    DAQDOC5_8 is constructed to be used with National Instruments boards. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:54 $

%1. Create a device object - Create the analog input object AI for a National 
%Instruments board. The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('nidaq',1);

%2. Add channels - Add one hardware channel to AI.
chan = addchannel(AI,0);

%3. Configure property values - Configure the sampling rate to 200 kHz and define a 
%two second acquisition.
duration = 2;
ActualRate = setverify(AI,'SampleRate',200000);
set(AI,'SamplesPerTrigger',duration*ActualRate)
%Configure the engineering units properties. This example assumes you are using a 
%National Instruments PCI-6024E board or an equivalent hardware device. SensorRange 
%is set to the maximum accelerometer range in volts, and UnitsRange is set to the 
%corresponding range in g's. InputRange is set to the value that most closely 
%encompasses the expected data range of +-200 mV.
set(chan,'SensorRange',[-5 5])
set(chan,'InputRange',[-0.5 0.5])
set(chan,'UnitsRange',[-50 50])
set(chan,'Units','g''s (1g = 9.80 m/s/s)')

%4. Acquire data - Start the acquisition.
start(AI)
%Extract and plot all the acquired data.
data = getdata(AI);
subplot(2,1,1),plot(data)
%Calculate and display the frequency information.
Fs = ActualRate;
blocksize = duration*ActualRate;
[f,mag]= daqdocfft(data,Fs,blocksize);
subplot(2,1,2),plot(f,mag)
%Make sure AI has stopped running before cleaning up the workspace.
waittilstop(AI,2)

%5. Clean up - When you no longer need AI, you should remove it from memory and 
%from the MATLAB workspace.
delete(AI)
clear AI