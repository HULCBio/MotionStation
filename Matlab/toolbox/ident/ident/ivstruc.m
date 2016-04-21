function V=ivstruc(z,zv,nn,p,maxsize)
%IVSTRUC Computes the output error fit for families of single-output ARX-models.
%   V = IVSTRUC(ZE,ZV,NN)
%
%   V: The first row of V is returned as the output error fit for
%   models of the structures, defined by the rows of NN.
%   These models are computed by the IV-method. The next rows
%   of V are returned as NN'. The last row of V contains the logarithms
%   of the conditioning numbers of the IV-matrix for the structures in
%   question. The last column of V contains the number of data points in Z
%
%   ZE : the output-input data as an IDDATA object (See Help IDDATA) 
%   Only Single-Output data are handled by this routine.
%    
%   ZV: the input-output data on which the validation is performed.
%   (could equal ZE).  Also an IDDATA object.
%
%   NN: Each row of NN is of the format [na nb nk], the orders and
%   delays associated with the corresponding model. (See also IV4 and
%   STRUC. See HELP SELSTRUC for analysis of V.
%
%   With V = IVSTRUC(Z,NN,p,maxsize) the calculation of conditioning numbers
%   can be suppressed (p=0), and the speed/memory trade-off affected.
%   See also AUXVAR and ARXSTRUC.

%   L. Ljung 4-12-87,12-27-91
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:19:05 $

if nargin < 3
   disp('Usage: V = IVSTRUC(EST_DATA,VAL_DATA,ORDERS)')
   return
end
if isa(z,'iddata')
    if strcmp(pvget(z,'Domain'),'Frequency')
        error('IVSTRUC does not support Frequency Domain Data.')
    end
   [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(z,0,inputname(1));
   error(errflag)
   if ny>1
      error('IVSTRUC only works for single output data.')
   end
   nz = 1+nu;
else
   
   [Ncaps,nz] = size(z);
   nu = nz-1;
   ze ={z};
   Ne = 1;
end
if isa(zv,'iddata')
   [zev,Nev,ny,nuv,Ts,Name,Ncapsv,errflag]=idprep(zv,0,inputname(1));
   error(errflag)
   if ny>1
      error('IVSTRUC only works for single output data.')
   end
   nzv = nuv +1;
else
   [Ncapsv,nzv] = size(zv); 
   zev ={zv};
   Nev = 1; 
end
[nm,nl] = size(nn);

na=nn(:,1); 
nb=nn(:,2:1+nu);
nk=nn(:,2+nu:1+2*nu);
[snbr,snbc]=size(nb);
if any(any(nb==zeros(snbr,snbc))'),
   error('nb=0 is not feasible for ivstruc!'),
end % Mod 911227
nma=max(na);nbkm=max(nb+nk)-ones(1,nu);nkm=min(nk);
n=nma+sum((nbkm-nkm))+nu;nbm=max(nb);
%
% *** Some initial tests on the input arguments ***
%
maxsdef=idmsize(max(Ncaps),n);

if nargin<5,maxsize=maxsdef;,end
if nargin<4, p=1;,end

% *** construct instruments (see (7.111)-(7.112)) ***
tha=arx(ze,[nma nbm nkm],maxsize,1,0);
NF=fstab([1 tha(1:nma)']);

for kexp = 1:Ne
   Ncap = Ncaps(kexp); 
   xe{kexp}=zeros(Ncap,1);rs=nma; 
   z = ze{kexp};
   for k=1:nu
      MF=[zeros(1,nkm(k)) tha(rs+1:rs+nbm(k))'];rs=rs+nbm(k);
      xe{kexp}=xe{kexp}+filter(MF,NF,z(:,k+1));
   end
end
%
% construct regression matrix
%
nmax=max(max([na+ones(nm,1) nb+nk]'))-1;
M=floor(maxsize/n);
nnuu=sum(nbkm)-sum(nkm)+nu;
Rxx=zeros(nma);
Ruu=zeros(nnuu);
Rxu=zeros(nma,nnuu);
Rxy=zeros(nma);
Ruy=zeros(nnuu,nma); 
F=zeros(n,1);
for kexp = 1:Ne
   x = xe{kexp};
   z = ze{kexp};
   Ncap = Ncaps(kexp);
   for k=nmax:M:Ncap
      jj=(k+1:min(Ncap,k+M));
      phix=zeros(length(jj),nma); phiy=phix; phiu=zeros(length(jj),nnuu);
      for kl=1:nma, phiy(:,kl)=-z(jj-kl,1); phix(:,kl)=-x(jj-kl); end
      ss=0;
      for ku=1:nu
         for kl=nkm(ku):nbkm(ku), phiu(:,ss+kl+1-nkm(ku))=z(jj-kl,ku+1);end
         ss=ss+nbkm(ku)-nkm(ku)+1;
      end
      Rxy=Rxy+phix'*phiy;
      Ruy=Ruy+phiu'*phiy;
      Rxu=Rxu+phix'*phiu;
      Ruu=Ruu+phiu'*phiu;
      Rxx=Rxx+phix'*phix;
      if nma>0, F(1:nma)=F(1:nma)+phix'*z(jj,1);end
      F(nma+1:n)=F(nma+1:n)+phiu'*z(jj,1);
   end
end
clear phiu, clear phix, clear phiy,
%
% compute estimate
W = 0;
for j=1:nm
   s=[];rs=0;
   for ku=1:nu
      s=[s,rs+nk(j,ku)-nkm(ku)+1:rs+nb(j,ku)+nk(j,ku)-nkm(ku)];
      rs=rs+nbkm(ku)-nkm(ku)+1;
   end
   RR=[Rxy(1:na(j),1:na(j)) Rxu(1:na(j),s);Ruy(s,1:na(j)) Ruu(s,s)];
   TH=RR\F([1:na(j) nma+s]);
   a=TH(1:na(j))';b=TH(na(j)+1:length(TH))';f=fstab([1 a]);
   V(1,j) = 0;  
   for kexp = 1:Nev
      zv = zev{kexp};
      if j == 1
         W = W + zv(:,1)'*zv(:,1);
      end
      
      [mzv,nzv] = size(zv(:,1));
      yhat=zeros(mzv,nzv);rs=0;
      for ku=1:nu
         bdum=[zeros(1,nk(j,ku)) b(rs+1:rs+nb(j,ku))]; rs=rs+nb(j,ku);
         yhat=yhat+filter(bdum,f,zv(:,ku));
      end
      V(1,j) = V(1,j)+(zv(:,1)-yhat)'*(zv(:,1)-yhat);
   end
   V(1,j) = V(1,j)/(sum(Ncaps)-nmax);
   if j == 1
      W = W/(sum(Ncaps)-nmax);      
   end
   

V(2:nl+1,j)=nn(j,:)';
if p~=0, V(nl+2,j)=log(cond(RR));,end
end
V(1,nm+1)=sum(Ncaps)-nmax; 
V(2,nm+1) = W; %%LL%% Ne *nmax?
