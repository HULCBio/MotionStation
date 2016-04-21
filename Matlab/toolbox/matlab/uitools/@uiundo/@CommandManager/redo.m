function redo(hThis)

% Copyright 2002 The MathWorks, Inc.

% Get the top of the RedoStack and Redo it.
stack = hThis.RedoStack;
len = length(stack);
if len > 0
  cmd = stack(len); % hack, can't do stack(end)
  hThis.RedoStack = stack(1:len-1);
else
  return;
end

% Redo command
redo(cmd);

% Push the redone transaction onto the UndoStack
stack = hThis.UndoStack;
hThis.UndoStack = [stack; cmd];

% Send the RedoPerformed event
send(hThis, 'CommandStackChanged', handle.EventData(hThis, 'CommandStackChanged'));