function [z,p,k] = cheb1ap(n, rp)
%CHEB1AP Chebyshev Type I analog lowpass filter prototype.
%   [Z,P,K] = CHEB1AP(N,Rp) returns the zeros, poles, and gain
%   of an N-th order normalized analog prototype Chebyshev Type I
%   lowpass filter with Rp decibels of ripple in the passband.
%   Chebyshev Type I filters are maximally flat in the stopband.
%
%   See also CHEBY1, CHEB1ORD, BUTTAP, CHEB2AP, ELLIPAP.

%   Author(s): L. Shure, 1-13-88
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:10:01 $

epsilon = sqrt(10^(.1*rp)-1);
mu = asinh(1/epsilon)/n;
p = exp(j*(pi*(1:2:2*n-1)/(2*n) + pi/2)).';
p = sinh(mu)*real(p) + j*cosh(mu)*imag(p);
z = [];
k = real(prod(-p));
if ~rem(n,2)	% n is even so patch k
	k = k/sqrt((1 + epsilon^2));
end
