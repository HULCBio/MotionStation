function refreshCallbacks(hThis)
% Work around function for UICLEARMODE bugs

% Copyright 2002 The MathWorks, Inc.

if hThis.Debug
  disp('refreshCallbacks')
end

set(hThis.MarkerHandle,'ButtonDown',hThis.MarkerHandleButtonDownFcn);
set(hThis.TextBoxHandle,'ButtonDown',hThis.TextBoxHandleButtonDownFcn);









