function [ux,uy]=pdegrad(p,t,u,sdl)
%PDEGRAD Compute the gradient of a PDE solution.
%
%       [UX,UY]=PDEGRAD(P,T,U) returns grad(u) evaluated at
%       the center of each triangle.
%
%       The geometry of the PDE problem is given by the triangle data P,
%       and T. Details under INITMESH.
%
%       The format for the solution vector U is described in ASSEMPDE.
%
%       [UX,UY]=PDEGRAD(P,T,U,SDL) restricts the computation to the
%       subdomains in the list SDL.
%
%       See also: ASSEMPDE, INITMESH, PDECGRAD

%       A. Nordmark 12-22-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:18 $

if nargin==4
  t=t(:,pdesdt(t,sdl));
elseif nargin~=3
  error('PDE:pdegrad:nargin', 'Wrong number of input arguments.')
end

np=size(p,2);
nt=size(t,2);
N=size(u,1)/np;

% Corner point indices
it1=t(1,:);
it2=t(2,:);
it3=t(3,:);

% Triangle geometries:
[ar,g1x,g1y,g2x,g2y,g3x,g3y]=pdetrg(p,t);

uu=reshape(u,np,N);
ux=uu(it1,:).'.*(ones(N,1)*g1x)+uu(it2,:).'.*(ones(N,1)*g2x)+ ...
   uu(it3,:).'.*(ones(N,1)*g3x);
uy=uu(it1,:).'.*(ones(N,1)*g1y)+uu(it2,:).'.*(ones(N,1)*g2y)+ ...
   uu(it3,:).'.*(ones(N,1)*g3y);

