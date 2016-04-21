function y = nbincdf(x,r,p)
%NBINCDF Negative binomial cumulative distribution function.
%   Y=NBINCDF(X,R,P) returns the negative binomial cumulative distribution
%   function with parameters R and P at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   The algorithm uses the cumulative sums of the binomial masses.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.2.2 $  $Date: 2004/01/16 20:09:42 $

if nargin < 3, 
    error('stats:nbincdf:TooFewInputs','Requires three input arguments.'); 
end 

scalarrp = (prod(size(r)) == 1 & prod(size(p)) == 1);

[errorcode x r p] = distchck(3,x,r,p);

if errorcode > 0
    error('stats:nbincdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to 0.
if ~isfloat(x)
   x = double(x);
end
y = zeros(size(x),class(x));

% Out of range or missing parameters and missing data return NaN.
% Infinite values for R correspond to a Poisson, but its mean cannot
% be determined from the (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1) | isnan(x);
y(nans) = NaN;

% Compute Y when 0 <= X.  Data outside this range return 0.
xx = floor(x);
k = find(0 <= xx  &  ~nans);

% Positive infinite values of X return 1.
k1 = find(isinf(xx(k)));
if any(k1)
    y(k(k1)) = 1;
    k(k1) = [];
end

% Accumulate probabilities up to the maximum value in X.
if any(k)
    val = max(xx(k));
    if scalarrp
        tmp = cumsum(nbinpdf(0:val,r(1),p(1)));
        y(k) = tmp(xx(k) + 1);
    else
        idx = [0:val]';
        compare = idx(:,ones(size(k)));
        index = xx(k);
		index = index(:);
        index = index(:,ones(size(idx)))';
        rbig = r(k);
		rbig = rbig(:);
        rbig = rbig(:,ones(size(idx)))';
        pbig = p(k);
		pbig = pbig(:);
        pbig = pbig(:,ones(size(idx)))';
        y0 = nbinpdf(compare,rbig,pbig);
        indicator = find(compare > index);
        y0(indicator) = zeros(size(indicator));
        y(k) = sum(y0,1);
    end
end

% Make sure that round-off errors never make P greater than 1.
k = find(y > 1);
if any(k)
    y(k) = ones(size(k));
end
