function [m,v] = binostat(n,p)
% BINOSTAT Mean and variance of the binomial distribution.
%   [M, V] = BINOSTAT(N,P) returns the mean and variance of the
%   binomial distribution with parameters N and P.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.20.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.2 $  $Date: 2004/01/16 20:09:00 $

if nargin < 2, 
    error('stats:binostat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode n p] = distchck(2,n,p);

if errorcode > 0
    error('stats:binostat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if ~isfloat(n)
   n = double(n);
end

m = n .* p;
v = n .* p .* (1 - p);

% Return NaN for parameter values outside their respective limits.
k = find(p<0 | p>1 | n<0 | round(n)~=n);
if any(k)
    tmp = NaN;
    m(k) = tmp(ones(size(k)));
    v(k) = m(k);
end
