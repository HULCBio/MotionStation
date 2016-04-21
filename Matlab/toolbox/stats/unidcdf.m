function p = unidcdf(x,n);
%UNIDCDF Uniform (discrete) cumulative distribution function.
%   P = UNIDCDF(X,N) returns the cumulative distribution function
%   for a random variable uniform on (1,2,...,N), at the values in X.
%
%   The size of P is the common size of X and N. A scalar input   
%   functions as a constant matrix of the same size as the other input.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.3 $  $Date: 2004/01/24 09:37:11 $

if nargin < 2, 
    error('stats:unidcdf:TooFewInputs','Requires two input arguments.'); 
end

[errorcode x n] = distchck(2,x,n);

if errorcode > 0
    error('stats:unidcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end

% P = 1 when X >= N
k2 = find(x >= n);
if any(k2);
    p(k2) = ones(size(k2));
end

xx=floor(x);

k = find(xx >= 1 & xx <= n);
if any(k),
    p(k) = xx(k) ./ n(k);
end

k1 = find(n < 1 | round(n) ~= n);
if any(k1)
    tmp   = NaN;
    p(k1) = tmp(ones(size(k1)));
end
