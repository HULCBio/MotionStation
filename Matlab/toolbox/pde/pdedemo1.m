%PDEDEMO1 Compare FEM Solution to exact solution.

%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2001/02/09 17:03:14 $

echo on
clc


%       Solve Poisson's equation
%        -div(grad(u))=1
%       on the unit disk with u=0 on the boundary.
%       Compare with exact solution.
pause % Strike any key to continue.
clc

%       Problem definition
g='circleg'; % The unit circle
b='circleb1'; % 0 on the boundary
c=1;
a=0;
f=1;

%       A coarse initial mesh
[p,e,t]=initmesh(g,'hmax',1);
pause % Strike any key to continue.
clc

%       Do iterative regular refinement until the error is acceptable
error=[]; er=1;
while er > 0.001,...
  [p,e,t]=refinemesh(g,p,e,t);...
  u=assempde(b,p,e,t,c,a,f);...
  exact=(1-p(1,:).^2-p(2,:).^2)'/4;...
  er=norm(u-exact,'inf');...
  error=[error er];...
  fprintf('Error: %e. Number of nodes: %d\n',er,size(p,2));...
end

%       The solution
pdesurf(p,t,u); pause % Press any key after plot

% The error
pdesurf(p,t,u-exact);

pause % Strike any key to end.

echo off


