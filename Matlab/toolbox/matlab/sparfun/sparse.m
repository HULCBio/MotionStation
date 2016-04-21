function [varargout] = sparse(varargin)
%SPARSE Create sparse matrix.
%   S = SPARSE(X) converts a sparse or full matrix to sparse form by
%   squeezing out any zero elements.
%
%   S = SPARSE(i,j,s,m,n,nzmax) uses the rows of [i,j,s] to generate an
%   m-by-n sparse matrix with space allocated for nzmax nonzeros.  The
%   two integer index vectors, i and j, and the real or complex entries
%   vector, s, all have the same length, nnz, which is the number of
%   nonzeros in the resulting sparse matrix S .  Any elements of s 
%   which have duplicate values of i and j are added together.
%
%   There are several simplifications of this six argument call.
%
%   S = SPARSE(i,j,s,m,n) uses nzmax = length(s).
%
%   S = SPARSE(i,j,s) uses m = max(i) and n = max(j).
%
%   S = SPARSE(m,n) abbreviates SPARSE([],[],[],m,n,0).  This
%   generates the ultimate sparse matrix, an m-by-n all zero matrix.
%
%   The argument s and one of the arguments i or j may be scalars,
%   in which case they are expanded so that the first three arguments
%   all have the same length.
%
%   For example, this dissects and then reassembles a sparse matrix:
%
%              [i,j,s] = find(S);
%              [m,n] = size(S);
%              S = sparse(i,j,s,m,n);
%
%   So does this, if the last row and column have nonzero entries:
%
%              [i,j,s] = find(S);
%              S = sparse(i,j,s);
%
%   All of MATLAB's built-in arithmetic, logical and indexing operations
%   can be applied to sparse matrices, or to mixtures of sparse and
%   full matrices.  Operations on sparse matrices return sparse matrices
%   and operations on full matrices return full matrices.  In most cases,
%   operations on mixtures of sparse and full matrices return full
%   matrices.  The exceptions include situations where the result of
%   a mixed operation is structurally sparse, eg.  A .* S is at least
%   as sparse as S .  Some operations, such as S >= 0, generate
%   "Big Sparse", or "BS", matrices -- matrices with sparse storage
%   organization but few zero elements.
%
%   See also SPALLOC, SPONES, SPEYE, SPCONVERT, FULL, FIND, SPARFUN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:08:29 $
%   Built-in function.

if nargout == 0
  builtin('sparse', varargin{:});
else
  [varargout{1:nargout}] = builtin('sparse', varargin{:});
end
