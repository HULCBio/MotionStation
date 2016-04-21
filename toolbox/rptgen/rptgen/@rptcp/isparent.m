function tf=isparent(p)
%ISPARENT true if component accepts subcomponents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:47 $

ud=get(p.h,'UserData');
if ~iscell(ud)
   ud={ud};
end

for i=length(ud):-1:1
   if isa(ud{i},'rptcomponent')
      tf(i)=isparent(ud{i});
   else
      tf(i)=logical(0);
   end
end