function y = csch(z)
%CSCH   Hyperbolic cosecant.
%   CSCH(X) is the hyperbolic cosecant of the elements of X.
%
%   See also ACSCH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:00 $

y = 1./sinh(z);

