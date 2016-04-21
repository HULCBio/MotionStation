function daqdoc7_2
%DAQDOC7_2 Digital I/O documentation example.
% 
%    DAQDOC7_2 is divided into four distinct sections:
%      1. Creating a device object
%      2. Adding lines
%      3. Configuring property values
%      4. Cleaning up
%
%    DAQDOC7_2 demonstrates how to:
%      - Generate timer events
%      - Use DAQCALLBACK
%
%    DAQDOC7_2 is constructed to be used with National Instruments boards.
%    You should feel free to modify this file to suit your specific needs.
%
%    See also DAQCALLBACK

%    DD 5-11-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:45:02 $
%

%1. Create a device object - Create the digital I/O object dio for a National 
%Instruments board. The installed adaptors and hardware IDs are found with daqhwinfo.
dio = digitalio('nidaq',1);

%2. Add lines - Add eight input lines from port 0 (line-configurable). 
addline(dio,0:7,'in');

%3. Configure property values - Configure the timer event to call daqaction every 
%five seconds.
set(dio,'TimerFcn',@daqcallback);
set(dio,'TimerPeriod',5.0);
%Start the digital I/O object. You must issue a stop command when you no longer 
%want to generate timer events.
start(dio)
%The pause command ensures that two timer events are generated when you run 
%daqdoc7_2 from the command line.
pause(11)
%4. Clean up - When you no longer need dio, you should remove it from memory and 
%from the MATLAB workspace.
delete(dio)
clear dio
