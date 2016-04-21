function mat4bvp
%MAT4BVP  Find the fourth eigenvalue of the Mathieu's equation.
%   Find the fourth eigenvalue of Mathieu's equation
%   
%      y'' + (lambda - 2*q*cos(2*x))*y = 0
%   
%   on the interval [0, pi] with boundary conditions y'(0) = 0, y'(pi) = 0
%   when the parameter q = 5.
%
%   Special codes for Sturm-Liouville problems can compute specific
%   eigenvalues. The general-purpose code BVP4C can only compute an
%   eigenvalue near to a guessed value. We can make it much more likely that
%   we compute the eigenfunction corresponding to the fourth eigenvalue by
%   supplying a guess that has the correct qualitative behavior. 
%   The eigenfunction y(x) is determined only to a constant multiple, so the
%   normalizing condition y(0) = 1 is used to specify a particular solution.
%
%   Plotting the solution on the mesh found by BVP4C does not result in a
%   smooth graph. The solution S(x) is continuous and has a continuous
%   derivative. It can be evaluated inexpensively using DEVAL at as many
%   points as necessary to get a smooth graph.  
%   
%   See also BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:35:00 $

% BVPINT is used to form an initial guess for a mesh of 10 equally spaced
% points. The guess cos(4x) for y(x) and its derivative as guess for y'(x)
% are evaluated in MAT4INIT. The desired eigenvalue is the one nearest the
% guess lambda = 15. A guess for unknown parameters is the last argument of
% BVPINIT.  
lambda = 15;
solinit = bvpinit(linspace(0,pi,10),@mat4init,lambda);

% BVP4C returns the structure 'sol'. The computed eigenvalue is returned in
% the field sol.parameters. 
sol = bvp4c(@mat4ode,@mat4bc,solinit);

fprintf('The fourth eigenvalue is approximately %7.3f.\n',sol.parameters)

% Plotting the solution just at the mesh points does not result in a smooth
% graph near the ends of the interval. The approximate solution S(x) is
% continuous and has a continuous derivative. DEVAL is used to evaluate it
% at enough points to get a smooth graph. 
xint = linspace(0,pi);
Sxint = deval(sol,xint);
figure;
plot(xint,Sxint(1,:));
axis([0 pi -1 1.1]);
title('Eigenfunction of Mathieu''s equation.'); 
xlabel('x');
ylabel('solution y');

% --------------------------------------------------------------------------

function dydx = mat4ode(x,y,lambda)
q = 5;
dydx = [              y(2)
         -(lambda - 2*q*cos(2*x))*y(1) ];

% --------------------------------------------------------------------------
  
function res = mat4bc(ya,yb,lambda)
res = [  ya(2) 
         yb(2) 
        ya(1)-1 ];

% --------------------------------------------------------------------------

function yinit = mat4init(x)
yinit = [   cos(4*x)
          -4*sin(4*x) ];
