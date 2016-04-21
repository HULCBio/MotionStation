function [nlogL,avar] = evlike(params,data,censoring,freq)
%EVLIKE Negative log-likelihood for the extreme value distribution.
%   NLOGL = EVLIKE(PARAMS,DATA) returns the negative of the log-likelihood
%   for the type 1 extreme value distribution, evaluated at parameters
%   PARAMS(1) = MU and PARAMS(2) = SIGMA, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = EVLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS are
%   the maximum likelihood estimates, the diagonal elements of AVAR are
%   their asymptotic variances.  AVAR is based on the observed Fisher's
%   information, not the expected information.
%
%   [...] = EVLIKE(PARAMS,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = EVLIKE(PARAMS,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-integer
%   non-negative values.  Pass in [] for CENSORING to use its default
%   value.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVFIT, EVINV, EVPDF, EVRND, EVSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/01/24 09:33:28 $

if nargin < 2
    error('stats:evlike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:evlike:VectorRequired','DATA must be a vector.');
end
if nargin < 3 | isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isequal(size(data), size(censoring))
    error('stats:evlike:InputSizeMismatch',...
          'DATA and CENSORING must have the same size.');
end
if nargin < 4 | isempty(freq)
    freq = 1; % make this a scalar, will expand when needed
elseif isequal(size(data), size(freq))
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        data(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
else
    error('stats:evlike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

mu = params(1);
sigma = params(2);

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

% Compute the individual log-likelihood terms.  Force a log(0)==-Inf for
% data from extreme right tail, instead of getting exp(Inf-Inf)==NaN.
z = (data - mu) ./ sigma;
expz = exp(z);
L = (z - log(sigma)).*(1-censoring) - expz;
L(z == Inf) = -Inf;

% Sum up the individual contributions, and return the negative log-likelihood.
nlogL = -sum(freq .* L);

% Compute the negative hessian at the parameter values, and invert to get
% the observed information matrix.
if nargout == 2
    unc = (1-censoring);
    nH11 = sum(freq .* expz);
    nH12 = sum(freq .* ((z+1).*expz - unc));
    nH22 = sum(freq .* (z.*(z+2).*expz - ((2.*z+1).*unc)));
    avar =  (sigma.^2) * [nH22 -nH12; -nH12 nH11] / (nH11*nH22 - nH12*nH12);
end
