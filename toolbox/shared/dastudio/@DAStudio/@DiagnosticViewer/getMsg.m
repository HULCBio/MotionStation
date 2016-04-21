function msg = getMsg(h,index)
%  GETMSG
%  This function will get a message from a list
%  of messages in the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
%Check that the index is within proper range

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:32 $
if (index <= 0 & length(h.Messages) > 0)
   error('index for DiagnosicMessageViewer.getMsg out of bounds') ;
end;

%Return correct message
msg = h.Messages(index);