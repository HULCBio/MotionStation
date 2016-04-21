function c = colon(a,d,b)
%COLON  Symbolic colon operator.
%   COLON(A,B) overloads symbolic A:B.
%   COLON(A,D,B) overloads symbolic A:D:B.
%
%   Example:
%       0:sym(1/3):1 is [  0, 1/3, 2/3,  1]

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 03:07:46 $

a = sym(a);
if nargin == 2
   b = d;
   d = 1;
end
if d == 0
   c = sym([]);
else
   n = double((b-a)/d);
   c = a + (0:n)*d;
end
