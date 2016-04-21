function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component
%   STROUT=OUTLINESTRING(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:39 $


if c.att.isForceOpen
   typeString='XY graphs & scope';
else
   typeString='XY graphs & open scope';
end

loopInfo=searchblocktype(c.zslmethods,typeString);

typeIndex=find(strcmp(loopInfo.contextCode,getparentloop(c)));
if ~isempty(typeIndex)
   typeIndex=typeIndex(1);
else
   typeIndex=length(loopInfo.contextCode);
end

strout=sprintf('Scope Snapshot - %s', loopInfo.contextName{typeIndex});