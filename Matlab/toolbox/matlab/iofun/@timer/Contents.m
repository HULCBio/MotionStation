% MATLAB Timer Object.
%
% Timer Functions and Properties.
%
% Timer object construction.
%   timer         - Construct timer object.
%
% Getting and setting parameters.
%   get           - Get value of timer object property.
%   set           - Set value of timer object property.
%
% General.
%   delete        - Remove timer object from memory.
%   display       - Display method for timer objects.
%   inspect       - Open the inspector and inspect timer object properties.
%   isvalid       - True for valid timer objects.
%   length        - Determine length of timer object array.
%   size          - Determine size of timer object array.
%   timerfind     - Find visible timer objects with specified property
%                   values.
%   timerfindall  - Find all timer objects with specified property values.
%
% Execution.
%   start         - Start timer object running.
%   startat       - Start timer object running at a specified time.
%   stop          - Stop timer object running.
%   waitfor       - Wait for timer object to stop running.
%
% Timer properties.
%   AveragePeriod    - Average number of seconds between TimerFcn executions.
%   BusyMode         - Action taken when TimerFcn executions are in progress.
%   ErrorFcn         - Callback function executed when an error occurs.
%   ExecutionMode    - Mode used to schedule timer events.
%   InstantPeriod    - Elapsed time between the last two TimerFcn executions. 
%   Name             - Descriptive name of the timer object.
%   Period           - Seconds between TimerFcn executions.
%   Running          - Timer object running status.
%   StartDelay       - Delay between START and the first scheduled TimerFcn 
%                      execution.
%   StartFcn         - Callback function executed when timer object starts.
%   StopFcn          - Callback function executed after timer object stops.
%   Tag              - Label for object.
%   TasksExecuted    - Number of TimerFcn executions that have occurred.
%   TasksToExecute   - Number of times to execute the TimerFcn callback.
%   TimerFcn         - Callback function executed when a timer event occurs.
%   Type             - Object type.
%   UserData         - User data for timer object.
%
% See also TIMER.
%

%    CP 3-01-02
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.3.4.1 $  $Date: 2003/04/23 06:20:04 $