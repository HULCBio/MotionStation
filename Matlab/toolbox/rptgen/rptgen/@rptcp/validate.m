function p=validate(p)
%VALIDATE makes sure that P points to a component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:08 $

for i=1:length(p.h)
   c=get(p.h(i),'UserData');
   if ~isa(c,'rptcomponent')
      if isfield(c,'comp') & isfield(c.comp,'Class')
         %r=rptparent;
         %oldSet=nenw(r);
         try
            newP=feval(c.comp.Class,c);
         catch
            warning(sprintf('Warning - component %s could not be loaded.',c.comp.Class))
            newP=crgempty('DescString',c.comp.Class);
         end
         %nenw(r,oldSet);
      else
         %it's not a component or a struct of a component
         %force it to be an empty component
         newP=rgempty;
      end
      c=get(newP,'UserData');   
      delete(newP);
   end
   tempP=rptcp(p.h(i));
   c.ref.ID=tempP;
   
   try
      olStr=outlinestring(c);
   catch
      olStr=c.comp.Class;
   end
   
   set(p.h(i),'UserData',c,...
      'Label',olStr,...
      'tag',c.comp.Class);
  
   validate(children(tempP));
end
