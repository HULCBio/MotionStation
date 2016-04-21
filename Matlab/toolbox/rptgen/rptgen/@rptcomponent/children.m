function childPointer=children(c)
%CHILDREN return child components

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:51 $

myPointer=subsref(c,substruct('.','ref','.','ID'));
if isa(myPointer,'rptcp')
   childPointer=children(myPointer);
else
   childPointer=rptcp;
end
