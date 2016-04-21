function A = rando(n, k)
%RANDO  Random matrix with elements -1, 0 or 1.
%   A = GALLERY('RANDO',N,K) is a random N-by-N matrix with 
%   elements from one of the following discrete distributions 
%   (default K = 1):
%      K = 1:  A(i,j) =  0 or 1    with equal probability,
%      K = 2:  A(i,j) = -1 or 1    with equal probability,
%      K = 3:  A(i,j) = -1, 0 or 1 with equal probability.
%   N may be a 2-vector, in which case the matrix is N(1)-by-N(2).

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:41:02 $

if nargin < 2, k = 1; end

m = n(1);                    % Parameter n specifies dimension: m-by-n.
n = n(length(n));

if k == 1                    % {0, 1}
   A = floor( rand(m,n) + .5 );
elseif k == 2                % {-1, 1}
   A = 2*floor( rand(m,n) + .5 ) - 1;
elseif k == 3                % {-1, 0, 1}
   A = round( 3*rand(m,n) - 1.5 );
end
