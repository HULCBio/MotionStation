function [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22]=hinf(varargin)

%     << 4-block Optimal H-inf Controller (all solution formulae) >>
%               (Safonov, Limebeer and Chiang, 1989 IJC)
%
%   [SS_CP,SS_CL,HINFO,TSS_K]=HINF(TSS_P,SS_U,VERBOSE) computes the
%   H-infinity controller F(s) and the controller parameterization K(s)
%   using the "loop-shifting formulae". Given any stable U(s) with
%   || U ||_inf <=1, F(s) is formed by wrapping feedback U(s) around K(s).
%
%   Required inputs --
%      Augmented plant P(s): TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%
%   Optional inputs --
%          Stable contraction U(s): SS_U=MKSYS(AU,BU,CU,DU) (default: U=0)
%          VERBOSE:  if  1,  a verbose display results (default),
%                    if  0, HINF operates silently
%
%   Output data: Controller F(s):        SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%                Closed-Loop Ty1u1(s):   SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%                hinfo = (hinflag,RHP_cl,lamps_max) ("hinflag":existence flag)
%                All-solutions controller parameterization K(s):
%                     TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK22)

% R. Y. Chiang & M. G. Safonov 9/18/1988
% Revised 3/29/98 M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ------------------------------------------------------------------------

% COMMENT:  This function also supports the following format for
% input and output data which is not described above.  Possible
% alternative usages include the following:
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL,HINFO,AK,BK1,BK2,CK1,CK2,DK11,DK12,...
%          DK21,DK22]=HINF(A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,VERBOSE)
%     [ACP,BCP,CCP,DCP,ACP,BCL,CCL,DCL,HINFO,AK,BK1,BK2,CK1,CK2,DK11,DK12,...
%          DK21,DK22]=HINF(A,B1,B2,C1,C2,D11,D12,D21,D22,VERBOSE)
% In all cases, the input data for U(s) and for VERBOSE is optional with
% defaults U(s)=0 and VERBOSE=1.

%
% ----- Initialize all the flags:
%
hexist  = ' OK ';
D11flag = ' OK ';
Pexist  = ' OK ';
Pflag   = ' OK ';
Sexist  = ' OK ';
Sflag   = ' OK ';
PSflag  = ' OK ';
%

%%%%

% Must have nargin<3 (lti version only)
if nargin>3, error('Too many input arguments'),end


%  Expand input arguments or, if none present, load them from main workspace
nag1 = nargin;
nag2 = nargout;
sysuflag=0;       % This flag will be set to one if U(s) data is input

[emsg,nag1,xsflag,Ts,A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,disp_hinf]=mkargs5x('tss,ss',varargin); error(emsg);
               % NAG1  may have changed if U(s) is given as system SS_U
               % or if plant is given is system TSS_P
               
if Ts, % discrete case (call DHINF instead)
   inargs=cell(1,nag1);
   [junk,junk,junk,inargs{:}]=mkargs5x('tss,ss',varargin);
   [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22]=dhinf(inargs{:});
else   % continuous case               
  if nag1==9
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22
     disp_hinf=1;
  elseif nag1==10   % If only 10 input args after expansion
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,disp_hinf
     disp_hinf=AU;
  elseif nag1==13
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU
     sysuflag=1;
     disp_hinf=1;
  elseif nag1==14
     % Case A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,disp_hinf
     sysuflag=1;
  else
     error('Incompatible number or type of input arguments')
  end

%  Create SYSP and DIMP, just in case not already present
sysp=[A B1 B2;C1 D11 D12;C2 D21 D22];
[dimx,dimu1]=size(B1);
[dimy1,dimu2]=size(D12);
[dimy2,dimu2]=size(D22);
dimp=[dimx dimu1 dimu2 dimy1 dimy2];

%%%

%
if disp_hinf == 1;
   disp('   ')
   disp('                << H-inf Optimal Control Synthesis >>')
   disp(' ')
   disp('            Computing the 4-block H-inf optimal controller ')
   disp('          using the S-L-C loop-shifting/descriptor formulae ')
end
%

%  If VERBOSE mode set, display message about U(s)
if sysuflag==0,
   if disp_hinf == 1
      disp('  ')
      disp('     Solving for the H-inf controller F(s) using U(s) = 0 (default)');
   end
else
   if disp_hinf == 1
      disp('  ')
      disp('     Solving for the H-inf controller F(s) using U(s) = (AU,BU,CU,DU)');
   end
end
%
% --------------------------------------------------------
%
% ---------- Checking stabilizability and detectability:
%
[junk,junk,junk,junk,aa,ba,ca,da,m]=...
   stabproj(A,B2,C2,D22);  % get antistable part
if m<min(size(A));
   na=min(size(aa));
   hsv = hksv(-aa-eye(na),ba,ca);
   % Note: -EYE(NA) term in above prevents Inf grammians
   if min(hsv)<(1.e-15)*max(hsv)
      error('Your system is not stabilizable and/or detectable !!');
   end
end

% ----------------------------------------------------------------------------
% ------------------------------------------- Pre-process the augmented plant:
%
% ------------------------------------------- 1) Zero out the D22 term:
%
[mD22,nD22] = size(D22);
d22 = zeros(mD22,nD22);
%
% ------------------------------------------- 2) Do the scaling:
%
[p1,m2] = size(D12);
[uu,sig12,vv] = svd(D12);
if m2>p1, error('      ERROR:  Must have dim(y1) >= dim(u2)'),end
if sig12(m2,m2)<eps, error('ERROR:  D12 must be full rank'),end
u1 = uu(:,1:m2);
u2 = uu(:,m2+1:p1);
SU2 = vv*inv(sig12(1:m2,1:m2));
SY1 = [u2';u1'];
%
[p2,m1] = size(D21);
[uuu,sig21,vvv] = svd(D21);
if p2>m1, error('      ERROR:  Must have dim(u1) >= dim(y2)'),end
if sig21(p2,p2)<eps, error('      ERROR:  D21 must be full rank'),end
v1 = vvv(:,1:p2);
v2 = vvv(:,p2+1:m1);
SY2 = inv(sig21(1:p2,1:p2))*uuu';
SU1 = [v2 v1];
%
b1 = B1*SU1;
b2 = B2*SU2;
c1 = SY1*C1;
c2 = SY2*C2;
d11 = SY1*D11*SU1;
d12 = SY1*D12*SU2;
d21 = SY2*D21*SU1;
%
if disp_hinf == 1
   disp('')
   disp('     Solving Riccati equations and performing H-infinity')
   disp('     existence tests:')
end
%
% ----------------------------------- 3) Checking the frequency @ inf:
%
d1111 = d11(1:p1-m2,1:m1-p2);
d1121 = d11(p1-m2+1:p1,1:m1-p2);
d1112 = d11(1:p1-m2,m1-p2+1:m1);
d1122 = d11(p1-m2+1:p1,m1-p2+1:m1);
mxsvd11r = max([svd([d1111 d1112]);0]);
mxsvd11c = max([svd([d1111;d1121]);0]);
gamainf = max([mxsvd11r,mxsvd11c]);
%
% ----------------------------------- Fix D11 term:
%
if m1 == p2 | p1 == m2
   fopt = -d1122;
else
   fopt  = -(d1122+d1121*inv(eye(m1-p2)-d1111'*d1111)*d1111'*d1112);
end
%
% ---- Fix the "Singular FOPT (if det(I+fopt*SY2*D22*SU2) = 0):
%
imax = 23;
foptscale = 2^(-imax);
fopt1 = fopt;
for i = 1:imax+1
    temp = eye(size(fopt)*[1;0])+fopt1*SY2*D22*SU2;
    svtemp = svd(temp);
    if any(svtemp<1.e-8)
       svfopt = svd(fopt);
       fopt1 = (1+foptscale*(1-gamainf)/svfopt(1,1))*fopt;
    else
       break
    end
    foptscale = 2*foptscale;
end
fopt = fopt1;
%
d11ok = 0;
if gamainf < 1 & foptscale < 1.99
    if disp_hinf == 1
       disp('        1.  Is D11 small enough?                       OK')
    end
else
    if disp_hinf == 1
       disp('        1.  Is D11 small enough?                       FAIL')
    end
    D11flag = 'FAIL'; hexist = 'FAIL';
end
%
a   = A  + b2*fopt*c2;
b1  = b1 + b2*fopt*d21;
c1  = c1 + d12*fopt*c2;
d11 = d11+ d12*fopt*d21;
%
% ----------------------------------- 4) Zero out D11 term via loop shifting:
%
X = d11;
[rX,cX] = size(X);
IXX1 = eye(rX)-X*X';
IXX2 = eye(cX)-X'*X;
IIXX1 = inv(IXX1);
a   = a+b1*X'*IIXX1*c1;
b2  = b2 + b1*X'*IIXX1*d12;
b1  = b1*IXX2^(-0.5);
c2  = c2+d21*X'*IIXX1*c1;
c1  = IXX1^(-0.5)*c1;
d22 = d21*X'*IIXX1*d12;
[rd11,cd11] = size(d11);
d11 = zeros(rd11,cd11);
d12 = IXX1^(-0.5)*d12;
d21 = d21*IXX2^(-0.5);
%
% ----------------------------------- 5) Zero out the new D22 term:
%
d22_4 = d22;
[rd22,cd22] = size(d22);
d22 = zeros(rd22,cd22);
%
% ----------------------------------- 6) Do the scaling again:
%
[p1,m2] = size(d12);
[uu,sig12,vv] = svd(d12);
u1 = uu(:,1:m2);
u2 = uu(:,m2+1:p1);
su2 = vv*inv(sig12(1:m2,1:m2));
sy1 = [u2';u1'];
%
[p2,m1] = size(d21);
[uuu,sig21,vvv] = svd(d21);
v1 = vvv(:,1:p2);
v2 = vvv(:,p2+1:m1);
sy2 = inv(sig21(1:p2,1:p2))*uuu';
su1 = [v2 v1];
%
b1 = b1*su1;
b2 = b2*su2;
c1 = sy1*c1;
c2 = sy2*c2;
d11 = sy1*d11*su1;
d12 = sy1*d12*su2;
d21 = sy2*d21*su1;
%
% ----------------------------------------------------------------------------
%
% ---------------------------------------- Start to compute the controller:
siz = [1 0]';
n = size(A)*siz;
[rd12,cd12] = size(d12);
c1til = (eye(rd12)-d12*d12')*c1;
[rd21,cd21] = size(d21);
b1til = b1*(eye(cd21)-d21'*d21);
%
% ---------------------------------------- Solving the P Riccati:
%
if disp_hinf == 1
   disp('        2.  Solving state-feedback (P) Riccati ...')
end
%
% ------ P =  0, if the Hamiltonian A matrix is stable and D12 is square
%
[rd12,cd12] = size(D12);
ar1 = a-b2*d12'*c1;
if rd12 == cd12
   lamar1 = eig(ar1);
   if max(real(lamar1)) < 0
       ar1flag=1;
   else
       ar1flag=0;
   end
else
   ar1flag=0;
end
if ar1flag == 1
   P2 = zeros(n,n);
   P1 = eye(n);
   P  = zeros(n,n);
   lamp_inf = lamar1;
   wellposed = 'TRUE ';
else
   q1  = c1til'*c1til;
   r1  = -(b1*b1'-b2*b2');
   [P1,P2,lamp,Perr,wellposed] = aresolv(ar1,q1,r1);
   [vpinf,dpinf] = eig(ar1*P1-b2*b2'*P2,P1);
   lamp_inf = diag(dpinf);
   for i = 1:n
     if isinf(lamp_inf(i)) | issame(lamp_inf(i),NaN)
        lamp_inf(i) = 1.e15;
     end
   end
end
if wellposed=='FALSE',
    if disp_hinf == 1
       disp('             a.  No Hamiltonian jw-axis roots?         FAIL')
    end
    Pexist='FAIL'; hexist = 'FAIL';
else
    if disp_hinf == 1
       disp('             a.  No Hamiltonian jw-axis roots?         OK')
    end
end
if max(real(lamp_inf)) > 0
    if disp_hinf == 1
       disp('             b.  A-B2*F stable (P >= 0)?               FAIL')
    end
    Pflag ='FAIL'; hexist = 'FAIL';
else
    if disp_hinf == 1
       disp('             b.  A-B2*F stable (P >= 0)?               OK')
    end
end
%
% ---------------------------------------- Solving the S Riccati:
%
if disp_hinf == 1
   disp('        3.  Solving output-injection (S) Riccati ...')
end
%
% ------ S =  0, if the Hamiltonian A matrix is stable and D21 is square
%
[rd21,cd21] = size(D21);
ar2 = a-b1*d21'*c2;
lamar2 = eig(ar2);
if rd21 == cd21 & max(real(lamar2)) < 0
      S2 = zeros(n,n); Serr = S2;
      S1 = eye(n); S  = zeros(n,n);
      lams_inf = lamar2;
      wellposed = 'TRUE ';
else
   q2  = b1til*b1til';
   r2  = -(c1'*c1-c2'*c2);
   [S1,S2,lams,Serr,wellposed] = aresolv(ar2',q2,r2);
   S1 = S1';
   S2 = S2';
   [vsinf,dsinf] = eig(S1*ar2-S2*c2'*c2,S1);
   lams_inf = diag(dsinf);
   for i = 1:n
      if isinf(lams_inf(i)) | issame(lams_inf(i),NaN)
         lams_inf(i) = 1.e15;
      end
   end
end
if wellposed=='FALSE',
    if disp_hinf == 1
       disp('             a.  No Hamiltonian jw-axis roots?         FAIL')
    end
    Sexist='FAIL'; hexist = 'FAIL';
else
    if disp_hinf == 1
       disp('             a.  No Hamiltonian jw-axis roots?         OK')
    end
end
if max(real(lams_inf)) > 0
    if disp_hinf == 1
       disp('             b.  A-G*C2 stable (S >= 0)?               FAIL')
    end
    Sflag ='FAIL'; hexist = 'FAIL';
else
    if disp_hinf == 1
       disp('             b.  A-G*C2 stable (S >= 0)?               OK')
    end
end
%
[vps,lamps] = eig(P2'*S2',P1'*S1');
lamps = diag(lamps);
for i = 1:n
   if isinf(lamps(i)) | issame(lamps(i),NaN)
      lamps(i) = 1.e15;
   end
end
%
lamps_max = max(real(lamps));
if lamps_max > 1
    if disp_hinf == 1
       disp('        4.  max eig(P*S) < 1 ?                         FAIL')
    end
    PSflag ='FAIL'; hexist = 'FAIL';
else
    if disp_hinf == 1
       disp('        4.  max eig(P*S) < 1 ?                         OK')
    end
end
%
% --------------------------------------- Checking the H-inf solution:
%
if disp_hinf == 1
   disp('    -------------------------------------------------------');
end
if hexist == 'FAIL',
   if disp_hinf == 1
         disp('       NO STABILIZING CONTROLLER MEETS THE SPEC. !!')
   end
else
   if disp_hinf == 1
         disp('       all tests passed -- computing H-inf controller ...')
   end
end
%
% --------------- Controller parameterization K(s) in descriptor form:
%
E = S1*P1-S2*P2;
%
ak   = a-b2*d12'*c1-b1*d21'*c2;
ak   = S1*ak*P1+S2*ak'*P2 + S1*(b1til*b1til'-b2*b2')*P2 + ...
       S2*(c1til'*c1til-c2'*c2)*P1;
bk1  = S2*c2' + S1*b1*d21';
bk2  = S1*b2 + S2*c1'*d12;
ck1  = -(b2'*P2+d12'*c1*P1);
ck2  = -(c2*P1 + d21*b1'*P2);
[rbk1,cbk1] = size(bk1);
[rbk2,cbk2] = size(bk2);
[rck1,cck1] = size(ck1);
[rck2,cck2] = size(ck2);
dk11 = zeros(rck1,cbk1);
dk12 = eye(rck1);
dk21 = eye(rck2);
dk22 = zeros(rck2,cbk2);
%
% ------------------------------------------------------------------------
%
% ------------------------------------ Post-process the controller:
%
% ------------------------------------ 1) Reverse the controller scaling:
%
bk1  = bk1*sy2;
ck1  = su2*ck1;
dk11 = su2*dk11*sy2;
dk12 = su2*dk12;
dk21 = dk21*sy2;
%
% ------------------------------------ 2) Shifting D22_4 term:
%
temp = inv(eye(size(dk11)*[1;0]) + dk11*d22_4);
ak   = ak-bk1*d22_4*temp*ck1;
bk2  = bk2-bk1*d22_4*temp*dk12;
ck2  = ck2-dk21*d22_4*temp*ck1;
ck1  = temp*ck1;
dk22 = dk22-dk21*d22_4*temp*dk12;
dk12 = temp*dk12;
dk11 = temp*dk11;
temp = eye(size(d22_4)*[1;0])-d22_4*dk11;
bk1  = bk1*temp;
dk21 = dk21*temp;
%
% ------------------------------------ 3) Reverse the "fopt" term:
%
dk11 = dk11 + fopt;
%
% ------------------------------------ 4) Reverse the controller scaling again:
%
bk1  = bk1*SY2;
ck1  = SU2*ck1;
dk11 = SU2*dk11*SY2;
dk12 = SU2*dk12;
dk21 = dk21*SY2;
%
% ------------------------------------ 5) Shifting D22 term:
%
temp = inv(eye(size(dk11)*[1;0]) + dk11*D22);
ak   = ak-bk1*D22*temp*ck1;
bk2  = bk2-bk1*D22*temp*dk12;
ck2  = ck2-dk21*D22*temp*ck1;
ck1  = temp*ck1;
dk22 = dk22-dk21*D22*temp*dk12;
dk12 = temp*dk12;
dk11 = temp*dk11;
temp = eye(size(D22)*[1;0])-D22*dk11;
bk1  = bk1*temp;
dk21 = dk21*temp;
%
% ----------------  Putting descriptor controller K(s) in state space form:
%
[ak,bk,ck,dk] = des2ss(ak,[bk1,bk2],[ck1;ck2],...
                         [dk11,dk12;dk21,dk22],E);
bk1=bk(:,1:cbk1);
bk2=bk(:,cbk1+1:cbk1+cbk2);
ck1=ck(1:rck1,:);
ck2=ck(rck1+1:rck1+rck2,:);
dk11=dk(1:rck1,1:cbk1);
dk12=dk(1:rck1,cbk1+1:cbk1+cbk2);
dk21=dk(rck1+1:rck1+rck2,1:cbk1);
dk22=dk(rck1+1:rck1+rck2,cbk1+1:cbk1+cbk2);
%
% --------------------- computing controller F(s) = (acp,bcp,ccp,dcp):
%
sysk = [ak,bk1,bk2;ck1,dk11,dk12;ck2,dk21,dk22];
dimk = [size(ak)*[1 0]',size(bk1)*[0 1]',size(bk2)*[0 1]',...
            size(ck1)*[1 0]',size(ck2)*[1 0]'];
if sysuflag,
   [acp,bcp,ccp,dcp] = lftf(sysk,dimk,AU,BU,CU,DU);
else
   acp = ak; bcp = bk1; ccp = ck1; dcp = dk11;
end
%
% ------------------------------------ Closed-loop TF (Ty1u1):
%
[acl,bcl,ccl,dcl] = lftf(sysp,dimp,acp,bcp,ccp,dcp);
lamcl = eig(acl);
RHP_cl = length(find(real(lamcl)>0));
if RHP_cl > 0
   if disp_hinf == 1
      disp(''),          disp('               -- CLOSED-LOOP UNSTABLE -- ')
   end
   if hexist == ' OK '
      if disp_hinf == 1
                      disp('               CANNOT COMPUTE CONTROLLER')
                      disp('            DUE TO NUMERICAL ROUNDOFF ERRORS')
      end
   end
else
   if disp_hinf == 1
      disp('                         DONE!!!')
      disp('    -------------------------------------------------------');
   end
end
syscp = [acp bcp;ccp dcp]; xcp = size(acp)*[1;0];
syscl = [acl bcl;ccl dcl]; xcl = size(acl)*[1;0];
hinflag = [hexist D11flag Pexist Pflag Sexist Sflag PSflag];
hinfo = [abs(hinflag),RHP_cl,lamps_max];
end % end if Ts

if xsflag,
     % Case     [SS_CP,SS_CL,HINFO,TSS_K]=HINF(TSS_P,SS_U,..)
     acp=mksys(acp,bcp,ccp,dcp,Ts);
     if nag2>1,
           bcp=mksys(acl,bcl,ccl,dcl,Ts);
           ccp=hinfo;
           if nag2>3,
             dcp=mksys(ak,bk1,bk2,ck1,ck2,dk11,dk12,dk21,dk22,Ts,'tss');
           end
     end
end
% If none of the above, then output args remain:
%     [acp,bcp,ccp,dcp,acp,bcl,ccl,dcl,hinfo,ak,bk1,bk2,ck1,ck2,dk11,dk12,...
%          dk21,dk22]=hinf(A,B1,B2,C1,C2,D11,D12,D21,D22,AU,BU,CU,DU,VERBOSE)
%
% ---------- End of LTI/HINF.M --- RYC/MGS -- %