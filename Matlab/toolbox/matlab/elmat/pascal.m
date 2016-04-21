function P = pascal(n,k)
%PASCAL Pascal matrix.
%   PASCAL(N) is the Pascal matrix of order N: a symmetric positive
%   definite matrix with integer entries, made up from Pascal's
%   triangle.  Its inverse has integer entries.
%
%   PASCAL(N,1) is the lower triangular Cholesky factor (up to signs
%   of columns) of the Pascal matrix.  It is involutary (is its own
%   inverse).
%
%   PASCAL(N,2) is a rotated version of PASCAL(N,1), with sign flipped 
%   if N is even, which is a cube root of the identity.

%   Reference:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Society for Industrial and Applied Mathematics, Philadelphia,
%       1996, Sec. 26.4.
%
%   Nicholas J. Higham, Dec 1999.
%   Author: N.J. Higham 6-23-89
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.13.4.1 $  $Date: 2003/05/01 20:41:53 $

if nargin < 2, k = 0; end

P = diag((-1).^(0:n-1));
P(:,1) = ones(n,1);

% Generate the Pascal Cholesky factor (up to signs).
for j=2:n-1
    for i=j+1:n
        P(i,j) = P(i-1,j) - P(i-1,j-1);
    end
end

if k == 0
    P = P*P';
elseif k == 1
    % P = P
elseif k == 2
   P = rot90(P,3);
   if n/2 == round(n/2), P = -P; end
else
    error('MATLAB:pascal:InvalidArg2', 'Second argument must be 0, 1, or 2.')
end
