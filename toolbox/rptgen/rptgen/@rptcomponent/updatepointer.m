function errMsg=updatepointer(c)
%UPDATEPOINTER renews the pointer image of the component
%   MESSAGE=UPDATEPOINTER(C) 
%    

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:23 $

try
   p=subsref(c,substruct('.','ref','.','ID'));
catch
   p=-1;
end

if isa(p,'rptcp')
   h=p.h;
   if length(h)==1 & ishandle(h)
      set(h,'UserData',c);
      errMsg='';
   else
      errMsg='Pointer handle is not valid';
   end
else
   errMsg='No pointer found';
end