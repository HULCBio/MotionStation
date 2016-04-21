function [h,p,ci,stats] = ttest2(x,y,alpha,tail,vartype)
%TTEST2 Two-sample T-test with pooled or unpooled variance estimate.
%   H = TTEST2(X,Y) performs a T-test of the hypothesis that two
%   independent samples, in the vectors X and Y, come from distributions
%   with equal means, and returns the result of the test in H.  H==0
%   indicates that the null hypothesis ("means are equal") cannot be
%   rejected at the 5% significance level.  H==1 indicates that the null
%   hypothesis can be rejected at the 5% level.  The data are assumed to
%   come from normal distributions with unknown, but equal, variances.  X
%   and Y can have different lengths.
%
%   H = TTEST2(X,Y,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.
%
%   H = TTEST2(X,Y,ALPHA,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "means are not equal" (two-tailed test)
%       'right' -- "mean of X is greater than mean of Y" (right-tailed test)
%       'left'  -- "mean of X is less than mean of Y" (left-tailed test)
%
%   H = TTEST2(X,Y,ALPHA,TAIL,'unequal') performs the test assuming that
%   the two samples come from normal distributions with unknown and unequal
%   variances.  This is known as the Behrens-Fisher problem.  TTEST2 uses
%   Satterthwaite's approximation for the effective degrees of freedom.
%
%   [H,P] = TTEST2(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = TTEST2(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true mean of the difference X-Y.
%
%   [H,P,CI,STATS] = TTEST2(...) returns a structure with the following fields:
%      'tstat' -- the value of the test statistic
%      'df'    -- the degrees of freedom of the test
%      'sd'    -- the pooled estimate of the population standard deviation
%                 (for the equal variance case) or a vector containing the unpooled
%                 estimates of the population standard deviations (for the unequal
%                 variance case)
%
%   See also TTEST, RANKSUM.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, section 13.4. (Table 13.4.1 on page 210)

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.15.4.2 $  $Date: 2004/01/24 09:37:10 $

if nargin < 2,
    error('stats:ttest2:TooFewInputs','Requires at least two input arguments');
end

[m1 n1] = size(x);
[m2 n2] = size(y);
if (m1 ~= 1 && n1 ~= 1) || (m2 ~= 1 && n2 ~= 1)
    error('stats:ttest2:InvalidData','X and Y must be vectors.');
end
x = x(~isnan(x));
y = y(~isnan(y));

if nargin < 3 || isempty(alpha)
    alpha = 0.05;
elseif numel(alpha) ~= 1 || alpha <= 0 || alpha >= 1
    error('stats:ttest2:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 4 || isempty(tail)
    tail = 0;
else
    if ischar(tail)
        tail = strmatch(lower(tail), {'left','both','right'}) - 2;
        if isempty(tail)
            error('stats:ttest2:BadTail',...
                  'TAIL must be ''both'', ''right'', or ''left''.');
        end
    end
end

if nargin < 5 || isempty(vartype)
    vartype = 1;
else
    if ischar(vartype)
        vartype = strmatch(lower(vartype), {'equal','unequal'});
        if isempty(vartype)
            error('stats:ttest2:BadVarType',...
                  'VARTYPE must be ''equal'' or ''unequal''.');
        end
    end
end

nx = length(x);
ny = length(y);
s2x = var(x);
s2y = var(y);
difference = mean(x) - mean(y);
if vartype == 1 % equal variances
    dfe = nx + ny - 2;
    sPooled = sqrt(((nx-1) .* s2x + (ny-1) .* s2y) ./ dfe);
    se = sPooled .* sqrt(1./nx + 1./ny);
    ratio = difference ./ se;

    if (nargout>3), stats = struct('tstat', ratio, 'df', dfe, 'sd', sPooled); end
elseif vartype == 2 % unequal variances
    s2xbar = s2x ./ nx;
    s2ybar = s2y ./ ny;
    dfe = (s2xbar + s2ybar) .^2 ./ (s2xbar.^2 ./ (nx-1) + s2ybar.^2 ./ (ny-1));
    se = sqrt(s2xbar + s2ybar);
    ratio = difference ./ se;

    if (nargout>3), stats = struct('tstat', ratio, 'df', dfe, 'sd', sqrt([s2x s2y])); end
else
    error('stats:ttest2:BadVarType',...
          'VARTYPE must be ''equal'' or ''unequal'', or 1 or 2.');
end

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = 2 * tcdf(-abs(ratio),dfe);
    if nargout > 2
        spread = tinv(1 - alpha ./ 2, dfe) .* se;
        ci = [(difference - spread) (difference + spread)];
    end
elseif tail == 1 % right one-tailed test
    p = tcdf(-ratio,dfe);
    if nargout > 2
        spread = tinv(1 - alpha, dfe) .* se;
        ci = [(difference - spread), Inf];
    end
elseif tail == -1 % left one-tailed test
    p = tcdf(ratio,dfe);
    if nargout > 2
        spread = tinv(1 - alpha, dfe) .* se;
        ci = [-Inf, (difference + spread)];
    end
else
    error('stats:ttest2:BadTail',...
          'TAIL must be ''both'', ''right'', or ''left'', or 0, 1, or -1.');
end

% Determine if the actual significance exceeds the desired significance
if p <= alpha,
    h = 1;
elseif p > alpha
    h = 0;
else % isnan(p) must be true
    h = NaN;
end
