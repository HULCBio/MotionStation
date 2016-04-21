function [nlogL,avar] = gamlike(params,data,censoring,freq)
%GAMLIKE Negative log-likelihood for the gamma distribution.
%   NLOGL = GAMLIKE(PARAMS,DATA)  returns the negative of the
%   log-likelihood for the gamma distribution, evaluated at parameters
%   PARAMS(1) = A and PARAMS(2) = B, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = GAMLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS are
%   the maximum likelihood estimates, the diagonal elements of AVAR are
%   their asymptotic variances.  AVAR is based on the observed Fisher's
%   information, not the expected information.
%
%   [...] = GAMLIKE(PARAMS,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = GAMLIKE(PARAMS,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-negative
%   values.  Pass in [] for CENSORING to use its default value.
%
%   See also GAMCDF, GAMFIT, GAMINV, GAMPDF, GAMRND, GAMSTAT.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley.
%      [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%          Data, Wiley.
%      [3} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for
%          Reliability Data, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.6.3 $  $Date: 2004/01/24 09:33:55 $

if nargin < 2
    error('stats:gamlike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:gamlike:VectorRequired','DATA must be a vector.');
end
if nargin < 3 || isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isequal(size(data), size(censoring))
    error('stats:gamlike:InputSizeMismatch',...
          'DATA and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = 1; % make this a scalar, will expand when needed
elseif isequal(size(data), size(freq))
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        data(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
else
    error('stats:gamlike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

a = params(1);
b = params(2);

% Return NaN for out of range parameters or data.
a(a <= 0) = NaN;
b(b <= 0) = NaN;
data(data <= 0) = NaN;

% Compute the individual log-likelihood terms.  Force a log(0)==-Inf for
% data from extreme right tail, instead of getting exp(Inf-Inf)==NaN.
z = data ./ b;
L = (a - 1) .* log(z) - z - gammaln(a) - log(b);
ncen = sum(freq.*censoring);
if ncen > 0
    cens = (censoring == 1);
    zcen = z(cens);
    Scen = gammainc(zcen,a,'upper');
    L(cens) = log(Scen);
end
L(z == Inf) = -Inf;

% Sum up the individual contributions, and return the negative log-likelihood.
nlogL = -sum(freq .* L);

% Compute the negative hessian at the parameter values, and invert to get
% the observed information matrix.
if nargout == 2
    dL11 = -repmat(psi(1,a),size(z));
    dL12 = -repmat(1./b,size(z));
    dL22 = -(2.*z-a) ./ (b.^2);
    if ncen > 0
        [dlnS,d2lnS] = dlngamsf(zcen,a);
        logzcen = log(zcen);
        tmp = exp(a .* logzcen - zcen - gammaln(a) - log(b)) ./ Scen;
        dL11(cens) = d2lnS;
        dL12(cens) = tmp .* (logzcen - dlnS - psi(0,a));
        dL22(cens) = tmp .* ((zcen-1-a)./b - tmp);
    end
    nH11 = -sum(freq .* dL11);
    nH12 = -sum(freq .* dL12);
    nH22 = -sum(freq .* dL22);
    nH = [nH11 nH12; nH12 nH22];
    if any(isnan(nH(:)))
        avar = [NaN NaN; NaN NaN];
    else
        avar = inv(nH);
    end
end


function [dlnS, d2lnS] = dlngamsf(x,a)
%DLNGAMSF Derivatives of the gamma distribution's log SF.
% Also known as logarithmic derivatives of the upper incomplete gamma function.

[dgamu, gamu, d2gamu] = dgammainc(x,a,'upper');
dlnS = dgamu ./ gamu;
d2lnS = d2gamu ./ gamu - dlnS.*dlnS;
