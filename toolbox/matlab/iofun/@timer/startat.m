function startat(obj, varargin)
%STARTAT Start timer(s) running at the specified time.
%
%    STARTAT(OBJ,TIME) starts the timer running, represented by the 
%    timer object OBJ, at the time specified by the serial date number 
%    TIME. If OBJ is an array of timer objects, STARTAT starts all the
%    timers running at the specified time. Use the TIMER function to 
%    create the timer object.
%
%    START sets the Running property of the timer object, OBJ, to 'On',
%    initiates TimerFcn callbacks, and executes the StartFcn callback.
%
%    The serial date number, TIME, indicates the number of days that
%    have elapsed since 1-Jan-0000 (starting at 1). See DATENUM for 
%    additional information about serial date numbers.
% 
%    STARTAT(OBJ,S) starts the timer at the time specified by the date 
%    string S. The date string must use date format 0,1,2,6,13,14,15,
%    16, or 23, as defined by the DATESTR function. Date strings with 
%    two-character years are interpreted to be within the 100 years
%    centered around the current year.
%
%    STARTAT(OBJ,S,PIVOTYEAR) uses the specified pivot year as the
%    starting year of the 100-year range in which a two-character year
%    resides. The default pivot year is the current year minus 50 years.
% 
%    STARTAT(OBJ,Y,M,D) and STARTAT(OBJ, [Y,M,D]) start the timer at  
%    the year(Y), month(M), and day(D) specified. Y, M, and D must be
%    arrays of the same size (or they can be a scalar).
% 
%    STARTAT(OBJ,Y,M,D,H,MI,S) and STARTAT(OBJ,[Y,M,D,H,MI,S]) start
%    the timer at the year(Y), month(M), day(D), hour(H), minute(MI), 
%    and second(S) specified. Y,M,D,H,MI, and S must be arrays of the 
%    same size (or they can be a scalar). Values outside the normal
%    range of each array are automatically carried to the next unit 
%    (for example month values greater than 12 are carried to years). 
%    Month values less than 1 are set to be 1; all other units can
%    wrap and have valid negative values.
%
%   The timer stops running when one of the following conditions apply:
%    - The number of TimerFcn callbacks executed equals the number 
%      specified by the TasksToExecute property.
%    - The STOP(OBJ) command is issued.
%    - An error occurs while executing a TimerFcn callback.
%
%    Examples:
%        t1=timer('TimerFcn','disp(''it is 10 o''''clock'')');
%        startat(t1,'10:00:00');
%
%        t2=timer('TimerFcn','disp(''It has been an hour now.'')');
%        startat(t2,now+1/24);
%
%    See also TIMER, TIMER/START, TIMER/STOP, DATENUM, DATESTR, NOW.

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.3.4.3 $  $Date: 2004/03/30 13:07:28 $

% check for not enough parameters (common error)
if (nargin==1)
    error('MATLAB:timer:startat:notenoughparameters',timererror('MATLAB:timer:startat:notenoughparameters'));
elseif ~isa(obj, 'timer')
    error('MATLAB:timer:noTimerObj',timererror('MATLAB:timer:noTimerObj'));
end

len = length(obj);
if ~all(isJavaTimer(obj.jobject)) % error if some are invalid
    if len==1
        error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
    else        
        error('MATLAB:timer:someinvalid',timererror('MATLAB:timer:someinvalid'));
    end
end

% evaluate the serial date number inputs using datenum
try
    delay = datenum(varargin{:});
catch
    error('MATLAB:timer:startat:invaliddatesyntax',timererror('MATLAB:timer:startat:invaliddatesyntax'));
end

dlen = length(delay);

% if only one starttime was given for multiple object, duplicate the starttime for each timer.
if (dlen==1) && (len>1)
    delay = repmat(delay,size(obj));
    dlen=len;
end

% trap case where number of object doesn't equal number of start-times
if (dlen>1) && (dlen ~= len)
    error('MATLAB:timer:startat:numtimersanddelaymismatch',timererror('MATLAB:timer:startat:numtimersanddelaymismatch'));
end

% foreach timer object
for lcv = 1:len
    startDelay = 86400*(delay(lcv) - now);
    if strcmp(obj.jobject(lcv).Running,'off')
        % don't allow negative start delays.
        if startDelay < 0
            % If the 13 form of datestr ('HH:MM:SS') is passed in, datenum
            % defaults to month = 1, day = 1, year = current year for the
            % missing information.  If that is the case, use the current
            % year, month and day.
            [delayyear delaymonth delayday delayhour delayminute delaysec] = datevec(delay(lcv));
            [curyear curmonth curday curhour curminute cursec] = datevec(now);
            
            if ( (delayyear == curyear) && (delaymonth == 1) && (delayday == 1) )
                startDelay = 86400 * (datenum([curyear curmonth curday delayhour delayminute delaysec]) - now);
            end
            
            if (startDelay < 0)
                error('MATLAB:timer:startat:startdelaynegative',timererror('matlab:timer:startat:startdelaynegative'));
            end
        end
        s=warning;
        warning('off','MATLAB:TIMER:STARTDELAYPRECISION');
        try
            set(obj.jobject(lcv),'StartDelay',startDelay);
        catch
            err = fixlasterr;
            warning(s);
            error(err{:});
        end
        warning(s);
    end
end

try
    start(obj);
catch
    err=fixlasterr;
    error(err{:});
end
