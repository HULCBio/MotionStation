function [thm,yhat,p,phi] = rarx(z,nn,adm,adg,th0,p0,phi)
%RARX   Computes estimates recursively for an ARX model.
%   [THM,YHAT] = RARX(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single output multiple input data only.
%   NN : NN=[na nb nk], The orders and delay of an ARX model (see also ARX)
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
%   [THM,YHAT,P] = RARX(Z,NN,adm,adg,TH0,P0)
%   Initial and last values of auxiliary data vector phi  are
%   obtained by [THM,YHAT,P,phi]=RARX(Z,NN,adm,adg,TH0,P0,phi0).
%
%   See also RARMAX, ROE, RBJ, RPEM and RPLR.

%   L. Ljung 10-1-89
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:28 $

if nargin < 4
   disp('Usage: MODEL_PARS = RARX(DATA,ORDERS,ADM,ADG)')
   disp('       [MODEL_PARS,YHAT,COV,PHI] = RARX(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI)')
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
if ns==1,if length(nn)~=1,
   error('For a time series nn should be a scalar nn=na!')
end,end
if 2*ns-1~=length(nn)
   error('Incorrect number of orders specified in nn. nn=[na nb nk]')
end
na=nn(1);if ns>1,nb=nn(2:ns);nk=nn(ns+1:2*ns-1);else nk=1;nb=0;end
nu=1;
if any(nk<1)
error('Sorry, this routine requires nk>0; Shift input sequence if necessary!')
end
d=na+sum(nb);
nbm=nb+nk-1;ncbm=na+cumsum([0 nbm]);
ii=[1:na+sum(nbm)];
i=[1:na];
for ku=1:ns-1,i=[i ncbm(ku)+nk(ku):ncbm(ku+1)];end

dm=na+sum(nbm);

if nargin<7, phi=zeros(dm,1);end
if nargin<6, p0=10000*eye(d);end
if nargin<5, th0=eps*ones(d,1);end
if isempty(phi),phi=zeros(dm,1);end
if isempty(p0),p0=10000*eye(d);end
if isempty(th0),th0=eps*ones(d,1);end
if length(th0)~=d, error('The length of th0 must equal the number of estimated parameters!'),end
[th0nr,th0nc]=size(th0);if th0nr<th0nc, th0=th0';end

p=p0;th=th0;
if adm(1)=='f', R1=zeros(d,d);lam=adg;end
if adm(1)=='k', [sR1,SR1]=size(adg);
     if sR1~=d | SR1~=d
         error(['The R1 matrix should be a square matrix with dimension ',...
              'equal to number of parameters.'])
     end
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

epsilon=z(kcou,1)-th'*phi(i);

phi(ii+1)=phi(ii);
if na>0,phi(1)=-z(kcou,1);end
if any(ncbm>0),phi(ncbm(1:ns-1)+1)=z(kcou,2:ns)';end

thm(kcou,:)=th';yhat(kcou)=yh;
end
yhat = yhat';
