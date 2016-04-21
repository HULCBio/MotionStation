function y = gffilter(b, a, x, p)
%GFFILTER Filter data using polynomials over a prime Galois field.
%   Y = GFFILTER(B, A, X) filters the data in vector X with the filter
%   described by vectors B and A.  The vectors B, A and X must be in GF(2),
%   that is, be binary and Y is also in GF(2).
%
%   Y = GFFILTER(B, A, X, P) filters the data X using the filter described
%   by vectors B and A.  All entries of B, A and X must be in GF(P), that
%   is, be integers between 0 and P-1, where P is a prime number.
%
%   B and A are row vectors that specify the polynomial coefficients in
%   order of ascending powers.
%
%   See also GFCONV, GFADD, FILTER.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.15 $ $Date: 2002/03/27 00:07:38 $

%   One may directly use the built-in function filter. However, the
%   computation may not be accurate if the computation order is high.
