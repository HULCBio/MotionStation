function [nlogL,avar] = normlike(params,data,censoring,freq)
%NORMLIKE Negative log-likelihood for the normal distribution.
%   NLOGL = NORMLIKE(PARAMS,DATA) returns the negative of the log-likelihood
%   for the normal distribution, evaluated at parameters PARAMS(1) = MU and
%   PARAMS(2) = SIGMA, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = NORMLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS are
%   the maximum likelihood estimates, the diagonal elements of AVAR are
%   their asymptotic variances.  AVAR is based on the observed Fisher's
%   information, not the expected information.
%
%   [...] = NORMLIKE(PARAMS,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = NORMLIKE(PARAMS,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-integer
%   non-negative values.  Pass in [] for CENSORING to use its default
%   value.
%
%   See also NORMCDF, NORMFIT, NORMINV, NORMPDF, NORMRND, NORMSTAT.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.
%      [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%          Data, Wiley, New York, 580pp.
%      [3} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for
%          Reliability Data, Wiley, New York, 680pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.15.4.1 $  $Date: 2003/11/01 04:27:38 $

if nargin < 2
    error('stats:normlike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:normlike:InvalidData','DATA must be a vector.');
end
if nargin < 3 | isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isequal(size(data), size(censoring))
    error('stats:normlike:InputSizeMismatch',...
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
    error('stats:normlike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

mu = params(1);
sigma = params(2);

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

% Compute the individual log-likelihood terms.
z = (data - mu) ./ sigma;
L = -.5.*z.*z - log(sqrt(2.*pi).*sigma);
ncen = sum(freq.*censoring);
if ncen > 0
    cens = (censoring == 1);
    zcen = z(cens);
    Scen = .5*erfc(zcen/sqrt(2));
    L(cens) = log(Scen);
end

% Sum up the individual contributions, and return the negative log-likelihood.
nlogL = -sum(freq .* L);

% Compute the negative hessian at the parameter values, and invert to get
% the observed information matrix.
if nargout == 2
    dL11 = -ones(size(z));
    dL12 = -2.*z;
    dL22 = 1 - 3.*z.*z;
    if ncen > 0
        dlogScen = exp(-.5*zcen.*zcen) ./ (sqrt(2*pi) .* Scen);
        d2logScen = dlogScen .* (dlogScen - zcen);
        dL11(cens) = -d2logScen;
        dL12(cens) = -dlogScen - zcen.*d2logScen;
        dL22(cens) = -zcen .* (2.*dlogScen + zcen.*d2logScen);
    end
    nH11 = -sum(freq .* dL11);
    nH12 = -sum(freq .* dL12);
    nH22 = -sum(freq .* dL22);
    avar =  (sigma.^2) * [nH22 -nH12; -nH12 nH11] / (nH11*nH22 - nH12*nH12);
end
