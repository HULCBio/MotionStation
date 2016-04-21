function empty(hThis)

% Copyright 2002 The MathWorks, Inc.

hThis.UndoStack = [];
hThis.RedoStack = [];

send(hThis,'CommandStackChanged',handle.EventData(hThis,'CommandStackChanged'));