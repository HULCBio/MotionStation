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

%   Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.7.4.4 $ $Date: 2004/04/06 01:04:54 $


error(nargchk(1,2,nargin));

mcc = cc;
% just a wrapper for multi-proc boards
for k = 1:length(mcc)
    cc = mcc(k);
    % Parse timeout
    if( nargin >= 2) & (~isempty(timeout)),
        if ~isnumeric(timeout) | length(timeout) ~= 1,
            error('TIMEOUT parameter must be a single numeric value.');
        end
        dtimeout = double(timeout);
    else
        dtimeout = double(get(cc,'timeout'));
    end
    if( dtimeout < 0)
        error(['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
    end
    
    callSwitchyard(cc.ccsversion,[24,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms]);
end

% [EOF] reset.m
