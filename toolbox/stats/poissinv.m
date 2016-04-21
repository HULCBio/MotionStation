function x = poissinv(p,lambda)
%POISSINV Inverse of the Poisson cumulative distribution function (cdf).
%   X = POISSINV(P,LAMBDA) returns the inverse of the Poisson cdf 
%   with parameter lambda. Since the Poisson distribution is discrete,
%   POISSINV returns the smallest value of X, such that the poisson 
%   cdf evaluated, at X, equals or exceeds P.
%
%   The size of X is the common size of P and LAMBDA. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.2 $  $Date: 2004/01/16 20:10:01 $

if nargin < 2, 
    error('stats:poissinv:TooFewInputs','Requires two input arguments.'); 
end

[errorcode p lambda] = distchck(2,p,lambda);

if errorcode > 0
    error('stats:poissinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if isa(p,'single')
   x = zeros(size(p),'single');
else
   x = zeros(size(p));
end

cumdist = poisspdf(0,lambda);
count = 0;

% Compare P to the poisson cdf.
k = find(lambda > 0 & p >= 0 & p < 1);
k = k(find(cumdist(k) < p(k)));
while ~isempty(k)
   count = count + 1;
   x(k) = count;
   cumdist(k) = cumdist(k) + poisspdf(count,lambda(k));
   k = k(find(cumdist(k) < p(k)));
end

% Return NaN if the arguments are outside their respective limits.
x(lambda <= 0 | p < 0 | p > 1) = NaN;

% Return Inf if p = 1 and lambda is positive.
x(lambda > 0 & p == 1) = Inf;

