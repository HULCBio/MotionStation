function tf=eq(a,b)
%EQ returns true if both pointers are equal

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:34 $

a=double(a);
b=double(b);

if length(a)==length(b)
   tf=min(a==b);
else
   tf=logical(0);
end
