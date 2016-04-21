function [nlogL,avar] = lognlike(params,data,censoring,freq)
%LOGNLIKE Negative log-likelihood for the lognormal distribution.
%   NLOGL = LOGNLIKE(PARAMS,DATA) returns the negative of the log-likelihood
%   for the lognormal distribution, evaluated at parameters PARAMS(1) = MU
%   and PARAMS(2) = SIGMA, given DATA.  NLOGL is a scalar.
%
%   [NLOGL, AVAR] = LOGNLIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS are
%   the maximum likelihood estimates, the diagonal elements of AVAR are
%   their asymptotic variances.  AVAR is based on the observed Fisher's
%   information, not the expected information.
%
%   [...] = LOGNLIKE(PARAMS,DATA,CENSORING) accepts a boolean vector of the
%   same size as DATA that is 1 for observations that are right-censored
%   and 0 for observations that are observed exactly.
%
%   [...] = LOGNLIKE(PARAMS,DATA,CENSORING,FREQ) accepts a frequency vector
%   of the same size as DATA.  FREQ typically contains integer frequencies
%   for the corresponding elements in DATA, but may contain any non-integer
%   non-negative values.  Pass in [] for CENSORING to use its default
%   value.
%
%   See also LOGNCDF, LOGNFIT, LOGNINV, LOGNPDF, LOGNRND, LOGNSTAT.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.
%      [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%          Data, Wiley, New York, 580pp.
%      [3} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for
%          Reliability Data, Wiley, New York, 680pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/01/24 09:34:23 $

if nargin < 2
    error('stats:lognlike:TooFewInputs','Requires two input arguments');
elseif numel(data) > length(data)
    error('stats:lognlike:VectorRequired','DATA must be a vector.');
end
if nargin < 3 | isempty(censoring)
    censoring = [];
elseif ~isequal(size(data), size(censoring))
    error('stats:lognlike:InputSizeMismatch',...
          'DATA and CENSORING must have the same size.');
end
if nargin < 4 | isempty(freq)
    freq = [];
elseif isequal(size(data), size(freq))
    zerowgts = find(freq == 0);
    if numel(zerowgts) > 0
        data(zerowgts) = [];
        if numel(censoring)==numel(freq), censoring(zerowgts) = []; end
        freq(zerowgts) = [];
    end
else
    error('stats:lognlike:InputSizeMismatch',...
          'DATA and FREQ must have the same size.');
end

% Return NaN for out of range data.
data(data < 0) = NaN;

logdata = log(data);

if nargout == 1
    nlogL = normlike(params,logdata,censoring,freq);
else
    [nlogL,avar] = normlike(params,logdata,censoring,freq);
end
if isempty(freq), freq = 1; end
if isempty(censoring), censoring = 0; end
nlogL = nlogL + sum(freq .* logdata .* (1-censoring));
