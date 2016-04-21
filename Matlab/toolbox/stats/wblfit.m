function [parmhat, parmci] = wblfit(x,alpha,censoring,freq,options)
%WBLFIT Parameter estimates and confidence intervals for Weibull data.
%   PARMHAT = WBLFIT(X) returns maximum likelihood estimates of the
%   parameters of the Weibull distribution given the data in X.  PARMHAT(1)
%   is the scale parameter, A, and PARMHAT(2) is the shape parameter, B.
%
%   [PARMHAT,PARMCI] = WBLFIT(X) returns 95% confidence intervals for the
%   parameter estimates.
%
%   [PARMHAT,PARMCI] = WBLFIT(X,ALPHA) returns 100(1-ALPHA) percent
%   confidence intervals for the parameter estimates.
%
%   [...] = WBLFIT(X,ALPHA,CENSORING) accepts a boolean vector of the same
%   size as X that is 1 for observations that are right-censored and 0 for
%   observations that are observed exactly.
%
%   [...] = WBLFIT(X,ALPHA,CENSORING,FREQ) accepts a frequency vector of
%   the same size as X.  FREQ typically contains integer frequencies for
%   the corresponding elements in X, but may contain any non-integer
%   non-negative values.
%
%   [...] = WBLFIT(X,ALPHA,CENSORING,FREQ,OPTIONS) specifies control
%   parameters for the iterative algorithm used to compute ML estimates.
%   This argument can be created by a call to STATSET.  See STATSET('wblfit')
%   for parameter names and default values.
%
%   Pass in [] for ALPHA, CENSORING, or FREQ to use their default values.
%
%   See also WBLCDF, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, MLE,
%   STATSET.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.2 $  $Date: 2004/02/01 22:10:47 $

% Illegal data return an error.
if ~isvector(x)
    error('stats:wblfit:BadData','X must be a vector.');
elseif any(x <= 0)
    error('stats:wblfit:BadData','The data in X must be positive.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 3 || isempty(censoring)
    censoring = [];
elseif ~isempty(censoring) && ~isequal(size(x), size(censoring))
    error('stats:wblfit:InputSizeMismatch',...
          'X and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = [];
elseif ~isempty(freq) && ~isequal(size(x), size(freq))
    error('stats:wblfit:InputSizeMismatch',...
          'X and FREQ must have the same size.');
end
if nargin < 5 || isempty(options)
    options = [];
end

% Fit an extreme value distribution to the logged data, then transform to
% the Weibull parameter scales.
%
% Get parameter estimates only.
if nargout == 1
    parmhatEV = evfit(log(x),alpha,censoring,freq,options);
    parmhat = [exp(parmhatEV(1)) 1./parmhatEV(2)];

% Get parameter estimates and CIs.
else
    [parmhatEV,parmciEV] = evfit(log(x),alpha,censoring,freq,options);
    parmhat = [exp(parmhatEV(1)) 1./parmhatEV(2)];
    parmci = [exp(parmciEV(:,1)) 1./parmciEV([2 1],2)];
end
