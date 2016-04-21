
function showMessageListener(h)
%  SHOWMESSAGELISTENER
%  This function is the listener for showing the message part 
%  of the Diagnsotic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
  
hVisib = findprop(h, 'messageVisible');
h.hMessageVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@showmessage_broadcast,h});

function showmessage_broadcast(obj, evd, h)
  if (h.javaAllocated == 0)
     return;
  end;
  
  javahandle = java(h.jDiagnosticViewerWindow);
  javahandle.setMessageVisib;
 

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:48 $
