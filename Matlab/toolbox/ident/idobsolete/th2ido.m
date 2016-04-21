function m = th2ido(th)
%TH2IDO  obsolete function
%   M = TH2IDO(TH) Translates from the Toolbox's old THETA format
%   to the new model objects, IDARX, IDPOLY, IDSS and IDGREY.
%
%   TH is a model in the old format, and M is returned as a model
%   object

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2001/09/23 14:27:23 $
if isa(th,'idmodel')
   m = th;
   return
end

if th(2,7)>20
   m = th2ids(th);
else
   m = th2idp(th);
end
%%%%%%%%%%%%%%%%%%******************************
function poly = th2idp(th)
% TH2IDP  Transformation from the Theta-structure to IDPOLY object
%
%     IDP = TH2IDP(th)

if isa(th,'idpoly')
   poly = th;
   return
end
poly = idpoly;
Ts = th(1,2);
Tss = Ts;
if Tss<=0, Tss=0;end
nu = th(1,3);
n = sum(th(1,4:6+2*nu));
nr = size(th,1);
if nr<4
   cov = [];
else
   cov = th(4:3+n,1:n);
end


set(poly,'Ts',Tss,'na',th(1,4),'nb',th(1,5:4+nu),...
   'nc',th(1,5+nu),'nd',th(1,6+nu),'nf',th(1,7+nu:6+2*nu),...
   'nk',th(1,7+2*nu:6+3*nu),'ParameterVector',th(3,1:n).',...
   'CovarianceMatrix',cov,...
   'NoiseVariance',th(1,1));
if Ts<=0
   try
      dead = th(4+n,1);
   catch
      dead = 0;
   end
   poly = pvset(poly ,'InputDelay',dead); 
end

s=1:6;text(1,s)='ARX   ';text(2,s)='BJ    '; text(3,s)='IV    ';
text(4,s)='IV4   ';text(5,s)='PEM   '; text(6,s)='POLY2T';
text(7,s)='ARMAX ';text(8,s)='OE    '; text(9,s)='INIVAL';
text(10,s)='IVAR  ';text(11,s)='IVX   ';text(12,s)='AR    ';
nu=th(1,3); T=th(1,2);
hist=str2mat(['This object was created by the command ',text(th(2,7),:)],[' on ',...
      int2str(th(2,3)),'/',int2str(th(2,4)),' ',int2str(th(2,2)*100),' at ',...
      int2str(th(2,5)),':',int2str(th(2,6))]);
set(poly,'Notes',hist)
est.Method = text(th(2,7),:);
est.FPE = th(2,1);
est.Status = 'Translated from the old Theta-format.';
est.LossFcn = th(1,1);
est.DataTs =  abs(Ts);
alpha=(th(2,1)-th(1,1))/(th(2,1)+th(1,1));
if alpha>eps,
   Ncap=floor(n/alpha);
else 
   Ncap = [];
end
est.DataLength = Ncap;
poly = pvset(poly,'EstimationInfo',est);

%%'*********************************************************************

function m = th2ids(th)
% TH2IDS Transformation from THETA  structure to IDSS object


nn=th(1,5);
ny = th(1,4);
nu = th(1,3);
ps = th(2,8);
p = th(3,1:nn);
nr = size(th,1);
if nr<4
   P = [];
else
   P = th(4:3+nn,1:nn);
end

[arg,nr,carg]=getargth(th);
lam = th(4+nn+nr:3+nn+nr+ny,1:ny);
%[p,P,lam]=th2par(th)
if ps==2 & th(1,2)<0
  ps = 1;
end

switch ps
case {1,11} %% Continuous time parameterization using ssmodx9 or ssmodx8
   m = idss;
   %th1=th;th1(3,1:nn)
   th1=NaN*ones(1,nn);
   [as,bs,cs,ds,ks,x0s]=ssmodx9(th1,1,arg);
   m = pvset(m,'As',as,'Bs',bs,'Cs',cs,'Ds',ds,'Ks',ks,'X0s',x0s,...
      'ParameterVector',p,'NoiseVariance',lam,'Ts',0);
   m = pvset(m,'CovarianceMatrix',P);
   est = pvget(m,'EstimationInfo');
   if ps == 11
      est.DataInterSample = 'foh';
   else
      est.DataInterSample = 'zoh';
   end
   est.DataTs = abs(th(1,2));
case 2 %%  Discrete time parameterization using ssmodx9
   m = idss;
   %th1=th;th1(3,1:nn)=NaN*ones(1,nn);
   [as,bs,cs,ds,ks,x0s]=ssmodx9(NaN*ones(1,nn),1,arg);
   m = pvset(m,'As',as,'Bs',bs,'Cs',cs,'Ds',ds,'Ks',ks,'X0s',x0s,...
      'ParameterVector',p.','NoiseVariance',lam,'Ts',th(1,2));
   m = pvset(m,'CovarianceMatrix',P);
   est = pvget(m,'EstimationInfo');
case 3 %% Multivariable ARX model
   m = idarx;
   [A,B]=th2arx(th);
   nna=size(A,2);nnb=size(B,2);
   for k = 1:nna/ny
      A1(:,:,k)=A(:,(k-1)*ny+1:k*ny);
   end
   if isempty(B)
      B1=zeros(ny,0,0);
   else
      for k = 1:nnb/nu
         B1(:,:,k)=B(:,(k-1)*nu+1:k*nu);
      end
   end
   m = pvset(m,'A',A1,'B',B1,'NoiseVariance',lam,'Ts',th(1,2));
   m = pvset(m,'CovarianceMatrix',P);
   est = pvget(m,'EstimationInfo');
    
case 4 %% Discrete time user defined parameterization
   m = idgrey;
   sspm=th(1,8:end);
   sspm=sspm(1:max(find(sspm~=0)));
   mfname=setstr(sspm);
   m = pvset(m,'ParameterVector',p,'CovarianceMatrix',P,'NoiseVariance',...
      lam,'FileArgument',arg,'MfileName',mfname,'CDmfile','d');
   est = pvget(m,'EstimationInfo');
case 5 %% User defined parameterization with c/d switch
   m = idgrey;
   sspm=th(1,8:end);
   sspm=sspm(1:max(find(sspm~=0)));
   mfname=setstr(sspm);
   m = pvset(m,'ParameterVector',p,'CovarianceMatrix',P,'NoiseVariance',...
      lam,'FileArgument',arg,'MfileName',mfname,'CDmfile','cd');
   est = pvget(m,'EstimationInfo'); 
end   
if isa(m,'idarx')
   s=1:8;text(1,s)='ARX     ';text(2,s)='ARX2TH  '; text(3,s)='PEM     ';
   text(4,s)='IV4     ';text(5,s)='FIXPAR  '; text(6,s)='UNFIXPAR';
   text(7,s)='THINIT  ';text(8,s)='IVX     '; text(9,s)='MKETAARX';
   sub = 30;
else
   s=1:8;text(1,s)='MS2TH   ';text(2,s)='MF2TH   '; text(3,s)='PEM     ';
   text(4,s)='CANSTART';text(5,s)='FIXPAR  '; text(6,s)='UNFIXPAR';
   text(7,s)='THINIT  ';text(30,s)='N4SID   ';
   sub = 20;
end
nu=th(1,3); T=th(1,2);
m = pvset(m,'Ts',T);
hist=str2mat(['This object was created by the command ',text(th(2,7)-sub,:)],[' on ',...
      int2str(th(2,3)),'/',int2str(th(2,4)),' ',int2str(th(2,2)*100),' at ',...
      int2str(th(2,5)),':',int2str(th(2,6))]);
m = pvset(m,'Notes',hist);
est.Method = text(th(2,7)-sub,:);
est.FPE = th(2,1);
est.Status = 'Translated from the old Theta-format.';
est.LossFcn = th(1,1);
alpha=(th(2,1)-th(1,1))/(th(2,1)+th(1,1));
if alpha>eps,
   Ncap=floor(nn/alpha);
else 
   Ncap = [];
end
est.DataLength = Ncap;
m = pvset(m,'EstimationInfo',est);


function [arg,rarg,carg]=getargth(eta)
%GETARGTH       Gets the auxiliary argument for a state-space model
%           structure
%
%   ARG = getargth(TH)
%
%   TH: The model structure in the THETA-format (See help theta)
%   ARG: The auxiliary argument

%   L. Ljung 10-2-90
%   $Revision: 1.14 $  $Date: 2001/09/23 14:27:23 $


%if ~isthss(eta),error('This is not a state-space based model!'),end
nd=eta(1,5);rarg=eta(1,6);carg=eta(1,7);
arg=eta(4+nd:3+nd+rarg,1:carg);
%%%%%%%%%%%%%%%%%%%
function [A,B,C,D,K,X0]=ssmodx9(th,T,mod)
%SSMODX9 The standard state-space model
%
%   [A,B,C,D,K,X0] = ssmodx9(PARVAL,T,MS)
%
%   This routine is used as the standard model-defining routine
%   inside the THETA-structure for state space models if no user-
%   defined structure is specified. The use of SSMODx9 should be
%   transparent to the user.
%
%   A,B etc: The discrete time state space matrices corresponding to
%   the parameter values PARVAL for a linear model structure
%   defined by MS (obtained from MODSTRUC or CANFORM)

%   L. Ljung 10-2-90,11-25-93
%   $Revision: 1.14 $  $Date: 2001/09/23 14:27:23 $
%%LL%% Could simplify without loops
[dum,nn]=size(mod);nyy=mod(1,nn);nx=mod(2,nn);
ny=abs(nyy);nu=(nn-nx-2*ny-2)/2;
s=1;
if nyy<0,arx=1;else arx=0;end
na=0;
if arx,
   as1=mod(1:nx,1:nx);
   sumas=sum4vms(as1');
   nr=find(sumas==0&~isnan(sumas));
   if isempty(nr),na=nx/ny;else na=(nr(1)-1)/ny;end
end
A=mod(1:nx,1:nx);
for kr=1:nx
   for kc=1:nx
      if isnan(A(kr,kc)), A(kr,kc)=th(s);s=s+1;end
   end
end
B=mod(1:nx,nx+1:nx+nu);
for kr=1:nx
   for kc=1:nu
      if isnan(B(kr,kc)),B(kr,kc)=th(s);s=s+1;end
   end
end
if na==0
   C=mod(1:nx,nx+nu+1:nx+nu+ny)';
   for kr=1:ny
      for kc=1:nx
         if isnan(C(kr,kc)),C(kr,kc)=th(s);s=s+1;end
      end
   end
   D=mod(1:ny,nx+nu+ny+1:nx+2*nu+ny);
   for kr=1:ny
      for kc=1:nu
         if isnan(D(kr,kc)),D(kr,kc)=th(s);s=s+1;end
      end
   end
else
   C=A(1:ny,1:nx);
   D=B(1:ny,:);
end
K=mod(1:nx,nx+2*nu+ny+1:nx+2*nu+2*ny);
for kr=1:nx
   for kc=1:ny
      if isnan(K(kr,kc)),K(kr,kc)=th(s);s=s+1;end
   end
end

X0=mod(1:nx,nx+2*nu+2*ny+1);
for kr=1:nx
   if isnan(X0(kr)),X0(kr)=th(s);s=s+1;end
end
%if T>0 % We shall in this case sample the model with sampling interval T
%s = expm([[A [B K]]*T; zeros(nu+ny,nx+nu+ny)]);
%A = s(1:nx,1:nx);
%B = s(1:nx,nx+1:nx+nu);
%K = s(1:nx,nx+nu+1:nx+nu+ny);
%end

function [A,B,dA,dB]=th2arx(eta)
%TH2ARX converts a THETA-format model to an ARX-model.
%   [A,B]=TH2ARX(TH)
%
%   TH: The model structure defined in the THETA-format (See also TEHTA.)
%
%   A, B : Matrices defining the ARX-structure:
%
%          y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%
%          A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%
%
%   With [A,B,dA,dB] = TH2ARX(TH), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also ARX2TH, and ARX

%   L. Ljung 10-2-90,3-13-93
%   $Revision: 1.14 $  $Date: 2001/09/23 14:27:23 $

if nargin < 1
   disp('Usage: [A,B,dA,dB] = TH2ARX(TH)')
   return
end

%[Ncap,nd]=getncap(eta);

tnr=eta(2,8); if tnr~=3,error('This is not an ARX-model!'),end
nd =eta(1,5);
etapar=eta(3,1:nd);
arg=getargth(eta);
[rarg,carg]=size(arg);
as1=arg(:,1:rarg);
sumas=sum4vms(as1');
nr=find(sumas==0&~isnan(sumas));
[as,bs,cs,ds]=ssmodx9(etapar,-1,arg);
[ny,nz]=size(cs);[nx,nz]=size(as);[nz,nu]=size(bs);
if isempty(nr),na=nx/ny;else na=(nr(1)-1)/ny;end
if nu>0,nb=(nx-na*ny)/nu;else nb=0;end
A=[eye(ny) -cs(:,1:na*ny)];
if nu>0,B=[ds cs(:,na*ny+1:nx)];else B=[];end
if na==0 & ~any(isnan(arg(:,nx+nu+1:nx+nu+ny))), B=ds;end

if nargout>2
   p=diag(eta(4:3+nd,1:nd));p=sqrt(p')+100*eps;
   etap1=etapar+p;
   [das,dbs,dcs,dds]=ssmodx9(etap1,-1,arg);
   dA=abs([eye(ny) -dcs(:,1:na*ny)]-A);
   if nu>0,dB=abs([dbs(1:ny,:) dcs(:,na*ny+1:nx)]-B);else dB=[];end
end

