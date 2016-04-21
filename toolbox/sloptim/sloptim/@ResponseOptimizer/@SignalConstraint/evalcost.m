function c = evalcost(this,t,y)
% Evaluates objective for given simulation.

% Author: P. Gahinet
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:52 $
% Copyright 1986-2004 The MathWorks, Inc.
if ~hasCost(this)
   c = zeros(0,1);
elseif length(t)==1 && isnan(t)
   % Sim failure
   c = 1e8 + i;
else
   % Evaluate L2 gap between reference 
   tr = this.ReferenceX;
   yr = this.ReferenceY;
   wr = this.ReferenceWeight;
   % Size checks
   if size(yr,2)~=size(y,2)
      if size(yr,2)==1
         yr = repmat(yr,[1 size(y,2)]);
      else
         error('Reference signal dimensions do not match signal dimensions.')
      end
   end
   % Merge the time bases
   tmin = max(t(1),tr(1));
   tmax = min(t(end),tr(end));
   ts = unique([t(t>=tmin & t<=tmax) ; tr(tr>=tmin & tr<=tmax)]);
   y = interp1(t,y,ts);
   yr = interp1(tr,yr,ts);
   if isempty(wr)
      wr = 1;
   else
      wr = interp1(tr,wr,ts);
   end
   % Estimate 1/T * int_0^T w(t) e(t)^2 dt
   e = (y-yr) * diag(1./max(abs(yr)));  % scaled error
   f = sum(e.^2,2) .* wr;
   ns = length(ts);
   c = sum((f(1:ns-1) + f(2:ns)).*diff(ts));
   
   % Safeguard against instability
   if ~isfinite(c)
      % NaN value can arise when goes unstable
      c = 1e8 + i;
   elseif c>10
      c = 10*(1+log(c/10));
   end
end

