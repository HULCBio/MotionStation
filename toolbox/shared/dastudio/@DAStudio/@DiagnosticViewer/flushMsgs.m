function flushMsgs(h)
%  FLUSHMSGS
%  This will remove all the messages from the 
%  udd object and remove them from java window also
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
%Clean your UDD messages

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:31 $
h.Messages = [];
% Only if the java window is visible and engaged you have to worry about 
% gettin rid of the row  
if (h.javaAllocated == 1)
  win = h.jDiagnosticViewerWindow;
  win.removeAllMsgs;
end  
