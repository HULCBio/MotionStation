function mod = getLastUndoModifier(h)

% Copyright 2004 The MathWorks, Inc.
  
  try,
    us = h.UndoStack;
    t = us(1);
    mod = t.name;
  catch
    mod = [];
  end
  
  