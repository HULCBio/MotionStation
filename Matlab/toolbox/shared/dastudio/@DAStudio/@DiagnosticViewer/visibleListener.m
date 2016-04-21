function visibleListener(h)
%  VISIBLELISTENER
%  This function is the listener for the visibility of the 
%  entire Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
hVisib = findprop(h, 'Visible');
h.hVisListener = handle.listener(h, hVisib, ...
                         'PropertyPostSet', {@visible_broadcast,h});

function visible_broadcast(obj, evd, h)

   if ( h.javaEngaged == 1)
     if (h.Visible == 0 & h.javaAllocated == 0)
       return;
     end;
     
     if (h.Visible == 1) 
       if (h.javaAllocated == 0)
	 h.loadJavaResources;
       end
        h.synchronizeJavaViewer;
     end;
     
     javahandle = java(h.jDiagnosticViewerWindow);
     javahandle.setVisible(h.Visible);
     
     % There are things that you have to do only after
     % the java window becomes visible
     
     if (h.Visible == 1)
        javahandle.postVisible;
     end
     
     % Make sure you dehilite the blocks before
     % getting out. Also initialize the sorting
     % array that determines whether you do forward
     % or backward sorting
     if (h.Visible == 0)
       blockH = [-1.0 -1.0 -1.0 -1.0 -1.0];
       h.reverseSort = blockH;
       dehilitBlocks(h);
       dehilitModelAncestors(h);
     end
     
   end
 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:55 $
