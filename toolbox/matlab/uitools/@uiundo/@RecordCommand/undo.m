function undo(hThis)

% Copyright 2002 The MathWorks, Inc.

if ishandle(hThis.Transaction)
  undo(hThis.Transaction);
end

