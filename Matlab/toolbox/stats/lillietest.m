function [H,pValue,KSstatistic,criticalValue] = lillietest(x , alpha)
%LILLIETEST Single sample Lilliefors hypothesis test of composite normality.
%   H = LILLIETEST(X,ALPHA) performs the Lilliefors modification of the 
%   Kolmogorov-Smirnov test to determine if the null hypothesis of composite
%   normality is a reasonable assumption regarding the population distribution
%   of a random sample X. The desired significance level, ALPHA, is an optional
%   scalar input (default = 0.05). The Lilliefors test is based on simulation, 
%   so the significance level is restricted to 0.01 <= ALPHA <= 0.20 (the 
%   region tabularized by Lilliefors).
%
%   H indicates the result of the hypothesis test:
%     H = 0 => Do not reject the null hypothesis at significance level ALPHA.
%     H = 1 => Reject the null hypothesis at significance level ALPHA.
% 
%   Let S(x) be the empirical c.d.f. estimated from the sample vector X, F(x) 
%   be the corresponding true (but unknown) population c.d.f., and CDF be a
%   normal c.d.f. with sample mean and standard deviation taken from X. The 
%   Lilliefors hypotheses and test statistic are:
% 
%   Null Hypothesis:        F(x) is normal with unspecified mean and variance.
%   Alternative Hypothesis: F(x) is not normally distributed.
%
%   Test Statistic:         T = max|S(x) - CDF|.
%
%   The decision to reject the null hypothesis occurs when the test statistic
%   exceeds the critical value. 
%
%   The Lilliefors test is a 2-sided test of composite normality with sample 
%   mean and sample variance used as estimates of the population mean and 
%   variance, respectively. The test statistic is based on the 'normalized'
%   samples (i.e., the Z-scores computed by subtracting the sample mean and
%   normalizing by the sample standard deviation).
%
%   X may be a row or column vector representing a random sample from some
%   underlying distribution. Missing observations in X, indicated by NaN's 
%   (Not-a-Number), are ignored.
%
%   [H,P] = LILLIETEST(...) also returns the approximate P-value P, computed
%   via interpolation into the Lilliefors simulation table. A NaN is 
%   returned when P is not found within the interval 0.01 <= P <= 0.20.
%
%   [H,P,LSTAT] = LILLIETEST(...) also returns the test statistic LSTAT, the 
%   largest absolute vertical deviation of S(x) from CDF.
%
%   [H,P,LSTAT,CV] = LILLIETEST(...) also returns the critical value of the 
%   test CV.
%
%   See also KSTEST, KSTEST2, CDFPLOT.
%

% Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 1.4.2.2 $   $ Date: 1998/01/30 13:45:34 $


% References:
%   Conover, W.J., "Practical Nonparametric Statistics", 
%     John Wiley & Sons, Inc., 1980.

%
% Ensure the sample data is a VECTOR.
%

[rows , columns]  =  size(x);

if (rows ~= 1) & (columns ~= 1) 
    error('stats:lillietest:VectorRequired',...
          ' Input sample X must be a vector.');
end

%
% Remove missing observations indicated by NaN's, and ensure that
% at least 4 valid observations remain.
%

x  =  x(~isnan(x));       % Remove missing observations indicated by NaN's.
x  =  x(:);               % Ensure a column vector.

if length(x) < 4
   error('stats:lillietest:NotEnoughData',...
         'Sample vector X must have at least 4 valid observations.');
end

%
% Ensure the significance level, ALPHA, is a scalar between the significance 
% levels of Lilliefors' simulation, and set default if necessary.
%

if (nargin >= 2) & ~isempty(alpha)
   if prod(size(alpha)) > 1
      error('stats:lillietest:BadAlpha',...
            'Significance level ALPHA must be a scalar.');
   end
   if (alpha < 0.01) | (alpha > 0.20)
      error('stats:lillietest:BadAlpha',...
            'Significance level ALPHA must in [0.01,0.2].');
   end
else
   alpha  =  0.05;
end

%
% Calculate S(x), the sample CDF.
%

[sampleCDF,xCDF,n,emsg,eid] = cdfcalc(x);
if ~isempty(eid)
   error(sprintf('stats:lillietest:%s',eid),emsg);
end

%
% Compute the critical value upon which to 
% base the acceptance or rejection of the test.
%

a  =  [0.010  0.050  0.100  0.150  0.200]';  % Lilliefors' Alphas.

if n <= 30

   sampleSize =  [4:20 25 30]'; % Sample sizes for each row of 'quantiles'.

   quantiles  =  [0.417  0.381  0.352  0.319  0.300
                  0.405  0.337  0.315  0.299  0.285
                  0.364  0.319  0.294  0.277  0.265
                  0.348  0.300  0.276  0.258  0.247
                  0.331  0.285  0.261  0.244  0.233
                  0.311  0.271  0.249  0.233  0.223
                  0.294  0.258  0.239  0.224  0.215
                  0.284  0.249  0.230  0.217  0.206
                  0.275  0.242  0.223  0.212  0.199
                  0.268  0.234  0.214  0.202  0.190
                  0.261  0.227  0.207  0.194  0.183
                  0.257  0.220  0.201  0.187  0.177
                  0.250  0.213  0.195  0.182  0.173
                  0.245  0.206  0.189  0.177  0.169
                  0.239  0.200  0.184  0.173  0.166
                  0.235  0.195  0.179  0.169  0.163
                  0.231  0.190  0.174  0.166  0.160
                  0.200  0.173  0.158  0.147  0.142
                  0.187  0.161  0.144  0.136  0.131];
%
%  Determine the interpolated 'row' of quantiles.
%
   Q  =  interp2(a , sampleSize, quantiles , a , n , 'linear');

%
%  Now compute the critical value.
%
   criticalValue  =  interp1(a , Q , alpha , 'linear');

else

%
%  Determine the asymptotic 'row' of quantiles.
%
   Q  =  [1.031 0.886 0.805 0.768 0.736] / sqrt(n);

%
%  1-D interpolation into Lilliefors' asymptotic expression.
%
   criticalValue  =  interp1(a , Q , alpha , 'linear');

end

%
% The theoretical CDF specified under the null hypothesis 
% is assumed to be normal (i.e., Gaussian).
%

zScores  =  (xCDF - mean(x))./std(x);
nullCDF  =  normcdf(zScores , 0 , 1);

%
% Compute the test statistic of interest: T = max|S(x) - nullCDF(x)|.
%

delta1    =  sampleCDF(1:end-1) - nullCDF;   % Vertical difference at jumps approaching from the LEFT.
delta2    =  sampleCDF(2:end)   - nullCDF;   % Vertical difference at jumps approaching from the RIGHT.
deltaCDF  =  abs([delta1 ; delta2]);

KSstatistic =  max(deltaCDF);

%
% Compute the approximate P-value. A NaN is returned if the P-value 
% is not found within the available 'Alphas' of Lilliefors' table.
%

pValue  =  interp1(Q , a , KSstatistic , 'linear');

%
% To maintain consistency with existing Statistics Toolbox hypothesis
% tests, returning "H = 0" implies that we "Do not reject the null 
% hypothesis at the significance level of alpha" and "H = 1" implies 
% that we "Reject the null hypothesis at significance level of alpha."
%

H  =  (KSstatistic > criticalValue);
