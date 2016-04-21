function [cmd] = peekundo(hThis)

% Copyright 2002 The MathWorks, Inc.

cmd = [];
undostack = hThis.UndoStack;

len = length(undostack);
if len>0
  cmd = undostack(end);
end
