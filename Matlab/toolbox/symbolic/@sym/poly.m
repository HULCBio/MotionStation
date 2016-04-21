function p = poly(A,x)
%POLY   Symbolic characteristic polynomial.
%   POLY(A) computes the characteristic polynomial of the SYM matrix A.
%   The result is a symbolic polynomial in 'x' or 't'
%
%   POLY(A,v) uses 'v' instead of 'x'. v is a SYM.
%
%   Example:  
%      poly([a b; c d]) returns x^2-x*d-a*x+a*d-b*c.
%
%   See also POLY, POLY2SYM, SYM2POLY, JORDAN, EIG, SOLVE.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/04/15 03:07:31 $

A = sym(A);

if nargin < 2
   s = findsym(A);
   if isempty(findstr(s,'x'))
      x = sym('x');
   else
      x = sym('t');
   end
end
if all(size(A) == 1)
   p = x-A;
else
   p = maple('charpoly',A,x);
end
