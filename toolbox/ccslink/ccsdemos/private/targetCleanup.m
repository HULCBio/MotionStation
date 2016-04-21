function targetCleanup(cc,bkPts)
% This function cleans up Code Composer Studio environment for
% CCSDEBUGDEMO. It closes the open source files and removes the
% breakpoints. 

%   Copyright 2004 The MathWorks, Inc.

error(nargchk(1,2,nargin));

% Delete breakpoints that were introduced in targetSetup
% Clear all breakpoints

if nargin==2,
    for k = 1:length(bkPts),
        delete(cc,'FilterFFT.c',bkPts(k),'break');
    end
end

% Close all open files in CCS

% close(cc,'FilterFFT.pjt', 'project');
close(cc,'all','text');

% [eof] targetCleanup.m