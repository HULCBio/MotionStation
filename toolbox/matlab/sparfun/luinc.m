function [varargout] = luinc(varargin)
%LUINC  Sparse Incomplete LU factorization.
%   LUINC produces two different kinds of incomplete LU factorizations -- the
%   drop tolerance and the 0 level of fill-in factorizations.  These factors
%   may be useful as preconditioners for a system of linear equations being
%   solved by an iterative method such as BICG (BiConjugate Gradients).
%
%   LUINC(X,DROPTOL) performs the incomplete LU factorization of
%   X with drop tolerance DROPTOL.
%
%   LUINC(X,OPTS) allows additional options to the incomplete LU
%   factorization.  OPTS is a structure with up to four fields:
%       droptol --- the drop tolerance of incomplete LU
%       milu    --- modified incomplete LU
%       udiag   --- replace zeros on the diagonal of U
%       thresh  --- the pivot threshold (see also LU)
%
%   Only the fields of interest need to be set.
%
%   droptol is a non-negative scalar used as the drop
%   tolerance for the incomplete LU factorization.  This factorization
%   is computed in the same (column-oriented) manner as the
%   LU factorization except after each column of L and U has
%   been calculated, all entries in that column which are smaller
%   in magnitude than the local drop tolerance, which is 
%   droptol * NORM of the column of X, are "dropped" from L or U.
%   The only exception to this dropping rule is the diagonal of the
%   upper triangular factor U which remains even if it is too small.
%   Note that entries of the lower triangular factor L are tested
%   before being scaled by the pivot.  Setting droptol = 0
%   produces the complete LU factorization, which is the default.
%
%   milu stands for modified incomplete LU factorization.  Its
%   value is either 0 (unmodified, the default) or 1 (modified).
%   Instead of discarding those entries from the newly-formed
%   column of the factors, they are subtracted from the diagonal
%   of the upper triangular factor, U.
%
%   udiag is either 0 or 1.  If it is 1, any zero diagonal entries
%   of the upper triangular factor U are replaced by the local drop
%   tolerance in an attempt to avoid a singular factor.  The default
%   is 0.
%
%   thresh is a pivot threshold in [0,1].  Pivoting occurs
%   when the diagonal entry in a column has magnitude less
%   than thresh times the magnitude of any sub-diagonal entry in
%   that column.  thresh = 0 forces diagonal pivoting.  thresh = 1 is
%   the default.
%
%   Example:
%
%      load west0479
%      A = west0479;
%      nnz(A)
%      nnz(lu(A))
%      nnz(luinc(A,1e-6))
%
%      This shows that A has 1887 nonzeros, its complete LU factorization
%      has 16777 nonzeros, and its incomplete LU factorization with a
%      drop tolerance of 1e-6 has 10311 nonzeros.
%
%
%   [L,U,P] = LUINC(X,'0') produces the incomplete LU factors of a sparse
%   matrix with 0 level of fill-in (i.e. no fill-in).  L is unit lower
%   trianglar, U is upper triangular and P is a permutation matrix.  U has the
%   same sparsity pattern as triu(P*X).  L has the same sparsity pattern as
%   tril(P*X), except for 1's on the diagonal of L where P*X may be zero.  Both
%   L and U may have a zero because of cancellation where P*X is nonzero.  L*U
%   differs from P*X only outside of the sparsity pattern of P*X.
%
%   [L,U] = LUINC(X,'0') produces upper triangular U and L is a permutation of
%   unit lower triangular matrix.  Thus no comparison can be made between the
%   sparsity patterns of L,U and X, although nnz(L) + nnz(U) = nnz(X) + n.  L*U
%   differs from X only outside of its sparsity pattern.
%
%   LU = LUINC(X,'0') returns "L+U-I", where L is unit lower triangular, U is
%   upper triangular and the permutation information is lost.
%
%   Example:
%
%      load west0479
%      A = west0479;
%      [L,U,P] = luinc(A,'0');
%      isequal(spones(U),spones(triu(P*A)))
%      spones(L) ~= spones(tril(P*A))
%      D = (L*U) .* spones(P*A) - P*A
%
%      spones(L) differs from spones(tril(P*A)) at some positions on the
%      diagonal and at one position in L where cancellation zeroed out a
%      nonzero element of P*A.  The entries of D are of the order of eps.
%
%   LUINC works only for sparse matrices.
%
%   See also LU, CHOLINC, BICG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $
%   Built-in function.

if nargout == 0
  builtin('luinc', varargin{:});
else
  [varargout{1:nargout}] = builtin('luinc', varargin{:});
end
