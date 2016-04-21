function A = moler(n, alpha)
%MOLER  Moler matrix (symmetric positive definite).
%   A = GALLERY('MOLER',N,ALPHA) is the symmetric positive definite 
%   N-by-N matrix U'*U, where U = GALLERY('TRIW',N,ALPHA).
%
%   For the default ALPHA = -1, A(i,j) = MIN(i,j)-2, and A(i,i) = i.
%   One of the eigenvalues of A is small.

%   Nash (1990) attributes the ALPHA = -1 matrix to Moler.
%
%   Reference:
%   [1] J.C. Nash, Compact Numerical Methods for Computers: Linear
%   Algebra and Function Minimisation, second edition, Adam Hilger,
%   Bristol, 1990 (Appendix 1).
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:43:02 $

if nargin == 1, alpha = -1; end

A = triw(n, alpha)'*triw(n, alpha);
