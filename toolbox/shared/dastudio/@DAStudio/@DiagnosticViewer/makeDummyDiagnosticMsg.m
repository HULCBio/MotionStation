function makeDummyNag(h,varargin)
%  MAKEDUMMYNAG
%  This function will make a dummy nag
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
msg = DAStudio.DiagnosticMsg(varargin);
msg.type = 'Marse';
msg.sourceFullName = 'yourModel/gain1';
msg.sourceName = 'gain1';
msg.component = 'RTW';

msg2 = DAStudio.DiagnosticMsg(varargin);
msg2.type = 'Parse';
msg2.sourceFullName = 'yourModel/gain2';
msg2.sourceName = 'gain2';
msg2.component = 'Me';

c = msg.Contents;
c.Type = 'Marse';
c.details = 'Parse error in gain due to ..';
c.summary = c.details;


c2 = msg.Contents;
c2.Type = 'Parse';
c2.details = 'Parse error in gain due to ..';
c2.summary = c.details;

%here add the message

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:41 $
h.addDiagnosticMsg(msg);
