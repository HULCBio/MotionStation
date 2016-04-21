function y = sech(z)
%SECH   Hyperbolic secant.
%   SECH(X) is the hyperbolic secant of the elements of X.
%
%   See also ASECH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:18 $

y = 1./cosh(z);
