function B = krylov(A, x, j)
%KRYLOV Krylov matrix.
%   GALLERY('KRYLOV',A,X,J) is the Krylov matrix
%   [X, A*X, A^2*X, ..., A^(J-1)*X], where A is an N-by-N matrix and
%   X is an N-vector. The defaults are X = ONES(N,1), and J = N.
%
%   GALLERY('KRYLOV',N) is the same as GALLERY('KRYLOV',RANDN(N)).

%   Reference:
%   [1] G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%   Johns Hopkins University Press, Baltimore, Maryland, 1996, Sec. 7.4.5.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:42:44 $

n = length(A);

if n == 1   % Handle special case A = scalar.
   n = A;
   A = randn(n);
end

if nargin < 3, j = n; end
if nargin < 2, x = ones(n,1); end


B = ones(n,j);
B(:,1) = x(:);
for i=2:j
    B(:,i) = A*B(:,i-1);
end
