function P = pei(n, alpha)
%PEI    Pei matrix.
%   GALLERY('PEI',N,ALPHA), where ALPHA is a scalar, is the symmetric 
%   matrix ALPHA*EYE(N) + ONES(N). The default for ALPHA is 1.
%   The matrix is singular for ALPHA = 0, -N.

%   Reference:
%   [1] M.L. Pei, A test matrix for inversion procedures, Comm. ACM, 
%   5 (1962), p. 508.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:43:11 $

if nargin == 1, alpha = 1; end

P = alpha*eye(n) + ones(n);
