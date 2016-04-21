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


%    p=DDGthole_driftdiffusion(mesh,Dsides,nin,pin,V,up,tn,tp,n0,p0)
%   IN:
%	  v    = electric potential
%	  mesh = integration domain
%     nin  = initial guess and BCs for electron density
%     pin  = hole density (to compute SRH recombination)
%     pold = hole density at previous timestep
%     dt   = timestep
%   OUT:
%     p    = updated hole density

function p=DDGthole_driftdiffusion(mesh,Dsides,nin,pin,V,up,tn,tp,n0,p0,pold,dt)

if (columns(nin)>rows(nin))
  nin=nin';
end

if (columns(V)>rows(V))
  V=V';
end

if (columns(pin)>rows(pin))
  pin=pin';
end

Nnodes    = max(size(mesh.p));
Nelements = max(size(mesh.t));

denom = (tp*(nin+sqrt(n0.*p0))+tn*(pin+sqrt(n0.*p0)));
u     = up;
U     = n0.*p0./denom + pold/dt;
M     = nin./denom + ones(size(pin))/dt ;
guess = pin;
V     = -V;

p = Udriftdiffusion(mesh,Dsides,guess,M,U,V,u);
