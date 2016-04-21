function oNags = create_nag(iComp, iNagType, iMsgType, iMsgs, iSrc)
%CREATE_NAG Utility function to create a SL/SF Nag.
%
%  Syntax:
%    oNags = create_nag(iComp, iNagType, iMsgType, iMsgs, iSrc)
%
%  Inputs:
%    iComp    : (string) Component this nag belongs to (Simulink, RTW, etc)
%    iNagType : (string) One of Error, Warning or Info
%    iMsgType : (string) Clasification of the nag (RTW Build error, etc)
%    iMsgs    : (cell array of strings) The nag'ing messages
%    iSrc     : The object to be hyper-linked to the nag (block, model, etc)
%
%  Outputs:     
%   oNags     - Structure array of nags than can be passed to slsfnagctlr.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $

  if ishandle(iSrc)
    sourceName = get_param(iSrc, 'Name');
    sourceFullName = getfullname(iSrc);
  else
    sourceName = iSrc;
    sourceFullName = iSrc;
  end
  
  nag = slsfnagctlr('NagTemplate');
  nag.component      = iComp;
  nag.type           = iNagType;
  nag.msg.type       = iMsgType;
  nag.sourceName     = sourceName;
  nag.sourceFullName = sourceFullName;

  if iscell(iMsgs),
    nag = repmat(nag,size(iMsgs));
    n = length(nag(:));
    for i = 1:n,
      nag(i).msg.details = iMsgs{i};
      nag(i).msg.summary = iMsgs{i};
    end
  else
    nag.msg.details = iMsgs;
    nag.msg.summary = iMsgs;
  end
  oNags = nag;
  
%endfunction

