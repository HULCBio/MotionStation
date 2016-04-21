function daqdoc5_1
%DAQDOC5_1 Analog input documentation example.
% 
%    DAQDOC5_1 is divided into five distinct sections:
%      1. Creating a device object
%      2. Adding channels
%      3. Configuring property values
%      4. Acquiring data
%      5. Cleaning up
%
%    DAQDOC5_1 demonstrates how to:
%      - Configure basic setup properties
%      - Poll the SamplesAcquired property
%      - Use PEEKDATA
%      - Efficiently display previewed data
%
%    DAQDOC5_1 can be used with any supported hardware. 
%    You should feel free to modify this file to suit your specific needs.

%    DD 12-15-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:44:47 $

%1. Create a device object - Create the analog input object AI for a sound card. 
%The available adaptors and hardware IDs are found with daqhwinfo.
AI = analoginput('winsound');
%AI = analoginput('nidaq',1);
%AI = analoginput('mcc',1); 

%2. Add channels - Add one hardware channel to AI.
addchannel(AI,1);
%addchannel(AI,0); % For NI and MCC

%3. Configure property values - Define a 10 second acquisition, set up a plot, and 
%store the plot handle and title handle in the variables P and T, respectively. 
duration = 10; % Ten second acquisition
ActualRate = get(AI,'SampleRate');
set(AI,'SamplesPerTrigger',duration*ActualRate)
figure
set(gcf,'doublebuffer','on') %Reduce plot flicker
P = plot(zeros(1000,1));
T = title([sprintf('Peekdata calls: '), num2str(0)]);
xlabel('Samples'), axis([0 1000 -1 1]), grid on

%4. Acquire data - Start AI and update the display for each 1000 samples acquired 
%by polling SamplesAcquired. The drawnow command forces MATLAB to update the plot. 
%Since peekdata is used, all acquired data may not be displayed.
start(AI)
i = 1;
while AI.SamplesAcquired < AI.SamplesPerTrigger
	while AI.SamplesAcquired < 1000*i
	end
	data = peekdata(AI,1000);
	set(P,'ydata',data);
	set(T,'String',[sprintf('Peekdata calls: '), num2str(i)]);
	drawnow
	i = i + 1;
end
%Make sure AI has stopped running before cleaning up the workspace.
waittilstop(AI,2)

%5. Clean up - When you no longer need AI, you should remove it from memory and 
%from the MATLAB workspace.
delete(AI)
clear AI