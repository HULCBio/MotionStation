function [x,xlo,xup] = expinv(p,mu,pcov,alpha)
%EXPINV Inverse of the exponential cumulative distribution function.
%   X = EXPCDF(P,MU) returns the inverse cdf of the exponential
%   distribution with location parameter MU, evaluated at the values in P.
%   The size of X is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other input.
%
%   The default value for MU is 1.
%
%   [X,XLO,XUP] = EXPINV(P,MU,PCOV,ALPHA) produces confidence bounds
%   for X when the input parameter MU is an estimate.  PCOV is the
%   variance of the estimated MU.  ALPHA has a default value of 0.05, and
%   specifies 100*(1-ALPHA)% confidence bounds.  XLO and XUP are arrays of
%   the same size as X containing the lower and upper confidence bounds.
%   The bounds are based on a normal approximation for the distribution of
%   the log of the estimate of MU.  You can get a more accurate set of
%   bounds simply by using EXPFIT to get a confidence interval for MU,
%   and evaluating EXPINV at the lower and upper end points of that interval.
%
%   See also EXPCDF, EXPFIT, EXPLIKE, EXPPDF, EXPRND, EXPSTAT, ICDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%     Copyright 1993-2004 The MathWorks, Inc. 
%     $Revision: 2.13.4.2 $  $Date: 2004/01/24 09:33:35 $

if nargin < 2
    mu = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>2
   if nargin<3
      error('stats:expinv:TooFewInputs',...
            'Must provide parameter variance to compute confidence bounds.');
   end
   if numel(pcov)~=1
      error('stats:expinv:BadVariance','Variance must be a scalar.');
   end
   if nargin<4
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:expinv:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

k = (0 < p & p < 1);
if all(k(:))
    q = -log(1-p);
    
else
    q = zeros(size(p));
    q(k) = -log(1-p(k));
    
    % Avoid log(0) warnings.
    q(p == 1) = Inf;
    
    % Return NaN for out of range probabilities.
    q(p < 0 | 1 < p | isnan(p)) = NaN;
end

% Return NaN for out of range parameters.
mu(mu <= 0) = NaN;

try
    x = mu .* q;
catch
    error('stats:expinv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Compute confidence bounds if requested.
if nargout>=2
   % Work on extreme value scale (log scale).
   logx = log(x);
   if pcov<0
      error('stats:expinv:BadVariance','PCOV must be non-negative.');
   end
   z = -norminv(alpha/2);
   halfwidth = z * sqrt(pcov ./ (mu.^2));
   
   % Convert back to Weibull scale
   xlo = exp(logx - halfwidth);
   xup = exp(logx + halfwidth);
end
