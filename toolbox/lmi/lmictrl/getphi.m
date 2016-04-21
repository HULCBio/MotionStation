% Called by KCEN
%
% Computes the corrective term PhiB or PhiC for singular Hinf
% controllers. Note that  Phi should satisfy
%     *  DR + P' Phi  + Phi' P < 0
%     *  eig(A+B*Phi,E) stable
% The trade-off between stability margins and norm of Phi
% is optimized among explicit solution of the form -alpha*P,
% and the best trade-off is compared against the outcome of
% BASICLMI.

% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [phi]=getphi(M,P,target)


wp=null(P);
[u,t]=schur(wp'*M*wp);
t=real(diag(t)); ind=find(t > 0);
projeig=t;
if length(ind)>0,
  u=wp*u(:,ind);
  M=M-2*u*diag(t(ind))*u';
end


n=size(M,1);


[u,s,v]=svd(P);
rk=size(P,1);
M1=v'*M*v;
P1=P*v(:,1:rk);

setlmis([]);
lmivar(2,[rk n]);       % (Z1,Z2)
lmivar(1,[1 0]);        % t

lmiterm([1 1 1 0],M1);
lmiterm([1 1 1 1],[eye(rk);zeros(n-rk,rk)],1,'s');

lmiterm([-2 1 1 2],1,1);
lmiterm([-2 2 1 1],1,1);
lmiterm([-2 2 2 2],P1',P1);
lmis=getlmis;

c=[zeros(1,rk*n) 1];

M11=M1(1:rk,1:rk);
[u,t]=schur(M11); t=real(diag(t)); t=max(t,zeros(size(t)));
Z1=-u*diag(t)*u'/2-eye(rk);
Z2=-M1(1:rk,rk+1:n);
t0=norm(P1'\[Z1 Z2]);
xinit=mat2dec(lmis,[Z1 Z2],10*t0);
options=[1e-1 0 max(1e8,10*norm(xinit,1)) 0 1];


[Nmin,xopt]=mincx(lmis,c,options,xinit,target);


Z=dec2mat(lmis,xopt,1);

phi=P1'\Z*v';
