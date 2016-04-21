function r = expand(s)
%EXPAND Symbolic expansion.
%   EXPAND(S) writes each element of a symbolic expression S as a
%   product of its factors.  EXPAND is most often used on polynomials,
%   but also expands trigonometric, exponential and logarithmic functions.
%
%   Examples:
%      expand((x+1)^3)   returns  x^3+3*x^2+3*x+1
%      expand(sin(x+y))  returns  sin(x)*cos(y)+cos(x)*sin(y)
%      expand(exp(x+y))  returns  exp(x)*exp(y)
%
%   See also SIMPLIFY, SIMPLE, FACTOR, COLLECT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:21 $

r = reshape(maple('map','expand',s(:)),size(s));
