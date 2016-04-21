function [na,nb,nc,nd,nf,nk,par,nu] = polychk(a,b,c,d,f,lam,T,inhib);
%POLYCHK  Private function for converting polynomials into their orders
%         and the corresponding parameter vector.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/10 23:17:52 $

if nargin<8
    inhib = 0;
end
if norm(lam)==0
    inhib = 1;
end
[nu,nb1]=size(b); nu=nu(1);
if isempty(a),a=1;end
if isempty(c),c=1;end
if isempty(d),d=1;end
if isempty(f)&~isempty(b),
    f=ones(nu,1);
end

if isempty(T),T=1;end
[nu1,dum]=size(f);
if size(a,1)>1
    error('A must be a row vector.')
end
if size(c,1)>1
    error('C must be a row vector.')
end
if size(d,1)>1
    error('D must be a row vector.')
end

if nu1~=nu,
    error('The B- and the F-polynomials should have the same number of rows.'),
end
if a(1)~=1, 
    error('The A-polynomial should be monic (start with "1").'),
end
if c(1)~=1, 
    error('The C-polynomial should be monic (start with "1").'),
end
if d(1)~=1, 
    error('The D-polynomial should be monic (start with "1").'),
end
if T>0,
    for ku=1:nu,
        if f(ku,1)~=1
            error('Each of the F-polynomials should be monic (start with "1") for discrete time models.')
        end,
    end,
end


na=length(a)-1;nc=length(c)-1;nd=length(d)-1;
if nu>0,
    ib=b~=0; 
    if nb1>1,
        nk=sum(cumsum(ib')==0);
    else 
        nk=(cumsum(ib')==0);
    end
    if T>0,
        ib=(b(:,nb1:-1:1)~=0);
        if nb1>1,
            nb=-sum(cumsum(ib')==0)-nk+nb1;
        else 
            nb=-(cumsum(ib')==0)-nk+nb1;
        end
        nb=max(nb,zeros(1,nu));
    else 
        nb=nb1-nk;
    end,
    nk(find(nb==0))=zeros(1,length(find(nb==0)));
end


if nu==0, 
   nb=zeros(1,0);nk=nb;
end  
[nuf,nf1]=size(f);
if nuf~=nu, error('F and B must have the same number of rows.'),return,end
if nf1==1 | nf1==0
    nf=zeros(1,nu);
else
    if T>0
        ih=(f(:,nf1:-1:1)~=0); nf=-sum(cumsum(ih')==0)+nf1-1;
    else
        ih=f~=0;
        for ku=1:nu
            nf(ku)=nf1-min(find(ih(ku,:)~=0));
            if f(ku,nf1-nf(ku))~=1
                error('For continuous time systems the first non zero element of the rows of f must be a "1", corresponding to a monic F-polynomial.')
            end
        end
    end
end
n=na+sum(nb)+nc+nd+sum(nf);
par=zeros(1,n);
if na>0, par(1:na)=a(2:na+1);end
if nc>0, par(na+sum(nb)+1:na+nc+sum(nb))=c(2:nc+1);end
if nd>0, par(na+nc+1+sum(nb):na+nc+nd+sum(nb))=d(2:nd+1);end


sb=na;sf=na+sum(nb)+nc+nd;
for k=1:nu
    if ~isempty(nb),if nb(k)>0,par(sb+1:sb+nb(k))=b(k,nk(k)+1:nk(k)+nb(k));end,end
    if nf(k)>0,
        if T>0,par(sf+1:sf+nf(k))=f(k,2:nf(k)+1);
        else   par(sf+1:sf+nf(k))=f(k,nf1-nf(k)+1:nf1);
        end
    end
    if ~isempty(nb),sb=sb+nb(k);end
    sf=sf+nf(k);
end
if T==0 & length(c)>length(conv(d,a)) &~inhib,
    warning(sprintf(['This model has differentiated white measurement noise.',...
        '\n   Expect problems with sampling and state-space representations.']))
end
if T==0 & length(c)<length(conv(d,a)) &~inhib,
    warning(sprintf([...
            'This model has no white component in the measurement noise.',...
            '\n         Expect problems with sampling and state-space representations.']))
end
par = par(:); 
