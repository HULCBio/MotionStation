function brussode(N)
%BRUSSODE  Stiff problem modelling a chemical reaction (the Brusselator).
%   The parameter N >= 2 is used to specify the number of grid points; the
%   resulting system consists of 2N equations. By default, N is 20.  The
%   problem becomes increasingly stiff and increasingly sparse as N is
%   increased.  The Jacobian for this problem is a sparse constant matrix
%   (banded with bandwidth 5). 
%   
%   The property 'JPattern' is used to provide the solver with a sparse
%   matrix of 1's and 0's showing the locations of nonzeros in the Jacobian
%   df/dy.  By default, the stiff solvers of the ODE Suite generate Jacobians
%   numerically as full matrices.  However, when a sparsity pattern is
%   provided, the solver uses it to generate the Jacobian numerically as a
%   sparse matrix.  Providing a sparsity pattern can significantly reduce the
%   number of function evaluations required to generate the Jacobian and can
%   accelerate integration.  For the BRUSSODE problem, only 4 evaluations of
%   the function are needed to compute the 2N x 2N Jacobian matrix. 
%   
%   Setting the 'Vectorized' property indicates the function f is
%   vectorized. 
%   
%   E. Hairer and G. Wanner, Solving Ordinary Differential Equations II,
%   Stiff and Differential-Algebraic Problems, Springer-Verlag, Berlin,
%   1991, pp. 5-8.
%   
%   See also ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.

%   Mark W. Reichelt and Lawrence F. Shampine, 8-30-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/15 03:30:40 $

if nargin<1  
  N = 20;
end

tspan = [0; 10];
y0 = [1+sin((2*pi/(N+1))*(1:N)); repmat(3,1,N)];

options = odeset('Vectorized','on','JPattern',jpattern(N));

[t,y] = ode15s(@f,tspan,y0,options,N);

u = y(:,1:2:end);
x = (1:N)/(N+1);
figure;
surf(x,t,u);
view(-40,30);
xlabel('space');
ylabel('time');
zlabel('solution u');
title(['The Brusselator for N = ' num2str(N)]);

% --------------------------------------------------------------------------

function dydt = f(t,y,N)
c = 0.02 * (N+1)^2;
dydt = zeros(2*N,size(y,2));      % preallocate dy/dt

% Evaluate the 2 components of the function at one edge of the grid
% (with edge conditions).
i = 1;
dydt(i,:) = 1 + y(i+1,:).*y(i,:).^2 - 4*y(i,:) + c*(1-2*y(i,:)+y(i+2,:));
dydt(i+1,:) = 3*y(i,:) - y(i+1,:).*y(i,:).^2 + c*(3-2*y(i+1,:)+y(i+3,:));

% Evaluate the 2 components of the function at all interior grid points.
i = 3:2:2*N-3;
dydt(i,:) = 1 + y(i+1,:).*y(i,:).^2 - 4*y(i,:) + ...
    c*(y(i-2,:)-2*y(i,:)+y(i+2,:));
dydt(i+1,:) = 3*y(i,:) - y(i+1,:).*y(i,:).^2 + ...
    c*(y(i-1,:)-2*y(i+1,:)+y(i+3,:));

% Evaluate the 2 components of the function at the other edge of the grid
% (with edge conditions).
i = 2*N-1;
dydt(i,:) = 1 + y(i+1,:).*y(i,:).^2 - 4*y(i,:) + c*(y(i-2,:)-2*y(i,:)+1);
dydt(i+1,:) = 3*y(i,:) - y(i+1,:).*y(i,:).^2 + c*(y(i-1,:)-2*y(i+1,:)+3);

% --------------------------------------------------------------------------

function S = jpattern(N)
B = ones(2*N,5);
B(2:2:2*N,2) = zeros(N,1);
B(1:2:2*N-1,4) = zeros(N,1);
S = spdiags(B,-2:2,2*N,2*N);
