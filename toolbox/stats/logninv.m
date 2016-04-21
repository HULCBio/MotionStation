function [x,xlo,xup] = logninv(p,mu,sigma,pcov,alpha);
%LOGNINV Inverse of the lognormal cumulative distribution function (cdf).
%   X = LOGNINV(P,MU,SIGMA) returns the inverse cdf for a lognormal
%   distribution with log mean MU and log standard deviation SIGMA,
%   evaluated at the values in P.  The size of X is the common size of the
%   input arguments.  A scalar input functions as a constant matrix of the
%   same size as the other inputs.
%
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%   [X,XLO,XUP] = LOGNINV(P,MU,SIGMA,PCOV,ALPHA) produces confidence bounds
%   for X when the input parameters MU and SIGMA are estimates.  PCOV is a
%   2-by-2 matrix containing the covariance matrix of the estimated parameters.
%   ALPHA has a default value of 0.05, and specifies 100*(1-ALPHA)% confidence
%   bounds.  XLO and XUP are arrays of the same size as X containing the lower
%   and upper confidence bounds.
%
%   See also ERFINV, ERFCINV, LOGNCDF, LOGNFIT, LOGNLIKE, LOGNPDF,
%            LOGNRND, LOGNSTAT.


%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, 1046pp., sections 7.1, 26.2.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.


%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.2 $  $Date: 2004/01/24 09:34:22 $


if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>2
   if nargin<4
      error('stats:logninv:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:logninv:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:logninv:BadAlpha',...
            'ALPHA must be a scalar between 0 and 1.');
   end
end

% Return NaN for out of range parameters or probabilities.
sigma(sigma <= 0) = NaN;
p(p < 0 | 1 < p) = NaN;


logx0 = -sqrt(2).*erfcinv(2*p);
try
    x = exp(sigma.*logx0 + mu);
catch
    error('stats:logninv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Compute confidence bounds if requested.
if nargout>=2
   xvar = pcov(1,1) + 2*pcov(1,2)*logx0 + pcov(2,2)*logx0.^2;
   if any(xvar<0)
      error('stats:logninv:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   normz = -norminv(alpha/2);
   halfwidth = normz * sqrt(xvar);
   xlo = x .* exp(-halfwidth);
   xup = x .* exp(+halfwidth);
end
