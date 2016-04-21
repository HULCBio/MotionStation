function [mad_s,rob_s] = cfrobsigma(robtype,r,p,t,h)
%CFROBSIGMA Compute sigma estimates for robust curve fitting.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:43:21 $

% Compute sigma estimated using median absolute deviation of
% residuals from the median; used during iterative fitting
m = median(r);
rs = sort(abs(r-m));
if (abs(m) > rs(end))
    % Unexpectedly all residuals are very small
    rs = sort(abs(r));
end
s = median(rs(p:end)) / 0.6745;
if (s==0), s = .5*mean(rs); end
mad_s = s;

% Compute value to use for final sigma estimate after fit
if nargout>1
   st = s*t;
   n = length(r);
   delta = 0.01;
   u = r ./ st - delta;
   phi = u .* cfrobwts(robtype,u);
   u1 = u + 2*delta;
   phi1 = u1 .* cfrobwts(robtype,u1);
   if max(abs(phi1-phi))<100*eps
      % These are of order 1 so they can be compared with eps.
      % If they're all basically the same aside from roundoff
      % error, act as if they're really the same
      rob_s = 0;
   else
      dphi = (phi1 - phi) ./ (2*delta);
      m1 = mean(dphi);
      m2 = mean((dphi-m1).^2);
      K = 1 + (p/n) * (m2 / m1.^2);
      
      s = (K/abs(m1)) * sqrt(sum(phi.^2 .* st^2 .* (1-h)) ./ (n-p));
      rob_s = s;
   end
end
