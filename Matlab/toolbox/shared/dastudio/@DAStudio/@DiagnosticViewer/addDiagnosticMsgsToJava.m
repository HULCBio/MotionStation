function addDiagnosticMsgsToJava(h)
%  ADDDIAGNOSTICMSGSTOJAVA
%  This adds a set of diagnostic messages to the
%  java window
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 




% Only if the java window is visible and engaged you have to worry about 
% refreshing the graphics
if (h.Visible == 1 & h.javaAllocated == 1)
  win = h.jDiagnosticViewerWindow;
  win.addDiagnosticMsgs;
end  
