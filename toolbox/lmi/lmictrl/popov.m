% [tau,P,S,N] = popov(sys,delta,flag)
%
% Using the Popov criterion, this function tests if the
% interconnection
%                   ___________
%                   |         |
%              +----|  Phi(.) |<---+
%              |    |_________|    |
%           w  |                   | y
%              |    ___________    |
%              +--->|         |----+
%                   |   SYS   |
%             ----->|_________|----->
%
%
% is stable for any operator Phi in the uncertainty class
% specified by DELTA.   This class can include nonlinear
% and/or time-varying uncertainties with norm or sector
% bounds.
%
% Stability is established when TAU < 0, in which case POPOV
% returns a Lyapunov matrix P and multipliers S and N proving
% stability.
%
% Input:
%  SYS        dynamical system (see LTISYS)
%  DELTA      description of the uncertainty class (see UBLOCK)
%  FLAG       optional, 0 by default. Setting FLAG=1 reduces
%             conservatism for real parameter uncertainty at
%             the expense of more intensive computations
%
% Output:
%  TAU        optimal largest eigenvalue of the corresponding
%             LMI feasibility problem.  Robust stability is
%             guaranteed when TAU < 0, i.e., when the Popov
%             LMIs are feasible
%  P          x'*P*x  is the quadratic part of the Lyapunov
%             function proving stability
%  S,N        if TAU < 0, S and N are the Popov "multipliers"
%             proving stability
%
%
% See also  QUADSTAB, PDLSTAB, MUSTAB, UBLOCK, UDIAG, UINFO.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [tau,P,D,N] = popov(sys,delta,option)


if nargin<2,
  error('usage: [tau,P,D,N] = popov(sys,delta)');
elseif ~islsys(sys),
  error('SYS must be a system matrix');
elseif size(delta,1)<=8,
  error('DELTA is not an uncertainty description');
elseif nargin==2,
  option=0;
end

P=[]; D=[]; N=[];
meps=mach_eps;

%%% v5 code
Nm = [];

% check dim. compatibility
rd=sum(delta(1,:));
cd=sum(delta(2,:));
[ns,ni,no]=sinfo(sys);
if ni<rd | no<cd,
   error('SYS and DELTA are not of compatible dimensions');
else
   sys=ssub(sys,1:rd,1:cd);
end


% eliminate frequency-dependent norm bounds
if any(delta(7,:)+delta(8,:)>2),
  Dl=[]; Dr=[];
  for b=delta,
    [dims,aux,bnd]=uinfo(b,1);
    rb=dims(1);  cb=dims(2);

    if any(length(bnd(:))==[1 2]), % scalar or sector bnd
       Dl=sdiag(Dl,eye(rb));
       Dr=sdiag(Dr,eye(cb));
    else                % freq-dep. bound
       ordr=min(rb,cb);
       w=bnd;
       for i=2:ordr, w=sdiag(w,bnd); end
       if rb<cb,
          Dl=sdiag(Dl,w); Dr=sdiag(Dr,eye(cb));
       else
          Dl=sdiag(Dl,eye(rb));  Dr=sdiag(Dr,w);
       end
    end
  end

  sys=smult(Dl,sys,Dr);
end


% balancing
sys=sbalanc(sys);


% get ss data
[a,b,c,d,e]=ltiss(sys);
na=size(a,1); nord=norm(d,1);
desc=(norm(e-eye(size(e)),1)>0);


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
  b=[b,zeros(na,newcolptr-rd)];
  c=[c;zeros(newrowptr-cd,na)];
  d=d(rowperm,colperm); b=b(:,colperm); c=c(rowperm,:);
end



% refined test for real blocks if option=1
if option & any(~delta(5,:) & delta(6,:)),
  ir=0; ib=1; scan=[dims;~delta(5,:) & delta(6,:)];
else scan=[]; end

for tt=scan,
  bs=tt(1);

  if tt(2) & max(max(abs(d(ir+1:ir+bs,:)))) < meps*max(100,nord),
  % real scalar block and Dj=0 -> replace Bj,Cj by Bj*Cj,I

     aux=[b;d];
     aux=[aux(:,1:ir) aux(:,ir+1:ir+bs)*c(ir+1:ir+bs,:) ...
                      aux(:,ir+bs+1:size(b,2))];
     b=aux(1:na,:);   d=aux(na+1:size(aux,1),:);
     c=[c(1:ir,:); eye(na); c(ir+bs+1:size(c,1),:)];
     d=[d(1:ir,:); zeros(na,size(d,2)); d(ir+bs+1:size(d,1),:)];
     dims(ib)=na; bs=na;
  end
  ir=ir+bs; ib=ib+1;
end



%%%%%%%%%%%   Generate the scaling structure %%%%%%%%%%%%%

K1=[]; K2=[]; Pi1=[]; Pi2=[]; base=0; nb=size(b,2);
scan=[dims;delta(3:min(10,size(delta,1)),:)];


% S scale
%   NB: for real repeated, S is any matrix s.t. S+S'>0

Sm=zeros(nb); ir=0;

for tt=scan,
  bs=tt(1);  % block size
  bnds=tt(8:7+tt(6));

  if tt(5),    % scalar block
     if ~tt(2),       % nonlinear repeated
        Sm(ir+1:ir+bs,ir+1:ir+bs)=diag(base+1:base+bs);
        base=base+bs;
     elseif ~tt(4),   % real repeated
        Sm(ir+1:ir+bs,ir+1:ir+bs)=reshape(base+1:base+bs^2,bs,bs)';
        base=base+bs^2;
     else             % complex repeated
        Sm(ir+1:ir+bs,ir+1:ir+bs)=symdec(bs,base);
        base=base+bs*(bs+1)/2;
     end
  else        % full block
     base=base+1;
     Sm(ir+1:ir+bs,ir+1:ir+bs)=base*eye(bs);
  end
  ir=ir+bs;


  if length(bnds)==1,
      bnds=[-bnds bnds];
  else
      bnds=[max(bnds(1),-1e8) , min(bnds(2),1e8)];
  end
  if abs(bnds(1))<1,
     K1=[K1,bnds(1)*ones(1,bs)]; Pi1=[Pi1,ones(1,bs)];
  else
     K1=[K1,sign(bnds(1))*ones(1,bs)]; Pi1=[Pi1,ones(1,bs)/abs(bnds(1))];
  end
  if abs(bnds(2))<1,
     K2=[K2,bnds(2)*ones(1,bs)]; Pi2=[Pi2,ones(1,bs)];
  else
     K2=[K2,sign(bnds(2))*ones(1,bs)]; Pi2=[Pi2,ones(1,bs)/abs(bnds(2))];
  end

end



% N scale

isN=~isempty(find(~delta(4,:) & delta(6,:)));
if isN, aux=scan; Nm=zeros(nb); ir=0; else aux=[]; end


for tt=aux,
  bs=tt(1);  % block size

  % Nj = 0 if dj ~= 0
  dbool=max(max(abs(d(ir+1:ir+bs,:)))) < meps*max(100,nord);

  if dbool & tt(2) & ~tt(3) & ~tt(4) & tt(5),     % Nj > 0
     Nm(ir+1:ir+bs,ir+1:ir+bs)=symdec(bs,base);
     base=base+bs*(bs+1)/2;
  elseif dbool & ~tt(2) & ~tt(3) & tt(5)
     Nm(ir+1:ir+bs,ir+1:ir+bs)=diag(base+1:base+bs);
     base=base+bs;
  end
  ir=ir+bs;
end

isN=max(max(abs(Nm)))>0;



% test stability at the extremes
% ------------------------------
if desc,
  eiga=eig(a+b*diag(K1./Pi1)*c,e);
else
  eiga=eig(a+b*diag(K1./Pi1)*c);
end
if max(real(eiga)) >=0,
  disp('The closed loop is unstable for  w = K1*y'); tau=Inf; return
end

if desc,
  eiga=eig(a+b*diag(K2./Pi2)*c,e);
else
  eiga=eig(a+b*diag(K2./Pi2)*c);
end
if max(real(eiga)) >=0,
  disp('The closed loop is unstable for  w = K2*y'); tau=Inf; return
end



% form the LMI system
%%%%%%%%%%%%%%%%%%%%%
% NB: P > 0 enforced by stability for w=K1(K2)*y  and dV/dt < 0

K1=diag(K1); K2=diag(K2);


% aux vars and variable scaling
lfS=[-c'*K1;diag(Pi1)-d'*K1];
rfS=[K2*c,K2*d+diag(-Pi2)];
scalP=sqrt(max(max(abs(e)))*max(max(abs([a b]))));
scalS=sqrt(max(max(abs(lfS)))*max(max(abs(rfS))));
if isN,
   if desc, ccab=(c/e)*[a,b]; else ccab=c*[a,b]; end
   scalN=sqrt(max(abs(Pi1))*max(max(abs(ccab))));
end


% declare variables
setlmis([]);
S=lmivar(3,Sm);
if isN, N=lmivar(3,Nm); end
P=lmivar(1,[na 1]);


% first LMI: S+S' > 1e-4*I
lmiterm([-1 1 1 S],10,1,'s');
lmiterm([1 1 1 0],1e-3);


% second LMI:  Popov
lmiterm([2 1 1 P],[e';zeros(nb,na)],[a b]/scalP,'s');
lmiterm([2 1 1 S],lfS/scalS,rfS,'s');


% N scaling
if isN,
  lmiterm([2 1 1 N],...
               [zeros(na,nb);diag(Pi1)],ccab/scalN,'s');
end
lmi=getlmis;


%  solve the LMI problem

opts=[0, 0, 1e7, 10, 0];

[tau,xf]=feasp(lmi,opts);


if nargout>1,
  P=dec2mat(lmi,xf,P)/scalP;
  if desc, P=e'*P*e; end
  D=diag((Pi1.*Pi2)/scalS)*dec2mat(lmi,xf,S);
  if isN, N=diag(Pi1/scalN)*dec2mat(lmi,xf,N);
  else    N=zeros(size(D)); end
end

if tau >= 0,
 disp(' Warning: stability could not be established via the Popov criterion');
else
 disp(' Robustly stable for the prescribed uncertainty');
end
disp(' ');


% end Popov
