function ms = getarxms(na,nb,nk);
%GETARXMS  build ARX model structure from parameter information

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/02/12 07:37:51 $

if nargin == 1
   nn = na;
elseif norm(nb)>0
   nn = [na nb nk];
else
    nn = na;
end

[ny,nc]=size(nn);
%if isempty(Tsamp),Tsamp=1;end
%if isempty(lam),lam=eye(ny);end

nu=(nc-ny)/2;
na=nn(:,1:ny);
if nu>0,nb=nn(:,ny+1:ny+nu);else nb=zeros(ny,1);end
if nu>0,nk=nn(:,ny+nu+1:nc);else nk=ones(ny,1);end
mna=max(max(na)');
nb1=nb+(nk-1); if nb1<0,nb1=0;end
mnb=max(max(nb1)');

mnk=min(min(nk)');
nx=mna*ny+mnb*nu;
C=zeros(ny,nx);
for ky=1:ny
   for kr=1:ny
      for kc=1:na(ky,kr)
         C(ky,(kc-1)*ny+kr)=NaN;
      end
   end
   for kr=1:nu
      for kc=max(1,nk(ky,kr)):nb1(ky,kr)
         C(ky,(kc-1)*nu+mna*ny+kr)=NaN;
      end
   end
end

if mna>0
   A0=C;A1=[eye(ny*(mna-1)),zeros(ny*(mna-1),ny+nu*mnb)];
else
   A0=[];A1=[];
end
if mnb>0
   A3=[zeros(nu,nx);[zeros(nu*(mnb-1),ny*mna),eye(nu*(mnb-1)),...
            zeros(nu*(mnb-1),nu)]];
else
   A3=zeros(0,size(A1,2));
end
A=[A0;A1;A3];
B=zeros(nx,nu);D=zeros(ny,nu);
if nu>0
   bc=(nk==0) & (nb>0);
   for kbc=1:ny
      for kbr=1:nu
         if bc(kbc,kbr), D(kbc,kbr)=NaN;end
      end
   end
   if mna>0,B(1:ny,1:nu)=D;end
   if mnb>0,B(ny*mna+1:ny*mna+nu,:)=eye(nu);end
end
if nx==0
   B=zeros(ny,nu);
   A=zeros(ny,ny);C=A;K=A;
else
   K=zeros(nx,ny);
end


if mna>0;C=zeros(ny,nx);K(1:ny,1:ny)=eye(ny);end
x0=zeros(nx,1);
if nx==0,x0=zeros(ny,1);end
ms.As = A;
ms.Bs = B;
ms.Cs = C;
ms.Ds = D;
ms.Ks = K;
ms.X0s = x0;
