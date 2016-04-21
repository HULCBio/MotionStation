% called by SLFT

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=slftpol(sys1,sys2,udim,ydim,ps1,ps2)


sys=[]; tol=1e3*mach_eps; pv=[];

if ps1,
  [xx,nv1]=psinfo(sys1); pv1=psinfo(sys1,'par');
  if ~isempty(pv1), pv=pv1; end
  [a,b,c,d,e]=sxtrct(psinfo(sys1,'sys',1));
else
  [a,b,c,d,e]=sxtrct(sys1);
  nv1=1;
end
if ps2,
  [xx,nv2]=psinfo(sys2); pv2=psinfo(sys2,'par');
  if ~isempty(pv2), pv=pv2; end
  [ak,bk,ck,dk,ek]=sxtrct(psinfo(sys2,'sys',1));
else
  nv2=1;
  [ak,bk,ck,dk,ek]=sxtrct(sys2);
end


if ps1 & ps2 & nv1~=nv2,
  error('Incompatible numbers of systems/parameters in SYS1 and SYS2');
end

na=size(a,1); [rd,cd]=size(d);
p2=ydim; m2=udim; m1=cd-m2; p1=rd-p2;
d220=d(p1+1:p1+p2,m1+1:m1+m2);
nak=size(ak,1); [rdk,cdk]=size(dk);
pk1=udim; mk1=ydim; mk2=cdk-mk1; pk2=rdk-pk1;
dk110=dk(1:pk1,1:mk1);



% check if the interconnection is polytopic

vflag1=zeros(1,5);
if ps1,
  if na==0, rgb=[]; rgc=[]; else rgb=m1+1:m1+m2; rgc=p1+1:p1+p2; end
  b20=b(:,rgb); c20=c(rgc,:);
  d120=d(1:p1,m1+1:m1+m2);
  d210=d(p1+1:p1+p2,1:m1);
  for j=2:nv1,
    [a,b,c,d,e]=sxtrct(psinfo(sys1,'sys',j));
    vflag1(1)=vflag1(1) | norm(b20-b(:,rgb),1)>tol;
    vflag1(2)=vflag1(2) | norm(c20-c(rgc,:),1)>tol;
    vflag1(3)=vflag1(3) | norm(d120-d(1:p1,m1+1:m1+m2),1)>tol;
    vflag1(4)=vflag1(4) | norm(d210-d(p1+1:p1+p2,1:m1),1)>tol;
    vflag1(5)=vflag1(5) | norm(d220-d(p1+1:p1+p2,m1+1:m1+m2),1)>tol;
  end
end

vflag2=zeros(1,5);
if ps2,
  if nak==0, rgb=[]; rgc=[]; else rgb=1:mk1; rgc=1:pk1; end
  bk10=bk(:,rgb); ck10=ck(rgc,:);
  dk120=dk(1:pk1,mk1+1:mk1+mk2);
  dk210=dk(pk1+1:pk1+pk2,1:mk1);
  for j=2:nv1,
    [ak,bk,ck,dk,ek]=sxtrct(psinfo(sys2,'sys',j));
    vflag2(1)=vflag2(1) | norm(bk10-bk(:,rgb),1)>tol;
    vflag2(2)=vflag2(2) | norm(ck10-ck(rgc,:),1)>tol;
    vflag2(3)=vflag2(3) | norm(dk120-dk(1:pk1,mk1+1:mk1+mk2),1)>tol;
    vflag2(4)=vflag2(4) | norm(dk210-dk(pk1+1:pk1+pk2,1:mk1),1)>tol;
    vflag2(5)=vflag2(5) | norm(dk110-dk(1:pk1,1:mk1),1)>tol;
  end
end


% form the index matrices

if vflag1(5), % D22 varies
  if norm(dk110,1)>0 | vflag2(5), M=10*eye(2); else M=[0 1;1 2]; end
elseif norm(d220,1)==0,
  if vflag2(5), m11=2; else m11=norm(dk110,1)>0; end
  M=[m11 1;1 0];
elseif vflag2(5),
  M=10*eye(2);
else
  M=[(norm(dk110,1)>0) 1;1 1];
end


L1=diag(1+[vflag1(1) vflag2(1)]);
R1=diag(1+[vflag1(2) vflag2(2)]);
L2=diag(1+[vflag1(3) vflag2(4)]);
R2=diag(1+[vflag1(4) vflag2(3)]);


% test polytopic nature
if max([max(max(L1*M*R1)) max(max(L1*M*R2)) ...
          max(max(L2*M*R1)) max(max(L2*M*R2))]) > 2,
  error('SLFT: The interconnection is not a polytopic system');
end



% form the interconnection

if ps1 & ps2,
  for j=1:nv1,
    sys=[sys slft(psinfo(sys1,'sys',j),psinfo(sys2,'sys',j),udim,ydim)];
  end
elseif ps1,
  for j=1:nv1, sys=[sys slft(psinfo(sys1,'sys',j),sys2,udim,ydim)]; end
else
  for j=1:nv1, sys=[sys slft(sys1,psinfo(sys2,'sys',j),udim,ydim)]; end
end

sys=psys(pv,sys,1);
