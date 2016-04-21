function boo = hasMatchingVars(D1,D2)
% Returns true if D1 and D2 have matching top-level variable and links.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:12 $
nv = length(D1.Data_);
nl = length(D1.Children_);
if length(D2.Data_)==nv && length(D2.Children_)==nl
   for ct=1:nv
      if D1.Data_(ct).Variable~=D2.Data_(ct).Variable
         boo = false; return
      end
   end
   for ct=1:nl
      if D1.Children_(ct).Alias~=D2.Children_(ct).Alias
         boo = false; return
      end
   end
   boo = true;
else
   boo = false;
end
   
      