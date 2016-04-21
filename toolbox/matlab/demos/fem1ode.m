function fem1ode(N)
%FEM1ODE  Stiff problem with a time-dependent mass matrix, M(t)*y' = f(t,y).
%   The parameter N controls the discretization, and the resulting system
%   consists of N equations. By default, N is 19.  
%
%   In this example, the subfunction f(T,Y,N) returns the derivatives vector
%   for a finite element discretization of a partial differential equation.
%   The subfunction mass(T,N) returns the time-dependent mass matrix M
%   evaluated at time T. By default, the solvers of the ODE Suite solve
%   systems of the form y' = f(t,y).  To solve a system M(t)y'=f(t,y), use
%   ODESET to set the property 'Mass' to a function the evaluates M(t) and
%   set 'MStateDependence' to 'none'.
%   
%   In this problem the Jacobian df/dy is a constant, tri-diagonal
%   matrix. The 'Jacobian' property is used to provide df/dy to the solver.
%
%   See also ODE15S, ODE23T, ODE23TB, ODESET, @.

%   Mark W. Reichelt and Lawrence F. Shampine, 11-11-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/04/15 03:30:42 $

if nargin < 1
  N = 19;
end
h = pi/(N+1);
y0 = sin(h*(1:N)');
tspan = [0; pi];

% the Jacobian is constant
e = repmat(1/h,N,1);    %  e=[(1/h) ... (1/h)];
d = repmat(-2/h,N,1);   %  d=[(-2/h) ... (-2/h)]; 
J = spdiags([e d e], -1:1, N, N);

options = odeset('Mass',@mass,'MStateDependence','none','Jacobian',J);

[t,y] = ode15s(@f,tspan,y0,options,N);

figure;
surf((1:N)/(N+1),t,y);
set(gca,'ZLim',[0 1]);
view(142.5,30);
title(['Finite element problem with time-dependent mass matrix, ' ...
       'solved by ODE15S']);
xlabel('space ( x/\pi )');
ylabel('time');
zlabel('solution');

% --------------------------------------------------------------------------

function out = f(t,y,N)
h = pi/(N+1);
e = repmat(1/h,N,1);    %  e=[(1/h) ... (1/h)];
d = repmat(-2/h,N,1);   %  d=[(-2/h) ... (-2/h)]; 
J = spdiags([e d e], -1:1, N, N);
out = J*y;

% --------------------------------------------------------------------------

function M = mass(t,N)
h = pi/(N+1);
e = repmat(exp(-t)*h/6,N,1);  % e(i)=exp(-t)*h/6
e4 = repmat(4*exp(-t)*h/6,N,1); 
M = spdiags([e e4 e], -1:1, N, N);


