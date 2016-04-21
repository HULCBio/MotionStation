function wait(obj)
%WAIT Wait until the timer stops running.
%
%    WAIT(OBJ) blocks the MATLAB command line and waits until the
%    timer, represented by the timer object OBJ, stops running. 
%    When a timer stops running, the value of the timer object's
%    Running property changes from 'On' to 'Off'.
%
%    If OBJ is an array of timer objects, WAIT blocks the MATLAB
%    command line until all the timers have stopped running.
%
%    If the timer is not running, WAIT returns immediately.
%
%    See also TIMER/START, TIMER/STOP.
%

%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.3 $  $Date: 2002/03/04 20:09:02 $

if ~all(isvalid(obj))
    error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
end

len = length(obj);

% foreach object, check end-times for naturally never-ending timers
for lcv = 1:len
    try 
        t = endtime(obj.jobject(lcv)); % estimate soonest end time
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
    % check if timer is never-ending
    if ~isfinite(t)
        error('MATLAB:timer:wait:infinitetimer',timererror('MATLAB:timer:wait:infinitetimer'));
    end
end

% wait for the end of each timer.
for lcv = 1:len
    while obj.jobject(lcv).isRunning
        time = endtime(obj.jobject(lcv));
        pause(time);
    end

end

return;


function time = endtime(obj)

% if singleShot, can't determine endtime
if strcmp(get(obj,'ExecutionMode'),'singleShot')
    time = 0.01;
else
    repeat = get(obj,'TasksToExecute');
    rate = get(obj,'Period');
    task = get(obj,'TasksExecuted');
    time = (repeat-task-1)*rate;
    % forces a minimum wait of 10ms. 
    if (time<0.01)
        time = 0.01;
    end
end
