function [varargout] = qr(varargin)
%QR     Orthogonal-triangular decomposition.
%   [Q,R] = QR(A) produces an upper triangular matrix R of the same
%   dimension as A and a unitary matrix Q so that A = Q*R.
%
%   [Q,R,E] = QR(A) produces a permutation matrix E, an upper
%   triangular R and a unitary Q so that A*E = Q*R.  The column
%   permutation E is chosen so that abs(diag(R)) is decreasing.
%
%   [Q,R] = QR(A,0) produces the "economy size" decomposition.
%   If A is m-by-n with m > n, then only the first n columns of Q
%   are computed.
%
%   [Q,R,E] = QR(A,0) produces an "economy size" decomposition in
%   which E is a permutation vector, so that Q*R = A(:,E).  The column
%   permutation E is chosen so that abs(diag(R)) is decreasing. 
%
%   By itself, QR(A) is the output of LAPACK'S DGEQRF or ZGEQRF routine.
%   TRIU(QR(A)) is R.
%
%   For sparse matrices, QR can compute a "Q-less QR decomposition",
%   which has the following slightly different behavior.
%
%   R = QR(A) returns only R.  Note that R = chol(A'*A).
%   [Q,R] = QR(A) returns both Q and R, but Q is often nearly full.
%   [C,R] = QR(A,B), where B has as many rows as A, returns C = Q'*B.
%   R = QR(A,0) and [C,R] = QR(A,B,0) produce economy size results.
%
%   The sparse version of QR does not do column permutations.
%   The full version of QR does not return C.
%
%   The least squares approximate solution to A*x = b can be found
%   with the Q-less QR decomposition and one step of iterative refinement:
%
%       x = R\(R'\(A'*b))
%       r = b - A*x
%       e = R\(R'\(A'*r))
%       x = x + e;
%
%   See also LU, NULL, ORTH, QRDELETE, QRINSERT, QRUPDATE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.2 $  $Date: 2004/04/16 22:07:29 $
%   Built-in function.

if nargout == 0
  builtin('qr', varargin{:});
else
  [varargout{1:nargout}] = builtin('qr', varargin{:});
end
