%   dx=affsim(t,x,flag,ufun,ptraj,pds,pv,range)
%
%   Called by PDSIMUL: integrate an affine PDS with ODE15s

%   Author: P. Gahinet  6/94
%   Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function dx = affsim(t,x,flag,ufun,ptraj,pds,pv,range)

% current parameter and input values
pt = feval(ptraj,t);
ut = feval(ufun,t);

% check position in box
if any(pt < range(:,1) | pt > range(:,2)),
  error(sprintf('The parameter trajectory leaves the parameter box at t = %6.3e',t));
end

% get A(p),B(p),C(p),D(p)
[ap,bp,cp,dp,ep]=ltiss(psinfo(pds,'eval',pt));


if isempty(flag)
   % Return state derivative
   if ~isequal(ep,eye(size(ap)))
      ap=ep\ap;
      bp=ep\bp;
   end
   dx=ap*x + bp*ut;
else 
   % Return output
   dx=(cp*x + dp*ut).';
end

