function start(obj)
%START Start timer(s) running.
%
%    START(OBJ) starts the timer running, represented by the timer 
%    object, OBJ. If OBJ is an array of timer objects, START starts 
%    all the timers. Use the TIMER function to create a timer object.
%
%    START sets the Running property of the timer object, OBJ, to 'On',
%    initiates TimerFcn callbacks, and executes the StartFcn callback.
%
%    The timer stops running when one of the following conditions apply:
%     - The number of TimerFcn callbacks executed equals the number 
%       specified by the TasksToExecute property.
%     - The STOP(OBJ) command is issued.
%     - An error occurs while executing a TimerFcn callback.
%   
%    See also TIMER, TIMER/STOP.

%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.3 $  $Date: 2002/03/14 14:34:54 $


len = length(obj);
if ~all(isJavaTimer(obj.jobject))
    if len==1
        error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
    else        
        error('MATLAB:timer:someinvalid',timererror('MATLAB:timer:someinvalid'));
    end
end

err = false;
alreadyRunning = false;
for lcv = 1:len % foreach object in OBJ array
    if (obj.jobject(lcv).isRunning == 1) % if timer already running, flag as error/warning
        alreadyRunning = true;
    else
        try
            obj.jobject(lcv).start; % start the timer
        catch
            err = true; % flag as error/warning needing to be thrown at end
        end
    end
end

if (len==1) % if OBJ is singleton, above problems are thrown as errors
    if alreadyRunning
        error('MATLAB:timer:start:alreadystarted',timererror('MATLAB:timer:start:alreadystarted'));
    elseif err % throw actual error
        lerr = fixlasterr;
        error(lerr{:});
    end
else % if OBJ is an array, above problems are thrown as warnings
    if alreadyRunning
        state = warning('backtrace','off');
        warning('MATLAB:timer:start:alreadystarted',timererror('MATLAB:timer:start:alreadystarted'));
        warning(state);
    elseif err
        state = warning('backtrace','off');
        warning('MATLAB:timer:errorinobjectarray',timererror('MATLAB:timer:errorinobjectarray'));
        warning(state);
    end
end