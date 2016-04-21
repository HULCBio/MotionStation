function df=pdeprbdf(t,u)
%PDEPRBDF Jacobian for PARABOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:41 $

global pdeprbqt pdeprbgt pdeprbht pdeprbrt pdeprbb pdeprbp pdeprbe ...
       pdeprbct pdeprbat pdeprbft pdeprbt pdeprbc pdeprba pdeprbN ...
       pdeprbK pdeprbQ pdeprbM pdeprbB pdeprbpm pdeprbdt pdeprbMM ...
       pdeprbd pdeprbts


if ~(pdeprbqt || pdeprbgt || pdeprbht || pdeprbrt || pdeprbct || pdeprbat || pdeprbft)
  df=-pdeprbK;
  return
end

if pdeprbqt || pdeprbht
  [Q,G,H,R]=assemb(pdeprbb,pdeprbp,pdeprbe,t);
end

if pdeprbct || pdeprbat
  [K,M]=assema(pdeprbp,pdeprbt,pdeprbc,pdeprba,zeros(pdeprbN,1),t);
end

if pdeprbqt
  pdeprbQ=Q;
end

if pdeprbht
  pdeprbB=pdenullorth(H);
end

if pdeprbct
  pdeprbK=K;
end

if pdeprbat
  pdeprbM=M;
end

if ~pdeprbht
  df=-pdeprbB'*(pdeprbK+pdeprbM+pdeprbQ)*pdeprbB;
else
  dt=pdeprbts*sqrt(eps);
  t1=t+dt;
  dt=t1-t;
  if pdeprbdt
    [unused,pdeprbMM]=assema(pdeprbp,pdeprbt,0,pdeprbd,zeros(pdeprbN,1),t);
  end
  [Q,G,H,R]=assemb(pdeprbb,pdeprbp,pdeprbe,t1);
  N1=pdenullorth(H);
  df=-pdeprbB'*((pdeprbK+pdeprbM+pdeprbQ)*pdeprbB+pdeprbMM*(N1-pdeprbB)/dt);
end

df=df(:,pdeprbpm);

