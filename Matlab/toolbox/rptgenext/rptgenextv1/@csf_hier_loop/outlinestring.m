function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   OUTLINESTRING(cobj) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:11 $

if ~rgsf( 'is_parent_valid', c );
   strout =  xlate('? Stateflow Loop <invalid parent>');
   return;
end

slsfParent = rgsf('get_slsf_parent', c);
if strcmp( slsfParent.comp.Class, 'csf_chart_loop' )
   loopStr = 'Charts defined in Chart Loop';
else
   loopInfo=searchblocktype(c.zslmethods,'Stateflow block');
   
   typeIndex=find(strcmp(loopInfo.contextCode,getparentloop(c)));
   if ~isempty(typeIndex)
      typeIndex=typeIndex(1);
   else
      typeIndex=length(loopInfo.contextCode);
   end
   loopStr = loopInfo.contextName{typeIndex};
end
strout=sprintf('Stateflow Loop - %s', loopStr );