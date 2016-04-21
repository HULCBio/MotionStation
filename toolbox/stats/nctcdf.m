function p = nctcdf(x,nu,delta)
%NCTCDF Noncentral T cumulative distribution function (cdf).
%   P = NCTCDF(X,NU,DELTA) Returns the noncentral T cdf with NU 
%   degrees of freedom and noncentrality parameter, DELTA, at the values 
%   in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     

%   References:
%      [1]  Johnson, Norman, and Kotz, Samuel, "Distributions in
%      Statistics: Continuous Univariate Distributions-2", Wiley
%      1970 p. 205.
%      [2]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 pp. 147-148.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.2.5 $  $Date: 2004/02/01 22:10:27 $

if nargin <  3, 
    error('stats:nctcdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x nu delta] = distchck(3,x,nu,delta);

if errorcode > 0
    error('stats:nctcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Special cases for delta==0 and x<0.
f0 = (delta == 0);
fn = (x < 0 & ~f0);
flag0 = any(f0(:));
flagn = any(fn(:));
if (flag0 | flagn)
   fp = ~(f0 | fn);
   p = zeros(size(delta));
   if flag0,        p(f0) = tcdf(x(f0),nu(f0)); end
   if any(fp(:)),   p(fp) = nctcdf(x(fp), nu(fp), delta(fp)); end
   if flagn,        p(fn) = 1 - nctcdf(-x(fn), nu(fn), -delta(fn)); end
   return
end

% Initialize P to zero.
[m,n] = size(x);
if isa(x,'single')
   p = zeros(m,n,'single');
   seps = eps('single')^(3/4);
   qeps = eps('single')^(1/4);
else
   p = zeros(m,n);
   seps = eps^(3/4);
   qeps = eps^(1/4);
end

kzero = find(x == 0);
kpos = 1:m*n;
kpos(kzero(:)) = [];

%Value passed to Incomplete Beta function.
tmp = (x.^2)./(nu+x.^2);

% Set up for infinite sum.
done = 0;
dsq = delta.^2;

% Use A&S 26.7.10 if we can't evaluate the exp(-delta^2/2) term
eterm = exp(-dsq/2);
k0 = abs(eterm) < realmin(class(eterm));
if any(k0(:))
   p(k0) = normcdf((x(k0) .* (1 - 1./(4*nu(k0))) - delta(k0)) ./ ...
                   sqrt(1 + (x(k0).^2)./(2*nu(k0))));
end

% Compute probability P[t<0] + P[0<t<x], starting with 1st term
p(~k0) = normcdf(-delta(~k0),0,1);

% Now sum a series to compute the second term
k0 = find(x~=0 & ~k0);
if any(k0(:))
   tmp = tmp(k0);
   nu = nu(k0);
   dsq = dsq(k0);
   subtotal = zeros(size(k0));

   % Compute an infinite sum using Johnson & Kotz eq 9, or new
   % edition eq 31.16, each term having this form:
   %      B  = betainc(tmp,(j+1)/2,nu/2);
   %      E  = (exp(0.5*j*log(0.5*delta^2) - gammaln(j/2+1)));
   %      term = E .* B;
   %
   % We'll compute betainc at the beginning, and then update using
   % recurrence formulas (Abramowitz & Stegun 26.5.16).  We'll sum the
   % series two terms at a time to make the recurrence work out.

   E1 = 1;
   E2 = delta(k0) ./ (sqrt(2) * exp(gammaln(1+1/2)));
   B1 = betainc(tmp,1/2,nu/2);
   B2 = betainc(tmp,1,nu/2);
   R1 = exp(gammaln(nu/2+0.5)-gammaln(1.5)-gammaln(nu/2)) .* ...
        ((1-tmp).^(nu/2)) .* sqrt(tmp);
   R2 = exp(gammaln(nu/2+1)-gammaln(2)-gammaln(nu/2)) .* ...
        ((1-tmp).^(nu/2)) .* tmp;
   jj = 0;
   while 1
      %Probability that t lies between 0 and x (x>0)
      twoterms = E1.*B1 + E2.*B2;
      subtotal = subtotal + twoterms;

      % Convergence test.
      if all(abs(twoterms) <= (abs(subtotal)+qeps)*seps)
         p(k0) = p(k0) + eterm(k0) .* subtotal/2;
         break;
      end
      jj = jj+2;

      E1 = E1 .* dsq ./ (jj);
      E2 = E2 .* dsq ./ (jj+1); 
      
      B1 = B1 - R1;
      B2 = B2 - R2;

      R1 = R1 .* tmp .* (jj+nu-1) ./ (jj+1);
      R2 = R2 .* tmp .* (jj+nu) ./ (jj+2);
   end
end

% Return NaN if X is negative or NU is not a positive integer.
p(nu <= 0) = NaN;
