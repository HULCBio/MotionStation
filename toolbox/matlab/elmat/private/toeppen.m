function P = toeppen(n, a, b, c, d, e)
%TOEPPEN Pentadiagonal Toeplitz matrix.
%   P = GALLERY('TOEPPEN',N,A,B,C,D,E) takes integer N and 
%   scalar A,B,C,D,E. P is the N-by-N sparse pentadiagonal Toeplitz 
%   matrix with the diagonals: P(3,1)=A, P(2,1)=B, P(1,1)=C, P(1,2)=D, 
%   P(1,3)=E.
%
%   Default: (A,B,C,D,E) = (1,-10,0,10,1) (a matrix of Rutishauser).
%   This matrix has eigenvalues lying approximately on the line segment 
%   2*cos(2*t) + 20*i*sin(t).

%   Interesting plots are
%   PS(FULL(TOEPPEN(32,0,1,0,0,1/4)))  - `triangle'
%   PS(FULL(TOEPPEN(32,0,1/2,0,0,1)))  - `propeller'
%   PS(FULL(TOEPPEN(32,0,1/2,1,1,1)))  - `fish'
%
%   References:
%   [1] R.M. Beam and R.F. Warming, The asymptotic spectra of banded 
%   Toeplitz and quasi-Toeplitz matrices, SIAM J. Sci. Comput. 14 (4), 
%   1993, pp. 971-1006.
%   [2] H. Rutishauser, On test matrices, Programmation en Mathematiques
%   Numeriques, Editions Centre Nat. Recherche Sci., Paris, 165, 1966, 
%   pp. 349-365.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:41:38 $

if nargin == 1, a = 1; b = -10; c = 0; d = 10; e = 1; end

P = spdiags([ a*ones(n,1) b*ones(n,1) c*ones(n,1) d*ones(n,1) ....
              e*ones(n,1) ], -2:2, n, n);
