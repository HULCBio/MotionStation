function C = chebvand(m,p)
%CHEBVAND Vandermonde-like matrix for the Chebyshev polynomials.
%   C = GALLERY('CHEBVAND',P), where P is a vector, produces the
%   (primal) Chebyshev Vandermonde matrix based on the points P:
%      C(i,j) = T_{i-1}(P(j)), where T_{i-1} is the Chebyshev
%      polynomial of degree i-1.
%   GALLERY('CHEBVAND',M,P) is a rectangular version of
%   GALLERY('CHEBVAND',P) with M rows.
%   Special case: If P is a scalar, then P equally spaced points on
%      [0,1] are used.

%   Reference:
%   [1] N. J. Higham, Stability analysis of algorithms for solving confluent
%       Vandermonde-like systems, SIAM J. Matrix Anal. Appl., 11 (1990),
%       pp. 23-41.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:41:56 $

if nargin == 1, p = m; end
n = length(p);

%  Handle scalar p.
if n == 1
   n = p;
   p = linspace(0,1,n);
end

if nargin == 1, m = n; end

p = p(:).';                    % Ensure p is a row vector.
C = ones(m,n);
if m == 1, return, end
C(2,:) = p;
%      Use Chebyshev polynomial recurrence.
for i=3:m
    C(i,:) = 2.*p.*C(i-1,:) - C(i-2,:);
end
