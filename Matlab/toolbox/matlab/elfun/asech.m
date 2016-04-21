function y = asech(z)
%ASECH  Inverse hyperbolic secant.
%   ASECH(X) is the inverse hyperbolic secant of the elements of X.
%
%   See also SECH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:47 $

y = acosh(1./z);
