function redo(hThis)

% Copyright 2002 The MathWorks, Inc.

if ishandle(hThis.Transaction)
  redo(hThis.Transaction);
end