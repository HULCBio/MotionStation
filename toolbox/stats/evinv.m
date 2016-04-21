function [x,xlo,xup] = evinv(p,mu,sigma,pcov,alpha)
%EVINV Inverse of the extreme value cumulative distribution function (cdf).
%   X = EVINV(P,MU,SIGMA) returns the inverse cdf for a type 1 extreme
%   value distribution with location parameter MU and scale parameter
%   SIGMA, evaluated at the values in P.  The size of X is the common size
%   of the input arguments.  A scalar input functions as a constant matrix
%   of the same size as the other inputs.
%   
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%   [X,XLO,XUP] = EVINV(P,MU,SIGMA,PCOV,ALPHA) produces confidence bounds
%   for X when the input parameters MU and SIGMA are estimates.  PCOV is a
%   2-by-2 matrix containing the covariance matrix of the estimated parameters.
%   ALPHA has a default value of 0.05, and specifies 100*(1-ALPHA)% confidence
%   bounds.  XLO and XUP are arrays of the same size as X containing the lower
%   and upper confidence bounds.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVFIT, EVLIKE, EVPDF, EVRND, EVSTAT, ICDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2004/01/24 09:33:27 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>2
   if nargin<4
      error('stats:evinv:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:evinv:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:evinv:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

k = (0 < p & p < 1);
if all(k(:))
    q = log(-log(1-p));
    
else
    q = zeros(size(p));
    
    % Avoid log(0) warnings.
    q(k) = log(-log(1-p(k)));
    q(p == 0) = -Inf;
    q(p == 1) = Inf;
    
    % Return NaN for out of range probabilities.
    q(p < 0 | 1 < p | isnan(p)) = NaN;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    x = sigma .* q + mu;
catch
    error('stats:evinv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Compute confidence bounds if requested.
if nargout>=2
   xvar = pcov(1,1) + 2*pcov(1,2)*q + pcov(2,2)*q.^2;
   if any(xvar<0)
      error('stats:evinv:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   z = -norminv(alpha/2);
   halfwidth = z * sqrt(xvar);
   xlo = x - halfwidth;
   xup = x + halfwidth;
end
