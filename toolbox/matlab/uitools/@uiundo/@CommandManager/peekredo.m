function [cmd] = peekredo(hThis)

% Copyright 2002 The MathWorks, Inc.

cmd = [];
redostack = hThis.RedoStack;

len = length(redostack);
if len>0
  cmd = redostack(end);
end
