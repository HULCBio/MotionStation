function [am,bm,cm,dm] = sfl(varargin)
%SFL Left spectral factorization.
%
% [SS_M] = SFL(SS_) or
% [AM,BM,CM,DM] = SFL(A,B,C,D) produces a left spectral factorization
%       such that
%
%                 M'(-s) M(s) = I - G'(-s)G(s).
%
%                Input data:  G(s):= SS_ = MKSYS(A,B,C,D);
%                Output data: M(s):= SS_M = MKSYS(AM,BM,CM,DM);
%
%  The regular state-space can be recovered by "branch".

% R. Y. Chiang & M. G. Safonov 7/85/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------
%
nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

hfnm = normhinf(a,b,c,d);
if (hfnm >= 1)
   disp('WARNING: Your System Has H-Infinity Norm Larger Than 1 ! Result Is Incorrect.');
end

[rd,cd] = size(d*d');
[rdd,cdd] = size(d'*d);
rricx = eye(cdd) - d'*d;
deln1 = inv(rricx);
aricx = a + b*deln1 * d' * c;
qricx = -c' * (eye(cd) + d * deln1 * d') * c;
qrnx = diagmx(qricx,rricx);
[kx,x] = lqrc(aricx,b,qrnx);
f1 = -deln1 * (b' * x - d' * c);
[ra,ca] = size(a);
qrny = diagmx(zeros(ra,ca),deln1);
[ky,y] = lqrc(a',f1',qrny);
f2 = -(b * deln1 + y * f1') * rricx;
%
% ------ State Space of M :
%
am = a + b * f1 + f2 * f1;
bm = f2;
ddd = rricx^(0.5);
cm = ddd * f1;
dm = ddd;
%
if xsflag
   am = mksys(am,bm,cm,dm);
end
%
% ------ End of SFL.M ---- RYC/MGS 7/85/87 %