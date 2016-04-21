function [lambdahat, lambdaci] = poissfit(x,alpha)
%POISSFIT Parameter estimates and confidence intervals for Poisson data.
%   POISSFIT(X) Returns the estimate of the parameter of the Poisson
%   distribution give the data X. 
%
%   [LAMBDAHAT, LAMBDACI] = POISSFIT(X,ALPHA) gives MLEs and 100(1-ALPHA) 
%   percent confidence intervals given the data. By default, the
%   optional parameter ALPHA = 0.05 corresponding to 95% confidence intervals.
%
%   See also POISSCDF, POISSINV, POISSPDF, POISSRND, POISSTAT, MLE. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.2 $  $Date: 2004/01/24 09:34:52 $

if nargin < 2 
    alpha = 0.05;
end


% Initialize params to zero.
[m, n] = size(x);
if min(m,n) == 1
   x = x(:);
   m = max(m,n);
   n = 1;
end

lambdahat = mean(x);
if ~isfloat(lambdahat)
   lambdahat = double(lambdahat);
end


if nargout > 1,
   lsum = m*lambdahat;
   k = find(lsum < 100);
   if any(k)
      lb(k) = chi2inv(alpha/2, 2*lsum(k))/2;
      ub(k) = chi2inv(1-alpha/2, 2*(lsum(k)+1))/2;
   end
   k = find(lsum >= 100);
   if any(k)
      lb(k) = norminv(alpha/2,lsum(k),sqrt(lsum(k)));
      ub(k) = norminv(1 - alpha/2,lsum(k),sqrt(lsum(k)));
   end
   
   lambdaci = [lb;ub]/m;
end

