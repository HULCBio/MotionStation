function p=ThDDGOXhole_driftdiffusion(mesh,Dnodes,nin,p,V,...
				      Tp,mobp0,mobp1,tn,tp,n0,p0)
  %%
  %%  p=ThDDGOXhole_driftdiffusion(mesh,Dnodes,nin,p,V,Tp,monp0,mobp1,tn,tp,n0,p0)
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

  alpha = mobp0;
  gamma = mobp1;
  eta   = Tp;
  beta  = -V-Tp;
  Dp = Uscharfettergummel3(mesh,alpha,gamma,eta,beta);
  
  denom = (tp*(nin+sqrt(n0.*p0))+tn*(p+sqrt(n0.*p0)));
  MASS_LHS = Ucompmass2(mesh,nin./denom,ones(Nelements,1));
  
  LHS = Dp+MASS_LHS;

  RHS     = Ucompconst (mesh,p0.*n0./denom,ones(Nelements,1));
  
  p(Varnodes) = LHS(Varnodes,Varnodes) \(RHS(Varnodes) -...
      LHS(Varnodes,Dnodes)*p(Dnodes));

