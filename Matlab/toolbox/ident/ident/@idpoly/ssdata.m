function [a,b,c,d,k,x0,dA,dB,dC,dD,dK,dX0]=ssdata(th);
%IDPOLY/SSDATA  Returns state-space matrices for IDPOLY models.
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
%   M is an IDPOLY model object.
%   The output are the matrices of the state-space model
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  in continuous or discrete time, depending on the model's sampling
%  time Ts.
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
%  returns also the model uncertainties (standard deviations) dA etc.

%   L. Ljung 10-2-90,10-10-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.13 $ $Date: 2001/09/23 14:27:03 $

[ap,bp,cp,dp,fp]=polydata(th);
nu  = size(th,'nu'); 
nk=th.nk;
if nu==0
    nf1 = th.nd+1;
else
nf1 = max(th.nd,max(th.nf))+1;
end
T = pvget(th.idmodel,'Ts'); 
if T > 0
   fp(nu+1,1:length(dp))=dp;
else
   fp(nu+1,1:nf1)=zeros(1,nf1);fp(nu+1,nf1-th.nd:nf1)=dp;
end
nf=th.nf;
nb=th.nb;
nf(nu+1)=th.nd;

for ku=1:nu+1
   if T>0  
      findx=1:nf(ku)+1;
   else 
      findx=nf1-nf(ku):nf1;
   end
   ffp=fp(ku,findx);
   ap=conv(ap,ffp);
   if ku==nu+1
      btemp=cp;
   else
      if T>0,
         btemp=bp(ku,1:nb(ku)+nk(ku));
      else  
         btemp=bp(ku,nk(ku)+1:nb(ku)+nk(ku));
      end
   end
   for kku=1:nu+1
      if T>0 
         findx=1:nf(kku)+1;
      else 
         findx=nf1-nf(kku):nf1;
      end
      if kku~=ku,
          if ~isempty(btemp)
         btemp=conv(btemp,fp(kku,findx));
     end
      end
   end
   bpp(ku,1:length(btemp))=btemp;nbpp(ku)=length(btemp);
end
[dum,maxindb]=size(bpp);nap=length(ap);nab=max(maxindb,nap);
bp=zeros(nu+1,nab);
if T<=0,
   if maxindb>nap,
      error('Pure differentiations of inputs. No state-space model produced.'),
   end
   for ku=1:nu+1,
      bp(ku,:)=[zeros(1,nab-nbpp(ku)) bpp(ku,1:nbpp(ku))];
   end
else
   bp=[bpp,zeros(nu+1,nab-maxindb)];
end
app=zeros(1,nab);app(1:nap)=ap;
d=bp(1:nu,1).';
if bp(nu+1,1)~=1&pvget(th,'NoiseVariance')>0  %%LLsom
   warning(sprintf(['Noise model indicates no white noise component.',...
   '\n         Resulting state-space model has unreliable noise structure.']))
end
bp=bp-bp(:,1)*app;
nx=nab-1;
bt=bp(:,2:nab);
at=app(2:nab).';

if nx==0
   a = zeros(0,0);
   b = zeros(0,nu);
   c = zeros(1,0);
   k = zeros(0,1);
else
   a=[-at,eye(nx,nx-1)]; % Transform to state-space
   b=bt(1:nu,:).';
   c=[1 zeros(1,nx-1)];
   k=bt(nu+1,:).';
end
x0=zeros(nx,1);
if nargout>6
   cov = pvget(th.idmodel,'CovarianceMatrix');
   if isempty(cov)
      dA = []; dB = []; dC = [];
      dD = []; dK = []; dX0 = [];
   else
      pp = pvget(th.idmodel,'ParameterVector');
      th = parset(th,pp+j*sqrt(diag(cov)));
      [a1,b1,c1,d1,k1,x01] = ssdata(th);
      dA = abs(a-a1); dB = abs(b-b1); dC = abs(c-c1);
      dD = abs(d-d1); dK = abs(k-k1); dX0 = abs(x0-x01);
   end
end
