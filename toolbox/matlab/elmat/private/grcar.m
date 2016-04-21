function G = grcar(n, k)
%GRCAR  Grcar matrix.
%   GALLERY('GRCAR',N,K) is an N-by-N Toeplitz matrix with -1s on 
%   the subdiagonal, 1s on the diagonal, and K superdiagonals of 1s.
%   The default is K = 3.  The eigenvalues are sensitive.

%  References:
%    [1] J.F. Grcar, Operator coefficient methods for linear equations,
%    Report SAND89-8691, Sandia National Laboratories, Albuquerque,
%    New Mexico, 1989 (Appendix 2).
%    [2] N.M. Nachtigal, L. Reichel and L.N. Trefethen, A hybrid GMRES
%    algorithm for nonsymmetric linear systems, SIAM J. Matrix Anal.
%    Appl., 13 (1992), pp. 796-825.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:42:23 $

if nargin == 1, k = 3; end

G = tril(triu(ones(n)), k) - diag(ones(n-1,1), -1);
