function [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl] = dh2lqg(varargin)
%DH2LQG Discrete H2 control synthesis.
%
% [SS_CP,SS_CL] = DH2LQG(TSS_,ARETYPE) computes the discrete H2 controller
%    for an "augmented" plant P(z) with suitable loop-shaping weighting
%    functions such that the H2-norm of the closed-loop transfer function
%    Ty1u1(z) is minimized.  
%
%   Required Input data:
%     Augmented plant P(z): TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%
%   Optional Input:
%     Riccati solver:    aretype = 'eigen' or 'Schur' (default = 'eigen')
%
%   Output data:
%     Controller F(z):     SS_CP = MKSYS(acp,bcp,ccp,dcp)
%     CLTF of Ty1u1(z):    SS_CL = MKSYS(acl,bcl,ccl,dcl)
%
%  Notes: - DH2LQG computes the optimal H2 controller under the constraint  
%           that it must be strictly causal; i.e., the controller's
%           D-matrix is constrained to be zero so that the current
%           value of the control u2(i) depends only on prior values
%           of the measurement signal {y(i-1), y(i-2),y(i-3),etc.}. 
%         - Unlike the continuous H2 theory in which the plant's D11
%           matrix must be zero for the H2 problem to be well-posed, the
%           discrete H2 theory imposes no such requirement. The optimal
%           discrete H2 controller SS_CP does not even depend on D11.

% R. Y. Chiang & M. G. Safonov 2/10/88 (revised 11/11/90 & 10/31/97)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------------

% COMMENT:  This function also supports the format
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL]=...
%          DH2LQG(A,B1,B2,C1,C2,D11,D12,D21,D22,ARETYPE)
% where ARETYPE is optional with default 'eigen'.  If no
% output arguments are supplied the variables (ss_cp,ss_cl,acp,bcp,ccp,
% dcp,acl,bcl,ccl,dcl) are automatically returned in the main workspace.

%
% --------------------------------------------------
%

%  Expand input arguments or, if none present, load them from main workspace
nag1 = nargin;
nag2 = nargout;

[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,aretype]=mkargs5x('tss',varargin); error(emsg);

%  Create SYSP and DIMP, just in case not already present
sysp=[A B1 B2;C1 D11 D12;C2 D21 D22];
[dimx,dimu1]=size(B1);
[dimy1,dimu2]=size(D12);
[dimy2,dimu2]=size(D22);
dimp=[dimx dimu1 dimu2 dimy1 dimy2];

% If aretype is not present, default to ARETYPE='eigen'
if nag1 == 9
  aretype='eigen';
end

%
% ---- Normalization :
%
ml = (D12'*D12)^(0.5);
s1 = inv(ml);
mr = (D21*D21')^(0.5);
s2 = inv(mr);
%
b2 = B2*s1;
c2 = s2*C2;
d12 = D12*s1;
d21 = s2*D21;
d22 = s2*D22*s1;
%
%c1tl = (eye(dimy1)-d12*d12')*C1;
%b1tl = B1*(eye(dimu1)-d21'*d21);
%
% ---- Kc Riccati:
%
ax = A;
bx = b2;
[rb2,cb2] = size(b2);
[rc1,cc1] = size(C1);
[rc2,cc2] = size(c2);
qx = C1'*C1;
rx = eye(cb2);
nx = C1'*d12;

qrnx = [qx nx;nx' rx];
[kkx,x2,xerr] = dlqrc(ax,bx,qrnx,aretype);
%
% ---- Kf Riccati:
%
ay = A';
by = c2';
qy = B1*B1';
ry = eye(rc2);
ny = B1*d21';

qrny = [qy ny;ny' ry];
[kky,y2,yerr] = dlqrc(ay,by,qrny,aretype);
%
kc = kkx;                % also equals to (b2'*x2+d12'*C1);
kf = kky';               % also equals to (y2*c2'+B1*d21');
%
% ---- Compensator :
%
acp = A - kf*c2 - b2*kc + kf*d22*kc;
bcp = kf;
ccp = kc;
[mb,cb] = size(bcp);
[mc,cc] = size(ccp);
%
bcp = bcp*s2;
ccp = -s1*ccp;
dcp = -zeros(mc,cb);
syscp = [acp,bcp;ccp dcp]; xcp = size(acp)*[1;0];
%
% ------------------------------------ Closed-loop TF (Ty1u1):
%
wacp = acp;
wbcp = bcp*inv(s2);
wccp = inv(s1)*ccp;
wdcp = inv(s1)*dcp*inv(s2);
sysp = [A B1 b2;C1 D11 d12;c2 d21 d22];
dimp = [size(A)*[1 0]',...
       size(B1)*[0 1]',size(b2)*[0 1]',...
       size(C1)*[1 0]',size(c2)*[1 0]'];
[acl,bcl,ccl,dcl] = lftf(sysp,dimp,wacp,wbcp,wccp,wdcp);
syscl = [acl bcl;ccl dcl]; xcl = size(acl)*[1;0];
%
% If appropriate convert F(z) and Ty1u1(z) data to format similar
% to the input to DH2LQG:
if xsflag
   % Case     [SS_CP,SS_CL] = DH2LQG(TSS_P,ARETYPE)
   acp=mksys(acp,bcp,ccp,dcp);
   if nag2>1,
         bcp=mksys(acl,bcl,ccl,dcl);
   end
end
% If none of the above, then ...
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL]=...
%                 DH2LQG(A,B1,B2,C1,C2,D11,D12,D21,D22,ARETYPE)
%
% ------------ End of DH2LQG.M 11/11/90 (rev. 10/31/97) RYC/MGS
