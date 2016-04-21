function setTitle(h,title)
%  SETTITLE
%  This function will set the title for 
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
import com.mathworks.toolbox.dastudio.diagView.*;

%set the title of the java window

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:47 $
if ( h.javaEngaged == 1 & h.javaAllocated == 1)
  h.Title = title;
  win = h.jDiagnosticViewerWindow;
  win.setTitleFromUDD(title);
end;
  