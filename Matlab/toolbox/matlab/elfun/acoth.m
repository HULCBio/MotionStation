function y = acoth(z)
%ACOTH  Inverse hyperbolic cotangent.
%   ACOTH(X) is the inverse hyperbolic cotangent of the elements of X.
%
%   See also COTH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:43 $

y = atanh(1./z);
