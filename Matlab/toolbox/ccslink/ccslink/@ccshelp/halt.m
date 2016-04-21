function halt(cc,timeout)
%HALT Immediately terminates execution of DSP processor.
%   HALT(CC,TIMEOUT) asynchronously stops execution of the DSP processor
%   referenced by the CC object.  This method waits for the DSP 
%   processor to terminate execution in the processor before returning. 
%   The RUN(CC) method can be used to resume execution after a HALT.  By 
%   reading the 'PC' register, it is possible to check the address 
%   where the code was stopped by this method. 
%   Note: If CC contains more than one processor, each of these processors 
%   will call 'halt' in a sequential order.
%
%   The TIMEOUT parameter defines how long to wait (in seconds) for 
%   the execution to terminate.  If this period is exceeded, 
%   the routine will return immediately with a timeout error.  In
%   general the action (halt) will still occur, but the timeout value
%   gave insufficient time to verify the completion of the action.
%
%   HALT(CC) Same as above, except the timeout value defaults to the 
%   timeout property specified by the CC object. Use CC.GET to examine 
%   this default timeout value.
%
%   See also RUN, ISRUNNING, REGREAD.

% Copyright 2004 The MathWorks, Inc.
