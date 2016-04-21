function K = kron(A,B)
%KRON   Kronecker tensor product.
%   KRON(X,Y) is the Kronecker tensor product of X and Y.
%   The result is a large matrix formed by taking all possible
%   products between the elements of X and those of Y.   For
%   example, if X is 2 by 3, then KRON(X,Y) is
%
%      [ X(1,1)*Y  X(1,2)*Y  X(1,3)*Y
%        X(2,1)*Y  X(2,2)*Y  X(2,3)*Y ]
%
%   If either X or Y is sparse, only nonzero elements are multiplied
%   in the computation, and the result is sparse.

%   Previous versions by Paul Fackler, North Carolina State,
%   and Jordan Rosenthal, Georgia Tech.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.17.4.1 $ $Date: 2004/01/24 09:22:29 $

[ma,na] = size(A);
[mb,nb] = size(B);

if ~issparse(A) && ~issparse(B)

   % Both inputs full, result is full.

   [ia,ib] = meshgrid(1:ma,1:mb);
   [ja,jb] = meshgrid(1:na,1:nb);
   K = A(ia,ja).*B(ib,jb);

else

   % At least one input is sparse, result is sparse.

   [ia,ja,sa] = find(A);
   [ib,jb,sb] = find(B);
   ia = ia(:); ja = ja(:); sa = sa(:);
   ib = ib(:); jb = jb(:); sb = sb(:);
   ka = ones(size(sa));
   kb = ones(size(sb));
   t = mb*(ia-1)';
   ik = t(kb,:)+ib(:,ka);
   t = nb*(ja-1)';
   jk = t(kb,:)+jb(:,ka);
   K = sparse(ik,jk,sb*sa.',ma*mb,na*nb);

end
