%% Demonstrate the use of triggers.
%    DEMOAO_TRIG illustrates how data can be output using an immediate and
%    manual trigger.  The various triggering properties are explored 
%    relative to each trigger type.  The trigger properties demonstrated
%    include: TriggerType and RepeatOutput.
%    
%    See also ANALOGOUTPUT, ADDCHANNEL, DAQDEVICE/SET, DAQDEVICE/GET,
%             PUTDATA, DAQDEVICE/START, STOP, PROPINFO, DAQHELP.
%
%    MP 11-21-98 
%    Copyright 1998-2003 The MathWorks, Inc. 
%    $Revision: 1.6.2.5 $   $Date: 2003/08/29 04:45:19 $

%%
% Find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% TRIGGERS.
% An analog output trigger is defined as an event that  
% initiates the output of data. 
% 
% An analog output object can output data using an immediate 
% trigger or a manual trigger. The trigger type is indicated 
% by the TriggerType property. An immediate trigger is the 
% default trigger type. 
% 
% In this demo, we are going to explore the properties 
% related to triggering, and output data using an immediate 
% and manual trigger.

%%
% IMMEDIATE TRIGGERS. 
% An immediate trigger automatically occurs just after 
% the START command is issued.
% 
% To demonstrate let's create the analog output object ao and add
% two channels to it. This will allow the winsound device to 
% run in stereo mode. The analog output object will be 
% configured to output 8000 samples per second.
% 
% Note: The ao object is configured to output data immediately.
ao = analogoutput('winsound');
addchannel(ao, [1 2]);
set(ao, 'SampleRate', 8000);
set(ao, 'TriggerType', 'Immediate');

%%
% Now Let's define the data to output, which is nothing more than
% a sine wave with a frequency of 500 Hz.
y = sin(500*(0:(2*pi/8000):2*pi))';

%%
% OUTPUTTING DATA. 
% Outputting data involves functions that queue the data 
% in the data acquisition engine and functions that execute
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
putdata(ao, [y y]);

%%
% As soon as the analog output object is started, the trigger 
% will occur. When the trigger executes, the data queued in 
% the data acquisition engine will be output to the sound card.
% 8000 samples are being output at 8000 samples per second. 
%
% It should take approximately one second to output the data.
start(ao); tic, while strcmp(ao.Running, 'On') end; toc
%

%%
% REPEATING OUTPUT.  
% You can configure the analog output object to output the  
% queued data repeatedly with the RepeatOutput property.  
% If RepeatOutput is greater than 0, then all data queued 
% before the START command is issued will be requeued the 
% specified number of times.
%
% Let's configure the analog output object, ao, to output  
% the queued data three times.
set(ao, 'RepeatOutput', 2);
putdata(ao, [y y]);

%%
% Once the analog output object is started. It should take three  
% seconds to output the data.
start(ao); tic, while strcmp(ao.Running, 'On') end; toc

%%
% MANUAL TRIGGERS. 
% A manual trigger begins outputting data after you manually 
% issue the TRIGGER command. 
% 
% Let's configure the analog output object, ao, to output 
% data at 8000 samples per second with one manual trigger.
set(ao, 'SampleRate', 8000);
set(ao, 'TriggerType', 'manual');
set(ao, 'RepeatOutput', 0);
putdata(ao, [y y]);

%%
% The analog output object is started with the START command.
%
% The data acquisition engine will be running as soon as  
% the START command is issued.
%
% However, the data samples will not be output to the sound  
% card until the TRIGGER command is issued. Therefore, the 
% number of samples output from the data acquisition engine
% will be zero.
start(ao);
get(ao, 'Running')
get(ao, 'SamplesOutput')
%


%%
% Let's execute the manual trigger and the data will be 
% output to the sound card.
trigger(ao);

%%
% Finally, delete the analog output object.
delete(ao)

