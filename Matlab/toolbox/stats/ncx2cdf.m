function p = ncx2cdf(x,v,delta)
%NCX2CDF Noncentral chi-square cumulative distribution function (cdf).
%   P = NCX2CDF(X,V,DELTA) Returns the noncentral chi-square cdf with V 
%   degrees of freedom and noncentrality parameter, DELTA, at the values 
%   in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   Some texts refer to this distribution as the generalized Rayleigh,
%   Rayleigh-Rice, or Rice distribution.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 50-52.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.4 $  $Date: 2004/01/16 20:09:52 $

if nargin <  3, 
    error('stats:ncx2cdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x v delta] = distchck(3,x,v,delta);

if errorcode > 0
    error('stats:ncx2cdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single')
   p = zeros(size(x),'single');
   peps = eps('single');
else
   p = zeros(size(x));
   peps = eps;
end
p(isnan(x)) = NaN;
p(x==Inf) = 1;

p(x <= 0) = 0;  
p(delta < 0) = NaN;  % can't have negative non-centrality parameter.
k = find((x > 0) & (delta >=0) & isfinite(x));
k1 = k;
hdelta = delta(k)/2;  % this is used in the loop, pre-compute.
v = v(k);
x = x(k);
x1 = x;  % make a copy to be used when reverse direction.
v1 = v;
hdelta1 = hdelta;

% when non-centrality parameter is very large, the initial values of
% the poisson numbers used in the approximation are very small,
% smaller than epsilon. This would cause premature convergence. To
% avoid that, we start from counter=hdelta, which is the peak of the
% poisson numbers, and go in both directions.

counter = floor(hdelta);
peps = eps(class(p));
crit = sqrt(peps);

% Sum the series.
% In principle we are going to sum terms of the form
%     poisspdf(counter,hdelta).*chi2cdf(x,v+2*counter)
% but we will compute these factors from scratch just once,
% and update them each time using a recurrence formula.
P = poisspdf(counter,hdelta);
C = chi2cdf(x,v+2*counter);
E = exp((v/2+counter-1).*log(x/2) - x/2 - gammaln(v/2+counter));
P0 = P;
C0 = C;
E0 = E;
while ~isempty(counter)
   pplus  = P.*C;
   j = isnan(pplus);
   if any(j(:))
      if all(j(:)), break; end
      j = ~j;
      x = x(j);
      v = v(j);
      hdelta = hdelta(j);
      counter = counter(j);
      k = k(j);
      pplus = pplus(j);
   end
   p(k) = p(k) + pplus; % accumulate p for k indices
   j = find(pplus > p(k)*crit);
   if isempty(j) % no more computation needed in this direction
      break;
   end
   x = x(j);
   v = v(j);
   hdelta = hdelta(j);
   counter = counter(j) + 1;
   k = k(j);
   P = P(j) .* hdelta ./ counter;
   E = E(j) .* (x/2) ./ (v/2+counter-1);
   C = C(j) - E;
end

   
counter = floor(hdelta1) - 1; % set counter back just below the peak;
j = find(counter>=0);         % sum down toward zero
if isempty(j)
   return;
end

% Now process in the other direction
x = x1(j);
v = v1(j);
hdelta = hdelta1(j);
k = k1(j);
counter = counter(j);
P = P0(j) .* (counter+1) ./ hdelta;
E = E0(j);
C = C0(j) + E;
while ~isempty(counter)
   pplus  = P.*C;
   j = isnan(pplus);
   if any(j(:))
      if all(j(:)), break; end
      j = ~j;
      x = x(j);
      v = v(j);
      hdelta = hdelta(j);
      counter = counter(j);
      k = k(j);
      pplus = pplus(k);
   end
   p(k) = p(k) + pplus; % accumulate p for k indices
   j = find(pplus>p(k)*peps & counter>0);
   if isempty(j) % no more computation needed in this direction
      break;
   end
   x = x(j);
   v = v(j);
   hdelta = hdelta(j);
   counter = counter(j) - 1;
   k = k(j);
   P = P(j) .* (counter+1) ./ hdelta;
   E = E(j) .* (v/2+counter+1) ./ (x/2);
   C = C(j) + E;
end
