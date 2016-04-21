function Z = null(A,how)
%NULL   Null space.
%   Z = NULL(A) is an orthonormal basis for the null space of A obtained
%   from the singular value decomposition.  That is,  A*Z has negligible
%   elements, size(Z,2) is the nullity of A, and Z'*Z = I.
%
%   Z = NULL(A,'r') is a "rational" basis for the null space obtained
%   from the reduced row echelon form.  A*Z is zero, size(Z,2) is an
%   estimate for the nullity of A, and, if A is a small matrix with 
%   integer elements, the elements of R are ratios of small integers.  
%
%   The orthonormal basis is preferable numerically, while the rational
%   basis may be preferable pedagogically.
%
%   Example:
%
%       A =
%
%           1     2     3
%           1     2     3
%           1     2     3
%
%      null(A) = 
%
%         -0.1690   -0.9487
%          0.8452    0.0000
%         -0.5071    0.3162
%
%      null(A,'r') = 
%
%          -2    -3
%           1     0
%           0     1
%
%   Class support for input A:
%      float: double, single
%
%   See also SVD, ORTH, RANK, RREF.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2004/04/10 23:30:03 $

[m,n] = size(A);
if (nargin > 1) && isequal(how,'r')

   % Rational basis

   [R,pivcol] = rref(A);
   r = length(pivcol);
   nopiv = 1:n;
   nopiv(pivcol) = [];
   Z = zeros(n,n-r,class(A));
   if n > r
      Z(nopiv,:) = eye(n-r,n-r,class(A));
      if r > 0
         Z(pivcol,:) = -R(1:r,nopiv);
      end
   end
else
   
   % Orthonormal basis

   [U,S,V] = svd(A,0);
   if m > 1, s = diag(S);
      elseif m == 1, s = S(1);
      else s = 0;
   end
   tol = max(m,n) * max(s) * eps(class(A));
   r = sum(s > tol);
   Z = V(:,r+1:n);
end
