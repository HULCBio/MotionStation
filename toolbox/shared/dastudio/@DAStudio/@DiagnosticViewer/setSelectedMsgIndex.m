function setSelectedMsgIndex(h,index)
%SETSELECTEDMSGINDEX
%Check that the index is within proper range
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:46 $
if (index <= 0 & length(h.Messages) > 0)
   error('index for DiagnosicMessageViewer.getMsg out of bounds') ;
end;  
%Set selected row
h.rowSelected = index;
