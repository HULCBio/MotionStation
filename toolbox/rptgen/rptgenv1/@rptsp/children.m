function myChild=children(p)
%CHILDREN returns a pointer to the first component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:15 $

%the 'flat' in findobj is very important - it prevents
%findobj from searching the undobuffer.
myChild=findobj(allchild(p.h),'flat',...
   'type','uimenu',...
   'tag','coutline');
if ~isempty(myChild)
   myChild=rptcp(myChild(1));
else
   myChild=coutline;
   set(myChild.h,'Parent',p.h);
end
