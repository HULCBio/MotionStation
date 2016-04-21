function fsbvp
%FSBVP  Continuation by varying an end point.
%   Falkner-Skan BVPs arise from similarity solutions of viscous,
%   incompressible, laminar flow over a flat plate. An example is
%         f''' + f*f'' + beta*(1-(f')^2) = 0
%   with f(0) = 0, f'(0) = 0, f'(infinity) = 1 and beta = 0.5. 
%
%   The BVP is solved by imposing the boundary condition at infinity 
%   at a finite point 'infinity'. Continuation in this end point is 
%   used to get convergence for large values of 'infinity' and to gain 
%   confidence from consistent results that 'infinity' is big enough.  
%   The solution for one value of 'infinity' is extended to a guess for 
%   a bigger 'infinity' using BVPINIT.
%
%   See also BVP4C, BVPINIT, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/15 03:34:58 $

infinity = 3;
maxinfinity = 6;

% This constant guess satisfying the boundary conditions
% is good enough to get convergence when 'infinity' = 3.
solinit = bvpinit(linspace(0,infinity,5),[0 0 1]);
sol = bvp4c(@fsode,@fsbc,solinit);
eta = sol.x;
f = sol.y;

% Reference solution from T. Cebeci and H.B. Keller, Shooting and parallel
% shooting methods for solving the Falkner-Skan boundary-layer equation, J. 
% Comp. Phy., 7 (1971) p. 289-300. 
fprintf('\n');
fprintf('Cebeci & Keller report that f''''(0) = 0.92768.\n')
fprintf('Value computed using infinity = %g is %7.5f.\n',infinity,f(3,1))
  
figure
plot(eta,f(2,:),eta(end),f(2,end),'o');
axis([0 maxinfinity 0 1.4]);
title('Falkner-Skan equation, positive wall shear, \beta = 0.5.')
xlabel('\eta')
ylabel('df/d\eta')
hold on
drawnow 
shg

for Bnew = infinity+1:maxinfinity
  
  solinit = bvpinit(sol,[0 Bnew]);   % Extend the solution to Bnew.
  sol = bvp4c(@fsode,@fsbc,solinit);
  eta = sol.x;
  f = sol.y;

  fprintf('Value computed using infinity = %g is %7.5f.\n',Bnew,f(3,1))
  plot(eta,f(2,:),eta(end),f(2,end),'o');
  drawnow
  
end
hold off

% --------------------------------------------------------------------------

function dfdeta = fsode(eta,f)
beta = 0.5;
dfdeta = [ f(2)
           f(3)
          -f(1)*f(3) - beta*(1 - f(2)^2) ];

% --------------------------------------------------------------------------

function res = fsbc(f0,finf)
res = [f0(1)
       f0(2)
       finf(2) - 1];
