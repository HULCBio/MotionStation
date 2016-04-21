function undo(hThis)

% Copyright 2002 The MathWorks, Inc.

% Pop the last command off the undo stack
stack = hThis.UndoStack;
len = length(stack); 
if len>0
  cmd = stack(len); 
  hThis.UndoStack = stack(1:len-1);
else
  return;
end


% Undo the last command
undo(cmd);

% Push the last command onto the redo stack
stack = hThis.RedoStack;
hThis.RedoStack = [stack; cmd];

% Send the UndoPerformed event
send(hThis, 'CommandStackChanged', handle.EventData(hThis, 'CommandStackChanged'));


