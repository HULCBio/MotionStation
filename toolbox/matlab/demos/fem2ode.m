function fem2ode(N)
%FEM2ODE  Stiff problem with a constant mass matrix, M*y' = f(t,y).
%   The parameter N controls the discretization, and the resulting system
%   consists of N equations.  For example, to solve a 20x20 system, use   
%       fem2ode(20)
%   By default, N is 9.  
%
%   F(T,Y,N) returns the derivatives vector for a finite element
%   discretization of a partial differential equation.  By default, the
%   solvers of the ODE Suite solve systems of the form y' = f(t,y).  To solve
%   a system My'=f(t,y), use ODESET to set the property 'Mass' to a constant
%   matrix M. 
%
%   See also ODE23S, ODE15S, ODE23T, ODE23TB, ODESET, @.

%   Mark W. Reichelt and Lawrence F. Shampine, 11-11-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.21.4.1 $  $Date: 2002/09/26 01:51:17 $

if nargin < 1
  N = 9;
end
tspan = [0; pi];
y0 = sin((pi/(N+1))*(1:N)');

% Constant mass matrix
e = repmat(pi/(6*(N+1)),N,1);     % h=pi/(N+1); e=(h/6)+zeros(N,1);
M = spdiags([e 4*e e], -1:1, N, N);  % mass matrix

options = odeset('Mass',M);

[t,y] = ode23s(@f,tspan,y0,options,N);

figure;
surf(1:N,t,y);
set(gca,'ZLim',[0 1]);
view(142.5,30);
title(['Finite element problem with constant mass matrix, ' ...
       'solved by ODE23S']);
xlabel('space');
ylabel('time');
zlabel('solution');

% --------------------------------------------------------------------------

function dydt = f(t,y,N)
e = repmat(exp(t)*(N+1)/pi,N,1);   % h=pi/(N+1); e=(exp(t)/h)+zeros(N,1);
d = repmat(-2*exp(t)*(N+1)/pi,N,1);
R = spdiags([e d e], -1:1, N, N);  
dydt = R * y;

