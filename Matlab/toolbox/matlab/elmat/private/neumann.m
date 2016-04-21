function [A, T] = neumann(n)
%NEUMANN Singular matrix from the discrete Neumann problem (sparse).
%   C = GALLERY('NEUMANN',N) takes N=M^2, a perfect square or a
%   two-element vector N and returns C, a singular, row
%   diagonally dominant matrix resulting from discretizing the
%   Neumann problem with the usual five point operator on a regular
%   mesh. C is sparse and has a one-dimensional null space with
%   null vector ONES(N,1).

%   Reference:
%   [1] R. J. Plemmons, Regular splittings and the discrete Neumann problem,
%       Numer. Math., 25 (1976), pp. 153-161.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2003/05/19 11:16:10 $

if length(n) == 1
   m = sqrt(n);
   if m^2 ~= n 
     error('MATLAB:newmann:NNotPerfectSquare', 'N must be a perfect square.') 
   end
   n(1) = m; n(2) = m;
end

T = tridiag(n(1), -1, 2, -1);
T(1,2) = -2;
T(n(1),n(1)-1) = -2;

A = kron(T, speye(n(2))) + kron(speye(n(2)), T);
