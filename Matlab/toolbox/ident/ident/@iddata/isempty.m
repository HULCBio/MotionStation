function is = isempty(data)

%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:15:59 $
%   Copyright 1986-2002 The MathWorks, Inc.

[N,ny,nu] = size(data);
if ny+nu==0
   is = true;
else 
   is = false;
end



