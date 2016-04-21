%PDEDEMO8 Solve Poisson's equation on rectangular grid.

%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

echo on
clc

%       We solve Poisson's equation
%        -div(grad(u))=3x^2
%       on a square with Dirichlet boundary conditions,
%       and compare the Fast Poisson solver with the
%       standard PDE solver.
pause % Strike any key to continue.
clc

%       Problem definition
g='squareg'; % The unit square
b='squareb4'; % 0 on three boundaries, half a sine on the rightmost
c=1;
a=0;
f='3*x.^2';

%       A small, regular grid
n=16;
[p,e,t]=poimesh(g,n);
pdemesh(p,e,t); axis equal
pause % Strike any key to continue.
clc

%       Fast solver
tm=cputime;
u=poisolv(b,p,e,t,f);
cputime-tm

%       Compare with solution not using fast solver
tm=cputime;
u1=assempde(b,p,e,t,c,a,f);
cputime-tm
pause % Strike any key to continue.
clc

%       The solution
pdesurf(p,t,u)
pause % Strike any key to continue.
clc

%       A larger grid with 65*65 nodes
n=64;
[p,e,t]=poimesh(g,n);
pause % Strike any key to continue.
clc

%       Fast solver
tm=cputime;
u=poisolv(b,p,e,t,f);
cputime-tm

%       Compare with solution not using fast solver
tm=cputime;
u1=assempde(b,p,e,t,c,a,f);
cputime-tm
pause % Strike any key to continue.
clc

echo off

