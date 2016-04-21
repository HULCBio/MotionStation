% [K,gfin]=klmi(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% Computes a "central" H-infinity controller K(s) given
% the continuous-time plant P(s) and some GAMA > 0. This
% controller
%   * internally stabilizes the plant, and
%   * yields a closed-loop gain no larger than GAMA.
% K(s) is computed from the solutions  X=X2/X1  and  Y=Y2/Y1
% of the two H-infinity Riccati inequalities (LMI approach)
%
% Input:
%  P            plant SYSTEM matrix (see LTISYS)
%  R            size of D22, i.e.,  R = [ NY , NU ]  where
%                      NY = number of measurements
%                      NU = number of controls.
%  GAMA         required H-infinity performance
%  X1,X2,...    X = X2/X1 and  Y = Y2/Y1 are solutions of the
%               two H_infinity Riccati inequalities.
%  TOLRED       optional (default value = 1.0e-4).  Reduced-order
%               synthesis is performed whenever
%                     rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% Output:                                                  -1
%  K            central controller   K(s) = DK + CK (sI-AK)  BK   in
%               SYSTEM matrix form.
%  GFIN         guaranteed closed-loop performance (GAMA may be reset
%               to GFIN > GAMA for numerical stability reasons)
%
%
% See also  HINFLMI, HINFGS.

% Author: P. Gahinet  4/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $


function [Kcen,gfin,flag]=klmi(P,r,gama,x1,x2,y1,y2,tolred)


if nargin<7,
  error('usage: [K,gfin] = klmi(P,r,gama,x1,x2,y1,y2,tolred)');
elseif nargin<8, tolred=1.0e-4;
end


% tolerances
macheps=mach_eps;
tolsing=macheps^(3/8);
toleig=macheps^(2/3);
flag=[0,0];


% retrieve the plant data
[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
[p1,m1]=size(d11); [p2,m2]=size(d22); na=size(a,1);





% SVD's of D12 and D21 : get their rank and invertible parts
% NB: the SV test is performed relatively to B2 to keep
%     || B2 D12^+ || < 1/tolsing

sing12=0; sing21=0;

[u,s,v]=svd(d12);
abstol=max(toleig*norm(b2,1),tolsing*s(1,1));
ratio=max([s;zeros(1,size(s,2))])./...
      max([tolsing*abs(b2*v);abstol*ones(1,m2)]);
ind1=find(ratio >= 1); ind2=find(ratio < 1);  r12=length(ind1);
u1=u(:,ind1); v1=v(:,ind1); v2=v(:,ind2);
sr12=xdiag(s); sr12=sr12(ind1);
if r12<m2,
  s(:,ind2)=zeros(p1,length(ind2)); d12=u*s*v';
  sing12=(norm(b2*v2) > toleig*norm(b2,1));
  % SINGULAR PB if b2*v2 nonzero
end

[u,s,v]=svd(d21');
abstol=max(toleig*norm(c2,1),tolsing*s(1,1));
ratio=max([s;zeros(1,size(s,2))])./...
      max([tolsing*abs(c2'*v);abstol*ones(1,p2)]);
ind1=find(ratio >= 1); ind2=find(ratio < 1);  r21=length(ind1);
z1=u(:,ind1); w1=v(:,ind1); w2=v(:,ind2);
sr21=xdiag(s); sr21=sr21(ind1);
if r21<p2,
  s(:,ind2)=zeros(m1,length(ind2)); d21=v*s'*u';
  sing21=(norm(w2'*c2) > toleig*norm(c2,1));
  % SINGULAR PB if w2'*c2 nonzero
end



% rescale the plant data to keep the conditioning of M,N small
sclf=1;
sclx=sqrt(norm(x2/x1,1));
if sclx > 10,
   c1=c1/sclx; d11=d11/sclx; d12=d12/sclx;  sr12=sr12/sclx;
   gama=gama/sclx;  x1=x1*sclx;  x2=x2/sclx; sclf=sclf*sclx;
end
scly=sqrt(norm(y2/y1,1));
if scly > 10,
   b1=b1/scly; d11=d11/scly; d21=d21/scly;  sr21=sr21/scly;
   gama=gama/scly;  y1=y1*scly;  y2=y2/scly; sclf=sclf*scly;
end



% orthogonalize [x1 x2] and [y1 y2]
if max(max(abs(x1'*x1+x2'*x2-eye(na)))) > .1,
   [q,rr]=qr([x1;x2]);
   x1=q(1:na,1:na);   x2=q(na+(1:na),1:na);
end
if max(max(abs(y1'*y1+y2'*y2-eye(na)))) > .1,
   [q,rr]=qr([y1;y2]);
   y1=q(1:na,1:na);   y2=q(na+(1:na),1:na);
end



% detect full vs reduced
%-----------------------

x2y2=x2'*y2; x1y1=x1'*y1;
gev=eig(x2y2,x1y1);
gama=max(gama,sqrt(max(0,max(real(gev)))));
gama0=gama;

rkred=length(find(gev < (1-tolred)*gama^2));
reduc=(rkred < na);




%%%%%%%%%%%%%%          SYNTHESIS STARTS     %%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       I. ATTEMPT AT REDUCED-ORDER SYNTHESIS IF REDUC=1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while reduc,

%disp('REDUCED')
  gama=gama0;

  [v,s,u]=svd([x1 y2/gama;x2/gama y1]);
  u=u(:,na+(rkred+1:na));
  um=u(1:na,:);  un=u(na+(1:na),:);

  % compute M,N
  [vm,srs,vn]=svd(x2y2/gama^2-x1y1);
  srs=diag(srs);
  shalf=srs(1:rkred).^.5;
  vmr=vm(:,1:rkred);  vnr=vn(:,1:rkred);
  M=vmr*diag(shalf);  N=vnr*diag(shalf);



  % COMPUTE AN ADEQUATE DK BY SOLVING THE ASSOCIATED LMI
  %-----------------------------------------------------

  aux11=-um'*x2'*a*y2*un;   aux21=b1'*x2*um;  aux31=-c1*y2*un;
  M0=[aux11+aux11',aux21',aux31';aux21,-gama*eye(m1),d11';...
                                       aux31,d11,-gama*eye(p1)];
  P0=[b2'*x2*um,zeros(m2,m1),d12'];
  Q0=[-c2*y2*un,d21,zeros(p2,p1)];

  dk=basiclmi(M0,P0,Q0,'Xmin,Shift');

  AA=a+b2*dk*c2;
  BB=b1+b2*dk*d21;
  CC=c1+d12*dk*c2;
  Dcl=d11+d12*dk*d21;

  gama=max(gama,(1+tolsing)*norm(Dcl));
  DELcl=[eye(m1),-Dcl'/gama;-Dcl/gama,eye(p1)];
  DELsq=chol(DELcl)';


  % COMPUTE AN ADEQUATE BK
  % ----------------------


  aux11=y1'*AA*y2;    aux12=y1'*BB;   aux31=CC*y2/gama;
  MB=[aux11+aux11',aux12,aux31';aux12',-eye(m1),Dcl'/gama;...
                                            aux31,Dcl/gama,-eye(p1)];
  PB=[N',zeros(rkred,p1+m1)];
  QB=[c2*y2,d21,zeros(p2,p1)];

  bk=basiclmi(MB,PB,QB,'Shift');

  nbk=N*bk;
  aux=(y1'*AA+nbk*c2)*y2;
  auxB=DELsq\[BB'*y1+d21'*nbk';CC*y2/gama];
  DS = aux+aux'+auxB'*auxB;

%disp(sprintf('max evals of DS/g (basiclmi):  %6.3e',max(real(eig(DS/gama)))));



  % COMPUTE AN ADEQUATE CK
  % ----------------------


  aux11=x2'*AA*x1;  aux12=x2'*BB/gama;   aux31=CC*x1;
  MC=[aux11+aux11',aux12,aux31';aux12',-eye(m1),Dcl'/gama;...
                                            aux31,Dcl/gama,-eye(p1)];
  PC=[b2'*x2,zeros(m2,m1),d12'];
  QC=[M',zeros(rkred,p1+m1)];

  ck=basiclmi(MC,PC,QC,'Shift');

  ckm=ck*M';
  aux1=x2'*(AA*x1+b2*ckm);
  auxC=DELsq\[BB'*x2/gama;CC*x1+d12*ckm];
  DR = aux1+aux1'+auxC'*auxC;

%disp(sprintf('max evals of DR/g (basiclmi):  %6.3e',max(real(eig(DR/gama)))));



  % COMPUTE AK
  %-----------

  [ur,tr]=schur(-DR);
  tr=diag(sqrt(abs(real(diag(tr)))));
  [us,ts]=schur(-DS);
  ts=diag(sqrt(abs(real(diag(ts)))));
  [pr,s,qr1]=svd(tr*ur'*um);
  [ps,s,qs]=svd(ts*us'*un);
  DEL21=us*ts*ps*qs'*qr1*pr'*tr*ur'/gama;

  ak=-diag(1./shalf)*vnr'*(y2'*AA'*x2/gama^2+y1'*AA*x1+N*bk*c2*x1+...
        y1'*b2*ck*M'+auxB'*auxC/gama-DEL21)*vmr*diag(1./shalf);

%disp(sprintf('max eig of [DR/gama DEL21''; DEL21 DS/gama]: %6.3e ',...
%  max(real(eig([DR/gama DEL21'; DEL21 DS/gama])))));


  % CHECK RESULTS
  % --------------

  reduc=0;

  if max(real(eig([AA b2*ck;bk*c2  ak]))) >= 0,
     tolred=tolred/100;
     if tolred < toleig,
        rkred=na; gama0=1.001*gama0;
     else
        rkred=max(rkred+1,length(find(gev < (1-tolred)*gama0^2)));
     end
     reduc=(rkred<na);
  end


end  % while reduc,



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              II. FULL-ORDER SYNTHESIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if rkred==na,

  gama=gama0;


  % Compute DK such that || Dcl || < gama
  % -------------------------------------


  nd11=norm(d11);
  if nd11 < .95*gama,
     dk=zeros(m2,p2);
  else
     % determine dk via a constrained Parrott pb
     dk=getdk(d11,b2,c2,d12,d21,gama,...
                        norm(b1'*x2,1),norm(c1*y2,1),0,tolsing);
     gama=max(gama,1.01*norm(d11+d12*dk*d21));
  end
  if ~isempty(v1) & ~isempty(w1),  dk=v1*v1'*dk*w1*w1'; end


  % factorization of x2*y2/g^2-x1*y1
  [vm,srs,vn]=svd(x2y2/gama^2-x1y1);
  shalf=sqrt(diag(srs));


  AA=a+b2*dk*c2;
  BB=b1+b2*dk*d21;
  CC=c1+d12*dk*c2;
  Dcl=d11+d12*dk*d21;

  DELcl=[eye(m1),-Dcl'/gama;-Dcl/gama,eye(p1)];
  DELsq=chol(DELcl)';


  % Compute BK , CK , AK
  % --------------------


  % compute  thetaB

  if r21==0,
    thetaB=zeros(p2,na);
  else
    nor21=min(0.1,sr21(1));
    thetaB=-[zeros(r21),diag(sr21)*z1'/nor21,zeros(r21,p1);...
             z1*diag(sr21)/nor21,-eye(m1),Dcl'/gama;zeros(p1,r21),...
             Dcl/gama,-eye(p1)]\[w1'*c2*y2/nor21;b1'*y1;CC*y2/gama];
    thetaB=w1*thetaB(1:r21,:)/nor21;
  end
  auxB=DELsq\[b1'*y1+d21'*thetaB;CC*y2/gama];

%disp(sprintf('norm of thetaB:  %6.3e ',norm(thetaB)))

  if sing21,
    % Singular pb: add  phiB s.t.   DS0 + y2'*c2'*w2*w2'*phiB + ()' < 0
    aux=(y1'*a+thetaB'*c2)*y2;
    DS0=aux+aux'+auxB'*auxB;
    thetaB=thetaB+w2*getphi(DS0,w2'*c2*y2,max(10,.1*norm(thetaB,1)));
  end


  % compute thetaC

  if r12==0,
    thetaC=zeros(m2,na);
  else
    nor12=min(0.1,sr12(1));
    thetaC=-[zeros(r12,r12+m1),(diag(sr12)*u1')/nor12;zeros(m1,r12),...
             -eye(m1),Dcl'/gama;u1*diag(sr12)/nor12,Dcl/gama,-eye(p1)]\...
                  [v1'*b2'*x2/nor12;BB'*x2/gama;c1*x1];
    thetaC=v1*thetaC(1:r12,:)/nor12;
  end
  auxC=DELsq\[BB'*x2/gama;c1*x1+d12*thetaC];

%disp(sprintf('norm of thetaC:  %6.3e ',norm(thetaC)))

  if sing12,
    % Singular pb: add  phiC s.t.   DR0 + x2'*b2*v2*v2'*phiC + ()' < 0
    aux=x2'*(a*x1+b2*thetaC);
    DR0=aux+aux'+auxC'*auxC;
    thetaC=thetaC+v2*getphi(DR0,v2'*b2'*x2,max(10,.1*norm(thetaC,1)));
  end



  bk=diag(1./shalf)*vn'*(thetaB'-y1'*b2*dk);
  ck=(thetaC-dk*c2*x1)*vm*diag(1./shalf);

  aux=b2*dk*c2;
  ak=-diag(1./shalf)*vn'*(y2'*(a+aux)'*x2/gama^2+y1'*(a-aux)*x1+...
      thetaB'*c2*x1+y1'*b2*thetaC+auxB'*auxC/gama)*vm*diag(1./shalf);

end



% post-analysis
%%%%%%%%%%%%%%%

if norm(ck,1) > 1e5, flag(1)=1; end
if norm(bk,1) > 1e5, flag(2)=1; end

Kcen=ltisys(ak,bk,ck,dk);
gfin=gama*sclf;




%%%%%%%%%%%%%%%% TMP %%%%%%%%%%%%
%
%norm_ak_dk=[norm(ak) norm(bk) norm(ck) norm(dk)]
%
%
%[vm,srs,vn]=svd(x2y2/gama^2-x1y1);
%srs=diag(srs);
%shalf=srs(1:rkred).^.5;
%vmr=vm(:,1:rkred);  vnr=vn(:,1:rkred);
%M=vmr*diag(shalf);  N=vnr*diag(shalf);
%rk=size(M,2);
%Pcl=[x1 y2/gama;M' zeros(rk,na)];
%Qcl=[x2/gama  y1; zeros(rk,na) N'];
%Acl=[AA b2*ck;bk*c2  ak];
%Bcl=[BB;bk*d21];
%Ccl=[CC d12*ck];

%BRL=[Pcl'*Acl'*Qcl+Qcl'*Acl*Pcl  Qcl'*Bcl  Pcl'*Ccl';...
%     Bcl'*Qcl   -gama*eye(m1)  Dcl'; Ccl*Pcl  Dcl  -gama*eye(p1)];

%eigBRL=eig(BRL)
%eigX=eig(Qcl/Pcl)

%BRLr=Pcl'*Acl'*Qcl+Qcl'*Acl*Pcl-[Qcl'*Bcl  Pcl'*Ccl']*pinv(...
%     [-gama*eye(m1)  Dcl'; Dcl -gama*eye(p1) ],tolsing*gama)*...
%     [Qcl'*Bcl  Pcl'*Ccl']';

%eigBRLr=eig(BRLr)
%eigDRR_DR=[eig(BRLr(1:na,1:na)) eig(DR/gama)]
%eigDSS_DS=[eig(BRLr(na+(1:na),na+(1:na))) eig(DS/gama)]


