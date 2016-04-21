function [varargout] = lu(varargin)
%LU     LU factorization.
%   [L,U] = LU(X) stores an upper triangular matrix in U and a
%   "psychologically lower triangular matrix" (i.e. a product
%   of lower triangular and permutation matrices) in L, so
%   that X = L*U. X can be rectangular.
%
%   [L,U,P] = LU(X) returns unit lower triangular matrix L, upper
%   triangular matrix U, and permutation matrix P so that
%   P*X = L*U.
%
%   Y = LU(X) returns the output from LAPACK'S DGETRF or ZGETRF
%   routine if X is full. If X is sparse, Y contains the strict
%   lower triangle of L embedded in the same matrix as the upper
%   triangle of U. In both full and sparse cases, the permutation
%   information is lost.
%
%   [L,U,P,Q] = LU(X) returns unit lower triangular matrix L,
%   upper triangular matrix U, a permutation matrix P and a column
%   reordering matrix Q so that P*X*Q = L*U for sparse non-empty X.
%   This uses UMFPACK and is significantly more time and memory
%   efficient than the other syntaxes, even when used with COLAMD.
%
%   [L,U,P] = LU(X,THRESH) controls pivoting in sparse matrices,
%   where THRESH is a pivot threshold in [0,1].  Pivoting occurs
%   when the diagonal entry in a column has magnitude less than
%   THRESH times the magnitude of any sub-diagonal entry in that
%   column.  THRESH = 0 forces diagonal pivoting.  THRESH = 1 is
%   the default.
%
%   [L,U,P,Q] = LU(X,THRESH) controls pivoting in UMFPACK, where
%   THRESH is a pivot threshold in [0,1].  Given a pivot column j,
%   UMFPACK selects the sparsest candidate pivot row i such that
%   the absolute value of the pivot entry is greater than or equal
%   to THRESH times the largest entry in the column j.  The magnitude
%   of entries in L is limited to 1/THRESH.  A value of 1.0 results
%   in conventional partial pivoting.  The default value is 0.1.
%   Smaller values tend to lead to sparser LU factors, but the
%   solution can become inaccurate.  Larger values can lead
%   to a more accurate solution (but not always), and usually an
%   increase in the total work.
%
%   See also COLAMD, LUINC, QR, RREF, UMFPACK.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.16.4.2 $  $Date: 2004/04/16 22:07:25 $
%   Built-in function.



if nargout == 0
  builtin('lu', varargin{:});
else
  [varargout{1:nargout}] = builtin('lu', varargin{:});
end
