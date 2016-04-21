function redo(h)

% Copyright 2004 The MathWorks, Inc.

if (h.canRedo)
    h.closeTransaction;
    
    rs = h.redoStack;
    t = rs(1);
    rs(1) = [];
    h.redoStack = rs;
    
    t.redo;
    
    h.undoStack = [t; h.undoStack];
    h.skimEmptyTransactions;
end
  


