function Y = heaviside(X)
%HEAVISIDE    Step function.
%    HEAVISIDE(X) is 0 for X < 0, 1 for X > 0, and NaN for X == 0.
%    HEAVISIDE(X) is not a function in the strict sense.
%    See also DIRAC.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:24 $

Y = zeros(size(X));
Y(X > 0) = 1;
Y(X == 0) = NaN;
