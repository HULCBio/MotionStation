function sf_tmp_undo_marker(whattodo)

% Copyright 2002 The MathWorks, Inc.
  
  % Note, this function will be obsoleted as soon as Acgir gets the necessary changes from Adas
  % When das_undo_stack is available, call it directly, instead of using this function!
    

    try
      us = das_undo_stack;
      switch (whattodo)
       case 'add'
        us.addExternalMarker;
       case 'remove'
        us.removeExternalMarker;
      end
    catch
      % It's okay to fail since we might not have the das_undo_stack function yet!
    end
    
