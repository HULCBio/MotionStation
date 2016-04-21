function y = acsch(z)
%ACSCH  Inverse hyperbolic cosecant.
%   ACSCH(X) is the inverse hyperbolic cosecant of the elements of X.
%
%   See also CSCH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:45 $

y = asinh(1./z);
