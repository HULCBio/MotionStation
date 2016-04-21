function [U,T] = rsf2csf(U,T)
%RSF2CSF Real block diagonal form to complex diagonal form.
%   [U,T] = RSF2CSF(U,T) transforms the outputs of SCHUR(X) (where X
%   is real) from Real Schur Form to Complex Schur Form.  The Real
%   Schur Form has the real eigenvalues on the diagonal and the
%   complex eigenvalues in 2-by-2 blocks on the diagonal.  The Complex
%   Schur Form is upper triangular with the eigenvalues of X on the
%   diagonal.
%   
%   Arguments U and T represent the unitary and Schur forms of a 
%   matrix A, such that A = U*T*U' and U'*U = eye(size(A)).
%
%   Class support for inputs U,T:
%      float: double, single
%
%   See also SCHUR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:30:10 $

% Find complex unitary similarities to zero subdiagonal elements.
[n,n] = size(T);
for m = n:-1:2
   if abs(T(m,m-1)) > eps(class(T))*(abs(T(m-1,m-1))+abs(T(m,m)));
      k = m-1:m;
      mu = eig(T(k,k)) - T(m,m);
      r = norm([mu(1), T(m,m-1)]);
      c = mu(1)/r;  s = T(m,m-1)/r;
      G = [c' s; -s c];
      j = m-1:n;  T(k,j) = G*T(k,j);
      i = 1:m;  T(i,k) = T(i,k)*G';
      i = 1:n;  U(i,k) = U(i,k)*G';
   end
   T(m,m-1) = 0;
end
