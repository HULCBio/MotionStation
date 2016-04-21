% function sysout = syscl(sys)
%
%  SYSCL scales a state space realization in order to
%  reduce errors in later calculations, using diagonal
%  similarity transformations, and deleting any rows
%  and columns which are zero (apart from the diagonal of A).

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout=syscl(sys)

[a,b,c,d]=unpck(sys);
[n,n1]=size(a);
if n1~=n
  disp('A is not square')
  return
end
[n1,m]=size(b)
if n1~=n
  disp('dimensions do not match')
  return
end
[p,n1]=size(c)
if n1~=n
  disp('dimensions do not match')
  return
end
ib=16;bb=256;il=1;ih=n;

% remove and save the diagonal of a.

adiag=diag(a); a=a-diag(adiag,0);

% find zero rows in a & b and zero columns in a & c

perm=ones(1,n);for i=1:n,perm(i)=i;end;
j=ih;
while j>0,
  nozra=any((a(perm,perm))');
  nozb=any([b(perm,:),zeros(n,1)]')|nozra;
  nozca=any(a(perm,perm));
  nozc=any([c(:,perm);zeros(1,n)])|nozca;
  if ~nozb(j)|~nozc(j),
    for i=j+1:n,perm(i-1)=perm(i);end;
    n=n-1;ih=ih-1;j=ih+1;
    perm=perm(1:n);
  elseif j==1,break;
  end;
  j=j-1;
end;
j=ih;
while j>0,
  if ~nozra(j),t=perm(j);perm(j)=perm(ih);perm(ih)=t;
    t=nozra(j);nozra(j)=nozra(ih);nozra(ih)=t;
    ih=ih-1;j=ih+1;
  elseif j==1,break;
  end;
  j=j-1;
end;
j=il;
while j<=ih,
  if ~nozca(j),t=perm(j);perm(j)=perm(il);perm(il)=t;
    t=nozca(j);nozca(j)=nozca(il);nozca(il)=t;
    il=il+1;j=il-1;
  elseif j==ih,break;
  end;
  j=j+1;
end;
perm=perm(1:n);a=a(perm,perm);b=b(perm,:);c=c(:,perm);
adiag=adiag(perm);
%n,a,b,c,il,ih
% scaling

fail=1;
while fail,fail=0;
  for i=1:n,
    cosum=sum([abs(a(:,i));abs(c(:,i))]);
    rosum=sum([abs(a(i,:)), abs(b(i,:))]);
    f=1;g=rosum/ib;s=cosum+rosum;
    while cosum<g,f=f*ib;cosum=cosum*bb;end;
    g=rosum*ib;
    while cosum>=g,f=f/ib;cosum=cosum/bb;end;
    if(cosum+rosum)/f<0.95*s,
      g=1/f;fail=1;
      a(i,:)=a(i,:)*g;a(:,i)=a(:,i)*f;
      b(i,:)=b(i,:)*g;c(:,i)=c(:,i)*f;
    end;
  end;
end;
a=a+diag(adiag,0);
sysout=pck(a,b,c,d);
%
%