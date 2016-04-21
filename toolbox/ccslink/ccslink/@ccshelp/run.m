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

% Copyright 2004 The MathWorks, Inc.
