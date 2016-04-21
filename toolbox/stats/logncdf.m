function [p,plo,pup] = logncdf(x,mu,sigma,pcov,alpha)
%LOGNCDF Lognormal cumulative distribution function (cdf).
%   P = LOGNCDF(X,MU,SIGMA) returns the cdf of a lognormal distribution
%   with log mean MU and log standard deviation SIGMA, evaluated at the
%   values in X.  The size of P is the common size of X, MU and SIGMA.  A
%   scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%   [P,PLO,PUP] = LOGNCDF(X,MU,SIGMA,PCOV,ALPHA) produces confidence bounds
%   for P when the input parameters MU and SIGMA are estimates.  PCOV is a
%   2-by-2 matrix containing the covariance matrix of the estimated parameters.
%   ALPHA has a default value of 0.05, and specifies 100*(1-ALPHA)% confidence
%   bounds.  PLO and PUP are arrays of the same size as P containing the lower
%   and upper confidence bounds.
%
%   See also ERF, ERFC, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, 1046pp., sections 7.1, 26.2.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.15.4.4 $  $Date: 2004/01/24 09:34:20 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>1
   if nargin<4
      error('stats:logncdf:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:logncdf:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:logncdf:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

% Negative data would create complex values, which erfc cannot handle.
x(x < 0) = 0;

try
    % Prevent LogOfZero warnings.
    warn = warning('off','MATLAB:log:logOfZero');
    z = (log(x)-mu) ./ sigma;
    warning(warn);
catch
    warning(warn);
    error('stats:logncdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Use the complementary error function, rather than .5*(1+erf(z/sqrt(2))),
% to produce accurate near-zero results for large negative x.
p = 0.5 * erfc(-z ./ sqrt(2));

% Compute confidence bounds if requested.
if nargout>=2
   zvar = (pcov(1,1) + 2*pcov(1,2)*z + pcov(2,2)*z.^2) ./ (sigma.^2);;
   if any(zvar<0)
      error('stats:logncdf:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   normz = -norminv(alpha/2);
   halfwidth = normz * sqrt(zvar);
   zlo = z - halfwidth;
   zup = z + halfwidth;

   plo = 0.5 * erfc(-zlo./sqrt(2));
   pup = 0.5 * erfc(-zup./sqrt(2));
end
