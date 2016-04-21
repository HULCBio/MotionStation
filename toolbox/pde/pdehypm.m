function m=pdehypm(t)
%PDEHYPM Mass matrix for HYPERBOLIC.

%       A. Nordmark 1-20-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:16 $

global pdehypht pdehypMM pdehypdt pdehypp pdehypt pdehypd pdehypN ...
       pdehypb pdehype pdehypB pdehyppm

if pdehypdt
  [unused,pdehypMM]=assema(pdehypp,pdehypt,0,pdehypd,zeros(pdehypN,1),t);
end
if pdehypht
  [unused,unused,H,unused]=assemb(pdehypb,pdehypp,pdehype,t);
  pdehypB=pdenullorth(H);
end
nu=size(pdehypB,2);
m=[speye(nu,nu) sparse(nu,nu); sparse(nu,nu) pdehypB'*pdehypMM*pdehypB];
m=m(:,pdehyppm);

