function [k,R0]=ac2rc(R)
%AC2RC  Convert autocorrelation sequence to reflection coefficients. 
%   [K,R0] = AC2RC(R) returns the reflection coefficients, K, and the zero lag
%   autocorrelation, R0, based on the autocorrelation sequence, R.
%
%   See also RC2AC, POLY2RC, RC2POLY, POLY2AC, AC2POLY.

%   References: S. Kay, Modern Spectral Estimation,
%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:15:40 $

[a_unused,efinal,k] = levinson(R);
R0 = R(1);

% [EOF] ac2rc.m

