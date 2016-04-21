function c=Udriftdiffusion(mesh,Dsides,guess,M,U,V,u)

%%
%  c=Udriftdiffusion(mesh,Dsides,guess,M,U,V,u)
% solves the drift diffusion equation
% $ -div ( u ( \nabla n - n \nabla V)) + M = U $
%%

% This file is part of 
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.

global DDG_RHS DDG_MASS %DEBUG_SGM


if (Ucolumns(guess)>Urows(guess))
    guess=guess';
end

if (Ucolumns(V)>Urows(V))
    V=V';
end

if (Ucolumns(U)>Urows(U))
    U=U';
end
Nnodes    = max(size(mesh.p));
Nelements = max(size(mesh.t));


% Set list of nodes with Dirichelet BCs
Dnodes=Unodesonside(mesh,Dsides);

% Set values of Dirichelet BCs
Bc     = guess(Dnodes);
% Set list of nodes without Dirichelet BCs
Varnodes = setdiff([1:Nnodes],Dnodes);


% Build LHS matrix and RHS
A = Uscharfettergummel(mesh,V,u);
if (isempty(DDG_MASS))
  DDG_MASS=Ucompmass2(mesh,ones(Nnodes,1),ones(Nelements,1));
end
A = A + DDG_MASS.*spdiag(M,0);

if (isempty(DDG_RHS))
	DDG_RHS=Ucompconst(mesh,ones(Nnodes,1),ones(Nelements,1));
end
b = DDG_RHS.*U;



%%%%%%%%DEBUG%%%%%%%%%%%
%DEBUG_SGM = A;

%% Apply boundary conditions
A (Dnodes,:) = 0;
b (Dnodes)   = 0;
b = b - A (:,Dnodes) * Bc;

A(Dnodes,:)= [];
A(:,Dnodes)= [];

b(Dnodes)	= [];

% Enforce positivity
% dA = abs(diag(A));
% edA= abs(sum(triu(A,1)+tril(A,-1),1));
% nondominant = find(dA < edA');
% for ii=1:length(nondominant)
%     A(nondominant(ii),nondominant(ii)) = edA(ii);
% end

c = guess;

c(Varnodes) = A \ b;

