function Y = floor(X)
%FLOOR  Symbolic matrix element-wise floor.
%   Y = FLOOR(X) is the matrix of the greatest integers <= X.
%   Example:
%      x = sym(-5/2)
%      [fix(x) floor(x) round(x) ceil(x) frac(x)]
%      = [ -2, -3, -3, -2, -1/2]
%
%   See also ROUND, CEIL, FIX, FRAC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:29 $

Y = maple('map','floor',X);
