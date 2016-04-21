function [p,plo,pup] = wblcdf(x,A,B,pcov,alpha)
%WBLCDF Weibull cumulative distribution function (cdf).
%   P = WBLCDF(X,A,B) returns the cdf of the Weibull distribution
%   with scale parameter A and shape parameter B, evaluated at the
%   values in X.  The size of P is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for A and B are 1 and 1, respectively.
%
%   [P,PLO,PUP] = WBLCDF(X,A,B,PCOV,ALPHA) produces confidence
%   bounds for P when the input parameters A and B are estimates.
%   PCOV is a 2-by-2 matrix containing the covariance matrix of the estimated
%   parameters.  ALPHA has a default value of 0.05, and specifies
%   100*(1-ALPHA)% confidence bounds.  PLO and PUP are arrays of the same
%   size as P containing the lower and upper confidence bounds.
%
%   See also CDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/01/24 09:37:22 $

if nargin < 2
    A = 1;
end
if nargin < 3
    B = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>1
   if nargin<4
      error('stats:wblcdf:CovarianceRequired',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:wblcdf:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:wblcdf:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;

% Force a zero for negative x.
x(x < 0) = 0;

try
    z = (x./A).^B;
catch
    error('stats:wblcdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
p = 1 - exp(-z);

% Compute confidence bounds if requested.
if nargout>=2
   % Work on extreme value scale (log scale).
   logz = log(z);
   deriv = [1./A, -1./(B.^2)];
   pcov = pcov .* (deriv' * deriv);
   logzvar = (pcov(1,1) + 2*pcov(1,2)*logz + pcov(2,2)*logz.^2) .* (B.^2);
   if any(logzvar<0)
      error('stats:wblcdf:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   normz = -norminv(alpha/2);
   halfwidth = normz * sqrt(logzvar);
   zlo = logz - halfwidth;
   zup = logz + halfwidth;

   % Convert back to Weibull scale
   plo = 1 - exp(-exp(zlo));
   pup = 1 - exp(-exp(zup));
end
