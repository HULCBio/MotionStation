function add(hThis,cmd)

% Copyright 2002 The MathWorks, Inc.

% Verbose print out
if ~isempty(hThis.Verbose)
  disp(tomcode(cmd))
end

stack = hThis.UndoStack;

% Trim off UndoStack if limit defined
len = length(stack);
if (~isempty(hThis.MaxUndoStackLength) & len >= hThis.MaxUndoStackLength)
  stack = stack(2:end);
end

hThis.UndoStack = [stack; cmd];

% Empty the redo stack since it is now stale
hThis.RedoStack = [];

% Notify listeners that the undo/redo stack changed
send(hThis,'CommandStackChanged',handle.EventData(hThis,'CommandStackChanged'));
send(hThis,'CommandAdded',handle.EventData(hThis,'CommandAdded'));






