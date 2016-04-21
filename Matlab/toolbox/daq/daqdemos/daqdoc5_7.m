function daqdoc5_7
%DAQDOC5_7 Analog input documentation example.
% 
%    DAQDOC5_7 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_7 demonstrates how to:
%      - Configure basic setup properties
%      - Use callback properties and functions
%      - Use the TimerFcn and TimerPeriod properties to display data
%
%    DAQDOC5_7 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:44:53 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The installed adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound');
%AI = analoginput('nidaq',1);
%AI = analoginput('mcc',1);

%2. Add channels - Add one hardware channel to AI.
chan = addchannel(AI,1);

%chan = addchannel(AI,0); % For NI and MCC

%3. Configure property values - Define a ten second acquisition and execute the 
%M-file daqdoc5_7plot every 0.5 seconds. Note that the variables bsize, P, 
%and T are passed to the callback function.
duration = 10; % Ten second duration
set(AI,'SampleRate',22050)
ActualRate = get(AI,'SampleRate');
set(AI,'SamplesPerTrigger',duration*ActualRate)
set(AI,'TimerPeriod',0.5)
bsize = (AI.SampleRate)*(AI.TimerPeriod);
figure
P = plot(zeros(bsize,1));
T = title(['Number of callback function calls: ', num2str(0)]);
xlabel('Samples'), ylabel('Signal (Volts)')
grid on
set(gcf,'doublebuffer','on')
set(AI,'TimerFcn',{@daqdoc5_7plot,bsize,P,T})

%4. Acquire data - Start AI. The drawnow command in daqdoc5_7plot forces 
%MATLAB to update the display. The waittilstop function blocks the 
%MATLAB command line, and waits for AI to stop running.
start(AI)
waittilstop(AI,duration)

%5. Clean up - When you no longer need AI, you should remove it from 
%memory and from the MATLAB workspace.
delete(AI)
clear AI

function daqdoc5_7plot(obj, event, blocksize, plothandle, titlehandle)
%DAQDOC5_7PLOT Analog input documentation example.
% 
%    DAQDOC5_7PLOT demonstrates how to construct a callback function that accepts
%    optional variables.
%
%    You should feel free to modify this file to suit your specific needs.

persistent index
if isempty(index)
   index = 0;
end
index = index + 1;
if ~ishandle(titlehandle)
	title(['Number of callback function calls:', num2str(index)])
   data = getdata(obj, blocksize);	
else
   set(titlehandle, 'String',['Number of callback function calls: ', num2str(index)])
end
data = getdata(obj, blocksize);
size(data);
set(plothandle, 'ydata', data)
drawnow