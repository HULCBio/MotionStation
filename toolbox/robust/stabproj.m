function [a11h,b1h,c1h,d1h,a22h,b2h,c2h,d2h,m] = stabproj(varargin)
%STABPROJ State-space stable/anti-stable decomposition.
%
% [SS_1,SS_2,M] = STABPROJ(SS_) or
% [A11H,B1H,C1H,D1H,A22H,B2H,C2H,D2H,M] = STABPROJ(A,B,C,D) produces
%     a decomposition of G(s) as the sum of its stable part G1(s) and
%     its antistable part G2(s) where
%
%                  G(s):= ss_ = mksys(a,b,c,d);
%                  G1(s):= ss_1 = mksys(a11h,b1h,c1h,d1h);
%                  G2(s):= ss_2 = mksys(a22h,b2h,c2h,d2h);
%
%  The regular state-space can be recovered by "branch".

% R. Y. Chiang & M. G. Safonov 7/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[ra,ca] = size(a);
[rd,cd] = size(d);
%
% ----- Real Schur Decomposition :
%
[u,t,m] = blkrsch(a,1);
%
kk = -1;
if m == 0.
  a22h = a; b2h = b; c2h = c; d2h = d;
  a11h = zeros(ra); b1h = zeros(ra,cd); c1h = zeros(rd,ca); d1h = zeros(rd,cd);
  kk = 1;
end
if m == ra
  a11h = a; b1h = b; c1h = c; d1h = zeros(rd,cd);
  a22h = zeros(ra);  b2h = zeros(ra,cd); c2h = zeros(rd,ca); d2h = d;
  kk = 1;
end
if kk < 0
    a11h = t(1:m,1:m);
    a22h = t(m+1:ra,m+1:ra);
    a12h = t(1:m,m+1:ra);
    v1 = u(:,1:m); v2 = u(:,m+1:ra);
    x = lyap(a11h,-a22h,a12h);
    t1 = v1;
    t2 = v1 * x + v2;
    s1 = v1' - x * v2';
    s2 = v2';
    b1h = s1 * b;    b2h = s2 * b;
    c1h = c * t1;    c2h = c * t2;
    [rb1h,cb1h] = size(b1h);
    [rc1h,cc1h] = size(c1h);
    d1h = zeros(rc1h,cb1h);    d2h = d;
end
%
if xsflag
   a11h = mksys(a11h,b1h,c1h,d1h);
   b1h = mksys(a22h,b2h,c2h,d2h);
   c1h = m;
end
%
% ------ End of STABPROJ.M ---- RYC/MGS 7/85 %