function msnew = rmnk(msold,nk)
%RMNK  xxx

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/06 14:21:54 $

a=msold.a;b=msold.b;c=msold.c;d=msold.d;k=msold.k;x=msold.x0; 
[n,dum]=size(a);[dum,nu]=size(b);[ny,dum]=size(c);
nk1=nk-1;
nkind=find(nk1>0);
newst=nk1(nkind);
stateind=cumsum(newst);naux=sum(newst);
if naux==0,msnew=msold;return,end
nr=n-naux;
anew=a(1:nr,1:nr);
bnew=b(1:nr,:);
bnew(:,nkind)=a(1:nr,nr+stateind);
 
 cnew=c(:,1:nr);
%dnew = c(:,nr+stateind);
knew=k(1:nr,:);
xnew=x(1:nr);
 
 msnew.a=anew;msnew.b=bnew;msnew.c=cnew;msnew.d=d;
 msnew.k=knew;msnew.x0=xnew;
