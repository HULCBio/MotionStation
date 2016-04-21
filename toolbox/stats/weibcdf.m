function p = weibcdf(x,a,b)
%WEIBCDF Weibull cumulative distribution function (cdf).
%   P = WEIBCDF(X,A,B) returns the Weibull cdf with parameters A and B
%   at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.    
%
%   Some references refer to the Weibull distribution with a 
%   single parameter. This corresponds to WEIBCDF with A = 1.

%   References:
%      [1] J. K. Patel, C. H. Kapadia, and D. B. Owen, "Handbook
%      of Statistical Distributions", Marcel-Dekker, 1976.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.4.2 $  $Date: 2004/02/01 22:10:48 $

if nargin < 3, 
    error('stats:weibcdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
    error('stats:weibcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end

k1 = find(a <= 0 | b <= 0);
if any(k1)
   tmp   = NaN;
   y(k1) = tmp(ones(size(k1)));
end

% The domain of the weibull distribution is the positive real axis.
k = find(x >= 0 & a > 0 & b > 0);
if any(k),
    p(k) = 1 - exp(-a(k) .* (x(k) .^ b(k)));
end
