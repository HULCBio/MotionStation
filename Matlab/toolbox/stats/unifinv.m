function x = unifinv(p,a,b)
%UNIFINV Inverse of uniform (continuous) distribution function.
%   X = UNIFINV(P,A,B) returns the inverse of the uniform
%   (continuous) distribution function on the interval [A,B],
%   at the values in P. By default A = 0 and B = 1.
%
%   The size of X is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.    

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.3 $  $Date: 2004/01/24 09:37:17 $

if nargin < 1, 
    error('stats:unifinv:TooFewInputs',...
          'Requires at least one input argument.'); 
end

if nargin == 1
    a = 0;
    b = 1;
end

[errorcode p a b] = distchck(3,p,a,b);

if errorcode > 0
    error('stats:unifinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize X to zero.
if isa(p,'single')
    x = zeros(size(p),'single');
else
    x = zeros(size(p));
end

%   Return NaN if the arguments are outside their respective limits.
k1 = find(a >= b | p < 0 | p > 1);
if any(k1)
    tmp   = NaN;
    x(k1) = tmp(ones(size(k1)));
end

k = find(~(a >= b | p < 0 | p > 1));
if any(k)
    x(k) = a(k) + p(k) .* (b(k) - a(k));
end
