function A = ris(n)
%RIS Ris matrix (symmetric Hankel).
%   A = GALLERY('RIS',N) is a symmetric N-by-N Hankel matrix with
%   elements A(i,j) = 0.5/(N-i-j+1.5).
%   The eigenvalues of A cluster around PI/2 and -PI/2.
%   This matrix was invented by F.N. Ris.

%   Reference:
%   [1] J. C. Nash, Compact Numerical Methods for Computers: Linear Algebra
%       and Function Minimisation, second edition, Adam Hilger, Bristol,
%       1990 (Appendix 1).
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:41:11 $

p= -2*(1:n) + (n+1.5);
A = cauchy(p);
