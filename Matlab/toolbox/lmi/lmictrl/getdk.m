% Called by KRIC
%
% Determines the optimal dk by solving a constrained Parrott
% problem

% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function dk=getdk(d11,b2,c2,d12,d21,gama,nb1x2,nc1y2,knobrk,tolsing)


% constraints on magnitude of b2*dk*c2, b2*dk*d21, etc.
maxmaginv=1e-8*10^(2*knobrk);


na=size(b2,1); [p1,m1]=size(d11); m2=size(d12,2); p2=size(d21,1);
a0min=maxmaginv*nb1x2/gama;
b0min=maxmaginv*nc1y2/gama;
A=mdiag(zeros(na),d11);


%disp(sprintf('\nalphamin and beta min: %6.3e    %6.3e',a0min,b0min));


% Step 1: determine optimal off-diagonal balancing to weight
%         || B2 Dk D21 || and || D12 DK C2 || equally.
%-------------------------------------------------------------

alpha0=max(sqrt(gama*maxmaginv),a0min);
beta0=max(sqrt(gama*maxmaginv),b0min);
%disp(sprintf('alpha0 and beta0: %6.3e    %6.3e',alpha0,beta0));
B=[alpha0*b2;d12];   C=[beta0*c2 d21];
[u,s,v]=svd(B);  sB=xdiag(s); rk=length(find(sB > tolsing*sB(1)));
sB=sB(1:rk);  orthB=u(:,1:rk); nullB=u(:,rk+1:na+p1); vB=v(:,1:rk);
[u,s,v]=svd(C);  sC=xdiag(s); rk=length(find(sC > tolsing*sC(1)));
sC=sC(1:rk);  orthC=v(:,1:rk); nullC=v(:,rk+1:na+m1); uC=u(:,1:rk);
gmin1=max(norm(A*nullC),norm(nullB'*A));

A11=nullB'*A; A21=orthB'*A;
[g0,x0]=parrott(A11*nullC,A11*orthC,A21*nullC,m2,p2,...
                                       1.001*(.2*gmin1+.8*max(gmin1,gama)));
dk=vB*diag(1./sB)*(x0-A21*orthC)*diag(1./sC)*uC';

n12=norm(b2*dk*d21);
n21=norm(d12*dk*c2);


% if objective value < gama -> exit (satisfactory solution found)
if gmin1 < gama | max(alpha0*n12,beta0*n21) < .1*gmin1, return, end


% Step 2: solve again with the optimal off-diagonal balancing
%         factor TH determined above.
%-----------------------------------------------------------

th=n12/max(tolsing,n21);
alpha0=max(sqrt(gama*maxmaginv/th),a0min);
beta0=max(sqrt(gama*maxmaginv*th),b0min);
%disp(sprintf('alpha0 and beta0: %6.3e    %6.3e',alpha0,beta0));
B=[alpha0*b2;d12];   C=[beta0*c2 d21];
[u,s,v]=svd(B);  sB=xdiag(s); rk=length(find(sB > tolsing*sB(1)));
sB=sB(1:rk);  orthB=u(:,1:rk); nullB=u(:,rk+1:na+p1); vB=v(:,1:rk);
[u,s,v]=svd(C);  sC=xdiag(s); rk=length(find(sC > tolsing*sC(1)));
sC=sC(1:rk);  orthC=v(:,1:rk); nullC=v(:,rk+1:na+m1); uC=u(:,1:rk);
gmin2=max(norm(A*nullC),norm(nullB'*A));

%disp(sprintf('gmin1 vs gmin2: %6.3e    %6.3e\n',gmin1,gmin2));


if gmin2 < .99*gmin1,  % improvement -> recompute dk
   A11=nullB'*A; A21=orthB'*A;
   [g0,x0]=parrott(A11*nullC,A11*orthC,A21*nullC,m2,p2,...
                                      1.001*(.2*gmin2+.8*max(gama,gmin2)));
   dk=vB*diag(1./sB)*(x0-A21*orthC)*diag(1./sC)*uC';
end


