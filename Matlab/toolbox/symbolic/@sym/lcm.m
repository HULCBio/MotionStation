function c = lcm(a,b)
%LCM    Least common multiple.
%   C = LCM(A,B) is the symbolic least common multiple of A and B.
%
%   Example:
%      syms x
%      factor(lcm(x^3-3*x^2+3*x-1,x^2-5*x+4))
%      returns (x-1)^3*(x-4)
%
%   See also GCD.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/16 19:36:18 $
 
c = sym(maple('lcm',sym(a),sym(b)));
