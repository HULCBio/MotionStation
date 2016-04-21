function [num,den] = polyallpasssub(b,a,allpassnum,allpassden)
%POLYALLPASSSUB   Substitute delays in polynomials with allpass filters.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:39:27 $

% Remove possible trailing zeros and get polynomial lengths
b = b(1:max(find(b~=0))); M = length(b);
a = a(1:max(find(a~=0))); N = length(a);

% Compute temporary numerator
tempnum = newpoly(b,allpassnum,allpassden,M);

% Compute temporary denominator
tempden = newpoly(a,allpassnum,allpassden,N);

% Now include common denominators
num = conv(tempnum,polypow(allpassden,N-M));
den = conv(tempden,polypow(allpassden,M-N));
%-------------------------------------------------------------------
function temppoly = newpoly(b,allpassnum,allpassden,M)
% Compute new polynomial after substitution


% For each coefficient, we will have a resulting polynomial after we
% substitute, form each polynomial and then add them all up to compute
% the new numerator or denominator.
for n = 1:M,
	temppoly(n,:) = b(n).*conv(polypow(allpassden,M-n),...
		polypow(allpassnum,n-1));
end

temppoly = sum(temppoly);

%-------------------------------------------------------------------
function p = polypow(q,N)
%POLYPOW   Evaluate polynomial to power of N.


% Initialize recursion
p = 1;

% Return early if order is zero or negative
if N <= 0,
	return
end

% Multiply polynomial by q, N times
for n = 1:N,
	p = conv(p,q);
end
