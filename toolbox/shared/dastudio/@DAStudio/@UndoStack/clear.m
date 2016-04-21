function clear(h)

% Copyright 2004 The MathWorks, Inc.

    % Release all our references
    h.closeTransaction;

    toDelete = [h.UndoStack; h.RedoStack];
    h.UndoStack = [];
    h.RedoStack = [];

    for i=1:length(toDelete)
       delete(toDelete(i));
    end

    h.ExternalMarkers = 0;

