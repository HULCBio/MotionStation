function x = hygeinv(p,m,k,n)
%HYGEINV Inverse of the hypergeometric cumulative distribution function (cdf).
%   X = HYGEINV(P,M,K,N) returns the inverse of the hypergeometric 
%   cdf with parameters M, K, and N. Since the hypergeometric 
%   distribution is discrete, HYGEINV returns the smallest integer X, 
%   such that the hypergeometric cdf evaluated at X, equals or exceeds P.   
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.3 $  $Date: 2004/01/24 09:34:07 $

if nargin < 4, 
    error('stats:hygeinv:TooFewInputs','Requires four input arguments.'); 
end

[errorcode p m k n] = distchck(4,p,m,k,n);

if errorcode > 0
    error('stats:hygeinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize X to zero.
if isa(p,'single')
   x = zeros(size(p),'single');
else
   x = zeros(size(p));
end

%   Return NaN for values of the parameters outside their respective limits.
k1 = find(m < 0 | k < 0 | n < 0 | round(m) ~= m | round(k) ~= k | ...
           round(n) ~= n | n > m | k > m | x > n | p < 0 | p > 1 | isnan(p));
if any(k1)
    x(k1) = NaN;
end

cumdist = hygepdf(x,m,k,n);
count = zeros(size(p));

% Compare P to the hypergeometric distribution for each value of N.
while any(p(:) > cumdist(:)) && count(1) < max(n(:)) && count(1) < max(k(:))
    count = count + 1;
    idx = find(cumdist < p - eps(p));
    x(idx) = x(idx) + 1;
    cumdist(idx) = cumdist(idx) + hygepdf(count(idx),m(idx),k(idx),n(idx));
end
