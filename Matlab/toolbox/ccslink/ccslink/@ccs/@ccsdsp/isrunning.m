function birun = isrunning(mcc)
%ISRUNNING Returns true if the target DSP is executing.
%   ISRUNNING(CC) returns true if the target DSP is executing.
%   Conversely, returns false when the DSP is halted.  The
%   target is the DSP processor referenced by the CC object.
%
%   Note: If CC contains more than one processor, this method returns an
%   array containing the status of each processor. 
%
%   See also HALT, RUN, RESTART.

%     Copyright 2000-2004 The MathWorks, Inc.
%     $Revision: 1.12.4.3 $ $Date: 2004/04/08 20:45:49 $

error(nargchk(1,1,nargin));

for k = 1:length(mcc)
    cc = mcc(k);
    birun(k) = callSwitchyard(cc.ccsversion,[15,cc.boardnum,cc.procnum,0,0]);
end

% [EOF] isrunning.m
