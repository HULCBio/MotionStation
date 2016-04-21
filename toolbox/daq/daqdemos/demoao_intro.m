%% Introduction to analog output objects.
%    DEMOAO_INTRO illustrates a basic data acquisition session using
%    an analog output object.  This is demonstrated by configuring
%    analog output properties, adding a channel to the analog output 
%    object and outputting data to a soundcard.
% 
%    See also ANALOGOUTPUT, ADDCHANNEL, PUTDATA, DAQDEVICE/SET,
%             DAQDEVICE/START, DAQHELP, PROPINFO.
%
%    MP 11-21-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:18 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this example, you will output data to the sound card 
% on your computer. To get started, you first need to  
% verify that your environment is set up so that you can 
% send data to your sound card. If you are unsure about this, 
% refer to Appendix A of the Data Acquisition Toolbox 
% User's Guide. 
% 
% In this demostration, a sine wave with two different frequencies 
% will be output to the sound card.

%%
% To begin, let's create an analog output object 
% associated with the winsound device. Two channels
% will be added to the analog output object, ao.  
% This will allow the winsound device to run in stereo
% mode.
ao = analogoutput('winsound');
addchannel(ao, [1 2]);

%%
% Let's configure the analog output object to output 
% the data at 8000 Hz.
set(ao, 'SampleRate', 8000);

%%
% Now, let's create the data to output to the sound card  
% - a sine wave at two different frequencies.
t = linspace(0,2*pi,16000);
y = sin(500*t);
y1 = sin(800*t);

%%
% OUTPUTTING DATA.
% Outputting data involves functions that queue the data 
% in the data acquisition engine, and functions that execute
% the analog output object.
% 
% QUEUING DATA.
% For data to be output, you must first queue it in the 
% data acquisition engine with the PUTDATA command.
% 
% putdata(ao, data);
% 
% data is an m-by-n matrix where m is the number of samples 
% to be output and n is the number of output channels.
putdata(ao, [y' y']);
putdata(ao, [y1' y1']);

%%
% STARTING THE OUTPUT.
% The analog output object and the data acquisition engine  
% are started with the START command. Starting the output 
% object means that the hardware device and the data 
% acquisition engine are both running. Running does not 
% necessarily mean that the data is being output. For data 
% to be output, a trigger must occur.
% 
% Let's configure the analog output object to trigger 
% immediately after a START command is issued.
set(ao, 'TriggerType', 'Immediate');

%%
% The analog output object is started.
start(ao);

%%
% You can repeatedly output the queued data by using the 
% RepeatOutput property. If RepeatOutput is greater than 
% 0, then all data queued before START is issued will be 
% repeated the specified number of times.
% 
% Let's configure the analog output object to send the   
% data to the sound card two times (or repeated once).
set(ao, 'RepeatOutput', 1);
putdata(ao, [y' y']);
putdata(ao, [y1' y1']);

%%
% The analog output object is started.
start(ao);

%%
% This completes the introduction to analog output objects. 
% Since the analog output object is no longer needed, you 
% should delete it with the DELETE command to free memory 
% and other physical resources.
delete(ao);

