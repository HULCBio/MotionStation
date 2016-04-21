function x = betainv(p,a,b);
%BETAINV Inverse of the beta cumulative distribution function (cdf).
%   X = BETAINV(P,A,B) returns the inverse of the beta cdf with 
%   parameters A and B at the values in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   BETAINV uses Newton's method to converge to the solution.

%   Reference:
%      [1]     M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.2 $  $Date: 2004/01/16 20:08:53 $

if nargin <  3, 
    error('stats:betainv:TooFewInputs','Requires three input arguments.'); 
end

[errorcode p a b] = distchck(3,p,a,b);

if errorcode > 0
    error('stats:betainv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

%   Initialize x to zero.
if isa(p,'single')
   x = zeros(size(p),'single');
   seps = sqrt(eps('single'));
else
   x = zeros(size(p));
   seps = sqrt(eps);
end

%   Return NaN if the arguments are outside their respective limits.
k = find(p < 0 | p > 1 | a <= 0 | b <= 0);
if any(k),
   tmp = NaN;
   x(k) = tmp(ones(size(k))); 
end

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is 1.  
k0 = find(p == 0 & a > 0 & b > 0);
if any(k0), 
    x(k0) = 0;
end

k1 = find(p==1);
if any(k1), 
    x(k1) = 1;
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
if isa(p,'single')
   xk = single(xk);
end

% Move starting values away from the boundaries.
xk(xk==0) = seps;
xk(xk==1) = 1 - seps;

h = ones(size(pk));
crit = seps;

% Break out of the iteration loop for the following:
%  1) The last update is very small (compared to x).
%  2) The last update is very small (compared to 100*eps).
%  3) There are more than 100 iterations. This should NEVER happen. 

while(any(abs(h) > crit * abs(xk)) & max(abs(h)) > crit    ...
                                 & count < count_limit), 
                                 
    count = count+1;    
    h = (betacdf(xk,a(k),b(k)) - pk) ./ betapdf(xk,a(k),b(k));
    xnew = xk - h;

% Make sure that the values stay inside the bounds.
% Initially, Newton's Method may take big steps.
    ksmall = find(xnew <= 0);
    klarge = find(xnew >= 1);
    if any(ksmall) | any(klarge)
        xnew(ksmall) = xk(ksmall) /10;
        xnew(klarge) = 1 - (1 - xk(klarge))/10;
    end

    xk = xnew;  
end

% Return the converged value(s).
x(k) = xk;

if count==count_limit, 
    fprintf('\nWarning: BETAINV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f\n'],max(h(:)));
    fprintf(outstr);
end

