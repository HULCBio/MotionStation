function A = condex(n, k, theta)
%CONDEX "Counter-examples" to matrix condition number estimators.
%   GALLERY('CONDEX',N,K,THETA) is a "counter-example" matrix to a
%   condition estimator. It has order N and scalar parameter
%   THETA (default 100). The matrix, its natural size, and the
%   estimator to which it applies are specified by K as follows:
%      K = 1:   4-by-4,     LINPACK.
%      K = 2:   3-by-3,     LINPACK.
%      K = 3:   arbitrary,  LINPACK (independent of THETA)
%      K = 4:   N >= 4,     LAPACK (RCOND) (default).
%                           It is the inverse of this matrix
%                           that is a counter-example.
%   If N is not equal to the natural size of the matrix, then
%   the matrix is padded out with an identity matrix to order N.

%   Note: In practice, the K = 4 matrix is not usually a counter-example
%   because of the rounding errors in forming it.
%
%   References:
%   [1] A. K. Cline and R. K. Rew, A set of counter-examples to three
%       condition number estimators, SIAM J. Sci. Stat. Comput.,
%       4 (1983), pp. 602-611.
%   [2] N. J. Higham, FORTRAN codes for estimating the one-norm of a
%       real or complex matrix, with applications to condition
%       estimation (Algorithm 674), ACM Trans. Math. Soft., 14 (1988),
%       pp. 381-396.
%   [3] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Society for Industrial and Applied Mathematics, Philadelphia,
%       1996, Chap. 14.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/24 09:21:40 $

if nargin < 3, theta = 100; end
if nargin < 2, k = 4; end

if k == 1    % Cline and Rew (1983), Example B.

   A = [1  -1  -2*theta     0
        0   1     theta  -theta
        0   1   1+theta  -(theta+1)
        0   0   0         theta];

elseif k == 2   % Cline and Rew (1983), Example C.

   A = [1   1-2/theta^2  -2
        0   1/theta      -1/theta
        0   0             1];

elseif k == 3    % Cline and Rew (1983), Example D.

    A = triw(n,-1)';
    A(n,n) = -1;

elseif k == 4    % Higham (1988), p. 390; Higham (1996), p. 296.

    x = ones(n,3);            %  First col is e
    x(2:n,2) = zeros(n-1,1);  %  Second col is e(1)

    % Third col is special vector b.
    x(:, 3) = (-1).^(0:n-1)' .* ( 1 + (0:n-1)'/(n-1) );

    Q = orth(x);  %  Q*Q' is now the orthogonal projector onto span(e(1),e,b)).
    P = eye(n) - Q*Q';
    A = eye(n) + theta*P;

end

% Pad out with identity as necessary.
m = length(A);
if m < n
   for i=n:-1:m+1, A(i,i) = 1; end
end
