function parentPointer=getparent(p)
%GETPARENT returns a pointer to the pointer's parent

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:39 $

parentPointer=get(p.h,'Parent');
if strcmp(get(parentPointer,'Type'),'figure')
   parentPointer=rptsp(parentPointer);
else
   parentPointer=rptcp(parentPointer);
end