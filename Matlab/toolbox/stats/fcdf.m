function p = fcdf(x,v1,v2);
%FCDF   F cumulative distribution function.
%   P = FCDF(X,V1,V2) returns the F cumulative distribution function
%   with V1 and V2 degrees of freedom at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.2.3 $  $Date: 2004/02/01 22:10:21 $

if nargin < 3, 
    error('stats:fcdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x v1 v2] = distchck(3,x,v1,v2);

if errorcode > 0
    error('stats:fcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end

t = (v1 <= 0 | v2 <= 0 | isnan(x) | isnan(v1) | isnan(v2));
p(t) = NaN;
s = (x==Inf) & ~t;
if any(s(:))
   p(s) = 1;
   t = t | s;
end

% Compute P when X > 0.
k = find(x > 0 & ~t & isfinite(v1) & isfinite(v2));
if any(k), 
% use A&S formula 26.6.2 to relate to incomplete beta function 
    % Also use 26.5.2 to avoid cancellation by subtracting from 1
    xx = x(k)./(x(k) + v2(k)./v1(k));
    p(k) = betainc(xx, v1(k)/2, v2(k)/2);
end

if any(~isfinite(v1(:)) | ~isfinite(v2(:)))
   k = find(x > 0 & ~t & isfinite(v1) & ~isfinite(v2) & v2>0);
   if any(k)
      p(k) = chi2cdf(v1(k).*x(k),v1(k));
   end
   k = find(x > 0 & ~t & ~isfinite(v1) & v1>0 & isfinite(v2));
   if any(k)
      p(k) = 1 - chi2cdf(v2(k)./x(k),v2(k));
   end
   k = find(x > 0 & ~t & ~isfinite(v1) & v1>0 & ~isfinite(v2) & v2>0);
   if any(k)
      p(k) = (x(k)>=1);
   end
end
