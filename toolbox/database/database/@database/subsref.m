function B = subsref(A,S)
%SUBSREF Reference a value for a Database object.
%  SUBSREF is currently only implemented for dot reference.
%  For example:
%    VALUE=H.PROPERTY
%
%  See also: GET.


%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.5 $  $Date: 2002/06/17 12:01:59 $

for idx = 1:length(S)
   switch S(idx).type
   case '.'
      if length(A)==1
        B = get(A,S(idx).subs);
      else
         B = {};
         for a=[A{:}]
            B{end+1}=subsref(a,S(idx));
         end
      end
   case {'()' '{}'}
      structA = struct(A);
      B = structA(S(idx).subs{:});
      B = class(B,'database');
   end
   A = B;
end
