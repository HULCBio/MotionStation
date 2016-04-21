function skimEmptyTransactions(h)

% Copyright 2004 The MathWorks, Inc.

  h.UndoStack = skim_from_stack_l(h, h.UndoStack);
  h.RedoStack = skim_from_stack_l(h, h.RedoStack);
  
  
function stack = skim_from_stack_l(h, stack)
  
  gotValid = logical(0);
  while (~gotValid & ~isempty(stack))
    t = stack(1);
    if (h.isTransactionEmpty(t))
      stack(1) = [];
    else
      gotValid = logical(1);
    end
  end

 