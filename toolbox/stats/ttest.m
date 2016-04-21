function [h,p,ci,stats] = ttest(x,m,alpha,tail)
%TTEST  One-sample and paired-sample T-test.
%   H = TTEST(X) performs a T-test of the hypothesis that the data in the
%   vector X come from a distribution with mean zero, and returns the
%   result of the test in H.  H==0 indicates that the null hypothesis
%   ("mean is zero") cannot be rejected at the 5% significance level.  H==1
%   indicates that the null hypothesis can be rejected at the 5% level.  The
%   data are assumed to come from a normal distribution with unknown
%   variance.
%
%   H = TTEST(X,M) performs a T-test of the hypothesis that the data in the
%   vector X come from a distribution with mean M.
%
%   H = TTEST(X,Y) performs a paired T-test of the hypothesis that two
%   matched samples, in the vectors X and Y, come from distributions with
%   equal means.  The difference X-Y is assumed to come from a normal
%   distribution with unknown variance.  X and Y must have the same length.
%
%   H = TTEST(...,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.
%
%   H = TTEST(...,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "mean is not zero (or M)" (two-tailed test)
%       'right' -- "mean is greater than zero (or M)" (right-tailed test)
%       'left'  -- "mean is less than zero (or M)" (left-tailed test)
%
%   [H,P] = TTEST(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = TTEST(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true mean of X, or of X-Y for a paired test.
%
%   [H,P,CI,STATS] = TTEST(...) returns a structure with the following fields:
%      'tstat' -- the value of the test statistic
%      'df'    -- the degrees of freedom of the test
%      'sd'    -- the estimated population standard deviation.  For a
%                 paired test, this is the std. dev. of X-Y.
%
%   See also TTEST2, ZTEST, SIGNTEST, SIGNRANK.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, page 206.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.15.4.2 $  $Date: 2004/01/24 09:37:09 $

[m1 n1] = size(x);
if m1 ~= 1 && n1 ~= 1
    error('stats:ttest:BadData','X must be a vector.');
end

if nargin < 2 || isempty(m)
    m = 0;
elseif numel(m) > 1 % paired t-test
    if ~isequal(size(m),size(x))
        error('stats:ttest:InputSizeMismatch',...
              'The data vectors in a paired t-test must be the same length.');
    end
    x = x - m;
    m = 0;
end
x = x(~isnan(x));

if nargin < 3 || isempty(alpha)
    alpha = 0.05;
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('stats:ttest:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 4 || isempty(tail)
    tail = 0;
else
    if ischar(tail)
        tail = strmatch(lower(tail), {'left','both','right'}) - 2;
        if isempty(tail)
            error('stats:ttest:BadTail',...
                  'TAIL must be ''both'', ''right'', or ''left''.');
        end
    end
end

samplesize  = length(x);
xmean = mean(x);
sdpop = std(x);
ser = sdpop ./ sqrt(samplesize);
tval = (xmean - m) / ser;
if (nargout > 3), stats = struct('tstat', tval, 'df', samplesize-1, 'sd', sdpop); end

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = 2 * tcdf(-abs(tval), samplesize - 1);
    if nargout > 2
        crit = tinv((1 - alpha / 2), samplesize - 1) .* ser;
        ci = [(xmean - crit) (xmean + crit)];
    end
elseif tail == 1 % right one-tailed test
    p = tcdf(-tval, samplesize - 1);
    if nargout > 2
        crit = tinv(1 - alpha, samplesize - 1) .* ser;
        ci = [(xmean - crit), Inf];
    end
elseif tail == -1 % left one-tailed test
    p = tcdf(tval, samplesize - 1);
    if nargout > 2
        crit = tinv(1 - alpha, samplesize - 1) .* ser;
        ci = [-Inf, (xmean + crit)];
    end
else
    error('stats:ttest:BadTail',...
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
