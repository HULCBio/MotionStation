% [P,r] = sconnect(inputs,outputs,K_in,G1_in,g1,G2_in,g2,...)
%
% SCONNECT computes the SYSTEM matrix  P  of the standard
% H-infinity plant P(s) associated with a given control
% structure.  It also returns the 1x2 vector R such that
%     R(1) = nbr of measurements (controller inputs)
%     R(2) = nbr of controls     (controller outputs)
%
% The control structure is described by the relations between
% the various signals flowing in the control loop:
%
%    * the string  INPUTS  lists the exogenous input signals.
%      For instance,  INPUTS = 'r(2) ; d'  specifies two inputs,
%      a vector r of size 2 and a scalar input d
%    * the string  OUTPUTS  lists the output signals.  The
%      output of a system G is denoted simply by G.  For
%      instance,  OUTPUTS = 'e=r-G ; G'  specifies two
%      output signals e=r-y and y where y is the output of
%      the system G
%    * the string  K_IN  gives the inputs of the controller in
%      terms of the exogenous inputs and the system outputs.
%      For instance,  K_IN = 'K:e'  specifies a controller
%      named K and with input e
%    * each LTI system G in the loop but the controller is
%      specified by its input list   G_IN  and its SYSTEM
%      matrix G.  For instance,  G1_IN = 'S:K' inserts a system
%      named S whose input is the output of the controller K
%
% The syntax G([2,4]) selects the 2nd and 4th output of a system G.
% Note that the names given to the various systems are immaterial
% provided that they are consistent throughout.
%
% If one of the systems is polytopic or parameter-dependent,
% SCONNECT returns a polytopic model of the interconnection.
%
%
% See also  LTISYS, SMULT.

% Author: M. Chilali  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $

function [sys,r]=sconnect(input,output,Kin,in1,g1,in2,g2,in3,g3,in4,g4,...
 in5,g5,in6,g6,in7,g7,in8,g8,in9,g9,in10,g10,in11,g11,in12,g12,in13,g13,...
 in14,g14,in15,g15,in16,g16,in17,g17,in18,g18,in19,g19,in20,g20)

if nargin<5,
 error('Not enough input arguments');
end
n=floor((nargin-3)/2); %number of systems
if 2*n+3~=nargin,
 error('SCONNECT takes an odd number of arguments');
end

%% this avoids that the arguments be changed after the call
%% to eval.
for k=1:n,
  eval(['i',int2str(k),'=in',int2str(k),';']);
end

polsflag=0;
for i=1:n,
  tmps=eval(['g' int2str(i)]);
  if ispsys(tmps),
    if polsflag,
      error('There can be at most one PPD system in the interconnection');
    else
      polsflag=1; pols=tmps;
      if strcmp(psinfo(pols),'aff'),
         disp('Warning: affine PD model converted to polytopic');
         pols=aff2pol(pols);
      end
      if i>1,  % put PDS upfront
         tmp=eval(['i' int2str(i)]);
         eval(['i' int2str(i) '=i1;']);eval(['g' int2str(i) '=g1;']);
         g1=pols; i1=tmp;
      end
    end
  end
end


%
ldef=[];
rdef=ldef;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%        input list parsing   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indim=0; %total input dimension
l=length(input);
i=1;
while i<=l,
 c=input(i);
 if isletter(c),
  dim=1; %default value for dimension of an input
  j=i;
  c='0';
  while isletter(c)|('0'<=c & c<='9'),
   j=j+1;
   if j<=l, c=input(j); else c=''; end
  end
  name=input(i:j-1);
  i=j;
  if i<=l, c=input(i); else c='0'; end
  if c=='(',
   j=find(input(i+1:l)==')');

%%% v4 code
% if j==[]

%%% v5 code
   if isempty(j), error('mismatched parenthesis'); end
   j=j(1)+i;
   sdim=input(i+1:j-1);
   i=j+1;
   sdim_isnum=1;
   for idim=1:length(sdim)
    if ~('0'<=sdim(idim) & sdim(idim)<='9'),
     sdim_isnum=0;
    end
   end
   if ~sdim_isnum,
    error(['badly specified input:',name]);
   end
   eval(['dim=',sdim,';']);
  end
  repname=['0(',int2str(indim+1),':',int2str(indim+dim),')'];
  indim=indim+dim;
  ldef=[ldef,name,'|'];
  rdef=[rdef,repname,'|'];
 else
  i=i+1;
 end
end
%%% v4 code
% if ldef==[]

%%% v5 code
if isempty(ldef), error('no input specified'); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%     system dimensions and names   %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
udim=0; ydim=0;
for k=1:n,
 s = eval(sprintf('i%d',k));
 i=1;
 l=length(s);
 name='';
 while i<=l,
  c=s(i);
  if isletter(c),
   j=i;
   c='0';
   while isletter(c) | ('0'<=c & c<='9'),
    j=j+1;
    if j<=l, c=s(j); else c=''; end
   end
   j2=j;
   while c==' ',
    j2=j2+1;
    if j2<=l, c=s(j2); else c='';end
   end
   if c==':'
    name=s(i:j-1);
    if j>=l, error(['no input to',name]); end
    if k>1,
     instr=[instr,';',s(j+1:l)];
    else
     instr=s(j+1:l);
    end
   end
   i=l+1;
  else
   i=i+1;
  end
 end

 if isempty(name),
    error(['Missing system name in ',int2str(k),'th input list']);
 end
 eval(['sysk=g',int2str(k),';']);
 if k==1 & polsflag,
   [tmp,tmp,tmp,sysin,sysout]=psinfo(sysk);
 else
   [tmp,sysin,sysout]=sinfo(sysk);
 end
 repname=['1(',int2str(ydim+1),':',int2str(ydim+sysout),')'];
 ldef=[ldef,name,'|'];
 rdef=[rdef,repname,'|'];
 ydim=ydim+sysout;
 udim=udim+sysin;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%       CONTROLLER NAME     %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i=1;
l=length(Kin);
name='';
while i<=l,
 c=Kin(i);
 if isletter(c),
  j=i;
  c='0';
  while isletter(c) | ('0'<=c & c<='9'),
   j=j+1;
   if j<=l, c=Kin(j); else c=''; end
  end
  j2=j;
  while c==' ',
   j2=j2+1;
   if j2<=l, c=Kin(j2); else c='';end
  end
  if c==':'
   name=Kin(i:j-1);
   eval(['Kin=Kin(',int2str(j+1),':',int2str(l),');']);
  end
  i=l+1;
 else
  i=i+1;
 end
end
if isempty(name),
 name='K';
 %error('Missing controller name');
end
repname='2(:)';
ldef=[ldef,name,'|'];
rdef=[rdef,repname,'|'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%        Definitions    %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if output(length(output))==';'
 output=output(1:length(output)-1);
end
if isempty(Kin), Kin=''; else output=[output,';',Kin]; end
s=[instr,'|',output];
p=find(s=='=');
dif=0;
for i=1:length(p),
 l=length(s);
 pi=p(i)-dif;
 i1=pi;
 c=' ';
 while c==' ',
  i1=i1-1;
  if i1>0, c=s(i1); else c=''; end
 end
 if ~isempty(c), if ~isletter(c) & ~('0'<=c & c<='9'),
   error('missing left hand side of =');
 end; end
 i2=i1;
 c='0';
 while isletter(c) | ('0'<=c & c<='9'),
  i2=i2-1;
  if i2>0, c=s(i2); else c=' '; end
 end
 name=s(i2+1:i1);
 j1=pi;
 c=' ';
 while c==' ',
  j1=j1+1;
  if j1<=l, c=s(i1); else c=''; end
 end
 if ~isletter(c) & ~('0'<=c & c<='9'),
   error('missing right hand side of = ');
 end
 j2=j1;
 c='0';
 while c~=';' & c~='|',
  j2=j2+1;
  if j2<=l, c=s(j2); else c=';'; end
 end
 repname=s(j1:j2-1);
 ldef=[ldef,name,'|'];
 rdef=[rdef,repname,'|'];
 s=[s(1:i1),s(j2:l)];
 dif=dif+j2-i1-1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%           SUBSTITUTION    %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=find(ldef=='|');
s=[rdef,'?',s];
s2='';
for i=1:length(s),
 if s(i)~=' ',
  s2=[s2,s(i)];
 end
end
s=s2;
len=length(s);
for i=1:length(p),
 q=find(s=='|');
 if i>1,
  pi=p(i-1)+1;
  qi=q(i-1)+1;
 else
  pi=1;
  qi=1;
 end
 name=ldef(pi:p(i)-1);
 repname=s(qi:q(i)-1);
 %parsing repname
 signame=[]; sigdim=[]; sigsign=[];
 l1=length(name); l2=length(repname);
 j=1;
 while j<=l2,
  c=repname(j);
  while c==' ',
   j=j+1; if j<=l2, c=repname(j); else c=''; end
  end
  if c=='-',
   sigsign=[sigsign,'-'];
  else
   sigsign=[sigsign,'+'];
  end
  while ~isempty(c) & ~isletter(c) & ~('0'<=c & c<='9'),
   j=j+1;
   if j<=l2, c=repname(j); else c=''; end
  end
  j2=j;
  while isletter(c) | ('0'<=c & c<='9'),
   j2=j2+1;if j2<=l2, c=repname(j2); else c=''; end
  end
  signame=[signame,repname(j:j2-1),'|'];
  if strcmp(c,'(')
   j3=find(repname(j2+1:l2)==')');
   j3=j3(1)+j2;
   aux=repname(j2+1:j3-1);
   j=j3+1;
  else
   aux=':';
   j=j2;
  end
  sigdim=[sigdim,aux,'|'];
 end
 jname=find(signame=='|');
 jdim=find(sigdim=='|');
%%searching for name
 pn=[];
 for j=1:len-l1+1,
  if s(j:j+l1-1)==name,
   if j>1, c=s(j-1); else c=' '; end
   if ~isletter(c) & ~('0'<=c & c<='9'),
    if j+l1<=len, c=s(j+l1); else c=' '; end
    if ~isletter(c) & ~('0'<=c & c<='9'),
     pn=[pn,j];
    end
   end
  end
 end
%%

 if ~isempty(pn), pn1=pn(1); else pn1=len+1;end
 y=s(1:pn1-2);
 if pn1>1, c=s(pn1-1); else c=''; end
 if c~='+' & c~='-', y=[y,c]; end
 for j=1:length(pn),
  p1=pn(j);
  p2=p1+l1;
  if p1>1, c=s(p1-1);else c=''; end
  if c=='-', sgn=-1; else sgn=1; end
  index='(:)';
  if p2<len
    if s(p2)=='(',
      p3=find(s(p2+1:len)==')');
      p3=p3(1)+p2;
      index=s(p2:p3);
      p2=p3+1;
    end
  end
  %replacement
  for jj=1:length(sigsign),
   aux0=sigsign(jj);
   if sgn==-1,
    if  aux0=='-', aux0='+'; else aux0='-'; end
   end
   if jj>1,
    aux1=signame(jname(jj-1)+1:jname(jj)-1);
    aux2=sigdim(jdim(jj-1)+1:jdim(jj)-1);
   else
    aux1=signame(1:jname(jj)-1);
    aux2=sigdim(1:jdim(jj)-1);
   end
   if aux2==':',
    aux2=index;
   else
    eval(['aux2=',aux2,';']);
    eval(['aux2=aux2',index,';']);
    laux=length(aux2);
    a1=aux2(1);a2=aux2(laux);
    if size(aux2,1)>1, aux2=aux2';end
    cont=0;
    if laux==a2-a1+1,
     if aux2==(a1:a2),
      cont=1;
     end
    end
    if cont,
      aux2=['(',int2str(a1),':',int2str(a2),')'];
    else
     aux3=['[',int2str(a1)];
     for iaux=2:laux,
      aux3=[aux3,',',int2str(aux2(iaux))];
     end
     aux2=['(',aux3,'])'];
    end
   end
   y=[y,aux0,aux1,aux2];
  end
  %
  if j<length(pn), pn1=pn(j+1); else pn1=len+1; end
  y=[y,s(p2:pn1-2)];
  if pn1>p2, c=s(pn1-1); else c=''; end
  if ~isempty(c), if c~='+' & c~='-', y=[y,c]; end , end
 end
 s=y; len=length(s);
end
%%
p=find(y=='?');
p=p(1);
rdef=y(1:p-1);
s=y(p+1:length(y));
p=findstr(s,'|');
p=p(1);
instr=s(1:p-1);
output=s(p+1:length(s));
if isempty(output),
 error('No output is specified');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Output Dimension of K %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(Kin), Kdim=0; else Kdim=[]; end

%%% v4 code
% if Kdim==[]

%%% v5 code
if isempty(Kdim),
%%searching for occurences of '2' (controller name)
 l=length(instr);
 i=0;found=0;
 while ~found,
  i=i+1;
  if i>l,
   pk=i; found=1;
  elseif instr(i)=='2',
   if i>1, c=instr(i-1); else c=' '; end
   if ~isletter(c) & ~('0'<=c & c<='9') & c~='(' & c~=':',
    if i<l, c=instr(i+1); else c=' '; end
     if ~isletter(c) & ~('0'<=c & c<='9') &c~=':' & c~=')'
      if c=='(',
       if i+3<=l,
        if instr(i+1:i+3)=='(:)', %change to more general?
         pk=i; found=1;
        end
       end
      else
      pk=i; found=1;
     end
    end
   end
  end %elseif
 end
 if ~found,
  error('Controller output must be used in system inputs');
 end
 if pk>l,
  error('Controller output must be used in system inputs');
 end
 %
 p=find([instr,';']==';');
 i=find(p>pk);
 i=i(1);
 if i>1,
  s=instr(p(i-1)+1:p(i)-1);
 else
  s=instr(1:p(i)-1);
 end
 j1=find(s=='(');
 j2=find(s==')');
 if length(j1)~=length(j2), error('Unmatched parenthesis'); end
 k=1;
 while isempty(Kdim) & k<=length(j1),
  k1=j1(k);k2=j2(k);
  if k2-k1~=2 | s(k1+1)~='(:)',
   eval(['Kdim=length(',s(k1+1:k2-1),');']);
  end
  k=k+1;
 end
 %
 if isempty(Kdim),
  dim=sqrt(-1);
  p=[p(1:i-1),p(i+1:length(p))];
  for i=1:length(p),
   if i>1,
    s=instr(p(i-1)+1:p(i)-1);
   else
    s=instr(1:p(i)-1);
   end
   blocdim=sqrt(-1);
   j1=find(s=='(');
   j2=find(s==')');
   if length(j1)~=length(j2), error('Unmatched parenthesis'); end
   if ~isempty(j1),
    k1=j1(1);k2=j2(1);
    if k2-k1~=2 | s(k1+1)~=':',
     eval(['blocdim=length(',s(k1+1:k2-1),');']);
    end
   end
   dim=dim+blocdim;
  end
  x=real(dim);
  y=imag(dim);
  Kdim=round((udim-x)/y);
 end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Input Dimension of K %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kindim=0;
if Kdim~=0,
 p=find(output==';');
 q=find(Kin==';');
 q=length(p)-length(q);
 p=p(q);
 s=output(p+1:length(output));
 p=find([s,';']==';');
 for i=1:length(p),
  if i>1,
   s1=s(p(i-1)+1:p(i)-1);
  else
   s1=s(1:p(i)-1);
  end
  blocdim=Kdim;
  j1=find(s1=='(');
  j2=find(s1==')');
  if length(j1)~=length(j2), error('Unmatched parenthesis'); end
  if ~isempty(j1),
   k1=j1(1);k2=j2(1);
   if k2-k1~=2 | s1(k1+1)~=':',
    eval(['blocdim=length(',s1(k1+1:k2-1),');']);
   end
  end
  Kindim=Kindim+blocdim;
 end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%  Determine transition matrices   %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
E=[];EK=[];F=[];
P=[];PK=[];Q=[];
s=instr;
for is=1:2,
 if is==2, s=output; end
 dim=0;
 p=find([s,';']==';');
 p1=1;
 for i=1:length(p);
  ak=[]; bk=[]; ck=[];
  p2=p(i)-1;
  sig=s(p1:p2);
  l=length(sig);
  j=0;
  blocdim=0;
  while j<l,
   j=j+1;
   sgn=1;c=sig(j);
   while ~isempty(c) & ~isletter(c) & ~('0'<=c & c<='9'),
    if j<=l, c=sig(j); else c=''; end
    if c=='-', sgn=-sgn; end
    j=j+1;
   end
   ic=j-1;
   if ~isempty(c),
    index=[];
    if j+2<=l,
     if sig(j)=='(',
      q=find(sig(j+1:l)==')');
      if isempty(q), error('Unmatched parenthesis'); end
      q=q(1)+j;
      sindex=sig(j+1:q-1);
      j=q;
      if length(sindex)>1 | sindex(1)~=':',
       eval(['index=',sindex,';']);
      end
     end
    end
    if isempty(index),
     if c=='0', index=1:indim; end
     if c=='1', index=1:ydim; end
     if c=='2', index=1:Kdim; end
    end
    if blocdim==0,
     blocdim=length(index);
    end
    if isempty(ak) & (~isempty(index)),
     ak=zeros(blocdim,indim);
     bk=zeros(blocdim,Kdim);
     ck=zeros(blocdim,ydim);
    end
    if c=='0', ak(:,index)=sgn*eye(blocdim); end
    if c=='1', ck(:,index)=sgn*eye(blocdim); end
    if c=='2', bk(:,index)=sgn*eye(blocdim); end
    if c~='0' & c~='1' & c~='2'
     jc=ic;
     while isletter(c) | ('0'<=c & c<='9'),
      jc=jc+1;
      if jc<=l, c=sig(jc); else c=''; end
     end
     error(['unrecognized symbol: ',sig(max(ic,1):jc-1)]);
    end
   end
  end
  if is==1,
   E=[E;ak]; EK=[EK;bk];F=[F;ck];
  else
   P=[P;ak]; PK=[PK;bk]; Q=[Q;ck];
  end
  p1=p2+2;
 end
end



%%% matrix computations:

E=[E,EK];  % transition matrices
P=[P,PK];
r=[Kindim,Kdim];
A=[]; B=[]; C=[]; D=[];
nA=0; nB=0; nC=0;

% form interconnection matrices for 2:n systems
for k=2:n,
 eval(['sysk=g',int2str(k),';']);
 [ak,bk,ck,dk]=sxtrct(sysk);
 [sysout,sysin]=size(dk); nak=size(ak,1);
 A=[A, zeros(nA,nak); zeros(nak,nA), ak];
 B=[B, zeros(nA,sysin); zeros(nak,nB), bk];
 C=[C, zeros(nC,nak); zeros(sysout,nA), ck];
 D=[D, zeros(nC,sysin); zeros(sysout,nB), dk];
 nA=nA+nak; nB=nB+sysin; nC=nC+sysout;
end




if polsflag,

  [tmp,nv,nak,sysin,sysout]=psinfo(pols);
  polout=[];
  for i=1:nv,
    [ak,bk,ck,dk]=sxtrct(psinfo(pols,'sys',i));
    AA=[ak zeros(nak,nA); zeros(nA,nak) A];
    BB=[bk zeros(nak,nB); zeros(nA,sysin)  B];
    CC=[ck zeros(sysout,nA);zeros(nC,nak)  C];
    DD=[dk zeros(sysout,nB);zeros(nC,sysin) D];

    na=size(AA,1);
    AA=mdiag(AA,P);
    BB=mdiag(BB,Q);
    CC=mdiag(CC,E);
    DD=[DD,-eye(size(DD,1));-eye(size(DD,2)),F];
    if rcond(DD)<1000*mach_eps,
     disp('Warning: badly conditioned computations due to algebraic loop');
    end
    sys=mdiag(AA-BB/DD*CC,-Inf);
    sys(1,size(sys,2))=na;
    polout=[polout sys];
  end

  sys=psys(psinfo(pols,'par'),polout,1);

else

  [ak,bk,ck,dk]=sxtrct(g1);
  [sysout,sysin]=size(dk);
  nak=size(ak,1);
  A=[ak zeros(nak,nA); zeros(nA,nak) A];
  B=[bk zeros(nak,nB); zeros(nA,sysin)  B];
  C=[ck zeros(sysout,nA);zeros(nC,nak)  C];
  D=[dk zeros(sysout,nB);zeros(nC,sysin) D];

  na=size(A,1);
  A=mdiag(A,P);
  B=mdiag(B,Q);
  C=mdiag(C,E);
  D=[D,-eye(size(D,1));-eye(size(D,2)),F];
  if rcond(D)<1000*mach_eps,
     disp('Warning: badly conditioned computations due to algebraic loop');
  end
  sys=mdiag(A-B/D*C,-Inf);
  sys(1,size(sys,2))=na;

end

%%
