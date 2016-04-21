%% Introduction to data acquisition callback functions.
%    DEMODAQ_CALLBACK illustrates how tasks can be performed based on the 
%    event that occurred.  
%
%    This demo gives examples on creating a callback function for
%    displaying event information to the MATLAB command window and a
%    callback function for plotting the data as it is acquired.
%
%    See also DAQHELP, DAQCALLBACK, DAQTIMERPLOT.
%
%    MP 11-24-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.2.2.5 $  $Date: 2003/08/29 04:45:20 $
%

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% EVENTS.
% In general, data acquisition tasks are based on events. An 
% event occurs at a specific time after a condition is met. 
% The event types supported by the Data Acquisition Toolbox 
% include: 
%   errors
%   triggers
%   start 
%   stop 

%%
% CALLBACK FUNCTIONS.
% When an event occurs, you can execute a related function 
% known as a callback function. A callback function is a 
% valid MATLAB M-file that can perform essentially any task 
% during your data acquisition session such as:
%   processing data
%   displaying data
%   displaying a message

%%
% A callback function is associated with an event by setting 
% one of the callback properties to the name of the callback 
% function. The callback properties are listed below. 
% 
%   ANALOG INPUT AND ANLAOG OUTPUT CALLBACK PROPERTIES:
% 
%   RuntimeErrorFcn       - Executes when a run-time error occurs.
%   StartFcn              - Executes just prior to the device  
%                           and engine start.
%   StopFcn               - Executes just before the device and 
%                           engine stop.
%   TimerFcn              - Executes when the time specified by  
%                           TimerPeriod occurs.
%   TriggerFcn            - Executes when a trigger occurs.
% 
%   ANALOG INPUT CALLBACK PROPERTIES:
%
%   DataMissedFcn         - Executes when the engine misses data.
%   SamplesAcquiredFcn    - Executes when the number of samples 
%                           specified by SamplesAcquiredFcnCount
%                           is acquired.
% 
%   ANLAOG OUTPUT CALLBACK PROPERTIES:
% 
%   SamplesOutputFcn      - Executes when the number of samples 
%                           specified by SamplesOutputFcnCount 
%                           is output.
% 
%   DIGITAL I/O CALLBACK PROPERITEIS: 
%
%   TimerFcn              - Executes when the time specified by 
%                           TimerPeriod passes.

%%
% The callback function must have at least two input arguments.    
% The first input argument is the object that caused the    
% event to occur. The second input argument is a structure 
% containing information regarding the event that occurred.
% 
% In the first example, let's create an analog input object  
% that displays the type of the event and the time the event  
% occurred to the MATLAB command window.
% 
% To begin, let's create an analog input object associated   
% with the winsound device and containing one channel. The  
% analog input object will be configured to acquire 8000 
% samples per second.
ai = analoginput('winsound');
addchannel(ai, 1);
set(ai, 'SampleRate', 8000);

%%
% The analog input object will trigger five times immediately  
% upon start. Each trigger will acquire 8000 samples.
set(ai, 'TriggerType', 'immediate');
set(ai, 'SamplesPerTrigger', 8000);
set(ai, 'TriggerRepeat', 4);

%%
% Let's create the callback function M-file, daqcallback.m, which  
% displays the event and time of the event to the MATLAB  
% command window.
type daqcallback

%%
% The analog input object is configured to display the start, 
% trigger, and stop events to the MATLAB Command Window.
set(ai, 'StartFcn', @daqcallback);
set(ai, 'StopFcn', @daqcallback);
set(ai, 'TriggerFcn', @daqcallback);

%%
% The analog input object is then started.
start(ai)
pause(6);

%%
% In the second example, let's create an analog input object
% that plots data as it is being acquired.
% 
% Let's configure the analog input object, ai, to collect 
% data for ten seconds immediately upon start.  
set(ai, 'TriggerType', 'immediate');
set(ai, 'SamplesPerTrigger', 80000);
set(ai, 'TriggerRepeat', 0);

%%
% Let's create the callback function M-file, daqtimerplot.m,  
% which plots the data as it is being acquired.
type daqtimerplot

%%
% Finally, let's configure the analog input object to plot 
% the data every 0.1 seconds.
set(ai, 'TimerPeriod', 0.1);
set(ai, 'TimerFcn', @daqtimerplot);
set(ai, {'StartFcn', 'StopFcn', 'TriggerFcn'}, {'', '', ''});

%%
shh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
% The ShowHiddenHandles code above is for Plot purpose
% and is not required for Data Acquisition.

% The analog input object is started.
start(ai)

%%
% It is possible to pass additional input arguments to your  
% callback function. For example, if the function was called  
% mycallback.m and you wanted to pass the arguments, range1 and  
% range2 to the function, the callback property would be defined 
% as follows:
% 
% >> set(ai, 'TriggerFcn', {@mycallback, 'range1', 'range2'})
% 
% And the callback function would have the following function
% line:
% 
%  function mycallback(obj, event, range1, range2)

%%
% Lastly, delete the analog input object.
set(0,'ShowHiddenHandles',shh);  %<- Only needed for plotting purposes
if strcmp(lower(get(ai, 'Running')), 'on')
   stop(ai);
end
delete(ai);

