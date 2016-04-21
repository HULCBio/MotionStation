function f=pdeprbf(t,u,flag)
%PDEPRBF  Right hand side for PARABOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:42 $

global pdeprbqt pdeprbgt pdeprbht pdeprbrt ...
       pdeprbct pdeprbat pdeprbft pdeprbb pdeprbp pdeprbe pdeprbt ...
       pdeprbc pdeprba pdeprbf pdeprbQ pdeprbG pdeprbH pdeprbR ...
       pdeprbK pdeprbM pdeprbF pdeprbpm pdeprbts pdeprbMM ...
       pdeprbNu pdeprbOr pdeprbdt pdeprbd pdeprbN

if nargin>=3
  if strcmp(flag,'mass')
    f=pdeprbm(t);
    return
  end
  if strcmp(flag,'jacobian')
    f=pdeprbdf(t,u);
    return
  end
end

if ~(pdeprbqt || pdeprbgt || pdeprbht || pdeprbrt || ...
     pdeprbct || pdeprbat || pdeprbft)
  f=-pdeprbK*u+pdeprbF;
  return
end

if pdeprbqt || pdeprbgt || pdeprbht || pdeprbrt
  [Q,G,H,R]=assemb(pdeprbb,pdeprbp,pdeprbe,t);
end

if pdeprbct || pdeprbat || pdeprbft
  [K,M,F]=assema(pdeprbp,pdeprbt,pdeprbc,pdeprba,pdeprbf,t);
end

if pdeprbqt
  pdeprbQ=Q;
end

if pdeprbgt
  pdeprbG=G;
end

if pdeprbht
  pdeprbH=H;
end

if pdeprbrt
  pdeprbR=R;
end

if pdeprbct
  pdeprbK=K;
end

if pdeprbat
  pdeprbM=M;
end

if pdeprbft
  pdeprbF=F;
end

if ~(pdeprbht || pdeprbrt)
  [K,F,B,ud]=assempde(pdeprbK,pdeprbM,pdeprbF,pdeprbQ,pdeprbG,pdeprbH,pdeprbR);
else
  dt=pdeprbts*sqrt(eps);
  t1=t+dt;
  dt=t1-t;
  if pdeprbdt
    [unused,pdeprbMM]=assema(pdeprbp,pdeprbt,0,pdeprbd,zeros(pdeprbN,1),t);
  end
  if pdeprbht
    [N,O]=pdenullorth(pdeprbH);
    ud=O*((pdeprbH*O)\pdeprbR);
    [Q,G,H,R]=assemb(pdeprbb,pdeprbp,pdeprbe,t1);
    [N1,O1]=pdenullorth(H);
    ud1=O1*((H*O1)\R);
    K=N'*((pdeprbK+pdeprbM+pdeprbQ)*N+pdeprbMM*(N1-N)/dt);
    F=N'*((pdeprbF+pdeprbG)-(pdeprbK+pdeprbM+pdeprbQ)*ud-pdeprbMM*(ud1-ud)/dt);
  else
    HH=pdeprbH*pdeprbOr;
    ud=pdeprbOr*(HH\pdeprbR);
    [Q,G,H,R]=assemb(pdeprbb,pdeprbp,pdeprbe,t1);
    ud1=pdeprbOr*(HH\R);
    K=pdeprbNu'*(pdeprbK+pdeprbM+pdeprbQ)*pdeprbNu;
    F=pdeprbNu'*((pdeprbF+pdeprbG)-(pdeprbK+pdeprbM+pdeprbQ)*ud- ...
                 pdeprbMM*(ud1-ud)/dt);
  end
end

K=K(:,pdeprbpm);

f=-K*u+F;

