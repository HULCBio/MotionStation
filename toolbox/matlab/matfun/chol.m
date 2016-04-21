function [varargout] = chol(varargin)
%CHOL   Cholesky factorization.
%   CHOL(X) uses only the diagonal and upper triangle of X.
%   The lower triangular is assumed to be the (complex conjugate)
%   transpose of the upper.  If X is positive definite, then
%   R = CHOL(X) produces an upper triangular R so that R'*R = X.
%   If X is not positive definite, an error message is printed.
%
%   [R,p] = CHOL(X), with two output arguments, never produces an
%   error message.  If X is positive definite, then p is 0 and R
%   is the same as above.   But if X is not positive definite, then
%   p is a positive integer.
%   When X is full, R is an upper triangular matrix of order q = p-1
%   so that R'*R = X(1:q,1:q).
%   When X is sparse, R is an upper triangular matrix of size q-by-n
%   so that the L-shaped region of the first q rows and first q
%   columns of R'*R agree with those of X.
%
%   See also CHOLINC, CHOLUPDATE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:07:17 $
%   Built-in function.

if nargout == 0
  builtin('chol', varargin{:});
else
  [varargout{1:nargout}] = builtin('chol', varargin{:});
end
