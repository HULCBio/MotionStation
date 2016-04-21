function can = canRedo(h)

% Copyright 2004 The MathWorks, Inc.

  rs = h.RedoStack;
  ct = h.currentTransaction;
  
  
  can = logical(0);

  if (h.externalMarkers > 0)
    return;
  end
  
  if (isempty(rs))
    return;
  end
  
  can = logical(1);
  if (~isempty(ct)) 
    can = ~(h.hasPendingTransaction);
  end
