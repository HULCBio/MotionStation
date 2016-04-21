%PDEDEMO4 Solve FEM problem using subdomain decomposition.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:10:09 $

echo on
clc


%       We solve Poisson's equation
%        -div(grad(u))=1
%       on the L-shaped membrane with u=0 on the boundary.
%       The problem is solved using subdomain decomposition.
pause % Strike any key to continue.
clc

%       Problem definition
g='lshapeg'; % L-shaped membrane
b='lshapeb'; % 0 on boundary
c=1;
a=0;
f=1;
time=[]; % We need to input a time to use the subdomain argument to ASSEMPDE

[p,e,t]=initmesh(g);
[p,e,t]=refinemesh(g,p,e,t);
[p,e,t]=refinemesh(g,p,e,t);
pause % Strike any key to continue.
clc

np=size(p,2);
%       First find the common points
cp=pdesdp(p,e,t);

%       Allocate space
nc=length(cp);
C=zeros(nc,nc); % Schur complement
FC=zeros(nc,1);
pause % Strike any key to continue.

%       Assemble domain 1 and update complement
[i1,c1]=pdesdp(p,e,t,1);ic1=pdesubix(cp,c1);
[K,F]=assempde(b,p,e,t,c,a,f,time,1);
K1=K(i1,i1);d=symamd(K1);i1=i1(d);
K1=chol(K1(d,d));B1=K(c1,i1);a1=B1/K1;
C(ic1,ic1)=C(ic1,ic1)+K(c1,c1)-a1*a1';
f1=F(i1);e1=K1'\f1;FC(ic1)=FC(ic1)+F(c1)-a1*e1;
pause % Strike any key to continue.

%       Assemble domain 2 and update complement
[i2,c2]=pdesdp(p,e,t,2);ic2=pdesubix(cp,c2);
[K,F]=assempde(b,p,e,t,c,a,f,time,2);
K2=K(i2,i2);d=symamd(K2);i2=i2(d);
K2=chol(K2(d,d));B2=K(c2,i2);a2=B2/K2;
C(ic2,ic2)=C(ic2,ic2)+K(c2,c2)-a2*a2';
f2=F(i2);e2=K2'\f2;FC(ic2)=FC(ic2)+F(c2)-a2*e2;
pause % Strike any key to continue.

%       Assemble domain 3 and update complement
[i3,c3]=pdesdp(p,e,t,3);ic3=pdesubix(cp,c3);
[K,F]=assempde(b,p,e,t,c,a,f,time,3);
K3=K(i3,i3);d=symamd(K3);i3=i3(d);
K3=chol(K3(d,d));B3=K(c3,i3);a3=B3/K3;
C(ic3,ic3)=C(ic3,ic3)+K(c3,c3)-a3*a3';
f3=F(i3);e3=K3'\f3;FC(ic3)=FC(ic3)+F(c3)-a3*e3;
pause % Strike any key to continue.

% Solve
u=zeros(np,1);
u(cp)=C\FC; % Common points
u(i1)=K1\(e1-a1'*u(c1)); % Points in SD 1
u(i2)=K2\(e2-a2'*u(c2)); % Points in SD 2
u(i3)=K3\(e3-a3'*u(c3)); % Points in SD 3

% Plot
pdesurf(p,t,u)
pause % Strike any key to end.

echo off

