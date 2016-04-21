function sys = subsasgn(sys,Struct,rhs)
%   See also SET, SUBSREF.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:11 $
 
if nargin==1,
   return
end
StructL = length(Struct);
% Peel off first layer of subassignment
switch Struct(1).type
case '.'
   % Assignment of the form sys.fieldname(...)=rhs
   FieldName = Struct(1).subs;
   try
      if StructL==1,
         FieldValue = rhs;
      else
         FieldValue = subsasgn(get(sys,FieldName),Struct(2:end),rhs);
      end
      set(sys,FieldName,FieldValue)
   catch
      error(lasterr)
   end
otherwise
   error('Unknown subassignment mode')
end

