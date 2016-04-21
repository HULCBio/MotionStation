function p = tcdf(x,v)
%TCDF   Student's T cumulative distribution function (cdf).
%   P = TCDF(X,V) computes the cdf for Student's T distribution
%   with V degrees of freedom, at the values in X.
%
%   The size of P is the common size of X and V. A scalar input
%   functions as a constant matrix of the same size as the other input.

%   References:
%      [1] M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.7.
%      [2] L. Devroye, "Non-Uniform Random Variate Generation",
%      Springer-Verlag, 1986
%      [3] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, Section 10.3, pages 144-146.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.4.2 $  $Date: 2004/01/16 20:10:33 $

normcutoff = 1e7;
if nargin < 2,
    error('stats:tcdf:TooFewInputs','Requires two input arguments.');
end

[errorcode x v] = distchck(2,x,v);

if errorcode > 0
    error('stats:tcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P.
if isa(x,'single')
    pnan = single(NaN);
else
    pnan = NaN;
end
p = repmat(pnan, size(x));

nans = (isnan(x) | ~(0<v)); %  v==NaN ==> (0<v)==false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
if any(normal(:))
   p(normal) = normcdf(x(normal));
end

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1
gen = ~(cauchy | normal | nans);
p(gen) = betainc(v(gen) ./ (v(gen) + x(gen).^2), v(gen)/2, 0.5)/2;

% Reflect if necessary.
reflect = gen & (x > 0);
p(reflect) = 1 - p(reflect);

% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;
