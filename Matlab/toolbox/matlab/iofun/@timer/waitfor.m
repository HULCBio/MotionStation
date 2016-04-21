function waitfor(obj)
%WAITFOR Wait until the timer stops running.
%
%    WAITFOR(OBJ) blocks the MATLAB command line and waits until the
%    timer, represented by the timer object OBJ, stops running. 
%    When a timer stops running, the value of the timer object's
%    Running property changes from 'On' to 'Off'.
%
%    If OBJ is an array of timer objects, WAITFOR blocks the MATLAB
%    command line until all the timers have stopped running.
%
%    If the timer is not running, WAITFOR returns immediately.
%
%    See also TIMER/START, TIMER/STOP, TIMER/WAIT.
%

%    RDD 3-11-2003
%    Copyright 2001-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/04/23 06:20:46 $

try
    wait(obj);
catch
    rethrow(lasterror)
end
    