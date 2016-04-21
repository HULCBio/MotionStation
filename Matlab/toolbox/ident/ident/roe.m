function [thm,yhat,p,phi,psi] = roe(z,nn,adm,adg,th0,p0,phi,psi)
%ROE    Computes estimates recursively for an output error model.
%   [THM,YHAT] = ROE(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single input single output data only.
%   NN : NN=[nb nf nk], The orders and delay of an output error
%        input-output model (see also OE).
%
%   adm: Adaptation mechanism. adg: Adaptation gain
%    adm='ff', adg=lam:  Forgetting factor algorithm, with forg factor lam
%    adm='kf', adg=R1: The Kalman filter algorithm with R1 as covariance
%           matrix of the parameter changes per time step
%    adm='ng', adg=gam: A normalized gradient algorithm, with gain gam
%    adm='ug', adg=gam: An Unnormalized gradient algorithm with gain gam
%   THM: The resulting estimates. Row k contains the estimates "in alpha-
%        betic order" corresponding to data up to time k (row k in Z)
%   YHAT: The predicted values of the outputs. Row k corresponds to time k.
%   Initial value of parameters(TH0) and of "P-matrix" (P0) can be given by
%   [THM,YHAT,P] = ROE(Z,NN,adm,adg,TH0,P0)
%   Initial and last values of auxiliary data vectors phi and psi are
%   obtained by [THM,YHAT,P,phi,psi]=ROE(Z,NN,adm,adg,TH0,P0,phi0,psi0).
%
%   See also RARX, RARMAX, RBJ, RPEM, and RPLR.

%   L. Ljung 10-1-89
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:29 $

if nargin < 4
   disp('Usage: MODEL_PARS = ROE(DATA,ORDERS,ADM,ADG)')
   disp('       [MODEL_PARS,YHAT,COV,PHI,PSI] = ROE(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI,PSI)')
   disp('       ADM is one of ''ff'', ''kf'', ''ng'', ''ug''.')
   return
end
adm=lower(adm(1:2));
if ~(adm=='ff'|adm=='kf'|adm=='ng'|adm=='ug')
 error('The argument ADM should be one of ''ff'', ''kf'', ''ng'', or ''ug''.')
end
if isa(z,'iddata')
   y = pvget(z,'OutputData');
   u = pvget(z,'InputData');
   z = [y{1},u{1}];
end

[nz,ns]=size(z);
if ns<=1,error('This routine requires an input. For a time series, use RARMAX or RARX instead!'),end
if ns>2,error('This  routine is for single input only. Use RPEM instead!'),end
if length(nn)~=3,error('Incorrect number of orders specified! nn = [nb nf nk]'),end
nb=nn(1);nf=nn(2);nk=nn(3);nu=1;
if nk<1,error('Sorry, this routine requires nk>0; Shift input sequence if necessary!'),end
d=sum(nn(1:2));
if ns>2,error('Sorry, this routine is for single input only!'),end

nbm=max([nb+nk-1,nf]);

tif=nb+1:d;

ib=nk:nb+nk-1;ibf=1:nf;
iff=nbm+1:nbm+nf;
iib=1:nbm-1;
iif=nbm+1:nbm+nf-1;
dm=nbm+nf;
ii=[iib iif];i=[ib iff];

if nargin<8, psi=zeros(dm,1);end
if nargin<7, phi=zeros(dm,1);end
if nargin<6, p0=10000*eye(d);end
if nargin<5, th0=eps*ones(d,1);end
if isempty(psi),psi=zeros(dm,1);end
if isempty(phi),phi=zeros(dm,1);end
if isempty(p0),p0=10000*eye(d);end
if isempty(th0),th0=eps*ones(d,1);end
if length(th0)~=d, error('The length of th0 must equal the number of estimated parameters!'),end
[th0nr,th0nc]=size(th0);if th0nr<th0nc, th0=th0';end

p=p0;th=th0;
if adm(1)=='f', R1=zeros(d,d);lam=adg;end
if adm(1)=='k', [sR1,SR1]=size(adg);
     if sR1~=d | SR1~=d,error('The R1 matrix should be a square matrix with dimension equal to number of parameters!'),end
     R1=adg;lam=1;
end
if adm(2)=='g', grad=1;else grad=0;end

for kcou=1:nz
yh=phi(i)'*th;
epsi=z(kcou,1)-yh;
if ~grad,K=p*psi(i)/(lam + psi(i)'*p*psi(i));
         p=(p-K*psi(i)'*p)/lam+R1;
else K=adg*psi(i);end
if adm(1)=='n', K=K/(eps+psi(i)'*psi(i));end
th=th+K*epsi;
f=fstab([1;th(tif)])';
th(tif)=f(2:nf+1);
w=phi(i)'*th;
ztil=[[z(kcou,2),-psi(ibf)'];[w,psi(iff)']]*f;

phi(ii+1)=phi(ii);psi(ii+1)=psi(ii);
if nb>0,phi(1)=z(kcou,2);psi(1)=ztil(1);end
if nf>0,phi(nbm+1)=-w;psi(nbm+1)=-ztil(2);end

thm(kcou,:)=th';yhat(kcou)=yh;
end
yhat = yhat';
