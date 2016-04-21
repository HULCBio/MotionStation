function X = lrscale(X,L,R)
%LRSCALE  Applies left and right scaling matrices.
%
%   Y = LRSCALE(X,L,R) forms Y = diag(L) * X * diag(R) in 
%   2mn flops if X is m-by-n.  L=[] or R=[] is interpreted
%   as the identity matrix.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:14:56 $
[m,n] = size(X);
if ~isempty(L)
   L = reshape(L,m,1);
   X = L(:,ones(1,n)) .* X;
end
if ~isempty(R)
   R = reshape(R,1,n);
   X = X .* R(ones(1,m),:);
end