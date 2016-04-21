function msg = getSelectedMsg(h)
%  GETSELECTEDMSG
%  This function will get the selected message
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
%Find selected row

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:33 $
row = h.rowSelected;
if (row <= 0)
   error('No message selected');
   return;
end
%Return correct message
msg = h.Messages(row);