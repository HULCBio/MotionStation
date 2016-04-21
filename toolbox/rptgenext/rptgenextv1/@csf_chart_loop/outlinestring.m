function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   OUTLINESTRING(cobj) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:04 $

if ~rgsf( 'is_parent_valid', c );
   strout = xlate('? Stateflow Chart Loop <invalid parent>');
   return;
end

if strcmp(c.att.LoopType, '$auto' )
   loopInfo=searchblocktype(c.zslmethods,'Stateflow block');
   
   typeIndex=find(strcmp(loopInfo.contextCode,getparentloop(c)));
   if ~isempty(typeIndex)
      typeIndex=typeIndex(1);
   else
      typeIndex=length(loopInfo.contextCode);
   end
   outline = loopInfo.contextName{typeIndex};
else
   outline = 'Manual selection';
end

strout=sprintf('Stateflow Chart Loop - %s', outline);