function R=rc2ac(k,R0)
%RC2AC  reflection coefficients to autocorrelation sequence.
%   R = RC2AC(K,R0) returns the autocorrelation sequence, R, based on the 
%   reflection coefficients, K, and the zero lag autocorrelation, R0.
%   R is a vector that contains the autocorrelation samples at lags
%   0,1,2,...,P, where P is the length of K.
%
%   See also AC2RC, POLY2AC, AC2POLY, POLY2RC, RC2POLY.

%   References: S. Kay, Modern Spectral Estimation,
%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:15:37 $

[a,efinal] = rc2poly(k,R0);
R = rlevinson(a,efinal);

% [EOF] rc2ac.m

