
function result = isVisible(h)
%  ISVISIBLE This function is used to see if the diagnostic viewer is visible or not
%  for the Diagnostic Viewer  
%  Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:39 $

result = false;
if ( h.javaEngaged == 1 & h.javaAllocated == 1)
  javahandle = java(h.jDiagnosticViewerWindow);
  javaVisible = javahandle.isVisible;
  uddVisible = h.Visible;
  % Always rely on java to tell you whether the window is visible or not
  result = javaVisible;
  if (~isequal(javaVisible,uddVisible))
    h.Visible = result;
  end;
end