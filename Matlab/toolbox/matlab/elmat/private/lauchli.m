function A = lauchli(n, mu)
%LAUCHLI Lauchli matrix.
%   GALLERY('LAUCHLI',N, MU) is the (N+1)-by-N matrix 
%   [ONES(1,N); MU*EYE(N)]. It is a well-known example in 
%   least squares and other problems that indicates the dangers of 
%   forming A'*A. MU defaults to SQRT(EPS).

%   Reference:
%   [1] P. Lauchli, Jordan-Elimination und Ausgleichung nach
%       kleinsten Quadraten, Numer. Math, 3 (1961), pp. 226-240.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:42:47 $

if nargin < 2, mu = sqrt(eps); end
A = [ones(1,n);
     mu*eye(n)];
