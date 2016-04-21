function R = spones(S)
%SPONES Replace nonzero sparse matrix elements with ones.
%   R = SPONES(S) generates a matrix with the same sparsity
%   structure as S, but with ones in the nonzero positions.
%
%   See also SPFUN, SPALLOC, NNZ.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2004/03/02 21:48:28 $

[i,j] = find(S);
[m,n] = size(S);
R = sparse(i,j,1,m,n);
