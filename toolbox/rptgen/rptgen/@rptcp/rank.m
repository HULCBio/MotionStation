function myRank=rank(p)
%RANK returns position of component in child list
%   RANK(P) returns the position of the component
%   pointed to by P in its parent's list of subcomponents.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:55 $


myParent=get(p.h,'Parent');
myParentChildren=get(myParent,'Children');
myHandle=p.h;

myRank=find(myParentChildren==myHandle);