function strip(p)
%STRIP removes information from component and children before saving

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:01 $

c=struct(get(p.h,'UserData'));
c.ref=[];
c.x=[];
set(p.h,'UserData',c);

subComponents=children(p);
for i=1:length(subComponents)
   strip(rptcp(subComponents.h(i)));
end   