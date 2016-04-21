function A=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:02 $

if ischar(S(1).subs) & S(1).subs(1)=='h'
   if length(S)>1
      B=builtin('subsasgn',A.h,S(2:end));
   else 
      A.h=B;
   end
else
   if strcmp(S(1).type,'.')
      subsIndex=1;
   else
      subsIndex=S(1).subs{1};
      S=S(2:end);
   end
   C=get(A.h(subsIndex),'UserData');
   if ~isempty(S)
      C=builtin('subsasgn',C,S,B);   
   else
      C=B;
   end    
   set(A.h(subsIndex),'UserData',C);
end




