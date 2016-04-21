function x = ncfinv(p,nu1,nu2,delta)
%NCFINV Inverse of the noncentral F cumulative distribution function (cdf).
%   X = NCFINV(P,NU1,NU2,DELTA) Returns the inverse of the noncentral F cdf with 
%   numerator degrees of freedom (df), NU1, denominator df, NU2, and noncentrality
%   parameter, DELTA, for the probabilities, P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.2 $  $Date: 2004/01/16 20:09:47 $

if nargin <  4, 
    error('stats:ncfinv:TooFewInputs','Requires four input arguments.'); 
end

[errorcode, p, nu1, nu2, delta] = distchck(4,p,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

%   Initialize x to zero.
if isa(p,'single')
   x = zeros(size(p),'single');
   crit = sqrt(eps('single'));
else
   x = zeros(size(p));
   crit = sqrt(eps);
end

%   Return NaN if the arguments are outside their respective limits.
k1 = (p < 0 | p > 1 | nu1 < 1 | nu2 < 1 | delta < 0);
x(k1) = NaN;      % assign NaN to illegal indices

k2 = (p == 0);
x(k2) = 0;        % the inverse cdf of 0 is 0

k3 = (p == 1);
x(k3) = Inf;      % the inverse cdf of 1 is Inf

k4 = (k1 | k2 | k3);
k = find(~k4);


% if nothing left, return;
if isempty(k), return; end

% Reset variables so that we don't have to deal with unneccessary indices,
% and at the same time convert everything to vectors
p = p(k);
nu1 = nu1(k);
nu2 = nu2(k);
delta = delta(k);

% Start at the mean, if the mean exists (if nu2>2)
y = nu2.*(nu1+delta) ./ (nu1.*max(1,nu2-2));

% Newton's Method.
% Permit no more than count_limit interations.
count_limit = 100;
count = 0;

h = y;

% Iterate until the last update is very small compared to x,
% or we have made too many iterations
oldh = 0;
F = ncfcdf(y,nu1,nu2,delta);
while(count<count_limit)
   count = count+1;

   f = ncfpdf(y,nu1,nu2,delta);
   h = (F - p) ./ f;

   % If iterations appear to be oscillating, damp them out
   if length(h)==length(oldh)
      t = sign(h)==-sign(oldh);
      h(t) = sign(h(t)) .* min(abs(h(t)),abs(oldh(t)))/2;
   end

   % Avoid stepping too far
   newy = max(y/5, min(5*y, y-h));

   % Back off if the step gives a worse result
   newF = ncfcdf(newy,nu1,nu2,delta);
   while(true)
      worse = (abs(newF-p) > abs(F-p)*(1+crit)) & ...
              (abs(y-newy) > crit*y);
      if ~any(worse), break; end
      newy(worse) = 0.5 * (newy(worse) + y(worse));
      newF(worse) = ncfcdf(newy(worse),nu1(worse),nu2(worse),delta(worse));
   end
   x(k) = newy;
   
   % See which elements have not yet converged
   h = y - newy;
   mask = (abs(h) > crit*abs(y));
   if ~any(mask), break; end
   
   % Save parameters for only these elements
   F = newF(mask);
   y = newy(mask);
   oldh = h(mask);
   if ~all(mask)
      nu1 = nu1(mask);
      nu2 = nu2(mask);
      delta = delta(mask);
      p = p(mask);
      k = k(mask);
   end
end

if count==count_limit, 
    fprintf('\nWarning: NCFINV did not converge.\n');
    fprintf(['The last step was:  ' num2str(h(:)') '\n']);
end

