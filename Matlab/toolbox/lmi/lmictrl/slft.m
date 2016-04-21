% sys=slft(sys1,sys2,udim,ydim)
%
% Forms the linear fractional interconnection
%
%		       _________
%          w1 -------->|       |-------> z1
%		       |  SYS1 |
%            +-------->|_______|-------+
%            |	 	               |
%         u  |                         | y
%            |         _________       |
%            +---------|       |<------+
%		       |  SYS2 |
%         z2 <---------|_______|-------- w2
%
%
% of the two systems SYS1 and SYS2. The resulting
% system SYS maps  (w1,w2)  to  (z1,z2).
%
% UDIM and YDIM are the lengths of the vectors u and y.
% When omitted, they are set to the default values:
%  * if SYS1 has more inputs/outputs than SYS2,
%        UDIM = number of outputs of SYS2
%        YDIM = number of inputs of SYS2
%  * if SYS2 has more inputs/outputs than SYS1,
%        UDIM = number of inputs of SYS1
%        YDIM = number of outputs of SYS1
%
%
% See also  SLOOP, SCONNECT, LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=slft(sys1,sys2,udim,ydim)


if nargin<2,
  error('usage: sys=slft(sys1,sys2,udim,ydim)');
end


% dims

if ispsys(sys1),
  [typ1,xx,na,cd,rd]=psinfo(sys1);
elseif islsys(sys1),
  [na,cd,rd]=sinfo(sys1);
else
  na=0; [rd,cd]=size(sys1);
end
if ispsys(sys2),
  [typ2,xx,nak,cdk,rdk]=psinfo(sys2);
elseif islsys(sys2),
  [nak,cdk,rdk]=sinfo(sys2);
else
  nak=0; [rdk,cdk]=size(sys2);
end
if nargin==2,
   if cd >= rdk & rd >= cdk,
     udim=rdk; ydim=cdk;
   elseif rd <= cdk & cd <= rdk,
     udim=cd; ydim=rd;
   else
     error('The dimensions of u and y must be specified');
   end
elseif udim > rdk | udim > cd | ydim > cdk | ydim > rd,
   error('Incompatible value of UDIM or YDIM');
end



if ispsys(sys1) & ispsys(sys2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert to polytopic in mixed cases
if strcmp(typ1,'aff') & strcmp(typ2,'pol'),
  sys1=aff2pol(sys1); typ1='pol';
elseif strcmp(typ1,'pol') & strcmp(typ2,'aff'),
  sys2=aff2pol(sys2);
end

if strcmp(typ1,'aff'),
  sys=slftaff(sys1,sys2,udim,ydim,1,1);
else
  sys=slftpol(sys1,sys2,udim,ydim,1,1);
end


elseif ispsys(sys1),
%%%%%%%%%%%%%%%%%%%%

if strcmp(typ1,'aff'),
  sys=slftaff(sys1,sys2,udim,ydim,1,0);
else
  sys=slftpol(sys1,sys2,udim,ydim,1,0);
end


elseif ispsys(sys2),
%%%%%%%%%%%%%%%%%%%%

if strcmp(typ2,'aff'),
  sys=slftaff(sys1,sys2,udim,ydim,0,1);
else
  sys=slftpol(sys1,sys2,udim,ydim,0,1);
end

else
%%%%

[a,b,c,d,e]=sxtrct(sys1);
p2=ydim; m2=udim; m1=cd-m2; p1=rd-p2;
b1=sys1(1:na,na+(1:m1));
b2=sys1(1:na,na+m1+(1:m2));
c1=sys1(na+(1:p1),1:na);
c2=sys1(na+p1+(1:p2),1:na);
d11=d(1:p1,1:m1);
d12=d(1:p1,m1+1:m1+m2);
d21=d(p1+1:p1+p2,1:m1);
d22=d(p1+1:p1+p2,m1+1:m1+m2);

[ak,bk,ck,dk,ek]=sxtrct(sys2);
pk1=udim; mk1=ydim; mk2=cdk-mk1; pk2=rdk-pk1;
bk1=sys2(1:nak,nak+(1:mk1));
bk2=sys2(1:nak,nak+mk1+(1:mk2));
ck1=sys2(nak+(1:pk1),1:nak);
ck2=sys2(nak+pk1+(1:pk2),1:nak);
dk11=dk(1:pk1,1:mk1);
dk12=dk(1:pk1,mk1+1:mk1+mk2);
dk21=dk(pk1+1:pk1+pk2,1:mk1);
dk22=dk(pk1+1:pk1+pk2,mk1+1:mk1+mk2);




% scale M=[eye(udim) -dk11;-d22 eye(ydim)] before inverting it

nor1=norm(dk11,1); nor2=norm(d22,1);
thresh=sqrt(mach_eps);
sclf=1;
if nor1 > 1 & nor2 > 1,
  sclf=sqrt(nor2/nor1);
elseif nor1 > 1,
  sclf=max(1/nor1,thresh);
elseif nor2 > 1,
  sclf=min(nor2,1/thresh);
end
M=[eye(udim) -sclf*dk11;-d22/sclf eye(ydim)];

[u,s,v,rk]=svdparts(M,0,mach_eps);
if rk < udim+ydim,
  error('This LFT interconnection is non causal (algebraic loop)');
end
M=v*diag(1./s)*u';
M(1:udim,udim+1:udim+ydim)=M(1:udim,udim+1:udim+ydim)/sclf;
M(udim+1:udim+ydim,1:udim)=M(udim+1:udim+ydim,1:udim)*sclf;


% interconnections

uy2X=M*[zeros(udim,na) ck1;c2 zeros(ydim,nak)];
uy2W=M*[zeros(udim,m1) dk12;d21 zeros(ydim,mk2)];
X2uy=[b2 zeros(na,ydim);zeros(nak,udim) bk1];
Z2uy=[d12 zeros(p1,ydim);zeros(pk2,udim) dk21];

a=mdiag(a,ak)+X2uy*uy2X;
b=[b1 zeros(na,mk2);zeros(nak,m1) bk2]+X2uy*uy2W;
c=[c1 zeros(p1,nak);zeros(pk2,na) ck2]+Z2uy*uy2X;
d=[d11 zeros(p1,mk2);zeros(pk2,m1) dk22]+Z2uy*uy2W;
e=mdiag(e,ek);

if isempty(dk), error('Algebraic loop'); end

sys=ltisys(a,b,c,d,e);

end


% balancing in SYSTEM case
% if islsys(sys), sys=sbalanc(sys); end
