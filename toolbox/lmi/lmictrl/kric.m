% [K,gfin]=kric(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% Computes a "central" H-infinity controller K(s) given
% the REGULAR continuous-time plant P(s) and some GAMA > 0.
% This controller
%   * internally stabilizes the plant, and
%   * yields a closed-loop gain no larger than GAMA.
% K(s) is computed from the stabilizing solutions  X=X2/X1
% and  Y=Y2/Y1  of the two H_infinity Riccati equations.
%
% Input:
%  P           plant SYSTEM matrix (see LTISYS)
%  R           size of D22, i.e.,  R = [ NY , NU ]  where
%                     NY = number of measurements
%                     NU = number of controls.
%  GAMA        required H-infinity performance
%  X1,X2,...   X = X2/X1 and  Y = Y2/Y1 are the stabilizing
%              solutions of the two H_infinity Riccati equations.
%  TOLRED      optional (default value = 1.0e-4).  Reduced-order
%              synthesis is performed whenever
%                   rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% Output:                                                -1
%  K           central controller  K(s) = DK + CK (sI-AK)  BK  in
%              SYSTEM matrix form.
%  GFIN        guaranteed closed-loop performance (GAMA may be reset
%              to GFIN > GAMA for numerical stability reasons)
%
% See also  HINFRIC.

% Authors: P. Gahinet and A.J. Laub   4/94
% Copyright 1995-2004 The MathWorks, Inc.
% $Date: 2004/04/10 23:21:13 $   $Revision: 1.7.4.3 $


function [Kcen,gfin]=kric(P,r,gama,x1,x2,y1,y2,tolred,knobrk)


if nargin<7,
  error('usage: [K,gfin] = kric(P,r,gama,x1,x2,y1,y2,tolred)');
elseif nargin<8, tolred=1.0e-4; knobrk=0;
end


% tolerances
macheps=mach_eps;
tolsing=macheps^(3/8);
toleig=macheps^(2/3);


% retrieve the plant data
[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
[p1,m1]=size(d11); [p2,m2]=size(d22); na=size(a,1);


% rescale the plant data to keep the conditioning of M,N small
sclf=1;
sclx=sqrt(norm(x2/x1,1));
if sclx > 10,
   c1=c1/sclx; d11=d11/sclx; d12=d12/sclx;
   gama=gama/sclx;  x1=x1*sclx;  x2=x2/sclx; sclf=sclf*sclx;
end
scly=sqrt(norm(y2/y1,1));
if scly > 10,
   b1=b1/scly; d11=d11/scly; d21=d21/scly;
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


% SVD's of D12 and D21

[u1,sr12,v1]=svd(d12);
sr12=diag(sr12(1:m2,1:m2));
if p1>m2, u2=u1(:,m2+1:p1); end
u1=u1(:,1:m2);

[w1,sr21,z1]=svd(d21);
sr21=diag(sr21(1:p2,1:p2));
if m1>p2, z2=z1(:,p2+1:m1); end
z1=z1(:,1:p2);


% detect full vs reduced
%-----------------------

x2y2=x2'*y2; x1y1=x1'*y1;
gev=eig(x2y2,x1y1);
gama=max(gama,sqrt(max(0,max(real(gev)))));
gama0=gama;

rkred=length(find(gev < (1-tolred)*gama^2));
reduc=(rkred < na);



%%%%%%%%%%%%%%      SYNTHESIS STARTS       %%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       I. ATTEMPT AT REDUCED-ORDER SYNTHESIS IF REDUC=1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while reduc,

  gama=gama0;

  [v,s,u]=svd([x1 y2/gama;x2/gama y1]);
  u=u(:,na+(rkred+1:na));
  um=u(1:na,:);  un=u(na+(1:na),:);

  % compute M,N
  [vm,srs,vn]=svd(x2y2/gama^2-x1y1);
  srs=diag(srs);
  shalf=sqrt(srs(1:rkred));
  vmr=vm(:,1:rkred);  vnr=vn(:,1:rkred);
  M=vmr*diag(shalf);  N=vnr*diag(shalf);



  % COMPUTE AN ADEQUATE DK BY SOLVING THE CORRESPONDING LMI
  %--------------------------------------------------------

  aux11=-um'*x2'*a*y2*un;   aux21=b1'*x2*um;  aux31=-c1*y2*un;
  M0=[aux11+aux11',aux21',aux31';aux21,-gama*eye(m1),d11';...
                                       aux31,d11,-gama*eye(p1)];
  P0=[b2'*x2*um,zeros(m2,m1),d12'];
  Q0=[-c2*y2*un,d21,zeros(p2,p1)];

%  dktmp=basiclmi(M0,P0,Q0,'Shift');
  dk=basiclmi(M0,P0,Q0,'Xmin,Shift');
%disp(sprintf('norm of dk w/o ''Xmin'' option : %6.6e', norm(dktmp)));
%disp(sprintf('norm of dk with ''Xmin'' option : %6.6e', norm(dk)));


%disp(sprintf('largest eval of DK - LMI : %6.6e',max(real(eig(M0+P0'*dk*Q0+Q0'*dk'*P0))))),


  AA=a+b2*dk*c2;
  BB=b1+b2*dk*d21;
  CC=c1+d12*dk*c2;
  Dcl=d11+d12*dk*d21;

  gama=max(gama,(1+tolsing)*norm(Dcl));
  DELcl=[eye(m1),-Dcl'/gama;-Dcl/gama,eye(p1)];
  DELsq=chol(DELcl)';

%  Use this instead to avoid ill-cond. inversion of DELsq?
%  [u,t]=schur(DELcl);
%  t=real(diag(t)); ind=find(t > 1e-4);
%  tsqi=zeros(size(t)); tsqi(ind)=sqrt(1./t(ind));
%  DELsqi=diag(tsqi)*u';





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

%disp('REDUCED FAILED');
     tolred=tolred/100;
     if tolred < toleig,
        rkred=na;
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
                      norm(b1'*x2,1),norm(c1*y2,1),knobrk,tolsing);
     gama=max(gama,1.01*norm(d11+d12*dk*d21));
  end


  % factorization of x2*y2/g^2-x1*y1
  [vm,srs,vn]=svd(x2y2/gama^2-x1y1);
  shalf=sqrt(diag(srs));


  % misc.
  AA=a+b2*dk*c2;
  BB=b1+b2*dk*d21;
  CC=c1+d12*dk*c2;
  Dcl=d11+d12*dk*d21;


%  gama=max(gama,(1+tolsing)*norm(Dcl));
  DELcl=[eye(m1),-Dcl'/gama;-Dcl/gama,eye(p1)];
  DELsq=chol(DELcl)';


  % Compute BK , CK , AK
  % --------------------

  % compute  thetaB

  nor21=min(0.1,sr21(1));
  if nd11 > 1e2*gama, tmpD=Dcl; tmpC=CC; else tmpD=d11; tmpC=c1; end
  thetaB=-[zeros(p2),d21/nor21,zeros(p2,p1);d21'/nor21,...
             -eye(m1),Dcl'/gama;zeros(p1,p2),tmpD/gama,-eye(p1)]\...
                  [c2*y2/nor21;b1'*y1;tmpC*y2/gama];
  thetaB=thetaB(1:p2,:)/nor21;
  auxB=DELsq\[b1'*y1+d21'*thetaB;CC*y2/gama];


  % compute thetaC

  nor12=min(0.1,sr12(1));
  if nd11 > 1e2*gama, tmpD=Dcl; tmpB=BB; else tmpD=d11; tmpB=b1; end
  thetaC=-[zeros(m2,m2+m1),d12'/nor12;zeros(m1,m2),...
          -eye(m1),tmpD'/gama;d12/nor12,Dcl/gama,-eye(p1)]\...
                  [b2'*x2/nor12;tmpB'*x2/gama;c1*x1];
  thetaC=thetaC(1:m2,:)/nor12;
  auxC=DELsq\[BB'*x2/gama;c1*x1+d12*thetaC];



  bk=diag(1./shalf)*vn'*(thetaB'-y1'*b2*dk);
  ck=(thetaC-dk*c2*x1)*vm*diag(1./shalf);

  aux=b2*dk*c2;
  ak=-diag(1./shalf)*vn'*(y2'*(a+aux)'*x2/gama^2+y1'*(a-aux)*x1+...
      thetaB'*c2*x1+y1'*b2*thetaC+auxB'*auxC/gama)*vm*diag(1./shalf);

end



Kcen=ltisys(ak,bk,ck,dk);
gfin=gama*sclf;


