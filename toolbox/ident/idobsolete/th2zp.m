function [zepo,k]=th2zp(th,ku,ky,thresh)
%TH2ZP  Computes zeros, poles, static gains and their standard deviations.
%   This function is obsolete. Use ZPKDATA instead.
%
%   [ZEPO,K] = TH2ZP(TH)
%
%   For a model defined by TH (as a model object IDPOLY, IDARX, IDSS or IDGREY)
%
%   ZEPO is returned as the zeros and poles and their standard deviations.
%   Its first row contains integers with information about the column in
%   question. See the manual.
%
%   The rows of K contain in order: the input/output number, the static
%   gain, and its standard deviation.
%
%   Both discrete and continuous time models are handled by TH2ZP
%
%   With  [ZEPO,K] = TH2ZP(TH,KU,KY) the zeros and poles associated with
%   the input and output numbers given by the entries of the row vectors
%   KU and KY, respectively, are computed.
%   Default values: KU=[1:number of inputs], KY=[1:number of outputs].
%   The noise e is then regarded as input # 0.
%   The information is best displayed by ZPPLOT. ZPPLOT(TH2ZP(TH),sd) is a
%   possible construction.
%   See also TH2FF, TH2POLY, TH2TF, TH2SS, and ZP.

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:43 $
if nargin<4,thresh=[];end
if nargin<3,ky=[];end
if nargin<2,ku=[];end
if ~isa(th,'idmodel')
   th = th2ido(th);
   end
if isa(th,'idpoly')
   [zepo,k] = th2zppoly(th,ku,ky,thresh);
   return
end

[ny,nu]=size(th);
T = pvget(th,'Ts');
%nu=th(1,3);ny=th(1,4);T=th(1,2);
if any(ku>nu),error('There are not that many inputs in the model!'),end
if any(ku<-ny),error('There are not that many noise sources in the model!'),end
if any(ky>ny) | any(ky<1),
   error('There are not that many outputs in the model!'),end
if isempty(thresh),thresh=100000;end
if isempty(ku),if nu>0,ku=1:nu;else ku=0;end,end
if isempty(ky),ky=1:ny;end
ku1=ku(find(ku>0));if any(ku==0),ku=[-ny:-1,ku1 ];end
zepo=[];k=[];
% IF necessary ...
try
   ut = pvget(th,'Utility');
      thbbmod = ut.Idpoly;
   catch
      thbbmod=[];
   end
   if isempty(thbbmod)
      thbbmod=idpolget(th);
      assignin('caller',inputname(1),th)
   end
    
for ko=ky
    if any(ku==-ko),kku=[ku1,0];flag=1;else kku=ku1;flag=0;end
    if ~isempty(kku)
       if iscell(thbbmod),th1=thbbmod{ko};else th1=thbbmod;end 
       [zep,kt]=th2zp(th1,kku);
    if flag,
      zep(1,find(abs(zep(1,:)>500)))=abs(zep(1,find(abs(zep(1,:)>500))))+...
      (ko-1);
      kt(1,find(kt(1,:)>500))=kt(1,find(kt(1,:)>500))+ko-1;
    end
    zep(1,:)=(ko-1)*1000+abs(zep(1,:));
    kt(1,:)=(ko-1)*1000+kt(1,:);
    else zep=[];kt=[];end
    zepo=zpform(zepo,zep);
    k=[k kt];
end
if ~isempty(zepo),
   if T==0
      zepo(1,:)=-zepo(1,:);
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [zepo,Kg]=th2zppoly(th,ku,ky,thresh)

%   L. Ljung 7-2-87,10-12-93
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:43 $

if nargin<1
   disp('Usage: ZEPO = TH2ZP(TH)')
   disp('       [ZEPO,K] = TH2ZP(TH,INPUTS,OUTPUTS)')
   return
end
pars=pvget(th,'ParameterVector'); 
% *** Set up default values ***
if nargin<4,thresh=[];end
if nargin<3,ky=[];end
if nargin<2,ku=[];end
P=pvget(th,'CovarianceMatrix'); 
if any(abs(imag(pars))>eps)
   disp('This model has complex valued parameters.')
   disp('The calculation of confidence regions is then not supported.')
   disp('ZP is used instead.')
   eval('[zepo,Kg]=zp(th,ku,ky,thresh);')
   return
end
[ny,nu]=size(th);%
T=pvget(th,'Ts');%=th(1,3);T=gett(th);
if isempty(thresh),thresh=100000;end
if nu==0, kudef=0;else kudef=1:nu;end
if isempty(ku), ku=kudef;end
if any(ku==-1),ku(find(ku==-1))=0;end
if max(ku)>nu | min(ku)<-1,error('Input indices outside # of inputs in theta')
   return,end

%[nt,ntt]=size(th);
Novar=0;
% Sort out the orders of the polynomials
na = pvget(th,'na');
nb=pvget(th,'nb');
nc=pvget(th,'nc');
nd=pvget(th,'nd'); 
nf=pvget(th,'nf');% 
ns=2*nu+3;
Ncum=cumsum([na nb nc nd nf]); 
par=pars;coP=P; 
if isempty(coP) | norm(coP)==0,Novar=1;end

% set up orders for the noise case
kzero=find(ku<=0);kku=ku;if length(kzero)>0,kku(kzero)=nu+1;end
nb(nu+1)=nc;nf(nu+1)=nd;
nnb=max(nb(kku));nnf=max(nf(kku));if nnb==nc,nnb=nnb+1;end
nzp=max(nnb-1,nnf+na);

zepo=zeros(nzp+1,4*length(ku))+inf;
ll=1:na;
a=[1 pars(ll).'];
aa=0;
if na>0,
   if Novar, tempP=[];else tempP=coP(ll,ll);end
   Apoles=rotvar(a,tempP);
   [aa,sl]=size(Apoles);
end
cc=1;
for k=ku
   if k>0,k1=k;else k1=501;end
   zepo(1,cc:cc+3)=[k1 60+k1 20+k1 80+k1];Kg(1,(cc+3)/4)=k1;
   
   if na>0,zepo(2:aa+1,cc+2:cc+3)=Apoles;end
   
   if k>0,
      llb=Ncum(k)+1:Ncum(k+1);
      llf=Ncum(nu+2+k)+1:Ncum(nu+3+k);
      b=pars(llb).';nbb=nb(k);nff=nf(k);
   else
      llb=Ncum(nu+1)+1:Ncum(nu+2);
      llf=Ncum(nu+2)+1:Ncum(nu+3);
      b=[1 pars(llb).'];nbb=nc;nff=nd;
   end
   f=[1 pars(llf).'];
   if length(b)>1,
      if Novar,tempP=[];else tempP=coP(llb,llb);end
      Bzeros=rotvar(b,tempP);%Corr 89-07-30
      [bb,sl]=size(Bzeros);
      for kinf=1:sl
         kind=find(abs(Bzeros(:,kinf))>thresh);
         if ~isempty(kind),Bzeros(kind,kinf)=inf*ones(length(kind),1);end
      end
      zepo(2:bb+1,cc:cc+1)=Bzeros;
   end
   if length(llf)>0,
      if Novar,tempP=[];else tempP=coP(llf,llf);end
      Fpoles=rotvar(f,tempP);
      [ff,sl]=size(Fpoles);zepo(aa+2:aa+1+ff,cc+2:cc+3)=Fpoles;
   end
   if T>0
      bst=sum(b);ast=sum(a);fst=sum(f);
      if abs(ast*fst)>eps,
         kgg=bst/ast/fst;
         dKdth=[-ones(1,na)*kgg/ast ones(1,nbb)/ast/fst -ones(1,nff)*kgg/fst];
      else kgg=inf;
      end
   else
      if abs(a(length(a))*f(length(f)))>eps
         kgg=b(length(b))/a(length(a))/f(length(f));
         if na>0,dna=[zeros(1,na-1) 1];else dna=[];end
         if nbb>0,dnb=[zeros(1,nbb-1) 1];else dnb=[];end
         if nff>0,dnf=[zeros(1,nff-1) 1];else dnf=[];end
         dKdth=[-dna*kgg/a(length(a)) dnb/a(length(a))/f(length(f)) -dnf*kgg/f(length(f))];
      else kgg=inf;
      end
   end
   Kg(2,(cc+3)/4)=kgg;
   if kgg==inf,Kg(3,(cc+3)/4)=inf;
   else
      if Novar,
         Kg(3,(cc+3)/4)=0;
      else
         Pk=dKdth*coP([ll llb llf],[ll llb llf])*dKdth';
         Kg(3,(cc+3)/4)=sqrt(Pk);
      end
   end
   cc=cc+4;
end
if T==0
   zepo(1,:)=-zepo(1,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zv=rotvar(pol,covm)
%ROTVAR computes the standard deviations of roots to polynomials
%
%   ZV = rotvar(POL,COVM)
%
%   POL is the entered polynomial and
%   COVM is the covariance matrix of its coefficients
%   ZV is returned as the roots of POL and their standard deviations.
%   The first column of ZV contains the roots and the corresponding
%   elements in the second column give the standard deviations.
%   For complex conjugate pairs the second entry is the correlation
%   coefficient between the real and imaginary parts.
%
%   The routine is primarily a help subroutine to th2zp.

%   L. Ljung 87-7-2, 94-08-27
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:43 $

[dr,dc]=size(covm);lp=length(pol);
r=roots(pol);
zv(:,1)=r;lr=length(r);
if isempty(covm),zv(:,2)=zeros(lr,1);return,end
k=1;
while k<lr+1
   if imag(r(k))==0
      D(k,:)=real(-poly(r([1:k-1,k+1:lr])));
      k=k+1;
   else
      
      D(k,:)=real(-2*poly([r([1:k-1,k+2:lr]);real(r(k))]));
      D(k+1,:)=real([0, 2*imag(r(k))*poly(r([1:k-1,k+2:lr]))]);
      k=k+2;
   end
end
D=inv(D)';
if lr~=dr,
   DZ(:,2:lp)=D/pol(1);
   DZ(:,1)=-D*pol(2:lp)'/(pol(1)^2);
else
   DZ=D;
end
PV=DZ*covm*DZ';
k=1;l=1;i=sqrt(-1);
while k<lp
   if imag(r(k))==0,
      zv(k,2)=sqrt(PV(l,l));k=k+1;l=l+1;
   else
      zv(k,2)=sqrt(PV(l,l))+i*sqrt(PV(l+1,l+1));
      zv(k+1,2)=PV(l,l+1)/sqrt(PV(l,l)*PV(l+1,l+1));
      k=k+2;l=l+2;
   end
end
