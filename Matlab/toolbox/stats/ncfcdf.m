function p = ncfcdf(x,nu1,nu2,delta)
%NCFCDF Noncentral F cumulative distribution function (cdf).
%   P = NCFCDF(X,NU1,NU2,DELTA) Returns the noncentral F cdf with numerator
%   degrees of freedom (df), NU1, denominator df, NU2, and noncentrality
%   parameter, DELTA, at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.

%   References:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 p. 192.
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.16.4.5 $  $Date: 2004/01/24 09:34:40 $

if nargin <  4,
    error('stats:ncfcdf:TooFewInputs','Requires four input arguments.');
end

[errorcode x nu1 nu2 delta] = distchck(4,x,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

[m,n] = size(x);

% Initialize p to zero.
if isa(x,'single')
   p = zeros(m,n,'single');
   cvgtol = eps('single').^(3/4);
else
   p = zeros(m,n);
   cvgtol = eps.^(3/4);
end

% Deal with illegal parameters, x==0, and the central distribution
k = (nu1 <= 0 | nu2 <= 0 | x < 0 | delta < 0);
kz = (delta==0);
p(k) = NaN;
if any(kz(:))
   p(kz) = fcdf(x(kz),nu1(kz),nu2(kz));
end
k1 = ~(k|kz|(x==0));
if ~any(k1(:)), return; end

if ~all(k1(:)) % reset variable so that we don't have to deal with bad indices.
   x = x(k1);
   nu1 = nu1(k1);
   nu2 = nu2(k1);
   delta = delta(k1);
end

% to simplify computation, pre-divide nu1,nu2 and delta
nu1 = nu1/2; nu2 = nu2/2; delta = delta/2;


%Value passed to Beta distribution function.
tmp = nu1.*x./(nu2+nu1.*x);
logtmp = log(tmp);
nu2const = nu2.*log(1-tmp) - gammaln(nu2);

% Sum the series.  The general idea is that we are going to sum terms
% of the form
%        poisspdf(j,delta) .* betacdf(tmp,j+nu1,nu2)
% We will save some time by computing these pdf and cdf functions once at
% a point that we hope will be near the maximum of the series, and we will
% compute other terms in the series using recurrence relations.
j0 = max(floor(delta(:)));      % start from here

% Compute Poisson pdf and beta cdf at the starting point
ppdf0 = exp(-delta + j0 .* log(delta) - gammaln(j0 + 1));
bcdf0 = betacdf(tmp,j0+nu1,nu2);

% Set up for loop over values less than j0
y = ppdf0 .* bcdf0;
ppdf = ppdf0;
bcdf = bcdf0;
olddy = 0;
for j=j0-1:-1:0
   % Use recurrence relation to compute new pdf and cdf
   ppdf = ppdf .* (j+1) ./ delta;
   bcdf = bcdf + exp((j+nu1).*logtmp + nu2const + ...
                     gammaln(j+nu1+nu2) - gammaln(j+nu1+1));
   deltay = ppdf.*bcdf;
   y = y + deltay;

   % Convergence test:  change must be small and not increasing
   small = all(deltay(:) <= y(:)*cvgtol);
   increasing = any(abs(deltay(:))>olddy);
   if small && ~increasing, break; end
   olddy = abs(deltay(:));
end

% Set up again for loop upward from j0
ppdf = ppdf0;
bcdf = bcdf0;
olddy = 0;
for j=j0+1:j0+1000    % so that we don't get into an infinite loop
   ppdf = ppdf .* delta ./ j;
   bcdf = bcdf - exp((j+nu1-1).*logtmp + nu2const + ...
                     gammaln(j+nu1+nu2-1) - gammaln(j+nu1));
   deltay = ppdf.*bcdf;
   y = y + deltay;

   % Convergence test:  change must be small and not increasing
   small = all(deltay(:) <= y(:)*cvgtol);
   increasing = any(abs(deltay(:))>olddy);
   if small && ~increasing, break; end
   olddy = abs(deltay(:));
end

if (j == j0+1000)
   warning('stats:ncfcdf:NoConvergence',...
           'Failed to converge, use the result cautiously.');
end

p(k1) = y;
