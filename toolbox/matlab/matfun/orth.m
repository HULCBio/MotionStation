function Q = orth(A)
%ORTH   Orthogonalization.
%   Q = ORTH(A) is an orthonormal basis for the range of A.
%   That is, Q'*Q = I, the columns of Q span the same space as 
%   the columns of A, and the number of columns of Q is the 
%   rank of A.
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, RANK, NULL.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2004/04/10 23:30:04 $

% Beginning with MATLAB 4.1, the algorithms for NULL and ORTH 
% use singular value decomposition, SVD, instead of orthogonal
% factorization, QR.  This doubles the computation time, but
% provides more reliable and consistent rank determination.

[U,S,V] = svd(A,0);
[m,n] = size(A);
if m > 1, s = diag(S);
   elseif m == 1, s = S(1);
   else s = 0;
end
tol = max(m,n) * max(s) * eps(class(A));
r = sum(s > tol);
Q = U(:,1:r);

%-------------
%
% Here is the old code.  Use it for faster computation, or for
% generating the same results as earlier versions of MATLAB.
%
%   % QR decomposition
%   [Q,R,E]=qr(A);
%   % Determine r = effective rank
%   tol = eps*norm(A,'fro');
%   r = sum(abs(diag(R)) > tol);
%   r = r(1); % fix for case where R is vector.
%   % Use first r columns of Q.
%   if r > 0
%      Q = Q(:,1:r);
%      % Cosmetic sign adjustment
%      Q = -Q;
%      Q(:,r) = -Q(:,r);
%   else
%      Q = [];
%   end
