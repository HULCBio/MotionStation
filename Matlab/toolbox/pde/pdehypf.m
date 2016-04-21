function f=pdehypf(t,u,flag)
%PDEHYPF Right hand side for HYPERBOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:26 $


global pdehypqt pdehypgt pdehypht pdehyprt ...
       pdehypct pdehypat pdehypft pdehypb pdehypp pdehype pdehypt ...
       pdehypc pdehypa pdehypf pdehypQ pdehypG pdehypH pdehypR ...
       pdehypK pdehypM pdehypF pdehyppm pdehypts pdehypMM ...
       pdehypNu pdehypOr pdehypdt pdehypd pdehypN

if nargin>=3
  if strcmp(flag,'mass')
    f=pdehypm(t);
    return
  end
  if strcmp(flag,'jacobian')
    f=pdehypdf(t,u);
    return
  end
end

if ~(pdehypqt || pdehypgt || pdehypht || pdehyprt || ...
     pdehypct || pdehypat || pdehypft)
  f=-pdehypK*u+pdehypF;
  return
end

if pdehypqt || pdehypgt || pdehypht || pdehyprt
  [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,t);
end

if pdehypct || pdehypat || pdehypft
  [K,M,F]=assema(pdehypp,pdehypt,pdehypc,pdehypa,pdehypf,t);
end

if pdehypqt
  pdehypQ=Q;
end

if pdehypgt
  pdehypG=G;
end

if pdehypht
  pdehypH=H;
end

if pdehyprt
  pdehypR=R;
end

if pdehypct
  pdehypK=K;
end

if pdehypat
  pdehypM=M;
end

if pdehypft
  pdehypF=F;
end

if ~(pdehypht || pdehyprt)
  [K,F,B,ud]=assempde(pdehypK,pdehypM,pdehypF,pdehypQ,pdehypG,pdehypH,pdehypR);
  nu=size(B,2);
  K=[sparse(nu,nu) -speye(nu,nu); K sparse(nu,nu)];
  F=[zeros(nu,1);F];
else
  dt=pdehypts*eps^(1/3);
  t1=t+dt;
  dt=t1-t;
  tm1=t-dt;
  if pdehypdt
    [unused,pdehypMM]=assema(pdehypp,pdehypt,0,pdehypd,zeros(pdehypN,1),t);
  end
  if pdehypht
    [N,O]=pdenullorth(pdehypH);
    nu=size(N,2);
    ud=O*((pdehypH*O)\pdehypR);
    [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,t1);
    [N1,O]=pdenullorth(H);
    ud1=O*((H*O)\R);
    [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,tm1);
    [Nm1,O]=pdenullorth(H);
    udm1=O*((H*O)\R);
    nu=size(N,2);
    K=[sparse(nu,nu) -speye(nu,nu); ...
         N'*((pdehypK+pdehypM+pdehypQ)*N+ ...
                   pdehypMM*(N1-2*N+Nm1)/(dt^2)) ...
         2*N'*pdehypMM*(N1-Nm1)/(2*dt)];
    F=[zeros(nu,1); N'*((pdehypF+pdehypG)-(pdehypK+pdehypM+pdehypQ)*ud- ...
                        pdehypMM*(ud1-2*ud+udm1)/(dt^2))];
  else
    nu=size(pdehypNu,2);
    HH=pdehypH*pdehypOr;
    ud=pdehypOr*(HH\pdehypR);
    [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,t1);
    ud1=pdehypOr*(HH\R);
    [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,tm1);
    udm1=pdehypOr*(HH\R);
    K=[sparse(nu,nu) -speye(nu,nu); ...
         pdehypNu'*(pdehypK+pdehypM+pdehypQ)*pdehypNu sparse(nu,nu)];
    F=[zeros(nu,1); ...
       pdehypNu'*((pdehypF+pdehypG)-(pdehypK+pdehypM+pdehypQ)*ud- ...
                  pdehypMM*(ud1-2*ud+udm1)/(dt^2))];
   end
end

K=K(:,pdehyppm);

f=-K*u+F;

