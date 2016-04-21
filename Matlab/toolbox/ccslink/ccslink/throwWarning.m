function throwWarning(warnid,warnmsg)
% Private. Turn off backtrace and verbose warning.

%   Copyright 2001-2003 The MathWorks, Inc.

origwarnstate = warning('query');
warning off backtrace;
warning off verbose;
warning(warnid,warnmsg);
warning(origwarnstate);

% [EOF] throwWarning.m