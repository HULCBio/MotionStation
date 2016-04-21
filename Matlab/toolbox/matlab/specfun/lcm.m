function c = lcm(a,b)
%LCM    Least common multiple.
%   LCM(A,B) is the least common multiple of corresponding elements of
%   A and B.  The arrays A and B must contain positive integers
%   and must be the same size (or either can be scalar).
%
%   See also GCD.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/05/01 20:43:49 $

if any(round(a(:)) ~= a(:) | round(b(:)) ~= b(:) | a(:) < 1 | b(:) < 1)
    error('MATLAB:lcm:InputNotPosInt',...
          'Input arguments must contain positive integers.');
end
c = a.*(b./gcd(a,b));
