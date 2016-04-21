function p = cfbetacdf(x,a,b)
%CFBETACDF Adapated from BETACDF in the Statistics Toolbox.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:40:49 $

if nargin<3, 
   error('curvefit:cfbetacdf:threeArgsRequired',...
         'Three input arguments are required.'); 
end

% Initialize P to 0.
p = zeros(size(x));

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
