function synchronizeJavaViewer(h)
%  SYNCHRONIZEJAVAVIEWER
%  This function will synchronize the java window
%  with the udd representation 
%  of the Array Editor
%  Copyright 1990-2004 The MathWorks, Inc.
  
% Make sure java is engaged
  if (h.javaEngaged == 1)
    if (h.javaAllocated == 1)
      % Here get the handle to the actual java object  
      win = h.jArrayEditorWindow;
      win.populate(h.Value);
    else
      error('Java not engaged');
    end;
  end;
