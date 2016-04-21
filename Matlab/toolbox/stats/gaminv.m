function [x,xlo,xup] = gaminv(p,a,b,pcov,alpha);
%GAMINV Inverse of the gamma cumulative distribution function (cdf).
%   X = GAMINV(P,A,B) returns the inverse cdf for the gamma distribution
%   with shape A and scale B, evaluated at the values in P.  The size of X
%   is the common size of the input arguments.  A scalar input functions as
%   a constant matrix of the same size as the other inputs.
%
%   [X,XLO,XUP] = GAMINV(P,A,B,PCOV,ALPHA) produces confidence bounds for
%   X when the input parameters A and B are estimates. PCOV is a 2-by-2
%   matrix containing the covariance matrix of the estimated parameters.
%   ALPHA has a default value of 0.05, and specifies 100*(1-ALPHA)%
%   confidence bounds.  XLO and XUP are arrays of the same size as X
%   containing the lower and upper confidence bounds.
%
%   See also GAMCDF, GAMFIT, GAMLIKE, GAMPDF, GAMRND, GAMSTAT.

%   GAMINV uses Newton's method to find roots of GAMCDF(X,A,B) = P.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, section 26.1.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.7 $  $Date: 2004/02/01 22:10:23 $

if nargin < 2
    error('stats:gaminv:TooFewInputs',...
          'Requires at least two input arguments.');
elseif nargin < 3
    b = 1;
end

% More checking if we need to compute confidence bounds.
if nargout > 2
   if nargin < 4
      error('stats:gaminv:TooFewInputs',...
            'Must provide covariance matrix to compute confidence bounds.');
   end
   if ~isequal(size(pcov),[2 2])
      error('stats:gaminv:BadCovariance',...
            'Covariance matrix must have 2 rows and columns.');
   end
   if nargin < 5
      alpha = 0.05;
   elseif ~isnumeric(alpha) || numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
      error('stats:gaminv:BadAlpha',...
            'ALPHA must be a scalar between 0 and 1.');
   end
end

% Weed out any out of range parameters or edge/bad probabilities.
try
    okAB = (0 < a) & (0 < b);
    k = (okAB & (0 < p & p < 1));
catch
    error('stats:gaminv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
allOK = all(k(:));

% Fill in NaNs for out of range cases, fill in edges cases when P is 0 or 1.
if ~allOK
    x = repmat(NaN, size(k));
    x(okAB & p == 0) = 0;
    x(okAB & p == 1) = Inf;
    
    if nargout > 1
        xlo = x; % NaNs or zeros or Infs
        xup = x; % NaNs or zeros or Infs
    end
    
    % Remove the bad/edge cases, leaving the easy cases.  If there's
    % nothing remaining, return.
    if any(k(:))
        if numel(p) > 1, p = p(k); end
        if numel(a) > 1, a = a(k); end
        if numel(b) > 1, b = b(k); end
    else
        return;
    end
end

% ==== Newton's Method to find a root of GAMCDF(X,A,B) = P ====

% Limit this to maxiter iterations.
maxiter = 500;
iter = 0;

% Choose a starting guess for q.  Use quantiles from a lognormal
% distribution with the same mean (==a) and variance (==a) as G(a,1).
loga = log(a);
sigsq = log(1+a) - loga;
mu = loga - 0.5 .* sigsq;
q = exp(mu - sqrt(2.*sigsq).*erfcinv(2*p));
    
h = ones(size(p));

% Break out of the iteration loop when the relative size of the last step
% is small for all elements of q.
reltol = eps(class(p)).^(3/4);
while any(abs(h(:)) > reltol*q(:))
    iter = iter + 1;
    if iter > maxiter
        % Too many iterations.  This should not happen.
        didnt = find(abs(h) > reltol*q); didnt = didnt(1);
        if numel(a) == 1, abad = a; else abad = a(didnt); end
        if numel(b) == 1, bbad = b; else bbad = b(didnt); end
        if numel(p) == 1, pbad = p; else pbad = p(didnt); end
        warning('stats:gaminv:NoConvergence',...
                'GAMINV did not converge for a = %g, b = %g, p = %g.',...
                abad,bbad,pbad);
        break
    end
    
    h = (gamcdf(q,a,1) - p) ./ max(gampdf(q,a,1), realmin(class(p)));
    qnew = q - h;
    % Make sure that the current iterates stay positive.  When Newton's
    % Method suggests steps that lead to negative values, take a step
    % 9/10ths of the way to zero instead.
    ksmall = find(qnew <= 0);
    if ~isempty(ksmall)
        qnew(ksmall) = q(ksmall) / 10;
        h = q - qnew;
    end
    q = qnew;
end

% Add in the scale factor, and broadcast the values to the correct place if
% need be.
if allOK
    x = q .* b;
else
    x(k) = q .* b;
end

% Compute confidence bounds if requested.
if nargout >= 2
    logq = log(q);
    dqda = -dgammainc(q,a) ./ exp((a-1).*logq - q - gammaln(a));
    
    % Approximate the variance of x=q*b on the log scale.
    %    dlogx/da = dlogx/dq * dqda = dqda/q
    %    dlogx/db = 1/b
    logx = logq + log(b);
    varlogx = pcov(1,1).*(dqda./q).^2 + 2.*pcov(1,2).*dqda./(b.*q) + pcov(2,2)./(b.^2);
    if any(varlogx(:) < 0)
        error('stats:gaminv:BadCovariance',...
              'PCOV must be a positive semi-definite matrix.');
    end
    z = -norminv(alpha/2);
    halfwidth = z * sqrt(varlogx);
    
    % Convert back to original scale
    if allOK
        xlo = exp(logx - halfwidth);
        xup = exp(logx + halfwidth);
    else
        xlo(k) = exp(logx - halfwidth);
        xup(k) = exp(logx + halfwidth);
    end
end
