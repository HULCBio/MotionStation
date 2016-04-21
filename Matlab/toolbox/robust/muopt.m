function [r,As,logd,x] = muopt(A,K);
%MUOPT Mixed real/complex structured singular value.
%
% [r,As,logd,x] = muopt(A) or muopt(A,K) produces the scalar upper bound
% r on the real or complex structured singular value (ssv) computed via
% the interior point method of Fan and Nekooie.
% Input:
%     A  -- an nxn complex matrix whose ssv is to be computed.
% Optional input:
%     K  -- an nx1 vector whose rows are the uncertainty block sizes
%           for which the ssv is to be evaluated; K must satisfy
%           sum(K)=n. Real uncertainty (must be scalar) is indicated
%           by multiplying the corresponding row of K by minus one,
%           e.g., if the second uncertainty block is real then set
%           K(2)=-1.
% Outputs:
%     r    -- an upper bound on the structured singular value of A.
%     As   -- r*(I-Ms)/(I+Ms) where Ms = Dt*(r*I-A)/(r*I)+A)/Dt',
%             Dt = Mult^0.5, and Mult = D^2 + sqrt(-1)*G/r
%             is the optimal generalized Popov multiplier
%             (see musol4.m for the definition of the matrices D and G).
%     logd -- 0.5*log(diag(Mult)).
%     x    -- the normalized eigenvector associated with the smallest
%             eigenvalue of X+X'>=0, where X=Mult*(r*I-A)/(r*I+A).

% Author: Michael Fan 12/94
%
% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

nag1 = nargin;

if nag1 == 1,
   K = ones(length(A),1);
   T = 2*K;
else
   K = K(:,1);
   T = 2*(K > 0) + (K < 0);
   K = abs(K);
end

% calling musol4
[r,D,G] = musol4(A,K,T);

% compute Mult
Mult = D^2 + sqrt(-1)*G/r;

% compute logd
logd = 0.5*log(diag(Mult));

% compute As
Dt = diag(sqrt(diag(Mult)));
n  = length(A);
Ms = Dt*(r*eye(n)-A)/(r*eye(n)+A)/Dt';
As = r*(eye(n)-Ms)/(eye(n)+Ms);

% compute x
X = Mult*(r*eye(n)-A)/(r*eye(n)+A);
[U,e] = eig(X'+X);
[e,index] = sort(real(diag(-e)));
U = U(:,index);
x = U(:,n);
x = x/norm(x);


% ----------- End of MUOPT.M %
