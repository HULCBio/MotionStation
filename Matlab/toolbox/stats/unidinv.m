function x = unidinv(p,n);
%UNIDINV Inverse of uniform (discrete) distribution function.
%   X = UNIDINV(P,N) returns the inverse of the uniform
%   (discrete) distribution function at the values in P.
%   X takes the values (1,2,...,N).
%   
%   The size of X is the common size of P and N. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.3 $  $Date: 2004/01/24 09:37:12 $

if nargin < 2, 
    error('stats:unidinv:TooFewInputs','Requires two input arguments.'); 
end

[errorcode p n] = distchck(2,p,n);

if errorcode > 0
    error('stats:unidinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize X to zero.
if isa(p,'single')
    x = zeros(size(p),'single');
else
    x = zeros(size(p));
end

%   Return NaN if the arguments are outside their respective limits.
k1 = find(p <= 0 | p > 1 | n < 1 | round(n) ~= n);
if any(k1),
    tmp   = NaN;
    x(k1) = tmp(ones(size(k1)));
end

k = find(p > 0 & p <= 1 & n >= 1 & round(n) == n);
if any(k)
    x(k) = ceil(n(k) .* p(k));
end
