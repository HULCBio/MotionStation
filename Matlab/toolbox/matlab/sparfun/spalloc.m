function s = spalloc(m,n,nzmax)
%SPALLOC Allocate space for sparse matrix.
%   S = SPALLOC(M,N,NZMAX) creates an M-by-N all zero sparse matrix
%   with room to eventually hold NZMAX nonzeros.
%
%   For example
%       s = spalloc(n,n,3*n);
%       for j = 1:n
%           s(:,j) = (a sparse column vector with 3 nonzero entries);
%       end
%
%   See also SPONES, SPDIAGS, SPRANDN, SPRANDSYM, SPEYE, SPARSE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:13:25 $

s = sparse([],[],[],m,n,nzmax);
