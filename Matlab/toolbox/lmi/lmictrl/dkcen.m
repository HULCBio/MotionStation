% [K,gfin]=dkcen(P,r,gama,X1,X2,Y1,Y2,tolred)
%
% Given a discrete-time plant P and GAMA > 0,  DKCEN
% computes a "central" H-infinity digital controller K(s) that
%   * internally stabilizes the plant,
%   * yields a closed-loop gain no larger than GAMA.
% This controller is calculated using either the stabilizing
% solutions X,Y of the two H_infinity Riccati equations
% (classical approach), or any solutions X,Y  of the Riccati
% inequalities (LMI approach).
%
% Input:
%  P         plant SYSTEM matrix (see LTISYS)
%  R         size of D22, i.e.,  R = [ NY , NU ]  where
%                   NY = number of measurements
%                   NU = number of controls.
%  GAMA      required H-infinity performance
%  X1,X2,..  Riccati approach:   X = X2/X1 and  Y = Y2/Y1
%               are the stabilizing solutions of the two
%               Riccati equations
%            LMI approach: X = X2/X1 and  Y = Y2/Y1 are
%               solutions of the two H_infinity Riccati
%               inequalities.
%  TOLRED    optional (default value = 1.0e-4).  Reduced-order
%            synthesis is performed whenever
%                    rho(X*Y) >=  (1 - TOLRED) * GAMA^2
% Output:                                               -1
%  K         Central controller   K(s) = DK + CK (zI-AK)  BK   in
%            packed  form.
%  GFIN      guaranteed closed-loop performance (GAMA may be reset
%            to GFIN > GAMA for numerical stability reasons)
%
%
% See also  DHINFRIC.

% Authors: P. Gahinet and A.J. Laub 10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $


function [Kcen,gfin]=dkcen(P,r,gama,x1,x2,y1,y2,tolred)


if nargin<7,
  error('usage: K = dkcen(P,r,gama,x1,x2,y1,y2,tolred)');
elseif nargin<8, tolred=1.0e-4;
end



% tolerances
macheps=mach_eps;
tolsing=sqrt(macheps);
toleig=macheps^(2/3);


% retrieve the plant data
[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
na=size(a,1); [p1,m1]=size(d11); [p2,m2]=size(d22);



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


% orthogonalize [x1;x2] and [y1;y2] (systematically because
% of the subsequent diagonalization of x1,x2)
[q,rr]=qr([x1;x2]);
x1=q(1:na,1:na);   x2=q(na+1:2*na,1:na);

[q,rr]=qr([y1;y2]);
y1=q(1:na,1:na);   y2=q(na+1:2*na,1:na);



% diagonalize x1,x2. Since X>=0, u1'*x2*v1 is diagonal
[ux1,sx1,vx1]=svd(x1);      sx2=real(diag(ux1'*x2*vx1));
[uy1,sy1,vy1]=svd(y1);      sy2=real(diag(uy1'*y2*vy1));

% zero small entries
ind=find(sx2 < toleig);
sx2(ind)=zeros(size(ind));   sqsx2=diag(sqrt(sx2));
ind=find(sy2 < toleig);
sy2(ind)=zeros(size(ind));   sqsy2=diag(sqrt(sy2));




% SVD's of [b2;d12] and [c2 d21]
%-------------------------------

BD=[b2'*ux1*sqsx2,d12'];
[uC,sC,vC,rC]=svdparts(BD,toleig*norm(b2,1),tolsing);

CD=[c2*uy1*sqsy2,d21];
[uB,sB,vB,rB]=svdparts(CD,toleig*norm(c2,1),tolsing);



% compute a solution of the characteristic LMI for DK
% ---------------------------------------------------

aux=[sqsx2*ux1'*a*uy1*sqsy2 , sqsx2*ux1'*b1; c1*uy1*sqsy2 d11];
MD=[-gama*mdiag(sx1,eye(p1)) aux;aux' , -gama*mdiag(sy1,eye(m1))];
PD=[BD,zeros(m2,na+m1)];
QD=[zeros(p2,na+p1),CD];
eigMD=eig(MD);

if max(real(eigMD)) < toleig*max(abs(eigMD)),
  dk=zeros(m2,p2);
else
  dk=basiclmi(MD,PD,QD,'Xmin,Shift');
end


AA=a+b2*dk*c2;
BB=b1+b2*dk*d21;
CC=c1+d12*dk*c2;
Dcl=d11+d12*dk*d21;


% compute the inverse square root of DELcl
aux=PD'*dk*QD;
DELcl=-(MD+aux+aux')/gama;
[u,t]=schur(DELcl);  t=real(diag(t));
ind=find(t > tolsing);
t=sqrt(1./t(ind));  u=u(:,ind);
DELsqi=diag(t)*u';               %   sqrt(inv(DELcl))

%disp(sprintf('min eval of DELcl:  %6.3e',min(real(eig(DELcl)))));



% detect full vs reduced
%-----------------------

x2y2=x2'*y2; x1y1=x1'*y1;
gev=eig(x2y2,x1y1);
gama=max(gama,sqrt(max(0,max(real(gev)))));
gama0=gama;



% svd of x2'y2/gama^2-x1'y1 -> M,N
[vm,srs,vn]=svd(x2y2/gama^2-x1y1);
shalf=sqrt(diag(srs));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    SYNTHESIS STARTS
%       BOTH FULL- AND REDUCED-ORDER CASES ARE TREATED AT ONCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ContinueLoop=1;

while ContinueLoop,

  rkred=length(find(gev < (1-tolred)*gama^2));
  vmr=vm(:,1:rkred);  vnr=vn(:,1:rkred);
  shalfr=shalf(1:rkred);

  y1vn=y1*vnr;
  x1vm=x1*vmr;

  % compute  B_K
  %-------------

  aux1=[-sqsx2*ux1'*y2/gama;zeros(p1,na)]*vnr;
  aux2=[sqsy2*uy1'*a'*y1vn;b1'*y1vn];

  if rB==0,
    thetaB=zeros(p2,rkred);
  else
    tmp=vB*diag(sB);
    thetaB=-[zeros(rB) zeros(rB,na+p1) tmp';[zeros(na+p1,rB); tmp] -DELcl]\...
                                           [zeros(rB,rkred);aux1;aux2];
    thetaB=uB*thetaB(1:rB,:);
  end

  auxB=DELsqi*[aux1;aux2+[sqsy2*uy1'*c2';d21']*thetaB];


%DS=-vnr'*y1'*y2*vnr+auxB'*auxB;
%disp(sprintf('max evals of DS:  %6.3e',max(real(eig(DS)))));


  % compute C_K
  %------------

  aux1=[sqsx2*ux1'*a*x1vm;c1*x1vm];
  aux2=[-sqsy2*uy1'*x2/gama;zeros(m1,na)]*vmr;

  if rC==0,
    thetaC=zeros(m2,rkred);
  else
    tmp=vC*diag(sC);
    thetaC=-[zeros(rC) tmp' zeros(rC,na+m1);[tmp; zeros(na+m1,rC)] -DELcl]\...
                                         [zeros(rC,rkred);aux1;aux2];
    thetaC=uC*thetaC(1:rC,:);
  end

  auxC=DELsqi*[aux1+[sqsx2*ux1'*b2;d12]*thetaC;aux2];


%DR=-vmr'*x1'*x2*vmr+auxC'*auxC;
%disp(sprintf('max evals of DR:  %6.3e',max(real(eig(DR)))));


  vny1=y1vn';
  bk=diag(1./shalfr)*(thetaB'-vny1*b2*dk);
  ck=(thetaC-dk*c2*x1vm)*diag(1./shalfr);

  ak=-diag(1./shalfr)*(vny1*(a-b2*dk*c2)*x1vm+thetaB'*c2*x1vm+...
           vny1*b2*thetaC+auxB'*auxC/gama)*diag(1./shalfr);


  % validation in the case of reduced-order synthesis


  ContinueLoop=0;
  if rkred < na,
    if max(abs(eig([AA b2*ck;bk*c2  ak]))) >= 1,
%disp('REDUCED FAILED');
       tolred=tolred/100; ContinueLoop=1;
       if tolred < toleig,
           rkred=na;
       else
           rkred=max(rkred+1,length(find(gev < (1-tolred)*gama0^2)));
       end
    end
  end

end  % while ContinueLoop


Kcen=ltisys(ak,bk,ck,dk);
gfin=gama*sclf;




%%%%%%%%%%%%%%%% TMP %%%%%%%%%%%%
% follows formulas in kcen.tex
%
%M=vm*diag(shalf);  N=vn*diag(shalf);
%
%rk=size(M,2);
%Pcl=[x1 y2/gama;M' zeros(rk,na)];
%Qcl=[x2/gama  y1; zeros(rk,na) N'];
%Acl=[AA b2*ck;bk*c2  ak];
%Bcl=[BB;bk*d21];
%Ccl=[CC d12*ck];
%
%BRL=gama*[-Qcl'*Pcl  Qcl'*Acl*Pcl  Qcl'*Bcl zeros(2*na,p1);...
%     Pcl'*Acl'*Qcl -Qcl'*Pcl zeros(2*na,m1) Pcl'*Ccl';...
%     Bcl'*Qcl zeros(m1,2*na) -gama*eye(m1)  Dcl';...
%     zeros(p1,na*2) Ccl*Pcl  Dcl  -gama*eye(p1)];
%D=mdiag(eye(4*na),eye(m1+p1)/gama);
%BRL=D*BRL*D;
%
%perm=[2*na+(1:na),na+(1:na),1:na,4*na+m1+(1:p1),3*na+(1:na),4*na+(1:m1)];
%BRL=BRL(perm,perm);
%D=mdiag(eye(2*na),mdiag(mdiag(vx1,eye(p1)),mdiag(vy1,eye(m1))));
%BRL=D'*BRL*D;
%
%DDEL=BRL(2*na+1:4*na+m1+p1,2*na+1:4*na+m1+p1);
%DD=mdiag(mdiag(sqsx2,eye(p1)),mdiag(sqsy2,eye(m1)));
%gap_DELcl=norm(DDEL+DD*DELcl*DD)
%
%BRLr=schrcomp(BRL,2*na+1,4*na+m1+p1,macheps);
%maxeigBRL=max(real(eig(BRLr)))
%
%DRR=BRLr(1:na,1:na);
%DSS=BRLr(na+(1:na),na+(1:na));
%D21=BRLr(na+(1:na),1:na);
