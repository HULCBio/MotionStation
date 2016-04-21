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
     
     javahandle = java(h.jArrayEditor);
     javahandle.setVisible(h.Visible);          
   end
 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:19 $
