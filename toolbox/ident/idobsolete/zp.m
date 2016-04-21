function [zepo,Kg]=zp(th,ku,ky,thresh)
%ZP     Computes zeros, poles and static gains associated with a model
%   This function is obsolete. Use ZPKDATA instead.
%
%   [ZEPO,K] = zp(TH)
%
%   For a model defined by TH (as a model object IDPOLY, IDARX, IDSS or IDGREY)
%   ZEPO is returned as the zeros and poles and K as the static gains
%   of the model. The first rows in these matrices contain integers with
%   information about the column in question. For the zeros and the gains
%   this integer is simply the input number, while for the poles it is
%   20 + the input number. The noise source e is in this context counted
%   as input number 0. For multi-output models, 1000*(output # - 1) is
%   added to these numbers.
%
%   With  [ZEPO,K] = zp(TH,KU,KY) the zeros and poles associated with
%   the input and output numbers given by the entries of the row vectors
%   KU and KY, respectively, are computed.
%   Default values: KU=[1:number of inputs], KY=[1:number of outputs].
%   Noise input from source ke is counted as input # -ke.
%   Input number 0 means all noise sources.
%   The zeros and poles can be plotted by ZPPLOT. zpplot(zp(TH)) is a
%   possible construction.
%   See also th2zp.

%   L. Ljung 10-1-86, revised 7-3-87,1-16-94.
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:20:12 $

% *** Set up default values ***
if nargin<4, thresh=[];end
if nargin<3, ky=[];end
if nargin<2, ku=[];end
if isempty(thresh),thresh=100000;end
if ~isa(th,'idmodel')
    th = th2ido(th);
end
if isthss(th)
    pars=th2par(th);
    if any(abs(imag(pars))>eps),cplx=1;else cplx=0;end
    %if ~cplx
    [zepo,Kg]=zpss(th,ku,ky,thresh);
    %else
    %   eval('[zepo,Kg]=zpssnosp(th,ku,ky,thresh);')
    %end
    return
end
nu = size(th,2);
if nu==0,kudef=0;else kudef=1:nu;end
if isempty(ku), ku=kudef;end
if any(ku==-1), ku(find(ku==-1))=0;end
if max(ku)>nu | min(ku)<0, 
    error('Input indices outside # of inputs in theta')
    return,
end
[a,b,c,d,f]=polydata(th);
if length(find(ku==0))>0
    b(nu+1,1:length(c))=c;
    f(nu+1,1:length(d))=d;
end
[n1,nb]=size(b); [n1,nf]=size(f);
nzp=max(nb-1,nf+length(a)-2);
zepo=zeros(nzp+1,2*length(ku))+inf;
cc=1;
for k=ku
    if k<=0,
        k1=501;k=nu+1;
    else 
        k1=k;
    end
    zepo(1,cc:cc+1)=[k1 20+k1];Kg(1,(cc+1)/2)=k1;
    dg=conv(a,f(k,:));
    zb=roots(b(k,:)); nzb=length(zb);
    kind=find(abs(zb)>thresh);
    if ~isempty(kind),
        zb(kind)=inf*ones(length(kind),1);
    end
    if nzb>0, 
        zepo(2:nzb+1,cc)=zb;
    end
    zg=roots(dg); nzg=length(zg);
    if nzg>0, 
        zepo(2:nzg+1,cc+1)=zg;
    end
    [tmp1,tmp2]=size(b(k,:));
    [md,nd] = size(dg);
    Kg(2,(cc+1)/2)=(b(k,:)*ones(tmp1,tmp2)')/(dg*ones(md,nd)');
    cc=cc+2;
end
zepo(1,:)=sign(gett(th))*zepo(1,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [zepo,k] = zpss(th,nnu,nny,thresh)
%ZPSS   An auxiliary function to ZP.
%
%   [zepo,k] = zpss(th,nnu,nny)
%

%   L. Ljung 10-2-90,11-11-91
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:20:12 $

if ~exist('ss2zp'),error('This routine requires the SIGNAL PROCESSING TOOLBOX'),end
[a,b,c,d,km]=ssdata(th); [nx,nu]=size(b);[ny,nx]=size(c);
if any(nnu>nu),error('There are not that many inputs in the model!'),end
if any(nnu<-ny),error('There are not that many noise sources in the model!'),end
if any(nny>ny) | any(nny<1)
    error('There are not that many outputs in the model!'),end
T=gett(th);
if isempty(nnu),nnu=1:nu;end
if isempty(nny),nny=1:ny;end
lny=length(nny);
if any(nnu==0),
    nnu=[-ny:-1,nnu(find(nnu>0))];
end
if length(nnu)>0
    zepo=[];k=[];
    for ku=nnu
        G1=zeros(1+nx,2*lny)+inf;ka1=zeros(2,lny);
        if ku<0, btemp=km;dtemp=eye(ny);ku1=abs(ku);ku=500+ku1;
        else btemp=b;dtemp=d;ku1=ku;end
        [z1,p1]=ss2zp(a,btemp,c(nny,:),dtemp(nny,:),ku1);
        [nzr,nzc]=size(z1);
        if nzc<lny,  %This fix is due to a bug in ss2zp
            z1=inf*ones(nx,lny);kcount=1;
            for kky=nny
                z1t=ss2zp(a,btemp,c(kky,:),dtemp(kky,:),ku1);
                if ~isempty(z1t),z1(1:length(z1t),kcount)=z1t;end,kcount=kcount+1;
            end
        end
        [k1,ph1]=trfsaux(a,btemp,c(nny,:),dtemp(nny,:),ku1,eps,T);
        k1=k1.*(1-2*abs(round(rem(ph1/180,2))));
        [rz1,cz1]=size(z1);
        for kinf=1:cz1
            kind=find(abs(z1(:,kinf))>thresh);
            if ~isempty(kind),z1(kind,kinf)=inf*ones(length(kind),1);end
        end
        G1(1,1:2:2*lny)=1000*(nny-1)+ku;
        G1(1,2:2:2*lny)=1000*(nny-1)+20+ku;ka1(1,1:lny)=1000*(nny-1)+ku;
        [nzr,nzc]=size(z1);
        G1(2:nzr+1,1:2:2*lny)=z1;
        G1(2:length(p1)+1,2:2:2*lny)=p1*ones(1,lny);
        ka1(2,1:lny)=k1;
        k=[k ka1];
        zepo=[zepo G1];
    end,end
zepo(1,:)=sign(T)*zepo(1,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mag,phas] = trfsaux(a,b,c,d,iu,w,Tsamp)
%TRFSAUX        Auxiliary function to TRFSS
%
%   [mag,phase] = trfsaux(a,b,c,d,ku,w,T)

%   L. Ljung 10-2-90
%   Copyright (c) 1986-98 by The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:20:12 $

[no,ns] = size(c);
nw = length(w);

[t,a] = balance(a);
b = t \ b;
c = c * t;
[p,a] = hess(a);
b = p' * b(:,iu);
c = c * p;
d = d(:,iu);
if Tsamp>0 w = exp(Tsamp*w * sqrt(-1)); else w = w * sqrt(-1);end
try
    g = ltifr(a,b,w);
catch
    g = mimofr(a,b,[],[],w(:));
    g = reshape(g,[length(a) prod(size(w))]);
end
g = c * g + diag(d) * ones(no,nw);
mag = abs(g)';
[ny,nx]=size(c);
for ky=1:ny
    phas(:,ky) = 180*phase(g(ky,:))'/pi;
end