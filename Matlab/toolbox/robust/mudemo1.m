function mudemo1
%MUDEMO1 Demo of MU-synthesis on a simple problem.
%
% See also MUDEMO.

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

clc
echo on

% Plant Data:

a=2;             b1=[.1 -1];          b2=-1;
c1=[1 .01]';    d11=[.1 .2;.01 .01]; d12=[1 0]';
c2=1;           d21=[0  1];          d22=3;
tss_=rct2lti(mksys(a,b1,b2,c1,c2,d11,d12,d21,d22,'tss'));
w=logspace(-2,1);


% H-infinity

[gam0,ss_cp0,ss_cl0]=hinfopt(tss_);
[mu0,logd0]=ssv(ss_cl0,w);

% Mu Synthesis -- Iteration No. 1 (CONSTANT D(s)):

[ss_d1,logd1]=fitd(logd0,w);
ss_d1=rct2lti(ss_d1);
[gam1,ss_cp1,ss_cl1]=hinfopt(augd(tss_,ss_d1));
[mu1,deltalogd]=ssv(ss_cl1,w);



% Mu Synthesis -- Iteration No. 2 (FIRST ORDER D(s)):

[ss_d2,logd2]=fitd(logd1+deltalogd,w,1);
ss_d2=rct2lti(ss_d2);
[gam2,ss_cp2,ss_cl2]=hinfopt(augd(tss_,ss_d2));

% Display Optimal hinf cost closed loop and SSV plot

clf
loglog(w,max(sigma(ss_cl2,w))/gam2,w,ssv(ss_cl2,w)/gam2);
echo off
drawnow
pause
