function [v,l]=pdeeig(b,p,e,t,c,a,d,r)
%PDEEIG Solve eigenvalue PDE problem.
%
%       [V,L]=PDEEIG(B,P,E,T,C,A,D,R) produces the solution to the
%       FEM formulation of the PDE eigenvalue problem
%       -div(c grad(u))+a u=l d u, on a geometry described by P, E, and
%       T, and with boundary conditions given by B.
%
%       R is a two element vector, indicating an interval on the real
%       axis. (The left-hand side may be -Inf.) The algorithm returns
%       all eigenvalues in this interval in L.
%
%       V is a matrix of eigenvectors. For the scalar case each column
%       in V is an eigenvector of solution values at the corresponding
%       node points from  P. For a system of dimension N with NP node
%       points, the first NP rows of V describe the first component of
%       v, the following NP rows of V describe the second component of v,
%       and so on.  Thus, the components of v are placed in blocks V
%       as N blocks of node point rows.
%
%       B describes the boundary conditions of the PDE problem.
%       See PDEBOUND for details.
%
%       The geometry of the PDE problem is given by the mesh data
%       P, E, and T.  See INITMESH for details.
%
%       The coefficients C, A, and D of the PDE problem can
%       be given in a wide variety of ways.  See ASSEMPDE for details.
%
%       [V,L]=PDEEIG(K,B,M,R) produces the solution to the generalized
%       matrix eigenvalue problem K*UI=l B'*M*B*UI, U=B*UI.

%       A. Nordmark 8-15-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2003/11/01 04:28:13 $

if nargin==8,
  np=size(p,2);
  % Boundary contributions
  [Q,unused1,H,unused2]=assemb(b,p,e);
  % Number of variables
  N=size(Q,2)/np;
  [K,M,unused3]=assema(p,t,c,a,zeros(N,1));
  [K,unused1,B,unused2]=assempde(K,M,unused3,Q,unused1,H,unused2);
  [unused,M]=assema(p,t,0,d,zeros(N,1));
elseif nargin==4,
  K=b;
  B=p;
  M=e;
  r=t;
else
  error('PDE:pdeeig:nargin', 'Number of input arguments must be 4 or 8.')
end

M=B'*M*B;

if r(1)~=-Inf
  spd=1; % We assume ...
else
  spd=0;
end

[v,l,ires]=sptarn(K,M,r(1),r(2),spd);

if ires<0,
  warning('PDE:pdeeig:MoreEigenvaluesMayExist', 'There may be more eigenvalues in the interval.');
end

if ~isempty(v)
  v=B*v;
end
