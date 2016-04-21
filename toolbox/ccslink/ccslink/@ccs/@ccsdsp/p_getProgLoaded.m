function progFile = p_getProgLoaded(cc)
%P_GETPROGLOADED Return the program file loaded on the target DSP.

% Copyright 2004 The MathWorks, Inc.

progFile = callSwitchyard(cc.ccsversion,[29,cc.boardnum,cc.procnum,0,0]);

% [EOF] p_getProgLoaded.m