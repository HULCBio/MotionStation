function [p,plo,pup] = evcdf(x,mu,sigma,pcov,alpha)
%EVCDF Extreme value cumulative distribution function (cdf).
%   P = EVCDF(X,MU,SIGMA) returns the cdf of the type 1 extreme value
%   distribution with location parameter MU and scale parameter SIGMA,
%   evaluated at the values in X.  The size of P is the common size of the
%   input arguments.  A scalar input functions as a constant matrix of the
%   same size as the other inputs.
%
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%   [P,PLO,PUP] = EVCDF(X,MU,SIGMA,PCOV,ALPHA) produces confidence bounds
%   for P when the input parameters MU and SIGMA are estimates.  PCOV is a
%   2-by-2 matrix containing the covariance matrix of the estimated parameters.
%   ALPHA has a default value of 0.05, and specifies 100*(1-ALPHA)% confidence
%   bounds.  PLO and PUP are arrays of the same size as P containing the lower
%   and upper confidence bounds.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also CDF, EVFIT, EVINV, EVLIKE, EVPDF, EVRND, EVSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/01/24 09:33:25 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>1
   if nargin<4
      error('stats:evcdf:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:evcdf:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:evcdf:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    z = (x-mu)./sigma;
    p = 1 - exp( -exp(z) );
catch
    error('stats:evcdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Compute confidence bounds if requested.
if nargout>=2
   zvar = (pcov(1,1) + 2*pcov(1,2)*z + pcov(2,2)*z.^2) ./ (sigma.^2);
   if any(zvar<0)
      error('stats:evcdf:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   normz = -norminv(alpha/2);
   halfwidth = normz * sqrt(zvar);
   zlo = z - halfwidth;
   zup = z + halfwidth;
   
   plo = 1 - exp(-exp(zlo));
   pup = 1 - exp(-exp(zup));
end
