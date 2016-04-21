%PDEDEMO2 Solve Helmholtz's equation study the reflected waves.

%       Magnus Ringh 10-20-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.9 $  $Date: 2001/02/09 17:03:14 $

echo on
clc


%       Let's solve Helmholtz's equation
%        -div(grad(u))-k^2u=0
%       and study the waves reflected from a square object.
%       The incoming wave comes from the right.
pause % Strike any key to continue.
clc


%       The incident wave has a wave number of 60.
k=60;

g='scatterg'; % Circle with a square hole
b='scatterb'; % Incident wave Dirichlet conditions on object and
%               outgoing wave conditions on outer boundary.
c=1;
a=-k^2;
f=0;

%       We need a fairly fine mesh to resolve the waves.
[p,e,t]=initmesh(g);
[p,e,t]=refinemesh(g,p,e,t);
[p,e,t]=refinemesh(g,p,e,t);

%       This is the mesh
pdemesh(p,e,t); axis equal
pause % Strike any key to continue.
clc

%       Solve for the complex amplitude
u=assempde(b,p,e,t,c,a,f);

%       The real part of a phase factor times u gives the instantaneous
%       wave field. This is at phase 0.
%
%       Use Z buffer to speed up the plotting.
h = newplot; set(get(h,'Parent'),'Renderer','zbuffer')
pdeplot(p,e,t,'xydata',real(u),'zdata',real(u),'mesh','off');
colormap(cool)
pause % Strike any key to continue.
clc


%       Now let us make an animation of the reflected waves.
%       Be patient ...
m=10; % Number of frames
h = newplot; hf=get(h,'Parent'); set(hf,'Renderer','zbuffer')
axis tight, set(gca,'DataAspectRatio',[1 1 1]); axis off
M=moviein(m,hf);
maxu=max(abs(u));
for j=1:m,...
  uu=real(exp(-j*2*pi/m*sqrt(-1))*u);...
  fprintf('%d ',j);...
  pdeplot(p,e,t,'xydata',uu,'colorbar','off','mesh','off'),...
  caxis([-maxu maxu]);...
  axis tight, set(gca,'DataAspectRatio',[1 1 1]); axis off,...
  M(:,j)=getframe(hf);...
  if j==m,...
    fprintf('done\n');...
  end,...
end

%       Show the movie
movie(hf,M,50);
pause % Strike any key to end.

echo off

