function u=poisolv(b,p,e,t,f)
%POISOLV Solution of Poisson's equation on a rectangular grid.
%
%       U=POISOLV(B,P,E,T,F) solves Poisson's equation with
%       Dirichlet boundary conditions on a regular rectangular
%       grid. A combination of sine transforms and tridiagonal
%       solutions is used for increased performance.
%
%       The boundary conditions B must specify Dirichlet
%       conditions for all boundary points.
%
%       The mesh P, E, T must be a regular rectangular grid.
%
%       F gives the right-hand side of Poisson's equation.
%
%       Apart from round off errors, the result should be
%       the same as U=ASSEMPDE(B,P,E,T,1,0,F)
%
%       See also ASSEMA, POIASMA, POIINDEX, POICALC

%       A. Nordmark 1-25-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:12:14 $

np=size(p,2);
u=zeros(np,1);

[nx,ny,hx,hy,i,c,ii,cc]=poiindex(p,e,t,1);
if nx==0
  error('PDE:poisolv:MeshSpacing',...
      'Mesh does not appear to be an evenly spaced rectangular grid.')
end

[unused,unused,F]=assema(p,t,0,0,f);
KK=poiasma(nx,ny,hx,hy);
[Q,G,H,R]=assemb(b,p,e);

if nnz(Q) || nnz(G)
  error('PDE:poisolv:BCnotDirichlet', 'Must only use Dirichlet boundary conditions.');
end

u(c)=H(:,c)\R;

IX=sparse(c,1,cc,nx*ny,1);
UU=sparse(IX(c),1,u(c),nx*ny,1);
FB=-KK(ii,cc)*UU(cc);
FF=F(i)+FB;
u(i)=poicalc(FF,hx,hy,nx-2,ny-2);

