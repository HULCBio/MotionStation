% [marg,peakf] = muperf(sys,delta,g,freqs)
% [grob,peakf] = muperf(sys,delta,0,freqs)
%
% Worst-case RMS performance of uncertain systems with
% norm- or sector-bounded linear time-invariant
% uncertainty:
%                   ___________
%                   |         |
%              |----|  DELTA  |<---|
%              |    |_________|    |
%              |                   |
%              |    ___________    |
%              |--->|         |----|
%                   |   SYS   |
%          u  ----->|_________|----->  y
%
%
% Depending on the third argument G, MUPERF computes:
%   * if G > 0, the portion MARGIN of the uncertainty
%     bounds where the RMS gain from u to y remains no
%     larger than G.  The performance G is robust iff
%     MARGIN >= 1.
%   * if G = 0, the worst-case RMS gain GROB from u to y.
%     This gain is finite iff the interconnection is
%     robustly stable.
% These estimates are based on the mixed-mu upper bound.
%
% Input:
%   SYS        dynamical system  (see LTISYS)
%   DELTA      uncertainty description  (see UBLOCK)
%   G          if positive, RMS performance to be
%              robustly maintained    (Default = 0)
%   FREQS      vector of frequencies  (optional)
%
% Output:
%   MARGIN     robust performance margin for the
%              prescribed maximum gain  G > 0
%   GROB       robust H-infinity performance
%   PEAKF      frequency near which it is achieved
%
%
% See also   MUSTAB, MUBND, UBLOCK, UDIAG, LTISYS.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function [perf,peakf]=muperf(sys,delta,g,freqs)


if nargin<2,
  error('usage: [perf,peakf]=muperf(sys,delta,g,freqs)');
elseif ~islsys(sys),
  error('SYS must be a system matrix');
elseif size(delta,1)<=8,
  error('DELTA is not an uncertainty description');
elseif ~isempty(find(delta(3,:)==0 | delta(4,:)==1)),
  error('the uncertainty must be linear time-invariant');
elseif nargin<4,
  freqs=[0 logspace(-3,3,20)];
  if nargin==2, g=0; end
else
  freqs=sort(freqs); freqs=(freqs(:))';
end

%%% v5 code
Tsec11 = []; Tsec12 = []; Tsec21 = []; Tsec22 = [];

if isempty(delta),
  if g>0, perf=norminf(sys);
  else error('No DELTA uncertainty specified'); end
end


% check dim. compatibility
rd=sum(delta(1,:));
cd=sum(delta(2,:));
[ns,ni,no]=sinfo(sys);
if ni<=rd | no<=cd,
   error('Not enough inputs/outputs in SYS');
end
su=ni-rd; sy=no-cd;


% add performance block
if g>0, pbnd=1/g; else pbnd=1; end
deltaug=udiag(delta,ublock([su,sy],pbnd));
rdaug=sum(deltaug(1,:));
cdaug=sum(deltaug(2,:));


%%%%%%%%%%%%%%%% NORMALIZE THE UNCERTAINTY %%%%%%%%%%%%%%%%%%%%%%%%%


% normalize uncertainty to one
Dl=[]; Dr=[];
for bb=deltaug,
  [dims,aux,bnd]=uinfo(bb,1);
  rb=dims(1);  cb=dims(2);

  if sum(size(bnd))==2,      % scalar bound
     bnd=sqrt(abs(bnd));
     Dl=sdiag(Dl,diag(bnd*ones(rb,1)));
     Dr=sdiag(Dr,diag(bnd*ones(cb,1)));
  elseif sum(size(bnd))~=3,  % freq-dep. bound
     ordr=min(rb,cb);
     w=bnd;
     for i=2:ordr, w=sdiag(w,bnd); end
     if rb<cb,
        Dl=sdiag(Dl,w); Dr=sdiag(Dr,eye(cb));
     else
        Dl=sdiag(Dl,eye(rb));  Dr=sdiag(Dr,w);
     end
  else
     Dl=sdiag(Dl,eye(rb)); Dr=sdiag(Dr,eye(cb));
  end
end

sys=smult(Dl,sys,Dr);


%%%%%%%%%%%%%%%% TEST THE PLANT %%%%%%%%%%%%%%%%%%%%%%%%%

% test nominal stability and perf
[a,b,c,d,e]=ltiss(sys);
desc=(norm(e-eye(size(e)),1)>0);
if desc, eiga=eig(a,e); else eiga=eig(a); end
if max(real(eiga)) >=0, error('The nominal plant SYS is not stable'); end
if g > 0,
  gmin=norminf(ssub(sys,rd+1:ni,cd+1:no));
  if 1 <= gmin,
    error(sprintf(...
    'G must be larger than the nominal performance GMIN = %6.3e',gmin));
  end
end

% triangularize (a,e)
na=size(a,1);
if desc,
  [a,e,qq,zz]=qz(a,e,'complex'); b=qq*b; c=c*zz;
else
  [p,a]=hess(a); e=eye(na);   b=p'*b;  c=c*p;
end

% add critical freqs
reala=abs(real(eiga));
imaga=imag(eiga);
ind=find(reala <= 10*imaga);
selfrq=imaga(ind)';
if isempty(find([selfrq freqs]==0)), freqs=[0 freqs]; end
freqs=[selfrq freqs];
lf=length(freqs);
if lf>1 & norm(d,1)>0, freqs=[freqs(1) 1e6 freqs(2:lf)]; end



%%%%%%%%%%%%% SQUARE UP + TRANSFORM SECTOR BOUNDS %%%%%%%%%%%%%%%%%

% make all uncertainty blocks square

dims=max(deltaug(1,:),deltaug(2,:));   n=sum(dims);
gap=deltaug(1,:)-deltaug(2,:);
indcol=find(gap<0); indrow=find(gap>0);
rowperm=[]; colperm=[];
Mrowptr=0; Mcolptr=0; newrowptr=cdaug;  newcolptr=rdaug;

for blck=indrow,   % insert rows, blck = current block involved
   newptr=sum(deltaug(2,1:blck));   % total row size up to block blck
   rowperm=[rowperm,Mrowptr+1:newptr,newrowptr+1:newrowptr+gap(blck)];
   Mrowptr=newptr;
   newrowptr=newrowptr+gap(blck);
end

for blck=indcol,   % insert columns, blck = current block involved
   newptr=sum(deltaug(1,1:blck));   % total row size up to block blck
   colperm=[colperm,Mcolptr+1:newptr,newcolptr+1:newcolptr-gap(blck)];
   Mcolptr=newptr;
   newcolptr=newcolptr-gap(blck);
end

if length(indrow)>0 | length(indcol)>0,
  rowperm=[rowperm,Mrowptr+1:cdaug];
  colperm=[colperm,Mcolptr+1:rdaug];
  d(newrowptr,newcolptr)=0;
  b=[b,zeros(na,newcolptr-rdaug)];
  c=[c;zeros(newrowptr-cdaug,na)];
  d=d(rowperm,colperm); b=b(:,colperm); c=c(rowperm,:);
end


% transform sector bounds into unit norm bound

issec=any(deltaug(7,:)+deltaug(8,:)==3);   % 1 if there are sector bounds
if issec, aux=deltaug; else aux=[]; end
for bl=aux,
  [dim,aux,bnd]=uinfo(bl,1);
  bs=dim(1);  % block size
  if sum(size(bnd))==3,
     aa=bnd(1);      bb=bnd(2);
     if abs(aa)<1e4, t1=1; t2=aa; else t1=1/abs(aa); t2=sign(aa); end
     if abs(bb)<1e4, t3=1; t4=bb; else t3=1/abs(bb); t4=sign(bb); end

     Ni=inv([t1+t3 -(t4+t2);t1-t3 t4-t2]);
     Tsec11=[Tsec11 , Ni(1,1)*ones(1,bs)];
     Tsec12=[Tsec12 , Ni(1,2)*ones(1,bs)];
     Tsec21=[Tsec21 , Ni(2,1)*ones(1,bs)];
     Tsec22=[Tsec22 , Ni(2,2)*ones(1,bs)];
  else
     Tsec11=[Tsec11 , ones(1,bs)];
     Tsec12=[Tsec12 , zeros(1,bs)];
     Tsec21=[Tsec21 , zeros(1,bs)];
     Tsec22=[Tsec22 , ones(1,bs)];
  end
end
Tsec=[diag(Tsec11) diag(Tsec12);diag(Tsec21) diag(Tsec22)];

if issec,
   Phi=[b zeros(na,n);d -eye(n)]*Tsec;
   y=-Phi(na+1:na+n,n+1:2*n)\[c Phi(na+1:na+n,1:n)];
   dx=[a Phi(1:na,1:n)]+Phi(1:na,n+1:2*n)*y;
   a=dx(:,1:na);     b=dx(:,na+1:na+n);
   c=y(:,1:na);      d=y(:,na+1:na+n);
end


%%%%%%%%%%%%%%%% GENERATE THE SCALING STRUCTURE %%%%%%%%%

% scaling structure for original delta
ds=[]; gs=[]; base=0;
dims0=max(delta(1,:),delta(2,:)); n0=sum(dims0);
scan=[dims0;delta(6,:)];

% D1
D1=zeros(n0); ir=0;
for tt=scan,
  bs=tt(1);  % block size
  if tt(2),  % scalar block
    D1(ir+1:ir+bs,ir+1:ir+bs)=symdec(bs,base);
    base=base+bs*(bs+1)/2;
  else
    base=base+1;
    D1(ir+1:ir+bs,ir+1:ir+bs)=base*eye(bs);
  end
  ir=ir+bs;
end

% D2
D2=zeros(n0);
isD2=~isempty(find(delta(6,:)));
if isD2, aux=scan; ir=0; else aux=[]; end
for tt=aux,
  bs=tt(1);  % block size
  if tt(2),  % scalar block
    D2(ir+1:ir+bs,ir+1:ir+bs)=skewdec(bs,base);
    base=base+bs*(bs-1)/2;
  end
  ir=ir+bs;
end


% G1
isG=~isempty(find(delta(5,:)==0));
if isG, scan=[dims0;delta(5:6,:)];aux=scan;G1=zeros(n0);ir=0; else aux=[]; end
for tt=aux,
  bs=tt(1);  % block size
  if ~tt(2) & tt(3),  % real scalar block
    G1(ir+1:ir+bs,ir+1:ir+bs)=symdec(bs,base);
    base=base+bs*(bs+1)/2;
  elseif ~tt(2),     % real full block
    base=base+1; G1(ir+1:ir+bs,ir+1:ir+bs)=base*eye(bs);
  end
  ir=ir+bs;
end


% G2
G2=zeros(n0);
if isempty(find(delta(6,:) & ~delta(5,:))), aux=[]; else aux=scan;ir=0; end
for tt=aux,
  bs=tt(1);  % block size
  if ~tt(2) & tt(3),
    G2(ir+1:ir+bs,ir+1:ir+bs)=skewdec(bs,base);
    base=base+bs*(bs-1)/2;
  end
  ir=ir+bs;
end



%%%%%%%%%%%%%%%%%%  FORM THE LMI SYSTEM %%%%%%%%%%%%%%%%%%%%%

setlmis([]);
dlb=100; feasr=dlb^4;

% declare variables
Dstr=[D1 D2;-D2 D1];
[D,ndec]=lmivar(3,Dstr);
if isG, [G,ndec]=lmivar(3,[G1 G2;-G2 G1]); end
if g>0,
  Xstr=(ndec+Dstr).*(Dstr~=0);
  [X,ndec]=lmivar(3,Xstr);
else
  [t,ndec]=lmivar(1,[1 0]);
end


bts=n-n0;      % size bottom block
tsel=[eye(n0);zeros(bts,n0)];          tsel=mdiag(tsel,tsel);
bsel=diag([zeros(1,n0),ones(1,bts),zeros(1,n0),ones(1,bts)]);

% term content
% NB: D>I replaced by D>1e-8 since part of D is pre-set to I
lmiterm([1 1 1 0],1/dlb^2);
lmiterm([1 1 1 D],-dlb,dlb);
if ~isD2, lmiterm([1 0 0 0],[eye(n0);zeros(n0)]); end
if g>0,
  lmiterm([-2 1 1 X],tsel,tsel');
  lmiterm([-2 1 1 0],bsel);
  lmiterm([3 1 1 X],1,1);
  lmiterm([-3 1 1 D],1,1);
else
  lmiterm([-2 1 1 D],tsel,tsel');
  lmiterm([-2 1 1 t],1,bsel);
  cc=zeros(1,ndec); cc(ndec)=1;
end
lmi0=getlmis;

% init
j=sqrt(-1); target=1e-6; peakf=freqs(1);
mub2=0;  opts=[1e-3, 0, feasr, 5, 1];
dlast=0; glast=0; alpha=0;




%%%%%%%%%%%%% MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%

for w=freqs,

   fprintf(1,'.');

   P=d+c*((j*w*e-a)\b); P1=P(1:n0,:); P2=P(n0+1:n,:);
   P1r=real(P1); P1i=imag(P1);
   P2r=real(P2); P2i=imag(P2);
   E1=[P1r P1i;-P1i P1r];
   F1=[-P1i P1r;-P1r -P1i];  % j*P1
   E2=[P2r P2i;-P2i P2r];


   % test if current scalings are valid at this freq.
   aux=tsel*glast*F1;
   if g>0,
     optim=max(real(eig(E1'*dlast*E1+E2'*E2+aux+aux'-...
                        mub2*tsel*dlast*tsel'-bsel)))>=0;
   else
     optim=max(real(eig(E1'*dlast*E1+E2'*E2+aux+aux'-...
                        tsel*dlast*tsel'-mub2*bsel)))>=0;
   end


   if optim,
      setlmis(lmi0);
      lmiterm([2 1 1 D],E1',E1);
      lmiterm([2 1 1 0],E2'*E2);
      if isG, lmiterm([2 1 1 G],tsel,F1,'s'); end

      if g>0,
         [alpha,xopt]=gevp(getlmis,1,opts,[],[],target);
      else
         [alpha,xopt]=mincx(getlmis,cc,opts,[],target);
         if isempty(alpha),
           disp(sprintf('\n The interconnection is not robustly stable'));
           perf=Inf; peakf=w; return
         end
      end

      if alpha > 1.01*mub2, peakf=w; end
      mub2=max(mub2,alpha); target=mub2;

      Dscal=dec2mat(lmi0,xopt,D); dlast=Dscal;
      if isG, Gscal=dec2mat(lmi0,xopt,G); glast=Gscal; end
   end
end

fprintf(1,'\n');



if g>0,
  perf=1/sqrt(mub2);
else
  perf=sqrt(mub2);
end
