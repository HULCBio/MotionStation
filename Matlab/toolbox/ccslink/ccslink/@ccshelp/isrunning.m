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

% Copyright 2004 The MathWorks, Inc.
