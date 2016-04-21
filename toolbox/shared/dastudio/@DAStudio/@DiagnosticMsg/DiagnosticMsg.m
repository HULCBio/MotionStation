function h = DiagnosticMsg(varargin)
% Class constructor function (for das.DiagnosticMsg)
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:20 $
 
  
% Instantiate object
h = DAStudio.DiagnosticMsg;

% Attach Message object to Nag class
h.Contents = DAStudio.DiagnosticMsgContents;
h.Contents.HyperSearched = 0;
