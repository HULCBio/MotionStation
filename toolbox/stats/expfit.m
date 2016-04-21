function [parmhat, parmci] = expfit(x,alpha,censoring,freq)
%EXPFIT Parameter estimates and confidence intervals for exponential data.
%   PARMHAT = EXPFIT(X) returns the maximum likelihood estimate of the
%   location parameter, mu, of the exponential distribution given the data
%   in X.  If X is a matrix, EXPFIT returns a separate parameter estimate
%   for each column of X.
%
%   [PARMHAT,PARMCI] = EXPFIT(X) returns a 95% confidence interval for the
%   parameter estimate(s).
%
%   [PARMHAT,PARMCI] = EXPFIT(X,ALPHA) returns a 100(1-ALPHA) percent
%   confidence interval for the parameter estimate(s).
%
%   The following syntaxes require that X be a vector.
%
%   [...] = EXPFIT(X,ALPHA,CENSORING) accepts a boolean vector of the same
%   size as X that is 1 for observations that are right-censored and 0 for
%   observations that are observed exactly.
%
%   [...] = EXPFIT(X,ALPHA,CENSORING,FREQ) accepts a frequency vector of
%   the same size as X.  FREQ typically contains integer frequencies for
%   the corresponding elements in X, but may contain any non-integer
%   non-negative values.
%
%   Pass in [] for ALPHA, CENSORING, or FREQ to use their default values.
%
%   See also EXPCDF, EXPINV, EXPLIKE, EXPPDF, EXPRND, EXPSTAT, MLE.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.4.4 $  $Date: 2004/04/16 22:22:00 $

% Illegal data return an error.
if ~isvector(x)
    if nargin < 3
        % Accept matrix data under the 2-arg syntax.  censoring and freq
        % will be scalar zero and one.
        n = size(x,1); % a scalar -- all columns have same number of data
    else
        error('stats:expfit:VectorRequired','X must be a vector.');
    end
else
    n = numel(x);
end
if any(x(:) < 0)
    error('stats:expfit:BadData','The data in X must be non-negative.');
end

if nargin < 2 || isempty(alpha)
    alpha = 0.05;
end
if nargin < 3 || isempty(censoring)
    censoring = 0; % make this a scalar, will expand when needed
elseif ~isempty(censoring) && ~isequal(size(x), size(censoring))
    error('stats:expfit:InputSizeMismatch',...
          'X and CENSORING must have the same size.');
end
if nargin < 4 || isempty(freq)
    freq = 1; % make this a scalar, will expand when needed
elseif ~isempty(freq) && ~isequal(size(x), size(freq))
    error('stats:expfit:InputSizeMismatch',...
          'X and FREQ must have the same size.');
else
    n = sum(freq);
end

% Overwrite Infs in the data to create NaN outputs.
x(~isfinite(x)) = NaN;

nunc = n - sum(freq.*censoring); % a scalar in all cases
sumx = sum(freq.*x);

if nunc > 0
    parmhat = sumx ./ nunc;
    if nargout > 1
        gamcrit = gaminv([alpha/2 1-alpha/2], nunc, 1);
        parmci = [nunc.*parmhat ./ gamcrit(2);
                  nunc.*parmhat./ gamcrit(1)];
    end
else
    parmhat = NaN(size(sumx),class(x));
    parmci = NaN(2,size(sumx,2),class(x));
end
