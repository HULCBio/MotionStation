%PDEDEMO6 Animation demo for wave propagation problem.

%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

echo on

% Animation demo for wave propagation problem.
clc

%       We solve the standard wave equation
%        d2u/dt2-div(grad(u))=0
%       on a square.
pause % Strike any key to continue.
clc

%       Problem definition
g='squareg'; % The unit square
b='squareb3'; % 0 on the left and right boundaries and
%               0 normal derivative on the top and bottom boundaries.
c=1;
a=0;
f=0;
d=1;

%       Mesh
[p,e,t]=initmesh('squareg');
pause % Strike any key to continue.
clc

%       The initial conditions:
%       u(0)=atan(cos(pi/2*x)) and
%       dudt(0)=3*sin(pi*x).*exp(sin(pi/2*y))
%       are chosen to avoid putting a lot of energy into
%       the higher vibration modes, thus permitting a reasonable
%       time step size.
x=p(1,:)';
y=p(2,:)';

u0=atan(cos(pi/2*x));
ut0=3*sin(pi*x).*exp(sin(pi/2*y));
pause % Strike any key to continue.
clc

%       We want the solution at 31 points in time between 0 and 5.
n=31;
tlist=linspace(0,5,n);

%       Solve hyperbolic problem
uu=hyperbolic(u0,ut0,tlist,b,p,e,t,c,a,f,d);
pause % Strike any key to continue.
clc

%       To speed up the plotting, we interpolate to a rectangular grid.
delta=-1:0.1:1;
[uxy,tn,a2,a3]=tri2grid(p,t,uu(:,1),delta,delta);
gp=[tn;a2;a3];

%       Make the animation
newplot;
M=moviein(n);
umax=max(max(uu));
umin=min(min(uu));
for i=1:n,...
  if rem(i,10)==0,...
    fprintf('%d ',i);...
  end,...
  pdeplot(p,e,t,'xydata',uu(:,i),'zdata',uu(:,i),'zstyle','continuous',...
          'mesh','off','xygrid','on','gridparam',gp,'colorbar','off');...
  axis([-1 1 -1 1 umin umax]); caxis([umin umax]);...
  M(:,i)=getframe;...
  if i==n,...
    fprintf('done\n');...
  end,...
end

% Show movie
nfps=5;
movie(M,10,nfps);
pause % Strike any key to end.

echo off

