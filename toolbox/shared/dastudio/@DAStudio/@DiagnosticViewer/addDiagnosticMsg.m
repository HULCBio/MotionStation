function addDiagnosticMsg(h,msg)
%  ADDDIAGNOSTICMSG
%  This adds a diagnostic message to the
%  java window
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
% Here append this message to the list of messages 
% associated with this DiagnosticViewer

h.messages = [h.messages;msg];

