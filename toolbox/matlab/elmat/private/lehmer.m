function A = lehmer(n)
%LEHMER Lehmer matrix.
%   A = GALLERY('LEHMER',N) is the symmetric positive definite
%   N-by-N matrix such that A(i,j) = i/j for j >= i.
%
%   Properties:
%      A is totally nonnegative.
%      INV(A) is tridiagonal and explicitly known.
%      N <= COND(A) <= 4*N*N.

%   References:
%   [1] M. Newman and J. Todd, The evaluation of matrix inversion
%       programs, J. Soc. Indust. Appl Math, 6 (1958),pp. 466-476.
%   [2] Solutions to problem E710 (proposed by D.H. Lehmer):
%       The inverse of a matrix, Amer. Math. Monthly, 53 (1946),
%       pp. 534-535.
%   [3] J. Todd, Basic Numerical Mathematics, Vol. 2: Numerical
%       Algebra, Birkhauser, Basel, and Academic Press, New York,
%       1977, p. 154.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:42:50 $

A = ones(n,1)*(1:n);
A = A./A';
A = tril(A) + tril(A,-1)';
