% X = basiclmi(M,P,Q,option)
%
% Computes a solution X to the LMI
%
%         M + P' * X * Q + Q' * X' * P < 0
%
% This LMI is solvable iff.
%
%       wP'*M*wP < 0     and     wQ'*M*wQ < 0
%
% for bases  wP  and  wQ  of the null spaces of P and Q.
% If either one of these conditions fails to be satisfied,
% X=[] on output.
%
% To obtain the least-norm solution, set OPTION to 'Xmin'.
%
%
% See also  FEASP, MINCX.

% Author: P. Gahinet  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [X]=basiclmi(M,P,Q,option)


if nargin <3,
   error('usage:   X = basiclmi(M,P,Q,option)');
end

MiniX=0; Shift=0;

if nargin==4,
   if ~isstr(option), error('OPTION must be a string'); end
   MiniX=~isempty(findstr(option,'Xmin'));
   Shift=~isempty(findstr(option,'Shift'));
   % option SHIFT used in KRIC: shifts the spectrum to satisfy the
   % projection conditions
end


% tolerance
macheps=mach_eps;
tolrel=sqrt(macheps);
toleig=macheps^(3/4);


% dimensions/norms
n=size(M,1); rx=size(P,1); cx=size(Q,1);
if rx+size(P,2)==2, rx=n; end   % case P=1
if cx+size(Q,2)==2, cx=n; end   % case Q=1
normM=max(max(abs(M)));
normP=max(max(abs(P))); normQ=max(max(abs(Q)));
M=(M+M')/2; M0=M;




% compute the bases Upq, Up, Uq, V
%---------------------------------
% wP: right null space of P
% rP: range of P'

[rP,u,u,rk,u,wP]=svdparts(P,0,toleig);
if rk==size(P,1), rP=1; end
[rQ,u,u,rk,u,wQ]=svdparts(Q,0,toleig);
if rk==size(Q,1), rQ=1; end


if isempty(wP) | isempty(wQ),
%%% v4 code
% Upq=[]; Up=wP; Uq=wQ;

%%% v5 code
  if isempty(wP), wP = zeros(size(M,1),0); end
  if isempty(wQ), wQ = zeros(size(M,1),0); end
  Upq = zeros(size(M,1),0);
  Up = wP;
  Uq = wQ;

else
  [u,s,v]=svd(wP'*wQ);
  rk=length(find(xdiag(s) > 1-tolrel));
  Upq=wQ*v(:,1:rk);
  Uq=wQ*v(:,rk+1:size(v,2));
  Up=wP*u(:,rk+1:size(u,2));
end

%%% v4 code
% T=[Upq,Up,Uq];

%%% v5 code
T = [];
if ~isempty(Upq), T = [T,Upq]; end
if ~isempty(Up), T = [T,Up]; end
if ~isempty(Uq), T = [T,Uq]; end

[rT,cT]=size(T);
if rT==0,
  V=eye(n);
else
  [u,s,v]=svd(T);    V=u(:,cT+1:rT);
end



% Check solvability conditions.
%   If Shift = 1, enforce these conditions by shifting part
%   of the spectrum of M
%--------------------------------------------------------

[up,tp]=schur(wP'*M*wP);
tp=real(diag(tp));
if isempty(tp), maxeigp=-1; else maxeigp=max(tp); end

if ~Shift & maxeigp > toleig*n*normM,
  disp(sprintf('\n   Warning in BASICLMI: the solvability conditions are not satisfied\n'));
  X=[]; return
elseif maxeigp > 0,
  ind=find(tp > 0);
  up=wP*up(:,ind);
  M=M-1.1*up*diag(tp(ind))*up';
end


[uq,tq]=schur(wQ'*M*wQ);
tq=real(diag(tq));
if isempty(tq), maxeigq=-1; else maxeigq=max(tq); end

if ~Shift & maxeigq > toleig*n*normM,
  disp(sprintf('\n   Warning in BASICLMI: the solvability conditions are not satisfied\n'));
  X=[]; return
elseif maxeigq > 0,
  ind=find(tq > 0);
  uq=wQ*uq(:,ind);
  M=M-uq*diag(tq(ind))*uq';
end


%  best achivable largest eigenvalue:
maxeigopt=max(maxeigp,maxeigq);



%%%%%%%% COMPUTE THE CENTRAL SOLUTION VIA LINEAR ALGEBRA %%%%%%%%%%%%%%


% congruence transformation
%--------------------------

% computation of  Y = [Y11 Y12 ; Y21 Y22] = [P1' ; P2'] X [Q1 , Q2]

tmp1=Upq'*M;   tmp2=Up'*M;   tmp3=Uq'*M;
M11=tmp1*Upq;     M11=(M11+M11')/2;
M12=tmp1*Up;      M13=tmp1*Uq;     M14=tmp1*V;
M22=tmp2*Up;      M22=(M22+M22')/2;
M23=tmp2*Uq;      M24=tmp2*V;
M33=tmp3*Uq;      M33=(M33+M33')/2;
M34=tmp3*V;
M44=V'*M*V;       M44=(M44+M44')/2;

if size(M11,1) > 0,
  % compute the Schur complement wrt M11.
  % systematic shift of M11 to prevent ill-condition
  % inversion via schur decomp.

  shift=max(toleig*norm(M11(:),1),macheps*n*normM);
  [u,t]=schur(-M11);
  t=max(real(diag(t))',shift*ones(1,size(M11,1)));
  t=diag(sqrt(1./t));

  %  now t*u' = 1/sqrt(-M11). Form the Schur complements
  %  and update M22, M33

  R2=t*(u'*M12);    R3=t*(u'*M13);   R4=t*(u'*M14);
  M22=M22+R2'*R2;   M23=M23+R2'*R3;  M24=M24+R2'*R4;
  M33=M33+R3'*R3;   M34=M34+R3'*R4;  M44=M44+R4'*R4;
end


% compute Y11 , Y12 , Y21

Y11=-M23';  Y12=-M34;  Y21=-M24';


% step 2: compute Y22 s.t. Y22+Y22'+M44 < 0  and  X

sy22=size(M44,1);

if sy22==0,

  X=rP*(((rP'*P*Uq)'\Y11)/(rQ'*Q*Up))*rQ';

else

  tP=rP'*P*[Uq,V];   ctP=size(tP,2);
  tQ=rQ'*Q*[Up,V];   ctQ=size(tQ,2);

%  shift=max(1e-2,tolrel*normM);
%  Y22=-M44/2-shift*eye(size(M44));

  [u,t]=schur(M44); t=real(diag(t))+1e-5;
  ind=find(t>0);  t(ind)=1.1*t(ind);
  ind=find(t<=0); t(ind)=zeros(length(ind),1);

  X=rP*(tP'\[Y11,Y12;Y21,-u*diag(t)*u'/2]/tQ)*rQ';

end

%  shift=max(1e-2,tolrel*normM);
%  Y22=-M44/2-shift*eye(size(M44));
%  X=rP*(tP'\[Y11,Y12;Y21,Y22]/tQ)*rQ';



%%%%%%%%%%%%%%%%  ENFORCE NEGATIVITY  %%%%%%%%%%%%%%%%%%%%
%
% X = central solution
%   Compute the largest eigenvalue MAXEIG of M(X) and check its
%   sign.
%    * if MAXEIG < max(0,10*MAXEIGOPT),  done
%    * otherwise, minimize  max(eig(M(X)))  directly with FEASP


PXQ=P'*X*Q;
maxeig=max(real(eig(M0+PXQ+PXQ')));


if maxeig > max(0,10*maxeigopt),

%disp(sprintf('before feasp: maxeig %9.5e',maxeig))


   % solve a feasibility pb to enforce negativity

   setlmis([]);
   lmivar(2,[rx cx]);         % X
   lmiterm([1 1 1 0],M0);
   lmiterm([1 1 1 1],P',Q,'s');
   lmis=getlmis;
   options=[0,75+rx*cx,10*norm(X),20,1];

   [tmin,xfeas]=feasp(lmis,options);


   if tmin < maxeig,
      X=dec2mat(lmis,xfeas,1);
      PXQ=P'*X*Q;
      maxeig=max(real(eig(M0+PXQ+PXQ')));
   end

%disp(sprintf('after feasp: maxeig %9.5e',maxeig))


end




%%%%%%%%%%%%%%%%%%  MINIMIZE THE NORM OF X   %%%%%%%%%%%%%%%%%%%


if MiniX & maxeig < max(0,10*maxeigopt),

   normX=norm(X,'fro');

   % compute a shift to ensure feasibility of the initial point
   % the factor 3 is to avoid getting stuck on the boundary
   if max(0,maxeig)>0,
     [u,t]=schur(M0+PXQ+PXQ');
     t=max(0,real(diag(t)));
     shft=2*u*diag(t)*u';
   else
     shft=0;
   end

   setlmis([]);
   lmivar(2,[rx cx]);  % X
   lmivar(2,[1 1]);    % tau
   lmiterm([1 1 1 0],M0-shft);
   lmiterm([1 1 1 1],P',Q,'s');
   lmiterm([-2 1 1 2],1,1);
   lmiterm([-2 2 2 2],1,1);
   lmiterm([-2 1 2 1],1,1);
   lmis=getlmis;
   c=[zeros(rx*cx,1);1];

   [topt,xopt]=mincx(lmis,c,[.5 40 100*normX 10 1],mat2dec(lmis,X,2*normX));

   if ~isempty(xopt),  X=dec2mat(lmis,xopt,1); end


end
