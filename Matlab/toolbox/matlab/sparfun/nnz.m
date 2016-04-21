function nz = nnz(S)
%NNZ    Number of nonzero matrix elements.
%   nz = NNZ(S) is the number of nonzero elements in S.
%
%   The density of a sparse matrix S is nnz(S)/prod(size(S)).
%
%   See also NONZEROS, NZMAX, SIZE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2004/03/02 21:48:24 $

nz = sparsfun('nnz',S);
