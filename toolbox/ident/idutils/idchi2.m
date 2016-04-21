function p = idchi2(x,n)
%IDCHI2 The cumulative chi2-distribution
%   P = IDCHI2(x,n)
%
%   if X is chi2(n) distributed, then P is the probability that
%   X is less than x.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/10 23:18:31 $
 
p = gamcdf(x,n/2,2);



function p = gamcdf(x,a,b);
%GAMCDF Gamma cumulative distribution function.
%   P = GAMCDF(X,A,B) returns the gamma cumulative distribution
%   function with parameters A and B at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   Some references refer to the gamma distribution with a single
%   parameter. This corresponds to the default of B = 1. 
%
%   GAMMAINC does computational work.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986. p. 401.
%      [2]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.32.

%   Was: Revision: 1.2, Date: 1996/07/25 16:23:36

if nargin < 3, 
    b = 1; 
end

if nargin < 2, 
    error('Requires at least two input arguments.'); 
end

% [errorcode x a b] = distchck(3,x,a,b);
% 
% if errorcode > 0
%     error('Requires non-scalar arguments to match in size.');
% end

%   Return NaN if the arguments are outside their respective limits.
k1 = find(a <= 0 | b <= 0);     
if any(k1)
    tmp   = NaN;
    p(k1) = tmp(ones(size(k1)));
end

% Initialize P to zero.
p = zeros(size(x));

k = find(x > 0 & ~(a <= 0 | b <= 0));
if any(k), 
    p(k) = gammainc(x(k) ./ b(k),a(k));
end

% Make sure that round-off errors never make P greater than 1.
k = find(p > 1);
if any(k)
    p(k) = ones(size(k));
end


function y = gampdf(x,a,b)
%GAMPDF Gamma probability density function.
%   Y = GAMPDF(X,A,B) returns the gamma probability density function 
%   with parameters A and B, at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   Some references refer to the gamma distribution with a single
%   parameter. This corresponds to the default of B = 1.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986, pages 401-402.

%   Was: Revision: 1.2, Date: 1996/07/25 16:23:36

if nargin < 3, 
    b = 1; 
end

if nargin < 2, 
    error('Requires at least two input arguments'); 
end

% [errorcode x a b] = distchck(3,x,a,b);
% 
% if errorcode > 0
%     error('Requires non-scalar arguments to match in size.');
% end

% Initialize Y to zero.
y = zeros(size(x));

%   Return NaN if the arguments are outside their respective limits.
k1 = find(a <= 0 | b <= 0);     
if any(k1)
    tmp = NaN;
    y(k1) = tmp(ones(size(k1)));
end

k=find(x > 0 & ~(a <= 0 | b <= 0));
if any(k)
    y(k) = (a(k) - 1) .* log(x(k)) - (x(k) ./ b(k)) - gammaln(a(k)) - a(k) .* log(b(k));
    y(k) = exp(y(k));
end
k1 = find(x == 0 & a < 1);
if any(k1)
  tmp = Inf;
  y(k1) = tmp(ones(size(k1)));
end
k2 = find(x == 0 & a == 1);
if any(k2)
  y(k2) = (1./b(k2));
end
