function [H,pValue,KSstatistic,criticalValue] = kstest(x , CDF , alpha , tail)
%KSTEST Single sample Kolmogorov-Smirnov goodness-of-fit hypothesis test.
%   H = KSTEST(X,CDF,ALPHA,TAIL) performs a Kolmogorov-Smirnov (K-S) test 
%   to determine if a random sample X could have the hypothesized, continuous 
%   cumulative distribution function CDF. CDF is optional: if omitted or 
%   unspecified (i.e., set to an empty matrix []), the hypothetical c.d.f is 
%   assumed to be a standard normal, N(0,1). ALPHA and TAIL are optional 
%   scalar inputs: ALPHA is the desired significance level (default = 0.05);
%   TAIL indicates the type of test (default = 0). H indicates the result of 
%   the hypothesis test:
%      H = 0 => Do not reject the null hypothesis at significance level ALPHA.
%      H = 1 => Reject the null hypothesis at significance level ALPHA.
% 
%   Let S(x) be the empirical c.d.f. estimated from the sample vector X, F(x) 
%   be the corresponding true (but unknown) population c.d.f., and CDF be the
%   known input c.d.f. specified under the null hypothesis.
% 
%   Null Hypothesis: F(x) equal to CDF for all x.
%      For TAIL =  0 (2-sided test), alternative: F(x) not equal to CDF.
%      For TAIL =  1 (1-sided test), alternative: F(x) greater than CDF.
%      For TAIL = -1 (1-sided test), alternative: F(x) less than CDF.
%
%   For TAIL = 0, 1, and -1, the K-S test statistics are T = max|S(x) - CDF|,
%   T = max[S(x) - CDF], and T = max[CDF - S(x)], respectively.
%
%   X may be a row or column vector representing a random sample from some
%   underlying distribution. Missing observations in X, indicated by NaN's 
%   (Not-a-Number), are ignored.
%
%   CDF is the c.d.f. under the null hypothesis. If specified, it must be an 
%   explicit 2-column matrix of paired (x,y) values. Column 1 contains the 
%   x-axis data, column 2 the corresponding y-axis c.d.f data. Since the K-S
%   test statistic will occur at one of the observations in X, the calculation 
%   is most efficient when CDF is only specified at the observations in X. 
%   When column 1 of CDF represents x-axis points independent of X, CDF is 
%   're-sampled' at the observations found in the vector X via interpolation. 
%   In this case, the interval along the x-axis (the column 1 spread of CDF)
%   must span the observations in X for successful interpolation. 
%
%   [H,P] = KSTEST(...) also returns the asymptotic P-value P.
%
%   [H,P,KSSTAT] = KSTEST(...) also returns the K-S test statistic KSSTAT
%   defined above for the test type indicated by TAIL.
%
%   [H,P,KSSTAT,CV] = KSTEST(...) returns the critical value of the test CV.
%
%   In general, the decision to reject the null hypothesis is based on the 
%   critical value. When CV = NaN, the decision has been based on the P-value.
%
%   See also KSTEST2, LILLIETEST, CDFPLOT.
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

%
% Ensure the significance level, ALPHA, is a scalar 
% between 0 and 1 and set default if necessary.
%

if (nargin >= 3) & ~isempty(alpha)
   if prod(size(alpha)) > 1
      error('stats:kstest:BadAlpha',...
            'Significance level ALPHA must be a scalar.');
   end
   if (alpha <= 0 | alpha >= 1)
      error('stats:kstest:BadAlpha',...
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
      error('stats:kstest:BadAlpha',...
            'Type-of-test indicator TAIL must be a scalar.');
   end
   if (tail ~= -1) & (tail ~= 0) & (tail ~= 1)
      error('stats:kstest:BadAlpha',...
            'Type-of-test indicator TAIL must be -1, 0, or 1.');
   end
else
   tail  =  0;
end

% Get sample cdf, display error message if any
[sampleCDF,x,n,emsg,eid] = cdfcalc(x);
if ~isempty(eid)
   error(sprintf('stats:kstest:%s',eid),emsg);
end

% Check & scrub the hypothesized CDF specified under the null hypothesis.
% If CDF has been specified, remove any rows with NaN's in them and sort 
% x-axis data found in column 1 of CDF. If CDF has not been specified, then
% allow the convenience of x ~ N(0,1) under the null hypothesis.
%

if (nargin >= 2) & ~isempty(CDF)
   if size(CDF,2) ~= 2
      error('stats:kstest:BadCdf',...
            'Hypothesized CDF matrix must have 2 columns.');
   end

   CDF  =  CDF(~isnan(sum(CDF,2)),:);

   if size(CDF,1) == 0
      error('stats:kstest:BadCdf',...
            'Hypothesized CDF matrix must have at least 1 valid row.');
   end
   
   [xCDF,i] =  sort(CDF(:,1));    % Sort the theoretical CDF.
   yCDF = CDF(i,2);
   
   ydiff = diff(yCDF);
   if (any(ydiff<0))
      error('stats:kstest:BadCdf',...
            'CDF must define an increasing function of X.');
   end
   
   % Remove duplicates, but it's an error if they are not consistent
   dups = find(diff(xCDF) == 0);
   if (~isempty(dups))
      if (~all(ydiff(dups) == 0))
         error('stats:kstest:BadCdf',...
               'CDF must not have duplicate X values.');
      end
      xCDF(dups) = [];
      yCDF(dups) = [];
   end
else
   xCDF = x;
   yCDF = normcdf(x,0,1);
end

%
% If CDF's x-axis values have been specified by the data sample X, then just
% assign column 2 to the null CDF; if not, then we interpolate subject to the 
% check that the x-axis interval of CDF must bound the observations in X. Note
% that both X and CDF have been sorted and have had NaN's removed.
%

if isequal(x,xCDF)
   nullCDF  =  yCDF;       % CDF has been specified at the observations in X.
else
   if (x(1) < xCDF(1)) | (x(end) > xCDF(end))
     error('stats:kstest:BadCdf',...
         'Hypothesized CDF matrix must span the observations interval in X.'); 
   end
   nullCDF  =  interp1(xCDF, yCDF, x, 'linear');
end

%
% Compute the test statistic of interest.
%

switch tail

   case  0      %  2-sided test: T = max|S(x) - CDF(x)|.
      delta1    =  sampleCDF(1:end-1) - nullCDF;   % Vertical difference at jumps approaching from the LEFT.
      delta2    =  sampleCDF(2:end)   - nullCDF;   % Vertical difference at jumps approaching from the RIGHT.
      deltaCDF  =  abs([delta1 ; delta2]);
      alpha1    =  alpha / 2;

   case -1      %  1-sided test: T = max[CDF(x) - S(x)].
      delta1    =  nullCDF - sampleCDF(1:end-1);   % Vertical difference at jumps approaching from the LEFT.
      delta2    =  nullCDF - sampleCDF(2:end);     % Vertical difference at jumps approaching from the RIGHT.
      deltaCDF  =  [delta1 ; delta2];
      alpha1    =  alpha;

   case  1      %  1-sided test: T = max[S(x) - CDF(x)].
      delta1    =  sampleCDF(1:end-1) - nullCDF;   % Vertical difference at jumps approaching from the LEFT.
      delta2    =  sampleCDF(2:end)   - nullCDF;   % Vertical difference at jumps approaching from the RIGHT.
      deltaCDF  =  [delta1 ; delta2];
      alpha1    =  alpha;

end

KSstatistic   =  max(deltaCDF);

%
% For 0.005 <= alpha <= 0.10 (1-sided tests) and 0.01 <= alpha <= 0.20 
% (2-sided tests), Miller's table for n <= 20 (small sample) is exact; 
% for n > 20 (large sample) his approximation is thought to be accurate
% to the 5th decimal place. Thus, if the significance level, alpha, is 
% covered by Miller's table (which will almost always be the case!), then 
% base the acceptance or rejection of the test on the critical value.
% If alpha is NOT covered by Miller's table, then base the acceptance 
% or rejection of the test on the P-value instead.
%

H  =  [];

if (alpha1 >= 0.005) & (alpha1 <= 0.10)

%
%  Calculate the critical value which 'KSstatistic' must exceed for the null
%  hypothesis to be rejected. If the sample size 'n' is greater than 20, use
%  Miller's approximation; otherwise interpolate into his 'exact' table.
%

   if n <= 20        % Small sample exact values.

%
%     Exact K-S test critical values are solutions of an nth order polynomial.
%     Miller's approximation is excellent for sample sizes n > 20. For n <= 20,
%     Miller tabularized the exact critical values by solving the nth order 
%     polynomial. These exact values for n <= 20 are hard-coded into the matrix
%     'exact' shown below. Note that the table shown below is expressed in 
%     reference to a 1-sided significance level. Rows 1,2,...20 correspond to
%     sample sizes n = 1,2,...20, respectively.
%

      a1    = [0.00500  0.01000  0.02500  0.05000  0.10000]';  % 1-sided test Alphas.

      exact = [0.99500  0.99000  0.97500  0.95000  0.90000
               0.92929  0.90000  0.84189  0.77639  0.68377
               0.82900  0.78456  0.70760  0.63604  0.56481
               0.73424  0.68887  0.62394  0.56522  0.49265
               0.66853  0.62718  0.56328  0.50945  0.44698
               0.61661  0.57741  0.51926  0.46799  0.41037
               0.57581  0.53844  0.48342  0.43607  0.38148
               0.54179  0.50654  0.45427  0.40962  0.35831
               0.51332  0.47960  0.43001  0.38746  0.33910
               0.48893  0.45662  0.40925  0.36866  0.32260
               0.46770  0.43670  0.39122  0.35242  0.30829
               0.44905  0.41918  0.37543  0.33815  0.29577
               0.43247  0.40362  0.36143  0.32549  0.28470
               0.41762  0.38970  0.34890  0.31417  0.27481
               0.40420  0.37713  0.33760  0.30397  0.26588
               0.39201  0.36571  0.32733  0.29472  0.25778
               0.38086  0.35528  0.31796  0.28627  0.25039
               0.37062  0.34569  0.30936  0.27851  0.24360
               0.36117  0.33685  0.30143  0.27136  0.23735
               0.35241  0.32866  0.29408  0.26473  0.23156];

      criticalValue  =  interp1(a1 , exact(n,:)' , alpha1 , 'linear');

   else                 % Large sample approximate values.
%
%     In Miller's formula for A(alpha), 'alpha' represents a 1-sided significance level.
%
      A              =  0.09037*(-log10(alpha1)).^1.5 + 0.01515*log10(alpha1).^2 - 0.08467*alpha1 - 0.11143;
      asymptoticStat =  sqrt(-0.5*log(alpha1)./n);
      criticalValue  =  asymptoticStat - 0.16693./n - A./n.^1.5;
      criticalValue  =  min(criticalValue , 1 - alpha1);

   end

%
%  To maintain consistency with existing Statistics Toolbox hypothesis
%  tests, returning "H = 0" implies that we "Do not reject the null 
%  hypothesis at the significance level of alpha" and "H = 1" implies 
%  that we "Reject null hypothesis at significance level of alpha."
%

   H  =  (KSstatistic > criticalValue);

end

%
% Compute the asymptotic P-value approximation (if requested) and accept 
% or reject the null hypothesis on the basis of the P-value if the decision
% has not already been made.
%

if (nargout >= 2) | isempty(H)

   lambda  =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);

   if tail ~= 0        % 1-sided test.

      pValue  =  exp(-2 * lambda * lambda);

   else                % 2-sided test (default).
%
%     Use the asymptotic Q-function to approximate the 2-sided P-value.
%
      j       =  (1:101)';
      pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));

      if pValue < 0 , pValue = 0; end
      if pValue > 1 , pValue = 1; end

   end

   if isempty(H)
      H              =  (alpha >= pValue);
      criticalValue  =  NaN;
   end

end
