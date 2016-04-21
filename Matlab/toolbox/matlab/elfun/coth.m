function y = coth(z)
%COTH   Hyperbolic cotangent.
%   COTH(X) is the hyperbolic cotangent of the elements of X.
%
%   See also ACOTH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:59 $

y = 1./tanh(z);
