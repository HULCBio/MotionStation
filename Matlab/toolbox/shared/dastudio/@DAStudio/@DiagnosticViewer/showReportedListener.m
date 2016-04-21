
function showReportedListener(h)
%  SHOWREPORTEDLISTENER
%  This function is the listener for showing the reported part 
%  of the Diagnsotic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
    
hVisib = findprop(h, 'reportVisible');
h.hReportedVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@showreported_broadcast,h});

function showreported_broadcast(obj, evd, h)
  
  if (h.javaAllocated == 0)
     return;
  end;
  
  javahandle = java(h.jDiagnosticViewerWindow);
  javahandle.setReportedVisib;
 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:49 $
