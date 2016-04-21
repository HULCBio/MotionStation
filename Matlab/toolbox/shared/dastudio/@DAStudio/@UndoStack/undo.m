function undo(h)

% Copyright 2004 The MathWorks, Inc.

  if (h.canUndo)
    h.closeTransaction;
    
    %You may have empty transaction that you need to ignore 
    % before you go on
    h.skimEmptyTransactions;
    
    % Here look at the undo stack and the top transaction on top of it
    us = h.undoStack;
    t = us(1);
    
    % Remove this transaction from the h.undoStack handle vector
    % By making it empty
    us(1) = [];
    h.undoStack = us;
    
    % Undo the actual transaction
    t.undo;
    
    % Put this transaction on the redo stack
    h.redoStack = [t; h.redoStack];
    %  h.skimEmptyTransactions;
  end
  
