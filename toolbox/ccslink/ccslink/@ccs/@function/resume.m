function resp = resume(ff)
% RESUME Resume function execution
%  O = RESUME(FF) Runs CCS from the current location until a breakpoint is
%  encountered. If the breakpoint encountered is the return address of
%  FF, the method reads and returns the value of the output.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/08 20:46:18 $

error(nargchk(1,1,nargin));
if ~ishandle(ff),
    errId = generateccsmsgid('InvalidHandle');
    error(errId,'First parameter must be a valid FUNCTION handle.');
end

% Run function from where it stopped until it reaches a breakpoint

resp = p_runtohalt(ff);

% [EOF] resume.m