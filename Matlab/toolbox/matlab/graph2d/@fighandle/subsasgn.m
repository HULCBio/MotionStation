function A = subsasgn(A,S,B)
%FIGHANDLE/SUBSASGN Subscripted assignment for fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:12:31 $

UD = getscribeobjectdata(A.figStoreHGHandle);

switch S.subs
case 'ObjectStore'
   UD.ObjectStore = B;
   setscribeobjectdata(A.figStoreHGHandle,UD);
otherwise
   UD.(S.subs) = B;
   setscribeobjectdata(A.figStoreHGHandle,UD);   
end
