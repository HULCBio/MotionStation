function m=pdeprbm(t)
%PDEPRBM Mass matrix for PARABOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:19 $

global pdeprbht pdeprbMM pdeprbdt pdeprbp pdeprbt pdeprbd pdeprbN ...
       pdeprbb pdeprbe pdeprbB pdeprbpm

if pdeprbdt
  [unused,pdeprbMM]=assema(pdeprbp,pdeprbt,0,pdeprbd,zeros(pdeprbN,1),t);
end
if pdeprbht
  [unused,unused,H,unused]=assemb(pdeprbb,pdeprbp,pdeprbe,t);
  pdeprbB=pdenullorth(H);
end
m=pdeprbB'*pdeprbMM*pdeprbB;
m=m(:,pdeprbpm);

