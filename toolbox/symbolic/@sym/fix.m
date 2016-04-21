function Y = fix(X)
%FIX    Symbolic matrix element-wise integer part.
%   Y = FIX(X) is the matrix of the integer parts of X.
%   FIX(X) = FLOOR(X) if X is positive and CEIL(X) if X is negative.
%
%   See also ROUND, CEIL, FLOOR, FRAC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:28 $

Y = maple('map','trunc',X);
