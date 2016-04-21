function df=pdehypdf(t,u)
%PDEHYPDF Jacobian for HYPERBOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:25 $

global pdehypqt pdehypgt pdehypht pdehyprt pdehypb pdehypp pdehype ...
       pdehypct pdehypat pdehypft pdehypt pdehypc pdehypa pdehypN ...
       pdehypK pdehypQ pdehypM pdehypB pdehyppm pdehypdt pdehypMM ...
       pdehypd pdehypts


if ~(pdehypqt || pdehypgt || pdehypht || pdehyprt || pdehypct || pdehypat || pdehypft)
  df=-pdehypK;
  return
end

if pdehypqt || pdehypht
  [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,t);
end

if pdehypct || pdehypat
  [K,M]=assema(pdehypp,pdehypt,pdehypc,pdehypa,zeros(pdehypN,1),t);
end

if pdehypqt
  pdehypQ=Q;
end

if pdehypht
  pdehypB=pdenullorth(H);
end

if pdehypct
  pdehypK=K;
end

if pdehypat
  pdehypM=M;
end

nu=size(pdehypB,2);
if ~pdehypht
  df=-[sparse(nu,nu) -speye(nu,nu); ...
       pdehypB'*(pdehypK+pdehypM+pdehypQ)*pdehypB sparse(nu,nu)];
else
  dt=pdehypts*eps^(1/3);
  t1=t+dt;
  dt=t1-t;
  tm1=t-dt;
  if pdehypdt
    [unused,pdehypMM]=assema(pdehypp,pdehypt,0,pdehypd,zeros(pdehypN,1),t);
  end
  [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,t1);
  N1=pdenullorth(H);
  [Q,G,H,R]=assemb(pdehypb,pdehypp,pdehype,tm1);
  Nm1=pdenullorth(H);
  df=-[sparse(nu,nu) -speye(nu,nu); ...
       pdehypB'*((pdehypK+pdehypM+pdehypQ)*pdehypB+ ...
                 pdehypMM*(N1-2*pdehypB+Nm1)/(dt^2)) ...
       2*pdehypB'*pdehypMM*(N1-Nm1)/(2*dt)];
end

df=df(:,pdehyppm);

