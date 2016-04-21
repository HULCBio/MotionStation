function modelddg_file_cb(h, dlgH)

% Copyright 2003 The MathWorks, Inc.

  h2 =  h.getWorkspace;
  val = dlgH.getWidgetValue('WorkspaceFile');
  h2.FileName = val;
