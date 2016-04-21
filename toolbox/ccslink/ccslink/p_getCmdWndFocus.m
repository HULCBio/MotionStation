function hasfocus = p_getCmdWndFocus
% STATE = P_GETCMDWNDFOCUS (private) Determines if the MATLAB command
% window is focused.

% Copyright 2004 The MathWorks, Inc.

% Query if command window is in focus
hasfocus = 0;
if usejava('desktop') % if using java command window
    try
        hasfocus = com.mathworks.mlservices.MLCommandWindowServices.hasFocus;
    end
else % if using -nodesktop option
    hasfocus = 0;
end

%[EOF] p_getCmdWndFocus.m
