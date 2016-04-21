function n=ThDDGOXelectron_driftdiffusion(mesh,Dnodes,n,pin,V,...
					  Tn,mobn0,mobn1,tn,tp,n0,p0)

  %%
  %%   n=ThDDGOXelectron_driftdiffusion(mesh,Dnodes,n,pin,V,Tn,un0,un1,tn,tp,n0,p0)
  %%

  %% This file is part of 
  %%
  %%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
  %%         -------------------------------------------------------------------
  %%            Copyright (C) 2004-2006  Carlo de Falco
  %%
  %%
  %%
  %%  SECS2D is free software; you can redistribute it and/or modify
  %%  it under the terms of the GNU General Public License as published by
  %%  the Free Software Foundation; either version 2 of the License, or
  %%  (at your option) any later version.
  %%
  %%  SECS2D is distributed in the hope that it will be useful,
  %%  but WITHOUT ANY WARRANTY; without even the implied warranty of
  %%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %%  GNU General Public License for more details.
  %%
  %%  You should have received a copy of the GNU General Public License
  %%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.

  Nnodes    = columns(mesh.p);
  Nelements = columns(mesh.t);
  Varnodes  = setdiff(1:Nnodes,Dnodes);

  alpha = mobn0;
  gamma = mobn1;
  eta   = Tn;
  beta  = V-Tn;
  Dn = Uscharfettergummel3(mesh,alpha,gamma,eta,beta);

  denom = (tp*(n+sqrt(n0.*p0))+tn*(pin+sqrt(n0.*p0)));
  MASS_LHS = Ucompmass2(mesh,pin./denom,ones(Nelements,1));

  LHS = Dn+MASS_LHS;

  RHS     = Ucompconst (mesh,p0.*n0./denom,ones(Nelements,1));

  n(Varnodes) = LHS(Varnodes,Varnodes) \(RHS(Varnodes) -...
      LHS(Varnodes,Dnodes)*n(Dnodes));

