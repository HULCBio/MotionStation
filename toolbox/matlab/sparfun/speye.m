function S = speye(m,n)
%SPEYE  Sparse identity matrix.
%   SPEYE(M,N) forms an M-by-N sparse matrix with 1's on
%   the main diagonal.  SPEYE(N) abbreviates SPEYE(N,N).
%
%   SPEYE(SIZE(A)) is a space-saving SPARSE(EYE(SIZE(A))).
%
%   See also SPONES, SPDIAGS, SPALLOC, SPRAND, SPRANDN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2003/05/01 20:43:11 $

if nargin < 2
   if length(m) == 1
      n = m;
   elseif length(m) == 2
      n = m(2);
      m = m(1);
   else 
      error('MATLAB:speye:InvalidInputFormat',...
            'Please use SPEYE(N), SPEYE(M,N) or SPEYE([M,N]).')
   end
end
k = 1:round(min(m,n));
S = sparse(k,k,1,m,n);
