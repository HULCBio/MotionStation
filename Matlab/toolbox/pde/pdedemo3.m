%PDEDEMO3 Let's solve the minimal surface problem

%       A. Nordmark 4-26-94, AN 8-01-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

echo on
clc

%       Let's solve the minimal surface problem
%        -div( 1/sqrt(1+grad|u|^2) * grad(u) ) = 0
%       with u=x^2 on the boundary

g='circleg'; % The unit circle
b='circleb2'; % x^2 on the boundary
c='1./sqrt(1+ux.^2+uy.^2)';
a=0;
f=0;
rtol=1e-3; % Tolerance for nonlinear solver
pause % Strike any key to continue.
clc

%       Generate mesh
[p,e,t]=initmesh(g);
[p,e,t]=refinemesh(g,p,e,t);

%       Solve the nonlinear problem
u=pdenonlin(b,p,e,t,c,a,f,'tol',rtol);

%       Solution
pdesurf(p,t,u);

pause % Strike any key to end.

echo off

