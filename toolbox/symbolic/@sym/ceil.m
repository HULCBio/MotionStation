function Y = ceil(X)
%CEIL   Symbolic matrix element-wise ceiling.
%   Y = CEIL(X) is the matrix of the smallest integers >= X.
%   Example:
%      x = sym(-5/2)
%      [fix(x) floor(x) round(x) ceil(x) frac(x)]
%      = [ -2, -3, -3, -2, -1/2]
%
%   See also ROUND, FLOOR, FIX, FRAC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:09 $

Y = maple('map','ceil',X);
