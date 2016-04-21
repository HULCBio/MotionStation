function A = clement(n, k)
%CLEMENT Clement matrix.
%   GALLERY('CLEMENT',N,K) is a tridiagonal matrix with zero diagonal 
%   entries and known eigenvalues. It is singular if N is odd. About 64
%   percent of the entries of the inverse are zero. The eigenvalues
%   are plus and minus the numbers N-1, N-3, N-5, ..., (1 or 0).
%   For K = 0 (the default) the matrix is unsymmetric, while for
%   K = 1 it is symmetric. GALLERY('CLEMENT',N,1) is diagonally similar 
%   to GALLERY('CLEMENT',N).
%
%   Note:
%   Similar properties hold for GALLERY('TRIDIAG',X,Y,Z) where 
%   Y = ZEROS(N,1). The eigenvalues still come in plus/minus pairs but 
%   they are not known explicitly.
%

%   References:
%   [1] P.A. Clement, A class of triple-diagonal matrices for test
%   purposes, SIAM Review, 1 (1959), pp. 50-52.
%   [2] O. Taussky and J. Todd, Another look at a matrix of Mark Kac,
%   Linear Algebra and Appl., 150 (1991), pp. 341-360.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:41:17 $

if nargin == 1, k = 0; end

n = n-1;

x = n:-1:1;
z = 1:n;

if k == 0
   A = diag(x, -1) + diag(z, 1);
else
   y = sqrt(x.*z);
   A = diag(y, -1) + diag(y, 1);
end
