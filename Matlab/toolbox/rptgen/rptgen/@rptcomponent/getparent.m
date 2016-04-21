function parentPointer=getparent(c)
%GETPARENT returns a pointer to the pointer's parent

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:05 $

try
   myPointer=subsref(c,substruct('.','ref','.','ID'));
catch
   myPointer=[];
end

if isa(myPointer,'rptcp')
   parentPointer=getparent(myPointer);
else
   parentPointer=rptcp;
end