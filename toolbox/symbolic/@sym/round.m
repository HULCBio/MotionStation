function Y = round(X)
%ROUND  Symbolic matrix element-wise round.
%   Y = ROUND(X) rounds the elements of X to the nearest integers.
%   Values halfway between two integers are rounded away from zero.
%   Example:
%      x = sym(-5/2)
%      [fix(x) floor(x) round(x) ceil(x) frac(x)]
%      = [ -2, -3, -3, -2, -1/2]
%
%   See also FLOOR, CEIL, FIX, FRAC.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:23:05 $

Y = maple('map','round',X);
