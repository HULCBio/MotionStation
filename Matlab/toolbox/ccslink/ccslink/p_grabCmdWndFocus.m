function p_grabCmdWndFocus(focusstate)
% P_GRABCMDWNDFOCUS (private) Return focus to the MATLAB command window,
% whether using java or -nodesktop option.

% Copyright 2004 The MathWorks, Inc.

if ( focusstate == 1 )
    commandwindow;
end

%[EOF] p_grabCmdWndFocus.m
