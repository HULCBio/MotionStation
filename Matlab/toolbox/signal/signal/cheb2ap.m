function [z,p,k] = cheb2ap(n, rs)
%CHEB2AP Chebyshev Type II analog lowpass filter prototype.
%   [Z,P,K] = CHEB2AP(N,Rs) returns the zeros, poles, and gain
%   of an N-th order normalized analog prototype Chebyshev Type II
%   lowpass filter with Rs decibels of ripple in the stopband.
%   Chebyshev Type II filters are maximally flat in the passband.
%
%   See also CHEBY2, CHEB2ORD, BUTTAP, CHEB1AP, ELLIPAP.

%   Author(s): L. Shure, 1-13-88
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:10:07 $

delta = 1/sqrt(10^(.1*rs)-1);
mu = asinh(1/delta)/n;
if (rem(n,2))
	m = n - 1;
	z = j ./ cos([1:2:n-2 n+2:2:2*n-1]*pi/(2*n))';
else
	m = n;
	z = j ./ cos((1:2:2*n-1)*pi/(2*n))';
end
% Organize zeros in complex pairs:
i = [1:m/2; m:-1:m/2+1];
z = z(i(:));

p = exp(j*(pi*(1:2:2*n-1)/(2*n) + pi/2)).';
p = sinh(mu)*real(p) + j*cosh(mu)*imag(p);
p = 1 ./ p;
k = real(prod(-p)/prod(-z));

