function target_state=connectToIDE_TItarget(target_state,modelInfo)

% $RCSfile: connectToIDE_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:36:58 $
% Copyright 2001-2003 The MathWorks, Inc.

% get ccs board info
try
    ccsbi = ccsboardinfo;
    ccsInstalled = logical(1);
catch % CCS not installed
    msg = lasterr;
    if ~findstr(msg,'CCSDSP:The system cannot find the path specified') & ...
        ~findstr(msg,'CCSDSP:Class not registered')
        error(msg);  % Re-issue this unexpected error
    else
        error('Could not connect to Code Composer Studio(R)')
    end
end

% % Get user-specified board and proc numbers
[boardNum, procNum] = c6000tgtpref('getBoardProcNums',modelInfo.name);

% create link to CCS
disp('### Connecting to Code Composer Studio(R)...')
try
    % call CCSDSP constructor 
    target_state.ccsObj=ccsdsp('boardnum',boardNum,'procnum',procNum);
catch
    disp(lasterr)
    error('Could not connect to specified board and processor.');
end
% put boardProc numbers in Reset blocks
boardProc = [boardNum, procNum];
attachToResetBlocks_TItarget(modelInfo,boardProc);

% [EOF] connectToIDE_TItarget.m
