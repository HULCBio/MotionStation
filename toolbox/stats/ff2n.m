function x = ff2n(n)
%FF2N   Two-level full-factorial design.
%   X = FF2N(N) creates a two-level full-factorial design, X.
%   N is the number of columns of X. The number of rows is 2^N.

%   B.A. Jones 2-17-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.1 $  $Date: 2004/01/24 09:33:44 $

rows = 2.^(n);
ncycles = rows;
x = zeros(rows,n);

for k = 1:n
   settings = (0:1);
   ncycles = ncycles/2;
   nreps = rows./(2*ncycles);
   settings = settings(ones(1,nreps),:);
   settings = settings(:);
   settings = settings(:,ones(1,ncycles));
   x(:,n-k+1) = settings(:);
end
