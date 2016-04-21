function [parmhat, parmci] = lognfit(x,alpha,censoring,freq,options)
%LOGNFIT Parameter estimates and confidence intervals for lognormal data.
%   PARMHAT = LOGNFIT(X) returns maximum likelihood estimates of the
%   parameters of the lognormal distribution given the data in X.
%   PARMHAT(1) and PARMHAT(2) are, respectively, the mean and standard
%   deviation parameters, MU and SIGMA, of the underlying normal
%   distribution.
%
%   [PARMHAT,PARMCI] = LOGNFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = LOGNFIT(X,ALPHA) returns 100(1-ALPHA) percent
%   confidence intervals for the parameter estimates.
%
%   [...] = LOGNFIT(X,ALPHA,CENSORING) accepts a boolean vector of the same
%   size as X that is 1 for observations that are right-censored and 0 for
%   observations that are observed exactly.
%
%   [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ) accepts a frequency vector of
%   the same size as X.  FREQ typically contains integer frequencies for
%   the corresponding elements in X, but may contain any non-integer
%   non-negative values.
%
%   [...] = LOGNFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) specifies control
%   parameters for the iterative algorithm used to compute ML estimates
%   when there is censoring.  This argument can be created by a call to
%   STATSET.  See STATSET('lognfit') for parameter names and default values.
%
%   Pass in [] for ALPHA, CENSORING, or FREQ to use their default values.
%
%   With no censoring, SIGMAHAT is computed using the square root of the
%   unbiased estimator of the variance of log(X).  With censoring,
%   SIGMAHAT is the maximum likelihood estimate.

%   With no censoring, SIGMAHAT is the square root of the unbiased estimate
%   of the variance of log(X).  With censoring, SIGMAHAT is the maximum
%   likelihood estimate.
%
%   See also LOGNCDF, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND, LOGNSTAT, MLE,
%   STATSET.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.
%      [2] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime
%          Data, Wiley, New York, 580pp.
%      [3} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for
%          Reliability Data, Wiley, New York, 680pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2004/04/16 22:22:01 $

% Illegal data return an error.
if ~isvector(x)
    error('stats:lognfit:VectorRequired','X must be a vector.');
elseif any(x <= 0)
    error('stats:lognfit:PositiveDataRequired',...
          'The data in X must be positive.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 3 || isempty(censoring)
    censoring = [];
elseif ~isempty(censoring) && ~isequal(size(x), size(censoring))
    error('stats:lognfit:InputSizeMismatch',...
          'X and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = [];
elseif ~isempty(freq) && ~isequal(size(x), size(freq))
    error('stats:lognfit:InputSizeMismatch',...
          'X and FREQ must have the same size.');
end
if nargin < 5 || isempty(options)
    options = [];
end

% Fit a normal distribution to the logged data.  The parameterizations of
% the normal and lognormal are identical.
%
% Get parameter estimates only.
if nargout == 1
    [muhat,sigmahat] = normfit(log(x),alpha,censoring,freq,options);
    parmhat = [muhat sigmahat];

% Get parameter estimates and CIs.
else
    [muhat,sigmahat,muci,sigmaci] = normfit(log(x),alpha,censoring,freq,options);
    parmhat = [muhat sigmahat];
    parmci = [muci sigmaci];
end
