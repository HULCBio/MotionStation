function Y = heaviside(X)
%HEAVISIDE    Symbolic step function.
%    HEAVISIDE(X) is 0 for X < 0, 1 for X > 0, and NaN for X == 0.
%    HEAVISIDE(X) is not a function in the strict sense, but rather
%    a distribution with diff(heaviside(x)) = dirac(x).
%    See also DIRAC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:33 $

Y = maple('map','heaviside',X);
