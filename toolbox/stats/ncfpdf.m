function Y = ncfpdf(x,nu1,nu2,delta)
%NCFPDF Noncentral F probability density function (pdf).
%   Y = NCFPDF(X,NU1,NU2,DELTA) returns the noncentral F pdf with numerator 
%   degrees of freedom (df), NU1, denominator df, NU2, and noncentrality
%   parameter, DELTA, at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     

%   Reference:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 p. 191. (equation 5)
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.4 $  $Date: 2004/01/16 20:09:48 $

if nargin < 4, 
    error('stats:ncfpdf:TooFewInputs','Requires four input arguments.');
end

[errorcode, x, nu1, nu2, delta] = distchck(4,x,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

[m,n] = size(x);

% Initialize Y to zero.
if isa(x,'single')
   y = zeros(m,n,'single');
   yeps = eps('single');
else
   y = zeros(m,n);
   yeps = eps;
end
Y = y;

k = (nu1 <= 0 | nu2 <= 0 | x < 0 | delta < 0);
k1 = ~k;
% set Y to NaN for indices where X is negative or NU1 or NU2 are not positives integers.
Y(k) = NaN;
if ~any(k1(:)), return; end

% Use good indices only, and make everything a vector
y = y(k1);
nu1 = nu1(k1);
nu2 = nu2(k1);
x = x(k1);
delta = delta(k1);

% to simply computation, pre-divide nu1,nu2 and delta
nu1 = nu1/2; nu2 = nu2/2; delta = delta/2;

% Set up for infinite sum.
g = nu1.*x./nu2;
% Sum the series.
olddelta = 0;
b = beta(nu1,nu2);

todo = 1:numel(delta);
N1 = nu1;
N2 = nu2;
D = delta;
P = exp(-D);
G = (g.^(N1-1)) ./ ((1+g).^(N1+N2));
j = 0;
while j<1000
   % In principle we are going to compute the following:
   %   b      = beta(j + nu1,nu2);
   %   tmp    = poisspdf(j,delta).*(g.^(j-1+nu1))./((1+g).^(j + nu1 + nu2));
   % However, we computed the beta, poisson, and g parts for j=0 above
   % the loop, and we will use recurrence relations to update them each time.

   tmp    = P .* G;
   deltay = tmp./b;
   y(todo) = y(todo) + deltay;
   
   % Find elements that have not yet converged
   mask = ((deltay./(y(todo)+yeps^(1/4)) >= sqrt(yeps)) | ...
           (deltay >= olddelta)) & (deltay>0);
   if ~any(mask(:)), break; end
   if ~all(mask(:))
      todo = todo(mask);
      b = b(mask);
      g = g(mask);
      deltay = deltay(mask);
      N1 = N1(mask);
      N2 = N2(mask);
      D = D(mask);
   end
   olddelta = deltay;
   b = b .* (j+N1) ./ (j+N1+N2);
   P = P(mask) .* D ./ (j+1);
   G = G(mask) .* g ./ (1+g);
   j = j + 1;
end

if (j == 1000) 
   warning('stats:ncfpdf:NoConvergence',...
           'Failed to converge, use the result cautiously.');
end

Y(k1) = nu1.*y./nu2;

