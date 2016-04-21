function index = getSelectedMsgIndex(h)
%  GETSELECTEDMSGINDEX
%  This function will get the index of the 
%  selected message for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
%Set selected row

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:34 $
index = h.rowSelected;

if (index <= 0)
   error('There is no message selected at this point');
end
