function y = nbinpdf(x,r,p)
% NBINPDF Negative binomial probability density function.
%   Y = NBINPDF(X,R,P) returns the negative binomial probability density 
%   function with parameters R and P at the values in X.
%   Note that the density function is zero unless X is an integer.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.2 $  $Date: 2004/01/16 20:09:45 $

if nargin < 3, 
    error('stats:nbinpdf:TooFewInputs','Requires three input arguments');
end

[errorcode x r p] = distchck(3,x,r,p);

if errorcode > 0
    error('stats:nbinpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if ~isfloat(x)
    x = double(x);
    y = zeros(size(x),class(x));
else
    y = zeros(size(x));
end

% Out of range or missing parameters and missing data return NaN.
% Infinite values for R correspond to a Poisson, but its mean cannot
% be determined from the (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1) | isnan(x);
y(nans) = NaN;

% Negative binomial distribution is defined on the non-negative
% integers.  Data outside this support return 0.
k = find(0 <= x & isfinite(x) & x == round(x)  &  ~nans);
if any(k),
    nk = exp(gammaln(r(k) + x(k)) - gammaln(x(k) + 1) - gammaln(r(k)));
    y(k) = nk .* (p(k) .^ r(k)) .* (1 - p(k)) .^ x(k);
end
