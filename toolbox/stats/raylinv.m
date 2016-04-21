function x = raylinv(p,b)
%RAYLINV  Inverse of the Rayleigh cumulative distribution function (cdf).
%   X = RAYLINV(P,B) returns the Rayleigh cumulative distribution 
%   function with parameter B at the probabilities in P.

%   The size of X is the common size of P and B. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 134-136.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.3 $  $Date: 2004/01/16 20:10:23 $

if nargin < 1
    error('stats:raylinv:TooFewInputs',...
          'Requires at least one input argument.'); 
end
if nargin<2
    b = 1;
end

[errorcode p b] = distchck(2,p,b);

if errorcode > 0
    error('stats:raylinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize x to zero.
if isa(p,'single')
    x = zeros(size(p),'single');
else
    x = zeros(size(p));
end

% Return NaN if the arguments are outside their respective limits.
k1 = find(b <= 0| p < 0 | p > 1);
if any(k1) 
    tmp   = NaN;
    x(k1) = tmp(ones(size(k1)));
end

% Put in the correct values when P is 1.
k = find(p == 1);
if any(k)
    tmp  = Inf;
    x(k) = tmp(ones(size(k))); 
end

k=find(b > 0 & p > 0  &  p < 1);
if any(k),
    pk = p(k);
    bk = b(k);
    x(k) = sqrt((-2*bk .^ 2) .* log(1 - pk));
end
