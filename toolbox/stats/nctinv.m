function x = nctinv(p,nu,delta)
%NCTINV Inverse of the noncentral T cumulative distribution function (cdf).
%   X = NCTINV(P,NU,DELTA) Returns the inverse of the noncentral T cdf with 
%   NU degrees of freedom and noncentrality parameter, DELTA, for the  
%   probabilities, P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 147-148.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.16.4.2 $  $Date: 2004/01/16 20:09:50 $

if nargin <  3, 
    error('stats:nctinv:TooFewInputs','Requires three input arguments.'); 
end

[errorcode, p, nu, delta] = distchck(3,p,nu,delta);

if errorcode > 0
    error('stats:nctinv:InputSizeMismatch',...
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

% if some delta==0, call tcdf for those entries, call nctcdf for other entries.
f = (delta == 0);
if any(f(:))
   x(f) = tinv(p(f),nu(f));
   f = ~f;
   if any(f(:)), x(f) = nctinv(p(f),nu(f),delta(f)); end
   return
end

%   Return NaN if the arguments are outside their respective limits.
k = find(p < 0 | p > 1 | nu <= 0);
x(k) = NaN;

% The inverse cdf of 0 is -Inf, and the inverse cdf of 1 is Inf.
k0  = find(p == 0);
if any(k0)
    x(k0) = -Inf;
end
k1 = find(p == 1);
if any(k1)
    x(k1) = Inf;
end

% Newton's Method.
% Permit no more than count_limit interations.
count_limit = 100;
count = 0;

k = find(p > 0 & p < 1 & nu > 0);
pk = p(k);
bigp = find(pk > 0.75);
smallp = find(pk <= 0.25);
vk = nu(k);
dk = delta(k);

% Use delta as a starting guess for x.
xk = dk;

h = ones(size(pk));

% Break out of the iteration loop for the following:
%  1) The last update is very small (compared to x or in abs. value).
%  2) There are more than 100 iterations. This should NEVER happen. 

F =  nctcdf(xk,vk,dk);
while(any(abs(h)>crit*abs(xk)) && ...
      max(abs(h))>crit && ...
      count<count_limit),
    count = count+1;
    f =  nctpdf(xk,vk,dk);
    h = (F - pk) ./ f;
    xnew = xk - h;

    % Back off if the step gives a worse result
    Fnew = nctcdf(xnew,vk,dk);
    while(true)
       worse = (abs(Fnew-pk) > abs(F-pk)*(1+crit)) & ...
               (abs(xk-xnew) > crit*abs(xk));
       if ~any(worse), break; end
       xnew(worse) = 0.5 * (xnew(worse) + xk(worse));
       Fnew(worse) = nctcdf(xnew(worse),vk(worse),dk(worse));
    end

    xk = xnew;
    F = Fnew;
end

% Return the converged value(s).
x(k) = xk;

if count==count_limit, 
    fprintf('\nWarning: NCTINV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],h);
    fprintf(outstr);
end

