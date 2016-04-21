%SYMEQNDEMO Demonstrate symbolic equation solving.

%  Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.8 $  $Date: 2002/04/15 03:14:05 $

if any(get(0,'children') == 3), close(3), end
echo on
clc

% Demonstrate symbolic equation solving.

% The "solve" and "dsolve" functions seek analytic solutions
% to algebraic and ordinary differential equations.

pause % Strike any key to continue.
clc

% The first example is a simple quadratic.
% You can either find the zeros of a symbolic expression, without quotes:

syms a b c x
x = solve(a*x^2 + b*x + c);

% Or, you can find the roots of an equation, given in quotes:

x = solve('a*x^2 + b*x + c = 0');

% Both of these produce the same result:

x

pause % Strike any key to continue.
clc

% The solution to a general cubic is:

x = solve('a*x^3 + b*x^2 + c*x + d')

pause % Strike any key to continue.

pretty(x)

pause % Strike any key to continue.
clc

% The statment

x = solve('p*sin(x) = r');

% chooses 'x' as the unknown and returns

x

pause % Strike any key to continue.
clc

% A system of two quadratic equations in two unknowns produces solution vectors.

[x,y] = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0')

pause % Strike any key to continue.
clc

% The solution can also be returned in a structure.

S = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0')
S.x
S.y

pause % Strike any key to continue.
clc

% The next example regards 'a' as a parameter and solves two
% equations for u and v.

[u,v] = solve('a*u^2 + v^2 = 0','u - v = 1')

pause % Strike any key to continue.
clc

% Add a third equation and solve for all three unknowns.

[a,u,v] = solve('a*u^2 + v^2','u - v = 1','a^2 - 5*a + 6')

pause % Strike any key to continue.
clc

% If an analytic solution cannot be found, "solve" returns a numeric solution.

digits(32)
[x,y] = solve('sin(x+y)-exp(x)*y = 0','x^2-y = 2')

pause % Strike any key to continue.
clc

% Similar notation, with "D" denoting differentiation, is used for
% for ordinary differential equations by the "dsolve" function.

y = dsolve('Dy = -a*y')

pause % Strike any key to continue.

% Specify an initial condition.

y = dsolve('Dy = -a*y','y(0) = 1')

pause % Strike any key to continue.
clc

% The second derivative is denoted by "D2'.

y = dsolve('D2y = -a^2*y', 'y(0) = 1, Dy(pi/a) = 0')


pause % Strike any key to continue.
clc

% A nonlinear equation produces two solutions in a vector.

y = dsolve('(Dy)^2 + y^2 = 1','y(0) = 0')

pause % Strike any key to terminate.
clc
echo off
