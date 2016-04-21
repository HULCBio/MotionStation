function B=subsref(A,S)
%SUBSREF subscripted reference

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:34 $

if S(1).subs(1)=='h'
   if length(S)>1
      B=get(A.h,S(2).subs);
   else      
      B=A.h;
   end
else
   B=subsref(get(A.h,'UserData'),S);   
end










