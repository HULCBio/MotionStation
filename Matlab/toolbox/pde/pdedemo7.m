%PDEDEMO7 Point forces and adaptive solution

%       A. Nordmark 2-6-95
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

echo on
clc

%       We solve Poisson's equation
%        -div(grad(u))=delta(x,y)
%       on the unit circle with u=0 on the boundary.
%       The exact solution is u=-1/(2*pi)*log(r), which is singular
%       at the origin. By using adaptive mesh generation, we can accurately
%       find the solution everywhere except close to the origin.
pause % Strike any key to continue.
clc

%       Problem definition
g='circleg'; % The unit circle
b='circleb1'; % 0 on the boundary
c=1;
a=0;
f='circlef'; % Point source at the origin.
%              Returns 1/area for tringle containing origin and
%              and 0 for other triangles.

%       We use our own tripick function that returns triangles with errf>tol.
[u,p,e,t]=adaptmesh(g,b,c,a,f,'tripick','circlepick','maxt',2000,'par',1e-3);
pause % Strike any key to continue.
clc


%       The adapted mesh
pdemesh(p,e,t); axis equal
pause % Strike any key to continue.

%       The solution
pdeplot(p,e,t,'xydata',u,'zdata',u,'mesh','off');
pause % Strike any key to continue.
clc


%       Compare with exact solution
x=p(1,:)';
y=p(2,:)';

r=sqrt(x.^2+y.^2);
uu=-log(r)/2/pi;
pdeplot(p,e,t,'xydata',u-uu,'zdata',u-uu,'mesh','off');

pause % Strike any key to end.

echo off

