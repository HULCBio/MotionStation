function r=pderesid(time,u)
%PDERESID Residual for nonlinear solver

%       M. Dorobantu 1-17-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:49 $

global pdenonb pdenonp pdenone pdenont pdenonc pdenona pdenonf pdenonn
global pdenonK pdenonF

u=full(u);
[cc,aa,ff]=pdetxpd(pdenonp,pdenont,u(1:pdenonn),pdenonc,pdenona,pdenonf);
[K,M,F,Q,G,H,R]=assempde(pdenonb,pdenonp,pdenone,pdenont,cc,aa,ff,u(1:pdenonn));
pdenonK=K+M+Q;pdenonF=F+G;
if any(any(H))
  if size(u,1)<(size(pdenonK,2)+size(H,1))
    u=[u;H'\(pdenonF-pdenonK*u)];
  end
  pdenonK=[pdenonK H';H zeros(size(H,1))];
  pdenonF=[pdenonF;R];
end
r=pdenonK*u-pdenonF;

