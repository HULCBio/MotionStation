function A = fiedler(c)
%FIEDLER Fiedler matrix.
%   A = GALLERY('FIEDLER',C), where C is an N-vector, is the N-by-N 
%   symmetric matrix with elements ABS(C(i)-C(j)). If C is a scalar, 
%   then A = GALLERY('FIEDLER',1:C).
%
%   A has a dominant positive eigenvalue and all the other eigenvalues
%   are negative. (Szego 1936)
%
%   Note: Explicit formulas for INV(A) and DET(A) are given in (Todd 1977)
%   and attributed to Fiedler. These indicate that INV(A) is 
%   tridiagonal except for nonzero (1,n) and (n,1) elements.

%   References:
%     [1] G. Szego, Solution to problem 3705, Amer. Math. Monthly,
%       43 (1936), pp. 246-259.
%     [2] J. Todd, Basic Numerical Mathematics, Vol. 2: Numerical Algebra,
%       Birkhauser, Basel, and Academic Press, New York, 1977, p. 159.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:42:11 $

n = length(c);

%  Handle scalar c.
if n == 1
   n = c;
   c = 1:n;
end

c = c(:).';                    % Ensure c is a row vector.

A = ones(n,1)*c;
A = abs(A - A.');              % NB. array transpose.
