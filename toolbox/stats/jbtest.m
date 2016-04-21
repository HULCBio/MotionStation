function [H, pValue, JBstatistic, criticalValue] = jbtest(x , alpha)
%JBTEST Bera-Jarque parametric hypothesis test of composite normality.
%   H = JBTEST(X,ALPHA) performs the Bera-Jarque test to determine if the null
%   hypothesis of composite normality is a reasonable assumption regarding the
%   population distribution of a random sample X. The desired significance 
%   level, ALPHA, is an optional scalar input (default = 0.05).
%
%   H indicates the Boolean result of the hypothesis test:
%     H = 0 => Do not reject the null hypothesis at significance level ALPHA.
%     H = 1 => Reject the null hypothesis at significance level ALPHA.
% 
%   The Bera-Jarque hypotheses are: 
%   Null Hypothesis:        X is normal with unspecified mean and variance.
%   Alternative Hypothesis: X is not normally distributed.
%
%   The Bera-Jarque test is a 2-sided test of composite normality with sample
%   mean and sample variance used as estimates of the population mean and 
%   variance, respectively. The test statistic is based on estimates of the 
%   sample skewness and kurtosis of the normalized data (the standardized 
%   Z-scores computed from X by subtracting the sample mean and normalizing by
%   the sample standard deviation). Under the null hypothesis, the standardized
%   3rd and 4th moments are asymptotically normal and independent, and the test
%   statistic has a Chi-square distribution with two degrees of freedom. Note 
%   that the Bera-Jarque test is an asymptotic test, and care should be taken
%   with small sample sizes.
%
%   X is a vector representing a random sample from some underlying 
%   distribution. Missing observations in X, indicated by NaN's (Not-a-Number),
%   are ignored.
%
%   [H,P] = JBTEST(...) also returns the P-value (significance level) at 
%   which the null hypothesis is rejected.
%
%   [H,P,JBSTAT] = JBTEST(...) also returns the test statistic JBSTAT.
%
%   [H,P,JBSTAT,CV] = JBTEST(...) also returns the critical value of the 
%   test CV.
%
%   See also LILLIETEST, KSTEST, KSTEST2.
%

% Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 1.4.2.1 $   $ Date: 1998/01/30 13:45:34 $

%
% References:
%   Judge, G.G., Hill, R.C., et al, "Introduction to Theory & Practice of
%     Econometrics", 2nd edition, John Wiley & Sons, Inc., 1988, pages 890-892.
%
%   Spanos, A., "Statistical Foundations of Econometric Modelling",
%     Cambridge University Press, 1993, pages 453-455.
%

%
% Ensure the sample data is a VECTOR.
%

[rows , columns]  =  size(x);

if (rows ~= 1) & (columns ~= 1) 
    error('stats:jbtest:VectorRequired','Input sample X must be a vector.');
end

%
% Remove missing observations indicated by NaN's.
%

x  =  x(~isnan(x));

if length(x) == 0
   error('stats:jbtest:NotEnoughData',...
         'Input sample X has no valid data (all NaN''s).');
end

x  =  x(:);               % Ensure a column vector.

%
% Ensure the significance level, ALPHA, is a 
% scalar, and set default if necessary.
%

if (nargin >= 2) & ~isempty(alpha)
   if prod(size(alpha)) > 1
      error('stats:jbtest:BadAlpha',...
            'Significance level ALPHA must be a scalar.');
   end
   if (alpha <= 0 | alpha >= 1)
      error('stats:jbtest:BadAlpha',...
            'Significance level ALPHA must be between 0 and 1.'); 
   end
else
   alpha  =  0.05;
end

%
% Compute moments and test statistic.
%

n  =  length(x);              % Sample size.
x  =  (x - mean(x)) / std(x); % Standardized data (i.e., Z-scores).
J  =  sum(x.^3) / n;          % Moment 3.
B  =  (sum(x.^4) / n) - 3;    % Moment 4 (excess kurtosis).

JBstatistic =  n * ( (J^2)/6  +  (B^2)/24 );

%
% Compute the P-values (i.e., significance levels). Since the 
% CHI2INV function is a slow, iterative procedure, compute the 
% critical values ONLY if requested. Under the null hypothesis 
% of composite normality, the test statistic of the standardized 
% data is asymptotically Chi-Square distributed with 2 degrees 
% of freedom.
%

if nargout >= 4
   criticalValue  =  chi2inv(1 - alpha , 2);
end

pValue =  1 - chi2cdf(JBstatistic , 2);

%
% To maintain consistency with existing Statistics Toolbox hypothesis
% tests, returning 'H = 0' implies that we 'Do not reject the null 
% hypothesis at the significance level of alpha' and 'H = 1' implies 
% that we 'Reject the null hypothesis at significance level of alpha.'
%

H  = (alpha >= pValue);

