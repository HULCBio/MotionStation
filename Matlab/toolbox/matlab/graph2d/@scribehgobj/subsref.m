function B = subsref(A,S)
%SCRIBEHGOBJ/SUBSREF Subscripted reference for scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:13:33 $

for idx = 1:length(S)
   switch S(idx).type
   case '.'
      if length(A)==1
         switch S(idx).subs
         case 'HGHandle'
            B = A.HGHandle;
         case 'IsSelected'
            B = A.ObjSelected;
         otherwise
            B = get(A,S(idx).subs);
         end
      else
         B = {};
         for a=[A{:}]
            B{end+1}=subsref(a,S(idx));
         end
      end
   case {'()' '{}'}
      structA = struct(A);
      B = structA(S(idx).subs{:});
      B = class(B,'scribehgobj');
   end
   A = B;
end

