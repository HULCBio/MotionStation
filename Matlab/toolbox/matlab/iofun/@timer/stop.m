function stop(obj)
% STOP Stop timer(s).
%
%    STOP(OBJ) stops the timer, represented by the timer object, 
%    OBJ. If OBJ is an array of timer objects, STOP stops all of
%    the timers. Use the TIMER function to create a timer object. 
%
%    STOP sets the Running property of the timer object, OBJ,
%    to 'Off', halts further TimerFcn callbacks, and executes the 
%    StopFcn callback.
%
%    See also TIMER, TIMER/START.  

%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.2 $  $Date: 2002/02/20 20:17:22 $

len = length(obj);
inval = false;

% for each object...
for lcv = 1:len
    if isJavaTimer(obj.jobject(lcv))
        obj.jobject(lcv).stop; % stop the timer
    else
        inval = true; % flag that an invalid timer object was found.
    end
end

if inval % at least one OBJ object is invalid
    if (len==1) % if OBJ is singleton, invalid object is thrown as error
        error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
    else % if OBJ is an array, above invalid object(len) is thrown as warning
        state = warning('backtrace','off');
        warning('MATLAB:timer:someinvalid',timererror('MATLAB:timer:someinvalid'));
        warning(state);
    end
end