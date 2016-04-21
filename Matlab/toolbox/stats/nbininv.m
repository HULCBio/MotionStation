function x = nbininv(y,r,p)
%NBININV Inverse of the negative binomial cumulative distribution function (cdf).
%   X = NBININV(Y,R,P) returns the inverse of the negative binomial cdf with 
%   parameters R and P. Since the negative binomial distribution is discrete,
%   NBININV returns the least integer X such that the negative
%   binomial cdf evaluated at X, equals or exceeds Y.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.2.2 $  $Date: 2004/01/16 20:09:44 $

if nargin < 3, 
    error('stats:nbininv:TooFewInputs','Requires three input arguments.'); 
end 

[errorcode y r p] = distchck(3,y,r,p);

if errorcode > 0
    error('stats:nbininv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize X to 0.
if isa(y,'single')
   x = zeros(size(y),'single');
else
   x = zeros(size(y));
end

% Out of range or missing parameters or probabilities return NaN.
% Infinite values for R correspond to a Poisson, but its mean cannot
% be determined from the (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1) | ~(0 <= y & y <= 1);
x(nans) = NaN;

% Compute X when 0 <= Y <= 1.
k = find(~nans);

% Return Inf if the probability is 1.
k1 = find(y(k) == 1);
if any(k1)
    x(k(k1)) = Inf;
    k(k1) = [];
end

% Accumulate probabilities to satisfy the values in Y.
if any(k)
   cumdist = zeros(size(y));
   count = 0;
   cumdist(k) = nbinpdf(0,r(k),p(k));
   k = k(cumdist(k) < y(k));
   while ~isempty(k)
      x(k) = x(k) + 1;
      count = count + 1;
      cumdist(k) = cumdist(k) + nbinpdf(count,r(k),p(k));
      k = k(cumdist(k) < y(k));
   end
end