function can = canUndo(h)

% Copyright 2004 The MathWorks, Inc.


  us = h.UndoStack;
  ct = h.currentTransaction;

  
  can = logical(0);
  if (h.externalMarkers > 0)
    return; % No undoing when an external tag is present
  end
  
  if (isempty(us))
    return;  % No undoing from an empty stack
  end
  
  can = logical(1);

         
