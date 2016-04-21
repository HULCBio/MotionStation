
function showSourceListener(h)
%  SHOWSOURCELISTENER.
%  This is the listener for the visibility of the source 
%  column
%  Copyright 1990-2004 The MathWorks, Inc.

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:50 $   
  
hVisib = findprop(h, 'sourceVisible');
h.hSourceVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@showsource_broadcast,h});

function showsource_broadcast(obj, evd, h)

  if (h.javaAllocated == 0)
     return;
  end;
  
  javahandle = java(h.jDiagnosticViewerWindow);
  javahandle.setSourceVisib;
 

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:50 $
