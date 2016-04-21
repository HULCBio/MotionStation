function [abal,bbal,cbal,g,t] = dobal(a,b,c)
%DOBAL Discrete balanced realization (Moore's SVD algorithm).
%
% [ABAL,BBAL,CBAL,G,T] = DOBAL(A,B,C) produces a discrete balanced
%    realization using B. C. Moore's SVD algorithm.
%
%           G : diagonal of the balanced grammian (ordered)
%           T : balancing transformation
%

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------

p = dgram(a,b);
q = dgram(a',c');
[up,sp,vp] = svd(p);
sph = diag(diag(sp).^0.5);
t1 = up*sph;
qq = t1'*q*t1;
[uqq,sqq,vqq] = svd(qq);
sq = diag(diag(sqq).^0.25);
t2 = uqq*inv(sq);
t = t1*t2;
abal = t \ a * t;
bbal = t \ b;
cbal = c * t;
g = diag(dgram(abal,bbal))';
%
% ----- End of OBALREAL.M --- RYC/MGS 8/85 %