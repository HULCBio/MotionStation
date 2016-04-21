function c=unpoint(p)
%UNPOINT converts from a pointer to a component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:07 $

c=get(p.h,'UserData');
c.ref.ID=[];
delete(p.h);