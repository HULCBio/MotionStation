function msnew = addnk(msold,nk,flag)
%ADDNK  Help function to IDSS/PVSET
%   
%   MSNEW = ADDNK(MSOLD,NK,FLAG)
%
%   Adds a delay of NK samples to the model structure MSOLD.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $ $Date: 2004/04/10 23:18:17 $

if strcmp(flag,'par')
   a = msold.a; 
   b = msold.b;
   c = msold.c;
   d = msold.d;
   k = msold.k;
   x = msold.x0; 
else
   a = msold.as;
   b = msold.bs;
   c = msold.cs;
   d = msold.ds;
   k = msold.ks;
   x = msold.x0s;
end

[n,dum] = size(a);
[dum,nu] = size(b);
[ny,dum] = size(c);
nk1 = nk-1;
nkind = find(nk1>0);
newst = nk1(nkind);
stateind = cumsum(newst);
naux = sum(newst);
if naux == 0,
    msnew = msold;
    return,
end
anew = [[a,zeros(n,naux)];...
      zeros(1,n+naux);...
      [zeros(naux-1,n),eye(naux-1,naux-1),zeros(naux-1,1)]];

bnew = [b;zeros(naux,nu)];
cnew = [c,zeros(ny,naux)];
knew = [k;zeros(naux,size(k,2))];
xnew = [x;zeros(naux,1)];
anew(1:n,n+stateind) = b(:,nkind);
cnew(:,n+stateind) = d(:,nkind);
bnew(:,nkind) = zeros(n+naux,length(nkind));
arowind = [n+1,stateind+n+1];
for kk = 1:length(nkind),
    bnew(arowind(kk),nkind(kk)) = 1;
    if n>0
        anew(arowind(kk),arowind(kk)-1) = 0;
    end
end
dd=zeros(size(d));
if nu>0
    for kk=find(nk1==-1)
        dd(:,kk)=d(:,kk);
    end
end
if strcmp(flag,'par')
    msnew.a = anew;
    msnew.b = bnew;
    msnew.c = cnew;
    msnew.d = dd;
    msnew.k = knew;
    msnew.x0 = xnew;
else
    msnew.as = anew;
   msnew.bs = bnew;
   msnew.cs = cnew;
   msnew.ds = dd;
   msnew.ks = knew;
   msnew.x0s = xnew;
end


