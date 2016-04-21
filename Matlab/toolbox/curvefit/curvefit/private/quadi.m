function step = quadi(x,f)
%QUADI Determine optimizer step from three points.
%   STEP = QUADI(x,f)
%   Finds the quadratic p(x) with p(x(1:3)) = f(1:3).
%   Returns the minimizer (or maximizer) of p(x).

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:43:36 $

% p(x) = a*x^2 + b*x + c.
% Solve [x.^2 x ones(3,1)]*[a b c]' = f.
% Minimum at p'(s) = 0,
% s = -b/(2*a) = (x1^2*(f2-f3) + x2^2*(f3-f1) + x3^2*(f1-f2))/ ...
%                 (x1*(f2-f3) + x2*(f3-f1) + x3*(f1-f2))/2

x = x(:); 
f = f(:);
g = f([2 3 1]) - f([3 1 2]);
step = ((x.*x)'*g)/(x'*g)/2;
