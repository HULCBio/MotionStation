function [H,pValue,KSstatistic] = kstest2(x1 , x2 , alpha , tail)
%KSTEST2 Two-sample Kolmogorov-Smirnov goodness-of-fit hypothesis test.
%   H = KSTEST2(X1,X2,ALPHA,TAIL) performs a Kolmogorov-Smirnov (K-S) test 
%   to determine if independent random samples, X1 and X2, are drawn from 
%   the same underlying continuous population. ALPHA and TAIL are optional
%   scalar inputs: ALPHA is the desired significance level (default = 0.05); 
%   TAIL indicates the type of test (default = 0). H indicates the result of
%   the hypothesis test:
%      H = 0 => Do not reject the null hypothesis at significance level ALPHA.
%      H = 1 => Reject the null hypothesis at significance level ALPHA.
% 
%   Let F1(x) and F2(x) be the empirical distribution functions from sample 
%   vectors X1 and X2, respectively. The 2-sample K-S test hypotheses and 
%   test statistic are:
%
%   Null Hypothesis: F1(x) = F2(x) for all x
%      For TAIL =  0 (2-sided test), alternative: F1(x) not equal to F2(x).
%      For TAIL =  1 (1-sided test), alternative: F1(x) > F2(x).
%      For TAIL = -1 (1-sided test), alternative: F1(x) < F2(x).
%
%   For TAIL = 0, 1, and -1, the test statistics are T = max|F1(x) - F2(x)|,
%   T = max[F1(x) - F2(x)], and T = max[F2(x) - F1(x)], respectively.
%
%   The decision to reject the null hypothesis occurs when the significance 
%   level, ALPHA, equals or exceeds the P-value.
%
%   X1 and X2 are row or column vectors of lengths N1 and N2, respectively, 
%   and represent random samples from some underlying distribution(s). 
%   Missing observations, indicated by NaN's (Not-a-Number), are ignored.
%
%   [H,P] = KSTEST2(...) also returns the asymptotic P-value P.
%
%   [H,P,KSSTAT] = KSTEST2(...) also returns the K-S test statistic KSSTAT
%   defined above for the test type indicated by TAIL.
%
%   The asymptotic P-value becomes very accurate for large sample sizes, and
%   is believed to be reasonably accurate for sample sizes N1 and N2 such 
%   that (N1*N2)/(N1 + N2) >= 4.
%
%   See also KSTEST, LILLIETEST, CDFPLOT.
%

% Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 1.5.2.1 $   $ Date: 1998/01/30 13:45:34 $

%
% References:
%   (1) Massey, F.J., "The Kolmogorov-Smirnov Test for Goodness of Fit",
%         Journal of the American Statistical Association, 46 (March 1956), 68-77.
%   (2) Miller, L.H., "Table of Percentage Points of Kolmogorov Statistics",
%         Journal of the American Statistical Association, (March 1951), 111-121.
%   (3) Conover, W.J., "Practical Nonparametric Statistics", 
%         John Wiley & Sons, Inc., 1980.
%   (4) Press, W.H., et. al., "Numerical Recipes in C", 
%         Cambridge University Press, 1992.
 
if nargin < 2
    error('stats:kstest2:TooFewInputs','At least 2 inputs are required.');
end

%
% Ensure each sample is a VECTOR.
%

[rows1 , columns1]  =  size(x1);
[rows2 , columns2]  =  size(x2);

if (rows1 ~= 1) & (columns1 ~= 1) 
    error('stats:kstest2:VectorRequired','Sample X1 must be a vector.');
end

if (rows2 ~= 1) & (columns2 ~= 1) 
    error('stats:kstest2:VectorRequired','Sample X2 must be a vector.');
end

%
% Remove missing observations indicated by NaN's, and 
% ensure that valid observations remain.
%

x1  =  x1(~isnan(x1));
x2  =  x2(~isnan(x2));
x1  =  x1(:);
x2  =  x2(:);

if isempty(x1)
   error('stats:kstest2:NotEnoughData',...
         'Sample vector X1 is composed of all NaN''s.');
end

if isempty(x2)
   error('stats:kstest2:NotEnoughData',...
         'Sample vector X2 is composed of all NaN''s.');
end

%
% Ensure the significance level, ALPHA, is a scalar 
% between 0 and 1 and set default if necessary.
%

if (nargin >= 3) & ~isempty(alpha)
   if prod(size(alpha)) > 1
      error('stats:kstest2:BadAlpha',...
            'Significance level ALPHA must be a scalar.');
   end
   if (alpha <= 0 | alpha >= 1)
      error('stats:kstest2:BadAlpha',...
            'Significance level ALPHA must be between 0 and 1.'); 
   end
else
   alpha  =  0.05;
end

%
% Ensure the type-of-test indicator, TAIL, is a scalar integer from 
% the allowable set {-1 , 0 , 1}, and set default if necessary.
%

if (nargin >= 4) & ~isempty(tail)
   if prod(size(tail)) > 1
      error('stats:kstest2:BadTail',...
            'Type-of-test indicator TAIL must be a scalar.');
   end
   if (tail ~= -1) & (tail ~= 0) & (tail ~= 1)
      error('stats:kstest2:BadTail',...
            'Type-of-test indicator TAIL must be -1, 0, or 1.');
   end
else
   tail  =  0;
end

%
% Calculate F1(x) and F2(x), the empirical (i.e., sample) CDFs.
%

binEdges    =  [-inf ; sort([x1;x2]) ; inf];

binCounts1  =  histc (x1 , binEdges);
binCounts2  =  histc (x2 , binEdges);

sumCounts1  =  cumsum(binCounts1)./sum(binCounts1);
sumCounts2  =  cumsum(binCounts2)./sum(binCounts2);

sampleCDF1  =  sumCounts1(1:end-1);
sampleCDF2  =  sumCounts2(1:end-1);

%
% Compute the test statistic of interest.
%

switch tail
   case  0      %  2-sided test: T = max|F1(x) - F2(x)|.
      deltaCDF  =  abs(sampleCDF1 - sampleCDF2);

   case -1      %  1-sided test: T = max[F2(x) - F1(x)].
      deltaCDF  =  sampleCDF2 - sampleCDF1;

   case  1      %  1-sided test: T = max[F1(x) - F2(x)].
      deltaCDF  =  sampleCDF1 - sampleCDF2;
end

KSstatistic   =  max(deltaCDF);

%
% Compute the asymptotic P-value approximation and accept or
% reject the null hypothesis on the basis of the P-value.
%

n1     =  length(x1);
n2     =  length(x2);
n      =  n1 * n2 /(n1 + n2);
lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);

if tail ~= 0        % 1-sided test.

   pValue  =  exp(-2 * lambda * lambda);

else                % 2-sided test (default).
%
%  Use the asymptotic Q-function to approximate the 2-sided P-value.
%
   j       =  [1:101]';
   pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));

   if pValue < 0 , pValue = 0; end
   if pValue > 1 , pValue = 1; end

end

H  =  (alpha >= pValue);
