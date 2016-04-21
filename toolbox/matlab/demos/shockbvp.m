function shockbvp
%SHOCKBVP  The solution has a shock layer near x = 0
%   This is an example used in U. Ascher, R. Mattheij, and R. Russell,
%   Numerical Solution of Boundary Value Problems for Ordinary Differential
%   Equations, SIAM, Philadelphia, PA, 1995,  to illustrate the mesh
%   selection strategy of COLSYS. 
%
%   For 0 < e << 1, the solution of 
%
%       e*y'' + x*y' = -e*pi^2*cos(pi*x) - pi*x*sin(pi*x)
%
%   on the interval [-1,1] with boundary conditions y(-1) = -2 and y(1) = 0
%   has a rapid transition layer at x = 0.
%
%   This example illustrates how a numerically difficult problem (e = 1e-4)
%   can be solved successfully using continuation. For this problem,
%   analytical partial derivatives are easy to derive and the solver benefits
%   from using them.  
%
%   See also BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:35:16 $

% The differential equations written as a first order system and the
% boundary conditions are coded in shockODE and shockBC, respectively. Their
% partial derivatives are coded in shockJac and shockBCJac and passed to the
% solver via the options. The option 'Vectorized' instructs the solver that
% the differential equation function has been vectorized, i.e.
% shockODE([x1 x2 ...],[y1 y2 ...],e) returns [shockODE(x1,y1,e) shockODE(x2,y2,e) ...]. 
% Such coding improves the solver performance. 

options = bvpset('FJacobian',@shockJac,'BCJacobian',@shockBCJac,'Vectorized','on');

% A guess for the initial mesh and the solution
sol = bvpinit([-1 -0.5 0 0.5 1],[1 0]);

% Solution for e = 1e-2, 1e-3, 1e-4 obtained using continuation.
e = 0.1;
for i=2:4
  e = e/10;   
  % e is the problem parameter. bvp4c passes its value to all the functions
  % shockODE, shockBC, shockJac and shockBCJac. 
  sol = bvp4c(@shockODE,@shockBC,sol,options,e);
end

% The final solution 
figure;
plot(sol.x,sol.y(1,:));
axis([-1 1 -2.2 2.2]);
title(['There is a shock at x = 0 when \epsilon =' sprintf('%.e',e) '.']); 
xlabel('x');
ylabel('solution y');

% --------------------------------------------------------------------------

function dydx = shockODE(x,y,e)
%SHOCKODE  Evaluate the ODE function (vectorized)
pix = pi*x;
dydx = [                 y(2,:)
         -x/e.*y(2,:) - pi^2*cos(pix) - pix/e.*sin(pix) ];   

% --------------------------------------------------------------------------

function res = shockBC(ya,yb,e)
%SHOCKBC  Evaluate the residual in the boundary conditions
res = [ ya(1)+2
         yb(1)  ];

% --------------------------------------------------------------------------

function jac = shockJac(x,y,e)
%SHOCKJAC  Evaluate the Jacobian of the ODE function
jac = [ 0   1
        0 -x/e ];

% --------------------------------------------------------------------------

function [dBCdya,dBCdyb] = shockBCJac(ya,yb,e)
%SHOCKBCJAC  Evaluate the partial derivatives of the boundary conditions
dBCdya = [ 1 0
           0 0 ];

dBCdyb = [ 0 0
           1 0 ];

