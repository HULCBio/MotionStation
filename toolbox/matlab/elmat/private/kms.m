function A = kms(n, rho)
%KMS Kac-Murdock-Szego Toeplitz matrix.
%  A = GALLERY('KMS', N, RHO) is the N-by-N Kac-Murdock-Szego
%  Toeplitz matrix such that
%     A(i,j) = RHO^(ABS(i-j)), for real RHO.
%  For complex RHO, the same formula holds except that elements
%  below the diagonal are conjugated. RHO defaults to 0.5.
%
%  Properties:
%    A has an LDL' factorization with
%      L = INV(GALLERY('TRIW',N,-RHO,1))', and
%      D(i,i) = (1-ABS(RHO)^2)*EYE(N),
%    except D(1,1) = 1.
%    A is positive definite if and only if 0 < ABS(RHO) < 1.
%    INV(A) is tridiagonal.

%   Reference:
%   [1] W. F. Trench, Numerical solution of the eigenvalue problem
%       for Hermitian Toeplitz matrices, SIAM J. Matrix Analysis
%       and Appl., 10 (1989), pp. 135-146.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 03:41:14 $

if nargin < 2, rho = 0.5; end

A = (1:n)'*ones(1,n);
A = abs(A - A');
A = rho .^ A;
if imag(rho)
   A = conj(tril(A,-1)) + triu(A);
end
