function daqtimerplot(obj, event)
%DAQTIMERPLOT Plots the data acquired.
%
%    DAQTIMERPLOT(OBJ, EVENT) plots the data acquired by the data
%    acquisition engine.  This is an example callback function for the
%    TimerFcn property and is used by the demodaq_callback demo.  
%
%    DAQTIMERPLOT can be used with any analog input object.
%
%    Example:
%      ai = analoginput('winsound');
%      addchannel(ai, 1);
%      set(ai, 'SamplesPerTrigger', 40000);
%      set(ai, 'TimerFcn', @daqtimerplot);
%      start(ai);
%
%    See also DEMODAQ_CALLBACK. 
%

%    MP 11-24-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.4.2.5 $  $Date: 2003/08/29 04:45:11 $

if nargin == 0 
   error(['This function may not be called with 0 inputs.\n',...
         'Type ''daqhelp daqtimerplot'' for an example using DAQTIMERPLOT.']);
elseif nargin == 1
   error('Type ''daqhelp daqtimerplot'' for an example using DAQTIMERPLOT.');
end

% Create a figure window if it does not exist.
hFig = findobj('Tag', 'daqtimerplot');
if isempty(hFig)
   
end

% Determine the number of samples to plot.
size = floor((obj.SampleRate)*(obj.TimerPeriod));

% Preview the data and plot it.
data = peekdata(obj, size);
plot(data);
drawnow;

