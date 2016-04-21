function A=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:33 $

if S(1).subs(1)=='h'
   if length(S)>1
      set(A.h,S(2).subs,B)
   else      
      A.h=B;
   end
else
   set(A.h,'UserData',...
      subsasgn(get(A.h,'UserData'),S,B))
end






