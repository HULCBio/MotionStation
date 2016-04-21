function [varargout] = cholinc(varargin)
%CHOLINC  Sparse Incomplete Cholesky and Cholesky-Infinity factorizations.
%   CHOLINC produces two different kinds of incomplete Cholesky factorizations
%   -- the drop tolerance and the 0 level of fill-in factorizations.  These
%   factors may be useful as preconditioners for a symmetric positive definite
%   system of linear equations being solved by an iterative method such as PCG
%   (Preconditioned Conjugate Gradients).
%
%   R = CHOLINC(X,DROPTOL) performs the incomplete Cholesky factorization of
%   X, with drop tolerance DROPTOL.
%
%   R = CHOLINC(X,OPTS) allows additional options to the incomplete Cholesky
%   factorization.  OPTS is a structure with up to three fields:
%       DROPTOL --- the drop tolerance of the incomplete factorization
%       MICHOL  --- modified incomplete Cholesky
%       RDIAG   --- replace zeros on the diagonal of R
%
%   Only the fields of interest need to be set.
%
%   DROPTOL is a non-negative scalar used as the drop tolerance for the
%   incomplete Cholesky factorization.  This factorization is computed by
%   performing the incomplete LU factorization with the pivot threshold option
%   set to 0 (which forces diagonal pivoting) and then scaling the rows of the
%   incomplete upper triangular factor, U, by the square root of the
%   diagonal entries in that column.  Since the nonzero entries U(I,J) are
%   bounded below by DROPTOL*NORM(X(:,J)) (see LUINC), the nonzero
%   entries R(I,J) are bounded below by DROPTOL*NORM(X(:,J))/R(I,I).
%   Setting DROPTOL = 0 produces the complete Cholesky factorization,
%   which is the default.
%
%   MICHOL stands for modified incomplete Cholesky factorization.  Its
%   value is either 0 (unmodified, the default) or 1 (modified).  This
%   performs the modified incomplete LU factorization of X and then scales
%   the returned upper triangular factor as described above.
%
%   RDIAG is either 0 or 1.  If it is 1, any zero diagonal entries
%   of the upper triangular factor R are replaced by the square root of
%   the local drop tolerance in an attempt to avoid a singular factor.  The
%   default is 0.
%
%   Example:
%
%      A = delsq(numgrid('C',25));
%      nnz(A)
%      nnz(chol(A))
%      nnz(cholinc(A,1e-3))
%
%      This shows that A has 2063 nonzeros, its complete Cholesky factorization
%      has 8513 nonzeros, and its incomplete Cholesky factorization with a
%      drop tolerance of 1e-3 has 4835 nonzeros.
%
%
%   R = CHOLINC(X,'0') produces the incomplete Cholesky factor of a real
%   symmetric positive definite sparse matrix with 0 level of fill-in (i.e. no
%   fill-in).  The upper triangular R has the same sparsity pattern as
%   triu(X), although R may be zero in some positions where X is nonzero due
%   to cancellation.  The lower triangle of X is assumed to be the transpose
%   of the upper.  Note that the positive definiteness of X does not guarantee
%   the existence of a factor with the required sparsity.  An error message
%   results if the factorization is not possible.  R'*R agrees with X over its
%   sparsity pattern.
%
%   [R,p] = CHOLINC(X,'0'), with two output arguments, never produces an
%   error message.  If R exists, then p is 0.   But if the incomplete
%   factor does not exist, then p is a positive integer and R is an upper
%   triangular matrix of size q-by-n where q = p-1 so that the sparsity
%   pattern of R is that of the q-by-n upper triangle of X.  R'*R agrees with
%   X over the sparsity pattern of its first q rows and first q columns.
%
%   Example:
%
%      A = delsq(numgrid('N',10));
%      R = cholinc(A,'0');
%      isequal(spones(R), spones(triu(A)))
%
%      A(8,8) = 0;
%      [R2,p] = cholinc(A,'0');
%      isequal(spones(R2), spones(triu(A(1:p-1,:))))
%
%      D = (R'*R) .* spones(A) - A;
%
%      D has entries of the order of eps.
%
%
%   R = CHOLINC(X,'inf') produces the Cholesky-Infinity factorization.  This
%   factorization is based on the Cholesky factorization, and handles real
%   positive semi-definite matrices as well.  It may be useful for finding
%   some sort of solution to systems which arise in primal-dual interior-point
%   method problems.  When a zero pivot is encountered in the ordinary
%   Cholesky factorization, the diagonal of the Cholesky-Infinity factor is set
%   to Inf and the rest of that row is set to 0.  This is designed to force a 0
%   in the corresponding entry of the solution vector in the associated system
%   of linear equations.  In practice, X is assumed to be positive
%   semi-definite so even negative pivots are replaced by Inf.
%
%   Example: This symmetric sparse matrix is singular, so the Cholesky
%       factorization fails at the zero pivot in the third row.  But cholinc
%       succeeds in computing all rows of the Cholesky-Infinity factorization.
%
%       S = sparse([ 1     0     3     0;
%                    0    25     0    30;
%                    3     0     9     0;
%                    0    30     0   661 ]);
%       [R,p] = chol(S);
%       Rinf = cholinc(S,'inf');
%
%   CHOLINC works only for sparse matrices.
%
%   See also CHOL, LUINC, PCG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $ $Date: 2004/04/16 22:08:19 $
%   Built-in function.



if nargout == 0
  builtin('cholinc', varargin{:});
else
  [varargout{1:nargout}] = builtin('cholinc', varargin{:});
end
