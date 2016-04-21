function [phi,gam,f0] = c2dmp(A,B,T,dx0);
%C2DMP	Discretization of a Continuous Time System
%
%	[Phi, Gam, f0] = c2dmp(A,B,T,dx0)
%
%       Continuous System :  dx/dt  = A*x + B*u + dx0
%       Discrete System   :  x(k+1) = Phi*x(k) + Gam*u(k) + f0
%       Sample Time       :  T
%
%       dx0 and f0 are optional and default to zero.  They
%       may be non-zero when a linear model is obtained by
%       linearization at an unsteady condition.

%
%   Algorithm:  [dx/dt] = [A  B  dx0][x]
%               [du/dt] = [0  0    0][u]
%                                    [1]
%
%   Solve using Matrix Exponential

%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

[nx,nx2] = size(A);
if(nx ~= nx2),
   error('Matrix A must be square')
end
[nx2,nu] = size(B);
if(nx2 ~= nx),
   error('Matrices A and B must contain same number of rows')
end
if nargin < 4
   dx0=[];
elseif ~isempty(dx0)
   dx0=dx0(:);
   if length(dx0) ~= nx
      error('Size of DX0 is inconsistent with size of A')
   end
end

if nx == 0
   phi=zeros(nx,nx);
   gam=zeros(nx,nu);
   f0=zeros(nx,1);
   return
end

ix=[1:nx];
if isempty(dx0)
   M              = [ [A  B]*T ; zeros(nu,nx+nu)];
   EM             = expm(M);
   phi            = EM(ix,ix);
   gam            = EM(ix,nx+1:nx+nu);
   f0             = zeros(nx,1);
else
   M              = [ [A  B dx0]*T ; zeros(nu+1,nx+nu+1)];
   EM             = expm(M);
   phi            = EM(ix,ix);
   gam            = EM(ix,nx+1:nx+nu);
   f0             = EM(ix,nx+nu+1);
end