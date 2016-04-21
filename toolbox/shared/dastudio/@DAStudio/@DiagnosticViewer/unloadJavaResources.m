function unloadJavaResources(h)
%  UNLOADJAVARESOURCES
%  This function will unload the java part  
%  of the Diagnsotic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
   
import com.mathworks.toolbox.dastudio.diagView.*;

%Make sure java is engaged 

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:54 $
if (h.javaAllocated == 0)
  error('java resources not loaded');
end    
%If it is visible make it invisible
if (h.Visible == 1)
   h.Visible = 0;
end  
% Here get to the actual java window 
win =  h.jDiagnosticViewerWindow;
%Dispose the java resource 
win.dispose;
% Now clear the variable in UDD
h.jDiagnosticViewerWindow = [];
