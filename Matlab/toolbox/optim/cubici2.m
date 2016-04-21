function step = cubici2(c,f,x)
%CUBICI2 Determine optimizer step from three points and one gradient.
%   STEP = CUBICI2(c,f,x)
%   Finds the cubic p(x) with p(x(1:3)) = f(1:3) and p'(0) = c.
%   Returns the minimizer of p(x) if it is positive.
%   Calls QUADI if the minimizer is negative.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/02/07 19:12:57 $

% p(x) = a/3*x^3 - b*x^2 + c*x + d.
% c = p'(0) is the first input parameter.
% Solve [1/3*x.^3 -1/2*x^2 ones(3,1)]*[a b d]' = f - c*x.
% Compute a and b; don't need d.
%    a = 3*(x1^2*(f2-f3) + x2^2*(f3-f1) + x3^2*(f1-f2))/h
%    b = (x1^3*(f2-f3) + x2^3*(f3-f1) + x3^3*(f1-f2))/h
%    where h = (x1-x2)*(x2-x3)*(x3-x1)*(x1*x2 + x2*x3 + x3*x1).
% Local min and max where p'(s) = a*s^2 - 2*b*s + c = 0
% Local min always comes from plus sign in the quadratic formula.
% If p'(x) has no real roots, step = b/a.
% If step < 0, use quadi instead.

x = x(:);
f = f(:);
g = f - c*x;
g = g([2 3 1]) - g([3 1 2]);
y = x([2 3 1]);
h = prod(x-y)*(x'*y);
a = 3*(x.^2)'*g/h;
b = (x.^3)'*g/h;

% Find minimizer.
step = (b + real(sqrt(b^2-a*c)))/a;

% Is step acceptable?
if step < 0 | ~isfinite(step)
   step = abs(quadi(x,f));
end
if isnan(step)
   step = x(2)/2;
end
