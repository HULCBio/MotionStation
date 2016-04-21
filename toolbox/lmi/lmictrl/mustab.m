% [margin,peakf,fs,ds,gs] = mustab(sys,delta,freqs)
%
% Estimates the robust stability margin MARGIN of uncertain
% systems with norm- or sector-bounded linear time-invariant
% uncertainty.
%                   ___________
%                   |         |
%              +----|  DELTA  |<---+
%              |    |_________|    |
%              |                   |
%              |    ___________    |
%              +--->|         |----+
%                   |   SYS   |
%          u  ----->|_________|----->  y
%
%
% The interconnection is robustly stable if MARGIN >= 1.
%
% The reciprocal of MARGIN is the upper bound on the mixed mu.
%
% Input:
%  SYS         dynamical system (see LTISYS)
%  DELTA       uncertainty structure (see UBLOCK)
%  FREQS       optional vector of frequency points
%
% Output:
%  MARGIN      robust stability margin
%  PEAKF       frequency near which the margin is weakest
%  FS,DS,GS    D,G scalings at the tested frequencies FS.
%              The scalings  Di, Gi  at the frequency  FS(i)
%              are given by
%                  Di = getdg(DS,i);    Gi = getdg(GS,i);
%
%
% See also    MUBND, MUPERF, GETDG, UBLOCK, UDIAG, UINFO.

% Author: P. Gahinet  3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $

function [margin,peakf,fs,ds,gs]=mustab(sys,delta,freqs)

%%% v5 code
Tsec11 = [];
Tsec12 = [];
Tsec21 = [];
Tsec22 = [];

if nargin<2,
  error('usage: [margin,peakf]=mustab(sys,delta,freqs)');
elseif ~islsys(sys),
  error('SYS must be a system matrix');
elseif size(delta,1)<=8,
  error('DELTA is not an uncertainty description');
elseif ~isempty(find(delta(3,:)==0 | delta(4,:)==1)),
  error('the uncertainty must be linear time-invariant');
elseif nargin < 3,
  freqs=[];
end




%%%%%%%%%%%%%%%%%%% UNCERTAINTY FORMATTING %%%%%%%%%%%%%%%%%

% check dim. compatibility
rd=sum(delta(1,:));
cd=sum(delta(2,:));
[ns,ni,no]=sinfo(sys);
if ni<rd | no<cd,
   error('SYS and DELTA are not of compatible dimensions');
else
   sys=ssub(sys,1:rd,1:cd);
end


% normalize uncertainty to one
Dl=[]; Dr=[];
for b=delta,
  [dims,aux,bnd]=uinfo(b,1);
  rb=dims(1);  cb=dims(2);

  if sum(size(bnd))==2,      % scalar norm bound
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


% unpack sys
[a,b,c,d,e]=ltiss(sys);
na=size(a,1);


% make all uncertainty blocks square

dims=max(delta(1,:),delta(2,:));   n=sum(dims);
gap=delta(1,:)-delta(2,:);
indcol=find(gap<0); indrow=find(gap>0);
rowperm=[]; colperm=[];
Mrowptr=0; Mcolptr=0; newrowptr=cd;  newcolptr=rd;

for blck=indrow,   % insert rows, blck = current block involved
   newptr=sum(delta(2,1:blck));   % total row size up to block blck
   rowperm=[rowperm,Mrowptr+1:newptr,newrowptr+1:newrowptr+gap(blck)];
   Mrowptr=newptr;
   newrowptr=newrowptr+gap(blck);
end

for blck=indcol,   % insert columns, blck = current block involved
   newptr=sum(delta(1,1:blck));   % total row size up to block blck
   colperm=[colperm,Mcolptr+1:newptr,newcolptr+1:newcolptr-gap(blck)];
   Mcolptr=newptr;
   newcolptr=newcolptr-gap(blck);
end


if length(indrow)>0 | length(indcol)>0,
  rowperm=[rowperm,Mrowptr+1:cd];
  colperm=[colperm,Mcolptr+1:rd];
  d(newrowptr,newcolptr)=0;
%  d=mdiag(d,zeros(newrowptr-cd,newcolptr-rd)); 9/94
  b=[b,zeros(na,newcolptr-rd)];
  c=[c;zeros(newrowptr-cd,na)];
  d=d(rowperm,colperm); b=b(:,colperm); c=c(rowperm,:);
end


% transform sector bounds into unit norm bound

issec=any(delta(7,:)+delta(8,:)==3);   % 1 if there are sector bounds
if issec, aux=delta; else aux=[]; end
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



%%%%%%%%%%%%%% GENERATE THE SCALING STRUCTURE %%%%%%%%%%

base=0; ir=0; bcoord=[]; % row coordinates of each block
for bs=dims, bcoord=[bcoord [ir+1;ir+bs]]; ir=ir+bs; end
nzg=bcoord(:,find(~delta(5,:)));
maxgb=max(dims(find(~delta(5,:))));
isG=~isempty(nzg);
scan=[dims;bcoord;delta(6,:)];

% D1
D1=zeros(n);
for tt=scan,
  bs=tt(1);  range=tt(2):tt(3);  % bs=block size
  if tt(4),  % scalar block
    D1(range,range)=symdec(bs,base); base=base+bs*(bs+1)/2;
  else
    base=base+1; D1(range,range)=base*eye(bs);
  end
end

% D2
D2=zeros(n);
aux=scan(1:3,find(delta(6,:))); isD2=~isempty(aux);
for tt=aux,
  bs=tt(1); range=tt(2):tt(3);
  D2(range,range)=skewdec(bs,base);
  base=base+bs*(bs-1)/2;
end

% G1
aux=scan(:,find(~delta(5,:)));
G1=zeros(n);
for tt=aux,
  bs=tt(1); range=tt(2):tt(3);
  if tt(4), % real scalar block
    G1(range,range)=symdec(bs,base); base=base+bs*(bs+1)/2;
  else      % real full block
    base=base+1; G1(range,range)=base*eye(bs);
  end
end

% G2
G2=zeros(n);
aux=scan(1:3,find(~delta(5,:) & delta(6,:)));
for tt=aux,
  bs=tt(1); range=tt(2):tt(3);
  G2(range,range)=skewdec(bs,base);
  base=base+bs*(bs-1)/2;
end



%%%%%%%%%%%%%%%%%% GENERATE THE FREQUENCY GRID %%%%%%%%%%%%%%%

% compute the eigenvalues of A
desc=(norm(e-eye(size(e)),1)>0);
if desc, eiga=eig(a,e)'; else eiga=eig(a)'; end
if max(real(eiga)) >=0, error('The nominal system is not stable'); end
if ~isempty(freqs), if ~freqs(1), freqs(1)=[]; end, end
finit=[]; tfreqs=[]; f0=min(abs(eiga))/10;


% determine resonant freqs and their multiplicity
resf=eiga(find(abs(real(eiga)) <= 10*imag(eiga)));
[aux,ix]=sort(abs(imag(resf)));  resf=resf(ix);

j=sqrt(-1);
% generate freq. grid
while ~isempty(resf),
  w0=abs(resf(1));
  ix=find(abs(imag(resf-resf(1)))<1e-2*w0);
  p=length(ix);  % multiplicity
  if isG & p > 2,
    w0=sum(abs(resf(ix)))/p;
    aux=resf(ix)/w0;
    polw=poly([-j*aux,-j*conj(aux)]);
    % we want those w making pol(w)/pol(w0) real
    r=roots(imag(polw/polyval(polw,1)));
    [aux,idx]=sort(abs(r-1));
    r=w0*sort(real(r(idx(1:3))))';  % keep only the first zero
  else
    r=[.9*w0 w0 1.1*w0];
  end
  resf(ix)=[];


  % update tfreqs and finit
  w1=log10(f0); w2=log10(r(1));
  if w1<w2, ftmp=logspace(w1,w2,max(2,round(5*(w2-w1)))); ftmp(1)=f0;
  else      ftmp=r(1);  end
  tfreqs=[tfreqs ftmp]; f0=r(3);

  ix=max(find(freqs<r(2) & freqs>r(1)));
  if ~isempty(ix), r(1)=freqs(ix); end
  ix=max(find(freqs<r(3) & freqs>r(2)));
  if ~isempty(ix), r(3)=freqs(ix); end
  finit=[finit r'];
end

% fill toward Inf
w1=log10(f0); w2=log10(max(abs(eiga)))+1;
if w1<w2,
  ftmp=logspace(w1,w2,max(2,round(5*(w2-w1)))); ftmp(1)=f0;
  tfreqs=[tfreqs ftmp Inf];
else
  tfreqs=[tfreqs Inf];
end

% merge with specified freqs
freqs=sort([freqs tfreqs]);
for t=finit, ix=find(freqs==t(3)); freqs(ix)=-freqs(ix); end
freqs(1)=-freqs(1);



% triangularize (a,e)
if desc,
  [a,e,qq,zz]=qz(a,e,'complex'); b=qq*b; c=c*zz;
else
  [p,a]=hess(a); e=eye(na);   b=p'*b;  c=c*p;
end




%%%%%%%%%%%%%%%%   FORM THE LMI SYSTEM  %%%%%%%%%%%%%%%%

% lmis: 1->D > I   2->lfc

% declare variables
setlmis([]);
D=lmivar(3,[D1 D2;-D2 D1]);
if isG, G=lmivar(3,[G1 G2;-G2 G1]); end

% term content
lmiterm([1 1 1 0],1e-3);
lmiterm([1 1 1 D],-10,10);
if ~isD2, lmiterm([1 0 0 0],[eye(n);zeros(n)]); end
lmiterm([-2 1 1 D],1,1);
lmi0=getlmis;


j=sqrt(-1); Dm=0; Gm=0; ds=[]; gs=[]; fs=[]; peakf=0; mub2=1e-6;
% default init for gevp
if isG,
  x0=mat2dec(lmi0,eye(2*n),zeros(2*n));
else
  x0=mat2dec(lmi0,eye(2*n));
end


%%%%%%%%%%%%%%%%%%%  MAIN LOOP  %%%%%%%%%%%%%%%%%%%%

[alpha,Dm,Gm,xinit]=mub13(lmi0,mub2,isG,0,0,x0,a,b,c,d,e,0);
mub2=max(alpha,mub2); fs=[fs,0]; ds=[ds,Dm(:)]; tinit=10*mub2;
if isG, gs=[gs,Gm(:)]; else gs=[gs,zeros(size(Dm,1)^2,1)]; end


% resonant frequencies
for w=finit,
   w1=w(1); wc=w(2); w2=w(3);

   % mu bound at wc
   [alpha,Dc,Gc,fmax,xin,inwc]=...
               muslv(lmi0,mub2,0,0,x0,a,b,c,d,e,wc,0,nzg);
   fs=[fs,wc]; ds=[ds,Dc(:)];
   if isG, gs=[gs,Gc(:)]; else gs=[gs,zeros(size(Dc,1)^2,1)]; end
   if alpha>mub2,
     mub2=alpha; peakf=fmax; xinit=xin; tinit=5*mub2; Dm=Dc; Gm=Gc;
   end

   % test if Dc,Gc work on [w1,wc]
   ft=logspace(log10(w1),log10(wc),6); ft=ft(1:5); optim=0;
   for f=ft,
     M=d+c*((j*f*e-a)\b);
     if norm(M,'fro') > sqrt(mub2),
       aux=Gc*M; optim=max(real(eig(M'*Dc*M+j*(aux-aux')-mub2*Dc)))>0;
       if optim, break, end
     end
   end

   % mu bound at w1
   if optim,
     [alpha,Ds,Gs,fmax,xin]=...
              muslv(lmi0,mub2,0,0,x0,a,b,c,d,e,w1,wc,[nzg;inwc]);
     fs=[fs,fmax]; ds=[ds,Ds(:)];
     if isG, gs=[gs,Gs(:)]; else gs=[gs,zeros(size(Ds,1)^2,1)]; end
     if alpha>mub2,
       mub2=alpha; peakf=fmax; xinit=xin; tinit=5*mub2;
       Dc=Ds; Gc=Gs; Dm=Ds; Gm=Gs;
     end
   end

   % test if Dc,Gc work on [wc,w2]
   ft=logspace(log10(wc),log10(w2),6); ft=ft(2:6); optim=0;
   for f=ft,
     M=d+c*((j*f*e-a)\b);
     if norm(M,'fro') > sqrt(mub2),
       aux=Gc*M; optim=max(real(eig(M'*Dc*M+j*(aux-aux')-mub2*Dc)))>0;
       if optim, break, end
     end
   end

   % mu bound at w2
   if optim,
     [alpha,Ds,Gs,fmax,xin]=...
              muslv(lmi0,mub2,0,0,x0,a,b,c,d,e,w2,wc,[nzg;inwc]);
     fs=[fs,fmax]; ds=[ds,Ds(:)];
     if isG, gs=[gs,Gs(:)]; else gs=[gs,zeros(size(Ds,1)^2,1)]; end
     if alpha>mub2,
       mub2=alpha; peakf=fmax; xinit=xin; tinit=5*mub2; Dm=Ds; Gm=Gs;
     end
   end
end



% regular frequencies
w0=0; inw0=[];

for w=freqs,
   if w<0 | ~isG, iw0=[]; end
   w=abs(w);
   if w < Inf, M=d+c*((j*w*e-a)\b); else M=d; end

   % test if current scalings are valid at this freq.
   optim=0;
   if norm(M,'fro')^2 > mub2,
     aux=Gm*M;
     genev=max(real(eig(M'*Dm*M+j*(aux-aux'),Dm)));
     optim=(genev>mub2);  tinit=5*genev;
   end

   if optim,
     [alpha,Dm,Gm,fmax,xinit,inw0]=...
           muslv(lmi0,mub2,tinit,xinit,x0,a,b,c,d,e,w,w0,[nzg;inw0]);
     if alpha>mub2, mub2=alpha; peakf=fmax; end
   else
     fprintf(1,'.');
   end

   w0=w; fs=[fs,w]; ds=[ds,Dm(:)];
   if isG, gs=[gs,Gm(:)]; else gs=[gs,zeros(size(Dm,1)^2,1)]; end
end


fprintf(1,'\n');

margin=1/sqrt(mub2);
[fs,ind]=sort(abs(fs)); ds=ds(:,ind); gs=gs(:,ind);

disp(sprintf(' Mu upper bound (peak value): %6.3e',1/margin));
disp(sprintf(' Robust stability margin    : %6.3e',margin));
if margin > 1e3,
  disp(' Warning: scale the uncertainty bound up for more accuracy');
end
