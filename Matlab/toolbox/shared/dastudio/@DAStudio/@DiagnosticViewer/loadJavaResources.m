function loadJavaResources(h)
%  LOADJAVARESOURCES
%  This function will load the java resources
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $     
  
import com.mathworks.toolbox.dastudio.diagView.*;

%If java is not engaged engage it

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:40 $

if ( h.javaEngaged == 1)
  if (h.javaAllocated == 0)
    % Here make the actual Java object 
    hjava = java(h);
    win = com.mathworks.toolbox.dastudio.diagView.DiagnosticViewerWindow.CreateDiagnosticViewerWindow(hjava);
    % Set the font size
    fontSize = get(0,'defaultuicontrolfontsize');
    fontSize=max(fontSize, 12);
    win.setFontSize(fontSize);
    % Here set the appropriate field within the UDD object
    % to let it know it is associated with this Java object 
    h.jDiagnosticViewerWindow= handle(win);     
    % Here mark the java as being engaged   
    h.javaAllocated = 1;
  else 
    error('First Unload your existing java resources before loading new ones '); 
  end;
end;