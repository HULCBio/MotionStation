function x = ncx2inv(p,v,delta)
%NCX2INV Inverse of the noncentral chi-square cdf.
%   X = NCX2INV(P,V,DELTA)  returns the inverse of the noncentral chi-square   
%   cdf with parameters V and DELTA, at the probabilities in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   NCX2INV uses Newton's method to converge to the solution.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.4.2 $  $Date: 2004/01/16 20:09:53 $

if nargin<3, 
    delta = 1;
end

[errorcode p v delta] = distchck(3,p,v,delta);

if errorcode > 0
    error('stats:ncx2inv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

%   Initialize X to zero.
if isa(p,'single')
   x = zeros(size(p),'single');
   crit = sqrt(eps('single'));
else
   x = zeros(size(p));
   crit = sqrt(eps);
end

k = find(p<0 | p>1 | v <= 0 | delta < 0);
if any(k),
    tmp  = NaN;
    x(k) = tmp(ones(size(k)));
end

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is 1.  
k0 = find(p == 0 & v > 0 & delta > 0);
if any(k0),
    x(k0) = zeros(size(k0)); 
end

k1 = find(p == 1 & v > 0 & delta > 0);
if any(k1), 
    tmp = Inf;
    x(k1) = tmp(ones(size(k1))); 
end

% Newton's Method
% Permit no more than count_limit interations.
count_limit = 100;
count = 0;

kz = (p > 0  &  p < 1 & v > 0 & delta == 0);
if any(kz(:))
   x(kz) = chi2inv(p(kz),v(kz));
end
   
k = find(p > 0  &  p < 1 & v > 0 & delta > 0);
pk = p(k);

% Supply a starting guess for the iteration.
%   Use a method of moments fit to the lognormal distribution. 
mn = v(k) + delta(k);
variance = 2*(v(k) + 2*delta(k));
temp = log(variance + mn .^ 2); 
mu = 2 * log(mn) - 0.5 * temp;
sigma = -2 * log(mn) + temp;
xk = exp(norminv(pk,mu,sigma));

h = ones(size(pk)); 

% Break out of the iteration loop for three reasons:
%  1) the last update is very small (compared to x)
%  2) the last update is very small (compared to sqrt(eps))
%  3) There are more than 100 iterations. This should NEVER happen. 
F = ncx2cdf(xk,v(k),delta(k));
while(count < count_limit), 
                                 
    count = count + 1;
    f = ncx2pdf(xk,v(k),delta(k));
    h = (F - pk) ./ f;
    xnew = xk - h;
    % Make sure that the current guess stays greater than zero.
    % When Newton's Method suggests steps that lead to negative guesses
    % take a step 9/10ths of the way to zero:
    ksmall = find(xnew < 0);
    if any(ksmall),
        xnew(ksmall) = xk(ksmall) / 10;
    end
    
    % Back off if the step gives a worse result
    newF = ncx2cdf(xnew,v(k),delta(k));
    while(true)
       worse = (abs(newF-pk) > abs(F-pk)*(1+crit)) & ...
               (abs(xk-xnew)> crit*xk);
       if ~any(worse), break; end
       xnew(worse) = 0.5 * (xnew(worse) + xk(worse));
       newF(worse) = ncx2cdf(xnew(worse),v(k(worse)),delta(k(worse)));
    end
    h = xk-xnew;
    x(k) = xnew;
    mask = (abs(h)>crit*abs(xk)) & (abs(h)>crit);
    if ~any(mask), break; end
    k = k(mask);
    xk = xnew(mask);
    F = newF(mask);
    pk = pk(mask);
end


% Store the converged value in the correct place
x(k) = xk;

if count == count_limit, 
    fprintf('\nWarning: NCX2INV did not converge.\n');
    str = 'The last step was:  ';
    outstr = sprintf([str,'%13.8f'],h);
    fprintf(outstr);
end
