% called by SLFT

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=slftaff(sys1,sys2,udim,ydim,ps1,ps2)

sys=[]; tol=1e3*mach_eps;

if ps1,
  [xx,nv]=psinfo(sys1); pv1=psinfo(sys1,'par'); pv=pv1;
  [a,b,c,d,e]=sxtrct(psinfo(sys1,'sys',1));
else
  [a,b,c,d,e]=sxtrct(sys1);
end

if ps2,
  [xx,nv]=psinfo(sys2); pv2=psinfo(sys2,'par'); pv=pv2;
  [ak,bk,ck,dk,ek]=sxtrct(psinfo(sys2,'sys',1));
else
  [ak,bk,ck,dk,ek]=sxtrct(sys2);
end

if ps1 & ps2,
  if any(pv1(:)~=pv2(:)),
    error('Incompatible parameter vector descriptions in SYS1 and SYS2');
  end
end

na=size(a,1); [rd,cd]=size(d);
p2=ydim; m2=udim; m1=cd-m2; p1=rd-p2;
if na==0, rgb1=[]; rgc1=[]; rgb2=[]; rgc2=[];
else rgb1=1:m1; rgc1=1:p1; rgb2=m1+1:m1+m2; rgc2=p1+1:p1+p2;  end
b10=b(:,rgb1);b20=b(:,rgb2);
c10=c(rgc1,:);c20=c(rgc2,:);
d110=d(1:p1,1:m1);
d120=d(1:p1,m1+1:m1+m2);
d210=d(p1+1:p1+p2,1:m1);
d220=d(p1+1:p1+p2,m1+1:m1+m2);


nak=size(ak,1); [rdk,cdk]=size(dk);
pk1=udim; mk1=ydim; mk2=cdk-mk1; pk2=rdk-pk1;
dk110=dk(1:pk1,1:mk1);
if nak==0, rgbk1=[]; rgck1=[]; rgbk2=[]; rgck2=[];
else rgbk1=1:mk1; rgck1=1:pk1; rgbk2=mk1+1:mk1+mk2; rgck2=pk1+1:pk1+pk2; end
bk10=bk(:,rgbk1);bk20=bk(:,rgbk2);
ck10=ck(rgck1,:);ck20=ck(rgck2,:);
dk110=dk(1:pk1,1:mk1);
dk120=dk(1:pk1,mk1+1:mk1+mk2);
dk210=dk(pk1+1:pk1+pk2,1:mk1);
dk220=dk(pk1+1:pk1+pk2,mk1+1:mk1+mk2);

%%% v5 code
if isempty(b20), b20 = zeros(na,udim); end
if isempty(bk10), bk10 = zeros(nak,ydim); end
if isempty(c20), c20 = zeros(ydim,na); end
if isempty(ck10), ck10 = zeros(udim,nak); end
if isempty(d120), d120 = zeros(p1,udim); end
if isempty(dk120), dk210 = zeros(pk2,ydim); end
if isempty(d210), d210 = zeros(ydim,m1); end
if isempty(dk120), dk120 = zeros(udim,mk2); end

L10=[b20 zeros(na,ydim);zeros(nak,udim) bk10];
R10=[c20 zeros(ydim,nak);zeros(udim,na) ck10];
L20=[d120 zeros(p1,ydim);zeros(pk2,udim) dk210];
R20=[d210 zeros(ydim,mk2);zeros(udim,m1) dk120];
M0=[-d220 eye(p2);eye(m2) -dk110];
[u,s,v,rk]=svdparts(M0,0,mach_eps);
if rk < udim+ydim,
  error('This LFT interconnection is non causal (algebraic loop)');
end
M0=v*diag(1./s)*u';


% check if the interconnection is affine

vflag1=zeros(1,5);
if ps1,
  for j=2:nv,
    [a,b,c,d,e]=sxtrct(psinfo(sys1,'sys',j));
    vflag1(1)=vflag1(1) | norm(b(:,rgb2),1)>tol;
    vflag1(2)=vflag1(2) | norm(c(rgc2,:),1)>tol;
    vflag1(3)=vflag1(3) | norm(d(1:p1,m1+1:m1+m2),1)>tol;
    vflag1(4)=vflag1(4) | norm(d(p1+1:p1+p2,1:m1),1)>tol;
    vflag1(5)=vflag1(5) | norm(d(p1+1:p1+p2,m1+1:m1+m2),1)>tol;
  end
end

vflag2=zeros(1,5);
if ps2,
  for j=2:nv,
    [ak,bk,ck,dk,ek]=sxtrct(psinfo(sys2,'sys',j));
    vflag2(1)=vflag2(1) | norm(bk(:,rgbk1),1)>tol;
    vflag2(2)=vflag2(2) | norm(ck(rgck1,:),1)>tol;
    vflag2(3)=vflag2(3) | norm(dk(1:pk1,mk1+1:mk1+mk2),1)>tol;
    vflag2(4)=vflag2(4) | norm(dk(pk1+1:pk1+pk2,1:mk1),1)>tol;
    vflag2(5)=vflag2(5) | norm(dk(1:pk1,1:mk1),1)>tol;
  end
end

% form the index matrices
if vflag1(5), % D22 varies
  if norm(dk110,1)>0 | vflag2(5), M=10*eye(2);
  else M=[0 1;1 2]; end
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
  error('SLFT: The interconnection is not affine in the parameters');
end





% form the interconnection

if ps1, s1=psinfo(sys1,'sys',1); else s1=sys1; end
if ps2, s2=psinfo(sys2,'sys',1); else s2=sys2; end
sys=slft(s1,s2,udim,ydim);

for j=2:nv,
  if ps1,
    [a,b,c,d,e]=sxtrct(psinfo(sys1,'sys',j));
    b1=b(:,rgb1);b2=b(:,rgb2);
    c1=c(rgc1,:);c2=c(rgc2,:);
    d11=d(1:p1,1:m1);
    d12=d(1:p1,m1+1:m1+m2);
    d21=d(p1+1:p1+p2,1:m1);
    d22=d(p1+1:p1+p2,m1+1:m1+m2);
  else
    b1=zeros(na,m1);  b2=zeros(na,m2);
    c1=zeros(p1,na);  c2=zeros(p2,na);
    d11=zeros(p1,m1); d12=zeros(p1,m2);
    d21=zeros(p2,m1); d22=zeros(p2,m2);
    a=zeros(na); e=zeros(na);
  end
  if ps2,
    [ak,bk,ck,dk,ek]=sxtrct(psinfo(sys2,'sys',j));
    bk1=bk(:,rgbk1);bk2=bk(:,rgbk2);
    ck1=ck(rgck1,:);ck2=ck(rgck2,:);
    dk11=dk(1:pk1,1:mk1);
    dk12=dk(1:pk1,mk1+1:mk1+mk2);
    dk21=dk(pk1+1:pk1+pk2,1:mk1);
    dk22=dk(pk1+1:pk1+pk2,mk1+1:mk1+mk2);
  else
    bk1=zeros(nak,mk1); bk2=zeros(nak,mk2);
    ck1=zeros(pk1,nak); ck2=zeros(pk2,nak);
    dk11=zeros(pk1,mk1); dk12=zeros(pk1,mk2);
    dk21=zeros(pk2,mk1); dk22=zeros(pk2,mk2);
    ak=zeros(nak); ek=zeros(nak);
  end

  L1=[b2 zeros(na,ydim);zeros(nak,udim) bk1];
  R1=[c2 zeros(ydim,nak);zeros(udim,na) ck1];
  L2=[d12 zeros(p1,ydim);zeros(pk2,udim) dk21];
  R2=[d21 zeros(ydim,mk2);zeros(udim,m1) dk12];
  if norm(d220,1)==0 & vflag2(5),
    M=mdiag(dk11,zeros(mk1,pk1));
  elseif norm(dk110,1)==0 & vflag1(5),
    M=mdiag(zeros(m2,p2),d22);
  else
    M=zeros(p2+m2);
  end

  a=mdiag(a,ak)+L1*M0*R10+L10*M*R10+L10*M0*R1;
  b=[b1 zeros(na,mk2);zeros(nak,m1) bk2]+...
                  L1*M0*R20+L10*M*R20+L10*M0*R2;
  c=[c1 zeros(p1,nak);zeros(pk2,na) ck2]+...
                L2*M0*R10+L20*M*R10+L20*M0*R1;
  d=[d11 zeros(p1,mk2);zeros(pk2,m1) dk22]+...
                L2*M0*R20+L20*M*R20+L20*M0*R2;
  e=mdiag(e,ek);
  sys=[sys ltisys(a,b,c,d,e)];
end

sys=psys(pv,sys);
