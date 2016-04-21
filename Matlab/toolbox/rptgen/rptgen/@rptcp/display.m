function display(p)
%DISPLAY controls how the index is displayed to screen

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:32 $

disp(' ');
disp([inputname(1), ' = '])
disp(' ');

if length(p.h)<=1
   disp(sprintf('Component Pointer: %d',p.h));
   if ishandle(p.h)
      UserData=get(p.h,'UserData');
      if isa(UserData,'rptcomponent')
         display(UserData,logical(0));
      else
         display(UserData);
      end
   else
      display('  ERROR: NOT A HANDLE');
   end
elseif length(p.h)>1
   toDisp={};
   for j=length(p.h):-1:1
      c=get(p.h(j),'UserData');      
      toDisp(j,:)={j,p.h(j),class(c)};
   end
   display(toDisp);
end

