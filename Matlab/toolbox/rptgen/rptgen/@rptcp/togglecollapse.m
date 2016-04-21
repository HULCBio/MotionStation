function togglecollapse(p)
%TOGGLECOLLAPSE changes the active state of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:06 $

for i=1:length(p.h)
   c=get(p.h(i),'UserData');
   active=c.comp.Active;
   
   if active==1
      newval=2;
   elseif active==2
      newval=1;  
   else
      newval=0;
   end
   
   c.comp.Active=newval;
   set(p.h(i),'UserData',c);
end
