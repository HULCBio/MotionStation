function A = minij(n)
%MINIJ Symmetric positive definite matrix MIN(i,j).
%   A = GALLERY('MINIJ',N) is the N-by-N symmetric positive definite
%   matrix with A(i,j) = MIN(i,j).
%
%   Properties:
%   A has eigenvalues 0.25*SEC((1:N)*PI/(2*N+1)).^2.
%   INV(A) is tridiagonal. It is minus the second difference matrix
%     except its (N,N) element is 1.
%   2*A-ONES(N) (Givens' matrix) has tridiagonal inverse and
%     eigenvalues 0.5*SEC((2*(1:N)-1)*PI/(4*N)).^2.
%   FLIPUD(TRIW(N,1)) is a square root of A.

%   References:
%   [1] J. Fortiana and C. M. Cuadras, A family of matrices, the
%       discretized Brownian bridge, and distance-based regression,
%       Linear Algebra Appl., 264 (1997), pp. 173-188.  (For the
%       eigensystem of A.)
%   [2] J. Todd, Basic Numerical Mathematics, Vol 2: Numerical Algebra,
%       Birkhauser, Basel, and Academic Press, New York, 1977, p. 158.
%   [3] D.E. Rutherford, Some continuant determinants arising in
%       physics and chemistry---II, Proc. Royal Soc. Edin., 63,
%       A (1952), pp. 232-241. (For the eigenvalues of Givens' matrix.)
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:42:59 $

A = min( ones(n,1)*(1:n), (1:n)'*ones(1,n) );
