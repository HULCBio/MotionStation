function restart(cc,timeout)
%RESTART Restores the DSP target to the program entry point.
%   RESTART(CC,TIMEOUT) immediately halts the DSP processor
%   and sets the program counter(PC) to the program entry point.
%   The CC.RESTART method does not initiate program execution after
%   the halt.  Use RUN(CC) to execute the DSP processor after a
%   restart. 
%   Note: If CC contains more than one processor, each of these 
%   processors will call 'restart' in a sequential order.
%
%   TIMEOUT defines an upper limit (in seconds) on the period this 
%   routine will wait for completion of the specified action.  
%   If this period is exceeded, the routine will immediately return
%   with a timeout error. In general, this method will cause the
%   processor to initiate a restart, even when a timeout is reached
%   The timeout simply indicates the confirmation was not received 
%   before the timeout period expired.
%
%   RESTART(CC) Same as above, except the default timeout from the
%   CC object is applied.
%
%   See also HALT, RUN, ISRUNNING.

% Copyright 2004 The MathWorks, Inc.
