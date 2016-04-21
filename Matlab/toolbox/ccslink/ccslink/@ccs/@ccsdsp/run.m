function run(cc,runopt,funcname,timeout)
%RUN initiate execution of target DSP
%   RUN(CC,OPTION,TIMEOUT) initiates execution of the target DSP 
%   processor from the present program counter(PC) location.  
%   After starting execution of the DSP, the OPTION parameter 
%   will determine when control is returned to the user.
%   Note: If CC contains more than one processor, each of these 
%   processors will call 'run' in a sequential order.
%
%   OPTION parameter defines the action of the RUN method.
%   'run' (default) - executes a run and waits to confirm 
%      that the DSP is running, then immediately returns.
%   'runtohalt' - executes a run but then waits until the DSP 
%      processor has halted.  The halt can be caused by a 
%      breakpoint, or direct interaction with Code Composer 
%      Studio(R), or finally by a normal program exit.
%   'tohalt' - This option will wait for the DSP processor to 
%      complete execution to halt. Unlike the two options
%      this selection does not directly modify the action
%      of the processor, but simply waits it's state to change.
%      The halt can be caused by a breakpoint, or direct 
%      interaction with Code Composer Studio(R), or finally
%      by a normal program exit.
%   'main' - This option resets the program and executes a run 
%      until the start of function 'main'.
%   'tofunc' - This option must be followed by an extra parameter 
%      FUNCNAME, the name of the function to run to: 
%        RUN(CC,'tofunc',FUNCNAME)
%        RUN(CC,'tofunc',FUNCNAME,TIMEOUT)
%      This executes a run from the present PC location until 
%      the start of function FUNCNAME is reached. If FUNCNAME is not
%      along the program's normal execution path, FUNCNAME will not be 
%      reached and the method will time out.
%
%   TIMEOUT defines an upper limit (in seconds) on the period this 
%   routine will wait for completion of the specified action.  
%   If this period is exceeded, the routine will immediately return
%   with a timeout error.  In general, the 'run' and 'runtohalt' 
%   options will cause the processor to initiate execution, even
%   when a timeout is reached.  The timeout simply indicates the
%   confirmation was not received before the timeout period expired.

%   RUN(CC,OPTION) same as above, except the default timeout is 
%   replaced by the default timeout provided by the DSP handle.
%
%   RUN(CC) same as above, except the option defaults to the 'run'
%   option.  This causes an immediate return of control after the 
%   target is running.
%
%   See also HALT, RESTART, ANIMATE, ISRUNNING.

% Copyright 2000-2004 The MathWorks, Inc.
% $Revision: 1.16.4.5 $ $Date: 2004/04/08 20:45:53 $

error(nargchk(1,4,nargin));
focusstate = p_getCmdWndFocus;

mcc = cc;
numcc = length(mcc);
% just a wrapper for multi-proc boards
for k = 1:numcc
    cc = mcc(k);
    
    % Parse timeout
    if nargin==1
        dtimeout = double(get(cc,'timeout'));
    else
        if strcmp(runopt,'tofunc')
            if nargin==3,       dtimeout = GetRunToFuncTimeout(cc,nargin,funcname);
            elseif nargin==4,   dtimeout = GetRunToFuncTimeout(cc,nargin,funcname,timeout);
            else,               dtimeout = GetRunToFuncTimeout(cc,nargin);
            end
        else
            if nargin==2,       dtimeout = GetRunTimeout(cc,nargin);
            else,               dtimeout = GetRunTimeout(cc,nargin,funcname);
            end
        end
    end
    
    if( dtimeout < 0)
        error(generateccsmsgid('InvalidTimeOutValue'),['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
    end
    
    try
        if nargin == 1,
            callSwitchyard(cc.ccsversion,[14,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms]);
        else
            if strcmp(runopt,'main')
                runto(cc,'main','restart',dtimeout);
            elseif strcmp(runopt,'tofunc')
                runto(cc,funcname,'',dtimeout);
            else
                callSwitchyard(cc.ccsversion,[14,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms],runopt);
            end
        end
    catch
        DisplayError(k-1,numcc);
    end
end

p_grabCmdWndFocus(focusstate);

%-----------------------------------------
function DisplayError(procnum,numcc)
if numcc==1
    rethrow(lasterror);
else
    [msg,msgid] = lasterr;
    error(msgid,sprintf('PROCESSOR %d:\n%s',procnum,msg));
end
%-----------------------------------------
function dtimeout = GetRunTimeout(cc,nargs,timeout)
if nargs==3 && ~isempty(timeout),
	if ~isnumeric(timeout) || length(timeout) ~= 1,
        error(generateccsmsgid('InvalidTimeOutValue'),'TIMEOUT parameter must be a single numeric value.');
	end
	dtimeout = double(timeout);
else
    dtimeout = double(get(cc,'timeout'));
end

%-----------------------------------------
function dtimeout = GetRunToFuncTimeout(cc,nargs,funcname,timeout)
if nargs==4
	if ~isnumeric(timeout) || length(timeout) ~= 1,
        error(generateccsmsgid('InvalidTimeOutValue'),'TIMEOUT parameter must be a single numeric value.');
	end
	dtimeout = double(timeout);
elseif nargs==3
    dtimeout = double(get(cc,'timeout'));
else
    error(generateccsmsgid('FunctionNameNotSpecified'),'Function name must be specified when using ''tofunc'' option.');
end
if isempty(funcname)
    error(generateccsmsgid('FunctionNameNotSpecified'),'Function name must be specified when using ''tofunc'' option.');
elseif ~ischar(funcname)
    error(generateccsmsgid('InvalidFunctionName'),'Function name must be a string.');
end

% [EOF] run.m
