function x = tinv(p,v);
%TINV   Inverse of Student's T cumulative distribution function (cdf).
%   X=TINV(P,V) returns the inverse of Student's T cdf with V degrees 
%   of freedom, at the values in P.
%
%   The size of X is the common size of P and V. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.2

%   B.A. Jones 1-18-93
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.2.3 $  $Date: 2004/01/24 09:37:01 $

if nargin < 2, 
    error('stats:tinv:TooFewInputs','Requires two input arguments.'); 
end

[errorcode p v] = distchck(2,p,v);

if errorcode > 0
    error('stats:tinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero, or NaN for invalid d.f.
if isa(p,'single')
    x = zeros(size(p),'single');
else
    x = zeros(size(p));
end
x(v <= 0) = NaN;

k = find(v == 1 & ~isnan(x));
if any(k)
  x(k) = tan(pi * (p(k) - 0.5));
end

% The inverse cdf of 0 is -Inf, and the inverse cdf of 1 is Inf.
k0 = find(p == 0 & ~isnan(x));
if any(k0)
    tmp   = Inf;
    x(k0) = -tmp(ones(size(k0)));
end
k1 = find(p ==1 & ~isnan(x));
if any(k1)
    tmp   = Inf;
    x(k1) = tmp(ones(size(k1)));
end

% For small d.f., call betainv which uses Newton's method
k = find(p >= 0.5 & p < 1 & ~isnan(x) & v < 1000);
if any(k)
    z = betainv(2*(1-p(k)),v(k)/2,0.5);
    x(k) = sqrt(v(k) ./ z - v(k));
end

k = find(p < 0.5 & p > 0 & ~isnan(x) & v < 1000);
if any(k)
    z = betainv(2*(p(k)),v(k)/2,0.5);
    x(k) = -sqrt(v(k) ./ z - v(k));
end

% For large d.f., use Abramowitz & Stegun formula 26.7.5
k = find(p>0 & p<1 & ~isnan(x) & v >= 1000);
if any(k)
   xn = norminv(p(k));
   df = v(k);
   x(k) = xn + (xn.^3+xn)./(4*df) + ...
           (5*xn.^5+16.*xn.^3+3*xn)./(96*df.^2) + ...
           (3*xn.^7+19*xn.^5+17*xn.^3-15*xn)./(384*df.^3) +...
           (79*xn.^9+776*xn.^7+1482*xn.^5-1920*xn.^3-945*xn)./(92160*df.^4);
end