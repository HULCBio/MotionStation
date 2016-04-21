
function showSummaryListener(h)
%  SHOWSUMMARYLISTENER
%  This function is the listener for showing the summary part 
%  of the Diagnsotic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
    
hVisib = findprop(h, 'summaryVisible');
h.hSummaryVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@showsummary_broadcast,h});

function showsummary_broadcast(obj, evd, h)

  if (h.javaAllocated == 0)
     return;
  end;
  
  javahandle = java(h.jDiagnosticViewerWindow);
  javahandle.setSummaryVisib;
 

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:51 $
