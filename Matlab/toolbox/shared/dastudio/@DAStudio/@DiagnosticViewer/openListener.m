function openListener(h)
%  OPENLISTENER
%  This function is the listener for opening a 
%  particular message 
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
hRowDoubleClick = findprop(h, 'RowOpen');
h.hDoubleClickListener = handle.listener(h, hRowDoubleClick, ...
                         'PropertyPostSet', {@clickdouble_broadcast,h});
 
function clickdouble_broadcast(obj, evd, h)
  if (h.rowOpen >= 0)  
   h.openSelectedMsg;
   h.rowOpen = -1;
  end

 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:42 $
