function reset(cc,timeout)
%RESET Software reset of the target DSP.
%   RESET(CC,TIMEOUT) stops execution of the target DSP processor
%   referenced by the CC object and then asynchronously performs a reset.
%   This routine waits for the DSP processor to halt before returning. The
%   TIMEOUT parameter defines how long to wait for the reset to complete.
%   Use RUN(CC) to resume execution from the reset location.
%   Note: If CC contains more than one processor, each of these 
%   processors will call 'reset' in a sequential order.
%
%   RESET(CC) Same as above, except the timeout value defaults to the
%   timeout property specified for the parent CCSDSP object. Use GET to
%   examine the default value supplied by the object.
%
%   See also HALT, RUN

% Copyright 2004 The MathWorks, Inc.
