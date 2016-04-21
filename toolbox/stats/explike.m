function [nlogL,avar] = explike(param,data,censoring,freq)
%EXPLIKE Negative log-likelihood for the exponential distribution.
%   NLOGL = EXPLIKE(PARAM,DATA) returns the negative of the log-likelihood
%   for the exponential distribution, evaluated at the location parameter
%   PARAM, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = EXPLIKE(PARAM,DATA) returns the inverse of Fisher's
%   information, AVAR, a scalar.  If the input parameter value in PARAM is
%   the maximum likelihood estimate, AVAR is its asymptotic variance.  AVAR
%   is based on the observed Fisher's information, not the expected
%   information.
%
%   [...] = EXPLIKE(PARAM,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = EXPLIKE(PARAM,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-integer
%   non-negative values.  Pass in [] for CENSORING to use its default
%   value.
%
%   See also EXPCDF, EXPFIT, EXPINV, EXPPDF, EXPRND, EXPSTAT.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/01/24 09:33:36 $

if nargin < 2
    error('stats:explike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:explike:VectorRequired','DATA must be a vector.');
end
if nargin < 3 || isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isequal(size(data), size(censoring))
    error('stats:explike:InputSizeMismatch',...
          'DATA and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = 1; % make this a scalar, will expand when needed
    n = numel(data);
elseif isequal(size(data), size(freq))
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        data(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
    n = sum(freq);
else
    error('stats:explike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

mu = param(1);

% Return NaN for out of range parameter or data.
mu(mu <= 0) = NaN;
data(data < 0) = NaN;

% Sum up the individual log-likelihood terms, and return the negative
% log-likelihood.
sumz = sum(freq.*data)./mu;
nunc = n - sum(freq.*censoring);
nlogL = nunc.*log(mu) + sumz;

% Compute the negative hessian at the parameter value, and invert to get
% the observed information.
if nargout == 2
    avar = mu.^2 ./ (2.*sumz - nunc);
end
