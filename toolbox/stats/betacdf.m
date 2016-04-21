function p = betacdf(x,a,b);
%BETACDF Beta cumulative distribution function.
%   P = BETACDF(X,A,B) returns the beta cumulative distribution
%   function with parameters A and B at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   BETAINC does the computational work.

%   Reference:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.5.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.2 $  $Date: 2004/02/01 22:10:13 $

if nargin<3, 
   error('stats:betacdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
   error('stats:betacdf:InputSizeMismatch',...
         'Requires non-scalar arguments to match in size.');
end

% Initialize P to 0.
if isa(x,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end

k1 = find(a<=0 | b<=0);
if any(k1)
   tmp = NaN;
   p(k1) = tmp(ones(size(k1))); 
end

% If is X >= 1 the cdf of X is 1. 
k2 = find(x >= 1);
if any(k2)
   p(k2) = ones(size(k2));
end

k = find(x > 0 & x < 1 & a > 0 & b > 0);
if any(k)
   p(k) = betainc(x(k),a(k),b(k));
end

% Make sure that round-off errors never make P greater than 1.
k = find(p > 1);
p(k) = ones(size(k));
