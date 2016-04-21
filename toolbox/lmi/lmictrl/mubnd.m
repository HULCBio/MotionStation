% [mu,D,G]=mubnd(M,delta,target)
%
% Computes the upper bound  MU  on the mixed-mu
% structured singular value  for the matrix M and
% the norm-bounded uncertainty DELTA.
%
% If each block  Dj  of DELTA is bounded in norm by
% dj, the matrix   I - M * DELTA  remains invertible
% as long as
%              MU * || Dj ||  <  dj
%
%
% When TARGET is specified, the minimization of MU
% stops as soon as  MU <= TARGET  (Default = 1e-3).
% MUBND also returns the optimal D,G scaling matrices.
%
%
% See also  MUSTAB, MUPERF.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [mub,D,G]=mubnd(M,delta,target)

if nargin<2,
  error('usage: [mub,D,G]=mubnd(M,delta{,target})');
elseif nargin==2,
  target=1e-6;
else
  target=target^2;
end

% check dim. compatibility
rd=sum(delta(1,:));
cd=sum(delta(2,:));
[rm,cm]=size(M);
if rd~=cm | cd~=rm,
   error('M and DELTA are not of compatible dimensions');
end


% trivial case
if max(max(abs(M)))==0,
    mub=0; D=1; G=0; return,
end



% normalize uncertainty to one

D=[];
for b=delta,
  [dims,aux,bnd]=uinfo(b,1);
  rb=dims(1);  cb=dims(2);
  bndtype=sum(size(bnd));

  if sum(size(bnd))==2,      % scalar bound
     D=mdiag(D,diag(bnd*ones(rb,1)));
  else
     error('Frequency-dependent and sectorial bounds not allowed');
  end
end
M=M*D;



% make all uncertainty blocks square
dims=max(delta(1,:),delta(2,:)); n=sum(dims);
gap=delta(1,:)-delta(2,:);
indcol=find(gap<0); indrow=find(gap>0);
rowperm=[]; colperm=[];
Mrowptr=0; Mcolptr=0; newrowptr=rm;  newcolptr=cm;

for b=indrow,   % insert rows, b = current block involved
   newptr=sum(delta(2,1:b));   % total row size up to block b
   rowperm=[rowperm,Mrowptr+1:newptr,newrowptr+1:newrowptr+gap(b)];
   Mrowptr=newptr;
   newrowptr=newrowptr+gap(b);
end
rowperm=[rowperm,Mrowptr+1:rm];

for b=indcol,   % insert columnss, b = current block involved
   newptr=sum(delta(1,1:b));   % total row size up to block b
   colperm=[colperm,Mcolptr+1:newptr,newcolptr+1:newcolptr-gap(b)];
   Mcolptr=newptr;
   newcolptr=newcolptr-gap(b);
end
colperm=[colperm,Mcolptr+1:cm];

M=mdiag(M,zeros(newrowptr-rm,newcolptr-cm));
M=M(rowperm,colperm);



% generate the scaling structure
D1=[]; D2=[]; G1=[]; G2=[];
base=0;

% D1
for tt=[dims;delta(6,:)],
  bs=tt(1);  % block size
  if tt(2),  % scalar block
    D1=mdiag(D1,symdec(bs,base));  base=base+bs*(bs+1)/2;
  else
    base=base+1; D1=mdiag(D1,base*eye(bs));
  end
end

% D2
isD2=~isempty(find(delta(6,:)));
if isD2, aux=[dims;delta(6,:)]; else D2=zeros(n);aux=[]; end
for tt=aux,
  bs=tt(1);  % block size
  if tt(2),  % scalar block
    D2=mdiag(D2,skewdec(bs,base));  base=base+bs*(bs-1)/2;
  else
    D2=mdiag(D2,zeros(bs));
  end
end


% G1
isG=~isempty(find(delta(5,:)==0));
if isG, aux=[dims;delta(5:6,:)]; else aux=[]; end
for tt=aux,
  bs=tt(1);  % block size
  if tt(2),
    G1=mdiag(G1,zeros(bs));
  elseif tt(3),  % scalar block
    G1=mdiag(G1,symdec(bs,base));  base=base+bs*(bs+1)/2;
  else
    base=base+1; G1=mdiag(G1,base*eye(bs));
  end
end


% G2
if isempty(find(delta(6,:) & ~delta(5,:))), G2=zeros(n); aux=[];
else aux=[dims;delta(5:6,:)]; end
for tt=aux,
  bs=tt(1);  % block size
  if tt(2) | ~tt(3),
    G2=mdiag(G2,zeros(bs));
  else
    G2=mdiag(G2,skewdec(bs,base)); base=base+bs*(bs-1)/2;
  end
end



% form the LMI system
%%%%%%%%%%%%%%%%%%%%%


M1=real(M);   M2=imag(M);
E=[M1 M2;-M2 M1];
F=[-M2 M1;-M1 -M2];

% declare variable D
setlmis([]);
D=lmivar(3,[D1 D2;-D2 D1]);


% term content
lmiterm([1 1 1 0],1e-3);
lmiterm([1 1 1 D],-10,10);
if ~isD2, lmiterm([1 0 0 0],[eye(n);zeros(n)]); end

lmiterm([-2 1 1 D],1,1);
lmiterm([2 1 1 D],E',E);
if isG,
  G=lmivar(3,[G1 G2;-G2 G1]);
  lmiterm([2 1 1 G],100,F,'s');
end
lmis=getlmis;


% initial point
if isG,
  xinit=mat2dec(lmis,eye(2*n),zeros(2*n));
else
  xinit=mat2dec(lmis,eye(2*n));
end
tinit=2*norm(M,'fro')^2;


% call gevp
options=[1e-2, 0, 1e5, 5, 0];
[alpha,xopt]=gevp(lmis,1,options,tinit,xinit,target);


if isempty(xopt),
   error(sprintf(['\nMU is greater than 1e4: \n' ...
              '  Scale the uncertainty bound down for more accuracy']));
end


mub=sqrt(max(0,alpha));

if nargout>1,
  D=dec2mat(lmis,xopt,D);   D=D(1:n,1:n)+j*D(1:n,n+1:2*n);
  if isG,
     G=dec2mat(lmis,xopt,G);  G=G(1:n,1:n)+j*G(1:n,n+1:2*n);
  else G=zeros(2*n); end
end


if mub < 1e-3,
   disp(sprintf(['\nMU is smaller than 1e-3: \n' ...
              '  Scale the uncertainty bound up for more accuracy']));
end
