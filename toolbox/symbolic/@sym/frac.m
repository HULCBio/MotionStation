function Y = frac(X)
%FRAC  Symbolic matrix element-wise fractional part.
%   Y = FRAC(X) is the matrix of the fractional part of the elements of X.
%   FRAC(X) = X - FIX(X).
%   Example:
%      x = sym(-5/2)
%      [fix(x) floor(x) round(x) ceil(x) frac(x)]
%      = [ -2, -3, -3, -2, -1/2]
%
%   See also ROUND, CEIL, FLOOR, FIX.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:31 $

Y = maple('map','frac',X);
