function threebvp
%THREEBVP  Three-point boundary value problem
%   This example of multipoint BVPs comes from the study of a physiological
%   flow problem described in C. Lin and L. Segel, Mathematics Applied to 
%   Deterministic Problems in the Natural Sciences, SIAM, Philadelphia, PA, 
%   1988. For x in [0, lambda], the equations for the problem are
%
%       v' = (C - 1)/n
%       C' = (vC - min(x,1))/eta
%
%   for known parameters n, kappa, and lambda > 1. eta = lambda^2/(n*kappa^2).
%   The term min(x,1) in the equation for C'(x) is not smooth at x = 1. 
%   Lin and Segel describe this BVP as two problems, one set on [0, 1] 
%   and the other on [1, lambda], connected by the requirement that v(x) 
%   and C(x) be continuous at x = 1. The solution is to satisfy the boundary  
%   conditions v(0) = 0 and C(lambda) = 1.  BVP4C solves this problem as 
%   a three-point BVP, imposing internal conditions at the interface point
%   x = 1.
%   
%   This example solves the problem for n = 5e-2, lambda = 2, and a range 
%   kappa = 2,3,4,5. The solution for one value of kappa is used as guess 
%   for the next. 
%
%   See also BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/05/08 21:46:05 $

% Problem parameter
n = 5e-2;

% Use default integration properties.
options = []; 

% Initial mesh - duplicate the interface point x = 1.
lambda = 2;
xinit = [0, 0.25, 0.5, 0.75, 1, 1, 1.25, 1.5, 1.75, 2];  

% Constant initial guess for the solution
yinit = [1; 1];

% The initial profile
sol = bvpinit(xinit,yinit);     

% For each kappa, the quantity of interest is the emergent osmolarity. 
% This example compares the value computed by BVP4C, Os = 1/v(lambda), 
% with Lin and Segel's asymptotic approximation.
fprintf(' kappa    computed Os    approximate Os \n')
for kappa = 2:5  
  eta = lambda^2/(n*kappa^2);  
  sol = bvp4c(@f,@bc,sol,options,n,eta);  
  
  K2 = lambda*sinh(kappa/lambda)/(kappa*cosh(kappa));
  approx = 1/(1 - K2);
  computed = 1/sol.y(1,end);
  fprintf('  %2i    %10.3f     %10.3f \n',kappa,computed,approx);
end

figure
plot(sol.x,sol.y(1,:),sol.x,sol.y(2,:),'--')
legend('v(x)','C(x)')
title('A three-point BVP solved with BVP4C')
xlabel(['\lambda = ',num2str(lambda),', \kappa = ',num2str(kappa),'.'])
ylabel('v and C')


% --------------------------------------------------------------------------
function dydx = f(x,y,region,n,eta)
dydx = zeros(2,1);
dydx(1) = (y(2) - 1)/n;
% The definition of C'(x) depends on the region.
switch region
case 1    % x in [0 1]
  dydx(2) = (y(1)*y(2) - x)/eta; 
case 2    % x in [1 lambda]
  dydx(2) = (y(1)*y(2) - 1)/eta; 
otherwise
  error('Incorrect region index: %d',region);
end

% --------------------------------------------------------------------------
function res = bc(YL,YR,n,eta)
res = [ YL(1,1)             % v(0) = 0
        YR(1,1) - YL(1,2)   % continuity of v(x) at x = 1
        YR(2,1) - YL(2,2)   % continuity of C(x) at x = 1
        YR(2,end) - 1    ]; % C(lambda) = 1
