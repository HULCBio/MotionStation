%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

% c = Udriftdiffusion(mesh,Dsides,guess,M,U,V,u)
% solves the drift diffusion equation
% $ -div[ mu (u \nabla n - n \nabla V) ] + M u = U $

function c=Udriftdiffusion(mesh,Dsides,guess,M,U,V,mu)

global DDG_RHS DDG_MASS

if (columns(guess)>rows(guess))
  guess=guess';
end

if (columns(V)>rows(V))
  V=V';
end

if (columns(U)>rows(U))
  U=U';
end
Nnodes    = max(size(mesh.p));
Nelements = max(size(mesh.t));

% Set values of Dirichelet BCs
Dnodes = Ugetnodesonface(mesh,Dsides);
Bc     = guess(Dnodes);

% Set list of nodes without Dirichelet BCs
Varnodes = setdiff([1:Nnodes],Dnodes);

% Build LHS matrix and RHS
A = Uscharfettergummel(mesh,V,mu);
if (isempty(DDG_MASS))
  DDG_MASS=Ucompmass2(mesh,ones(Nnodes,1),ones(Nelements,1));
end
A = A + DDG_MASS*spdiags(M,0,Nnodes,Nnodes);

if (isempty(DDG_RHS))
  DDG_RHS=Ucompconst(mesh,ones(Nnodes,1),ones(Nelements,1));
end
b = DDG_RHS.*U;


%% Apply boundary conditions
A (Dnodes,:) = 0;
b (Dnodes)   = 0;
b = b - A (:,Dnodes) * Bc;

A(Dnodes,:)= [];
A(:,Dnodes)= [];

b(Dnodes)	= [];

% Boundary conditions
c = guess;
c(Varnodes) = A \ b;
