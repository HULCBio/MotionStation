function strip(p)
%STRIP shrinks the setup file for saving

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:32 $

s=struct(get(p.h,'UserData'));
s.ref=[];
set(p.h,'UserData',s);

mainChild=children(p);
%returns a handle to the first subcomponent

%delete all children of the figure which are
%not the main components
delete(setxor(mainChild.h,...
   findall(allchild(p.h),'flat')));



strip(children(p));