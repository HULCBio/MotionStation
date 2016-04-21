function x = cfbetainv(p,a,b)
%CFBETAINV Adapted from BETAINV in the Statistics Toolbox.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:40:50 $

if nargin <  3, 
    error('curvefit:cfbetainv:threeArgsRequired', ...
          'Three input arguments are required.'); 
end

%   Initialize x to zero.
x = zeros(size(p));

%   Return NaN if the arguments are outside their respective limits.
k = find(p < 0 | p > 1 | a <= 0 | b <= 0);
if any(k),
   tmp = NaN;
   x(k) = tmp(ones(size(k))); 
end

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is 1.  
k0 = find(p == 0 & a > 0 & b > 0);
if any(k0), 
    x(k0) = zeros(size(k0)); 
end

k1 = find(p==1);
if any(k1), 
    x(k1) = ones(size(k1)); 
end

% Newton's Method.
% Permit no more than count_limit interations.
count_limit = 100;
count = 0;

k = find(p > 0 & p < 1 & a > 0 & b > 0);
if isempty(k)
   return;
end
pk = p(k);

%   Use the mean as a starting guess. 
xk = a(k) ./ (a(k) + b(k));


% Move starting values away from the boundaries.
if xk == 0,
    xk = sqrt(eps);
end
if xk == 1,
    xk = 1 - sqrt(eps);
end


h = ones(size(pk));
crit = sqrt(eps); 

% Break out of the iteration loop for the following:
%  1) The last update is very small (compared to x).
%  2) The last update is very small (compared to 100*eps).
%  3) There are more than 100 iterations. This should NEVER happen. 

while(any(abs(h) > crit * abs(xk)) && max(abs(h)) > crit    ...
                                 && count < count_limit), 
                                 
    count = count+1;    
    h = (cfbetacdf(xk,a(k),b(k)) - pk) ./ cfbetapdf(xk,a(k),b(k));
    xnew = xk - h;

% Make sure that the values stay inside the bounds.
% Initially, Newton's Method may take big steps.
    ksmall = find(xnew <= 0);
    klarge = find(xnew >= 1);
    if any(ksmall) || any(klarge)
        xnew(ksmall) = xk(ksmall) /10;
        xnew(klarge) = 1 - (1 - xk(klarge))/10;
    end

    xk = xnew;  
end

% Return the converged value(s).
x(k) = xk;

if count==count_limit, 
    fprintf('\nWarning: CFBETAINV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],h);
    fprintf(outstr);
end
