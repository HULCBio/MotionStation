function toggleactive(p)
%TOGGLEACTIVE changes the active state of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:05 $

for i=1:length(p.h)
   c=get(p.h(i),'UserData');
   active=c.comp.Active;
   
   if active==1
      newval=0;
   elseif active==2
      newval=0;  
   else
      newval=1;
   end
   
   c.comp.Active=newval;
   set(p.h(i),'UserData',c);
end
