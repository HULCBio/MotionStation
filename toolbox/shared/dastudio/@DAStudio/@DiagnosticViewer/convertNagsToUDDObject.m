function convertNagsToUDDObject(h,msgs)
%  CONVERTNAGSTOUDDOBJECT
%  This function will convert a bunch of nags to udd
%  objects
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 
  
  for i = 1:length(msgs)
    msg = h.convertNagToUDDObject(msgs(i));
    h.messages = [h.messages;msg];
  end
  h.addDiagnosticMsgsToJava;

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:27 $
