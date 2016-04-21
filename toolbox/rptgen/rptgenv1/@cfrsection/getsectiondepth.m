function nestDepth=getsectiondepth(c)
%GETSECTIONDEPTH returns number of parent CFRSECTION components
%   D=GETSECTIONDEPTH(C) returns the number of parent 
%   components which are also CFRSECTION components plus
%   one.  GETSECTIONDEPTH is only used at design-time.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:50 $


%exeStack=subsref(c,substruct('.','rptcomponent','.','stack'));

%exeStack=c.rptcomponent.stack;

%if length(exeStack)>0
   %%we are executing and can use the stack
   %try
   %   parentTypes=get(exeStack.h,'tag');
   %catch
   %   parentTypes={};
   %end
   
   %component classes are stored in the handle tags
   %the last member of parentTypes is the current component
   %nestDepth=length(find(ismember(parentTypes,c.comp.Class)));   
   
   
   
   
   
%else
   %we are in design-mode and must use getparent
   nestDepth=1;
   parentPointer=getparent(c);
   while isa(parentPointer,'rptcp')
      if strcmp(get(parentPointer,'tag'),c.comp.Class)
         nestDepth=nestDepth+1;
      end
      parentPointer=getparent(parentPointer);
   end   
%end

nestDepth=min(nestDepth,length(c.ref.allTypes));