function x = finv(p,v1,v2);
%FINV   Inverse of the F cumulative distribution function.
%   X=FINV(P,V1,V2) returns the inverse of the F distribution 
%   function with V1 and V2 degrees of freedom, at the values in P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.6.2

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.2.3 $  $Date: 2004/01/24 09:33:45 $

if nargin <  3, 
    error('stats:finv:TooFewInputs','Requires three input arguments.'); 
end

[errorcode p v1 v2] = distchck(3,p,v1,v2);

if errorcode > 0
    error('stats:finv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if isa(p,'single')
   x = zeros(size(p),'single');
else
   x = zeros(size(p));
end

k = (v1 <= 0 | v2 <= 0 | isnan(p));
if any(k(:))
   x(k) = NaN;
end

k1 = (p > 0 & p < 1 & v1 > 0 & v2 > 0);
if any(k1(:))
    z = betainv(1 - p(k1),v2(k1)/2,v1(k1)/2);
    x(k1) = (v2(k1) ./ z - v2(k1)) ./ v1(k1);
end

k2 = (p == 1 & v1 > 0 & v2 > 0);
if any(k2(:))
   x(k2) = Inf;
end
