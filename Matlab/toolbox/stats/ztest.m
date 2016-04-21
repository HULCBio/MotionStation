function [h,p,ci,zval] = ztest(x,m,sigma,alpha,tail)
%ZTEST  One-sample Z-test.
%   H = ZTEST(X,M,SIGMA) performs a Z-test of the hypothesis that the data
%   in the vector X come from a distribution with mean M, and returns the
%   result of the test in H.  H==0 indicates that the null hypothesis
%   ("mean is M") cannot be rejected at the 5% significance level.  H==1
%   indicates that the null hypothesis can be rejected at the 5% level.  The
%   data are assumed to come from a normal distribution with standard
%   deviation SIGMA.
%
%   H = ZTEST(X,M,SIGMA,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.
%
%   H = ZTEST(X,M,SIGMA,ALPHA,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "mean is not M" (two-tailed test)
%       'right' -- "mean is greater than M" (right-tailed test)
%       'left'  -- "mean is less than M" (left-tailed test)
%
%   [H,P] = ZTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = ZTEST(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true mean.
%
%   [H,P,CI,ZVAL] = ZTEST(...) returns the value of the test statistic.
%
%   See also TTEST, SIGNTEST, SIGNRANK.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, page 206.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.15.4.1 $  $Date: 2003/11/01 04:29:53 $

if nargin < 3,
    error('stats:ztest:TooFewInputs',...
          'Requires at least three input arguments.');
end

[m1 n1] = size(x);
if m1 ~= 1 && n1 ~= 1
    error('stats:ztest:InvalidData','X must be a vector.');
end
x = x(~isnan(x));

if numel(m) ~= 1
    error('stats:ztest:NonScalarM','M must be a scalar.');
end
if numel(sigma) ~= 1
    error('stats:ztest:NonScalarSigma','SIGMA must be a scalar.');
end

if nargin < 4 || isempty(alpha)
    alpha = 0.05;
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('stats:ztest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 5 || isempty(tail)
    tail = 0;
else
    if ischar(tail)
        tail = strmatch(lower(tail), {'left','both','right'}) - 2;
        if isempty(tail)
            error('stats:ztest:BadTail',...
                  'TAIL must be ''both'', ''right'', or ''left''.');
        end
    end
end

samplesize  = length(x);
xmean = mean(x);
ser = sigma ./ sqrt(samplesize);
zval = (xmean - m) ./ ser;

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = 2 * normcdf(-abs(zval),0,1);
    if nargout > 2
        crit = norminv(1 - alpha/2, 0, 1) .* ser;
        ci = [(xmean - crit) (xmean + crit)];
    end
elseif tail == 1 % right one-tailed test
    p = normcdf(-zval,0,1);
    if nargout > 2
        crit = norminv(1 - alpha, 0, 1) .* ser;
        ci = [(xmean - crit), Inf];
    end
elseif tail == -1 % left one-tailed test
    p = normcdf(zval,0,1);
    if nargout > 2
        crit = norminv(1 - alpha, 0, 1) .* ser;
        ci = [-Inf, (xmean + crit)];
    end
else
    error('stats:ztest:BadTail',...
          'TAIL must be ''both'', ''right'', or ''left'', or 0, 1, or -1.');
end

% Determine if the actual significance exceeds the desired significance
if p <= alpha
    h = 1;
elseif p > alpha
    h = 0;
else % isnan(p) must be true
    h = NaN;
end
