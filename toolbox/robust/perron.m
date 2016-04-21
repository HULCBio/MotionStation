function [MU] = perron(A,K)
%PERRON Perron eigenvalue.
%
% [MU] = PERRON(A) or
% [MU] = PERRON(A,K) produces the scalar upper bound MU on the
% structured singular value (ssv) computed via the Perron
% eigenvalue technique of Safonov (IEE Proc., Pt. D, Nov. '82).
%
% Input:
%     A  -- a pxq complex matrix whose ssv is to be computed
% Optional input:
%     K  -- uncertainty block sizes--default is K=ones(q,2).  K is an
%           an nx1 or nx2 matrix whose rows are the uncertainty block
%           sizes for which the ssv is to be evaluated; K must satisfy
%           sum(K) == [q,p].  If only the first column of K is given then the
%           uncertainty blocks are taken to be square, as if K(:,2)=K(:,1).
% Output:
%     MU -- An upper bound on the structured singular value of A

%
% R. Y. Chiang & M. G. Safonov 8/14/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% --------------------------------------------------------------------
%
[m,n] = size(A);
if nargin == 1
    K = ones(n,1);
end
[s,ck] = size(K);
if ck == 1
   K = [K K];
end
K1c = K(:,2);
K2c = K(:,1);
if sum(abs(K1c))~= m | sum(abs(K2c))~= n,
    error('K and A are not dimensionally compatible')
end
%
% ------ form matrix aa of max singular values of blocks of A
%
if s < n
   aa = zeros(s,s);
   xi_1 = 0;
   for i = 1:s
       x = sum(K1c(1:i));
       yj_1 = 0;
       for j = 1:s
           y = sum(K2c(1:j));
           aa(i,j) = max(svd(A(xi_1+1:x,yj_1+1:y)));
           yj_1 = y;
       end
       xi_1 = x;
   end
   n = s;
else
   aa = abs(A);
end
%
MU = max(real(eig(aa)));
%
% ------ End of PERRON.M --- RYC/MGS 8/14/88