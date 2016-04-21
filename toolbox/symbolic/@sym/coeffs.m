function [c,t] = coeffs(p,x)
%COEFFS Coefficients of a multivariate polynomial.
%   C = COEFFS(P) returns the coefficients of the polynomial P with
%   respect to all the indeterminates of P.
%   C = COEFFS(P,X) returns the coefficients of the polynomial P with
%   respect to X.
%   [C,T] = COEFFS(P,X) also returns an expression sequence of the
%   terms of P.  There is a one-to-one correspondence between the
%   coefficients and the terms of P. 
%
%   Examples:
%      syms x
%      t = 2 + (3 + 4*log(x))^2 - 5*log(x);
%      coeffs(expand(t)) = [ 11, 19, 16]      
%
%      syms a b c x
%      y = a + b*sin(x) + c*sin(2*x)
%      coeffs(y,sin(x)) = [a+c*sin(2*x), b]
%      coeffs(expand(y),sin(x)) = [a, b+2*c*cos(x)]
%      
%      syms x y
%      z = 3*x^2*y^2 + 5*x*y^3
%      coeffs(z) = [3, 5] 
%      coeffs(z,x) = [5*y^3, 3*y^2]
%      [c,t] = coeffs(z,y) returns c = [3*x^2, 5*x], t = [y^2, y^3]
%
%   See also SYM2POLY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:11 $

if nargin == 1 && nargout < 2
   c = maple('coeffs',p);
elseif nargout < 2
   c = maple('coeffs',p,x);
else
   c = maple('coeffs',p,x,'''_ans''');
   t = sym(maple('_ans'));
   maple('_ans := ''_ans''');
end
