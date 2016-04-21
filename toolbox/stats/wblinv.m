function [x,xlo,xup] = wblinv(p,A,B,pcov,alpha)
%WBLINV Inverse of the Weibull cumulative distribution function (cdf).
%   X = WBLINV(P,A,B) returns the inverse cdf for a Weibull
%   distribution with scale parameter A and shape parameter B,
%   evaluated at the values in P.  The size of X is the common size of the
%   input arguments.  A scalar input functions as a constant matrix of the
%   same size as the other inputs.
%   
%   Default values for A and B are 1 and 1, respectively.
%
%   [X,XLO,XUP] = WBLINV(P,A,B,PCOV,ALPHA) produces confidence
%   bounds for X when the input parameters A and B are estimates.
%   PCOV is a 2-by-2 matrix containing the covariance matrix of the estimated
%   parameters.  ALPHA has a default value of 0.05, and specifies
%   100*(1-ALPHA)% confidence bounds.  XLO and XUP are arrays of the same
%   size as X containing the lower and upper confidence bounds.
%
%   See also WBLCDF, WBLFIT, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, ICDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2004/01/16 20:10:45 $

if nargin < 2
    A = 1;
end
if nargin < 3
    B = 1;
end

% More checking if we need to compute confidence bounds.
if nargout>2
   if nargin<4
      error('stats:wblinv:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:wblinv:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin<5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
      error('stats:wblinv:BadAlpha','ALPHA must be a scalar between 0 and 1.');
   end
end

k = (0 < p & p < 1);
if all(k(:))
    q = -log(1-p);
    
else
    if isa(p,'single')
        q = zeros(size(p),'single');
    else
        q = zeros(size(p));
    end
    q(k) = -log(1-p(k));
    
    % Avoid log(0) warnings.
    q(p == 1) = Inf;
    
    % Return NaN for out of range probabilities.
    q(p < 0 | 1 < p | isnan(p)) = NaN;
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;

try
    x = A .* q.^(1./B);
catch
    error('stats:wblinv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Compute confidence bounds if requested.
if nargout>=2
   % Work on extreme value scale (log scale).
   logx = log(x);
   logq = log(q);
   deriv = [1./A, -1./(B.^2)];
   pcov = pcov .* (deriv' * deriv);
   logxvar = pcov(1,1) + 2*pcov(1,2)*logq + pcov(2,2)*logq.^2;
   if any(logxvar<0)
      error('stats:wblinv:BadCovariance',...
            'PCOV must be a positive semi-definite matrix.');
   end
   z = -norminv(alpha/2);
   halfwidth = z * sqrt(logxvar);
   
   % Convert back to Weibull scale
   xlo = exp(logx - halfwidth);
   xup = exp(logx + halfwidth);
end
