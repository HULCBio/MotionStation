function target_state = connectToCCS (h, target_state, modelInfo, s)

% $RCSfile: connectToCCS.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:29 $
% Copyright 2003-2004 The MathWorks, Inc.

% create link to Code Composer Studio
try
    % call CCSDSP constructor 
    target_state.ccsObj = ccsdsp ('boardnum', s.boardNum, 'procnum', s.procNum);
catch
    error (sprintf (['Could not connect to specified board. \n'...
            'Make sure selected board is properly configured.']));
end
% put boardProc numbers in Reset blocks
boardProc = [s.boardNum, s.procNum];

% attachToResetBlocks_TItarget(modelInfo,boardProc);

% [EOF] connectToCCS.m
