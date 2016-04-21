function i=getinfo(p)
%GETINFO an interface to the component's GETINFO method

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:38 $

i=getinfo(get(p.h,'UserData'));
