function [thm,yhat,p,phi] = rplr(z,nn,adm,adg,th0,p0,phi)
%RPLR   Computes PLR estimates recursively for a general model.
%   [THM,YHAT] = RPLR(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single input single output data only.
%   NN : NN=[na nb nc nd nf nk], The orders and delay of a general
%        input-output model (see also PEM).
%
%   adm: Adaptation mechanism. adg: Adaptation gain
%    adm='ff', adg=lam:  Forgetting factor algorithm, with forg factor lam
%    adm='kf', adg=R1: The Kalman filter algorithm with R1 as covariance
%           matrix of the parameter changes per time step
%    adm='ng', adg=gam: A normalized gradient algorithm, with gain gam
%    adm='ug', adg=gam: An Unnormalized gradient algorithm with gain gam
%   THM: The resulting estimates. Row k contains the estimates "in alpha-
%        betic order" corresponding to data up to time k (row k in Z)
%   YHAT: The predicted valued of the output. Row k corresponds to time k.
%   Initial value of parameters(TH0) and of "P-matrix" (P0) can be given by
%   [THM,YHAT,P] = RPLR(Z,NN,adm,adg,TH0,P0)
%   Initial and last values of auxiliary data vector phi  are
%   obtained by [THM,YHAT,P,phi]=RPLR(Z,NN,adm,adg,TH0,P0,phi0).
%
%   See also RPEM, RARMAX, RARX, RBJ and ROE

%   L. Ljung 10-1-89
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:29 $

if nargin < 4
   disp('Usage: MODEL_PARS = RPLR(DATA,ORDERS,ADM,ADG)')
   disp('       [MODEL_PARS,YHAT,COV,PHI] = RPLR(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI)')
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
if ns==1,if length(nn)~=2,error('For a time series nn should be nn = [na nc]!'),end,end
if ns==2,if length(nn)~=6,error('The argument should be nn = [na nb nc nd nf nk]!'),end,end
if ns==2,na=nn(1);nb=nn(2);nc=nn(3);nd=nn(4);nf=nn(5);nk=nn(6);
else na=nn(1);nc=nn(2);nk=1;nb=0;nd=0;nf=0;end
if nk<1,error('Sorry, this routine requires nk>0; Shift input sequence if necessary!'),end
d=na+nb+nc+nd+nf;
if ns>2,error('Sorry, this routine is for single input only!'),end

nbm=nb+nk-1;
tia=1:na;tib=na+1:na+nb;tic=na+nb+1:na+nb+nc;tid=na+nb+nc+1:na+nb+nc+nd;
tif=na+nb+nc+nd+1:d;
ia=tia;ib=na+nk:na+nb+nk-1;ic=tic+nk-1;id=tid+nk-1;iff=tif+nk-1;
iib=na+1:na+nb+nk-1;
dm=na+nbm+nc+nd+nf;
ii=[ia iib ic id iff];i=[ia ib ic id iff];

if nargin<7, phi=zeros(dm,1);end
if nargin<6, p0=10000*eye(d);end
if nargin<5, th0=eps*ones(d,1);end
if isempty(phi),phi=zeros(dm,1);end
if isempty(p0),p0=10000*eye(d);end
if isempty(th0),th0=eps*ones(d,1);end
if length(th0)~=d,error('The length of th0 must equal the number of estimated parameters!'),end
[th0nr,th0nc]=size(th0);if th0nr<th0nc,th0=th0';end

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
if ~grad,K=p*phi(i)/(lam + phi(i)'*p*phi(i));
         p=(p-K*phi(i)'*p)/lam+R1;
else K=adg*phi(i);end
if adm(1)=='n', K=K/(eps+phi(i)'*phi(i));end
th=th+K*epsi;

if nb+nf>0,w=th([tib tif])'*phi([ib iff]);else w=0;end
v=[z(kcou,1);-phi(ia)]'*[1;th(ia)]-w;
epsilon=v-th([tic tid])'*phi([ic id]);


phi(ii+1)=phi(ii);
if na>0,phi(1)=-z(kcou,1);end
if nb>0,phi(na+1)=z(kcou,2);end
if nc>0,phi(na+nbm+1)=epsilon;end
if nd>0,phi(na+nbm+nc+1)=-v;end
if nf>0,phi(na+nbm+nc+nd+1)=-w;end

thm(kcou,:)=th';yhat(kcou)=yh;
end
yhat = yhat';
