function [logL, avar] = nbinlike(params, data)
%NBINLIKE Negative of the negative binomial log-likelihood function.
%   L = NBINLIKE(PARAMS,DATA) returns the negative of the negative binomial
%   log-likelihood function for the parameters PARAMS(1) = R and PARAMS(2)
%   = P, given DATA.
%
%   [LOGL, AVAR] = NBINLIKE(PARAMS,DATA) adds the inverse of Fisher's
%   information matrix, AVAR. If the input parameter values in PARAMS
%   are the maximum likelihood estimates, the diagonal elements of AVAR
%   are their asymptotic variances.  AVAR is based on the observed
%   Fisher's information, not the expected information.
%
%   NBINLIKE is a utility function for maximum likelihood estimation. 
%   See also BETALIKE, GAMLIKE, NBINFIT, NBINLIKE, NORMLIKE, MLE, WBLLIKE.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2003/12/11 03:50:41 $

if nargin < 2, 
    error('stats:nbinlike:TooFewInputs',...
          'Requires at least two input arguments'); 
end

[n, m] = size(data);
if min(n,m) > 1
    error('stats:nbinlike:InvalidData',...
          'The second argument must be a vector.');
end

if nargout == 2 & max(m,n) == 1
    error('stats:nbinlike:NotEnoughData',...
          'To compute AVAR, DATA must have at least two elements.');
end

if n == 1
   data = data';
   n = m;
end

r = params(1);
p = params(2);

% Out of range or missing parameters or data return NaN.  Infinite
% values for R correspond to a Poisson, but its mean cannot be determined
% from the (R,P) parametrization.
if ~(0 < r & isfinite(r) & 0 < p & p <= 1) ...
        | ~all(0 <= data & isfinite(data) & data == round(data))
    logL = NaN;
    avar = [];
    return
end

gamlnr = gammaln(r + data) - gammaln(data + 1) - gammaln(r);
sumx = sum(data);
logL = -(sum(gamlnr) + n*r*log(p)) - sumx*log(1-p);

if nargout == 2
    dL11 = sum(psi(1,r+data) - psi(1,r));
    dL12 = n./p;
    dL22 = -n.*r./p.^2 - sumx./(1-p).^2;
    nH = -[dL11 dL12; dL12 dL22];
    if any(isnan(nH(:)))
        avar = [NaN NaN; NaN NaN];
    else
        avar = inv(nH);
    end
end
