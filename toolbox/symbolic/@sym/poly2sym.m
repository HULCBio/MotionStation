function p = poly2sym(c,x)
%POLY2SYM Polynomial coefficient vector to symbolic polynomial.
%   POLY2SYM(C,V) is a polynomial in the symbolic variable V
%   with coefficients from the vector C.
% 
%   Example:
%       x = sym('x');
%       poly2sym([1 0 -2 -5],x)
%   is
%       x^3-2*x-5
%
%   See also SYM2POLY, POLYVAL.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:06:49 $

p = sym(0);
for a = c(:).'
   p = p*x + a;
end
p = expand(p);
