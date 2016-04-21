function Tl = ThDDGOXupdatelattice_temp(mesh,Dnodes,Tl,Tn,Tp,n,p,...
					kappa,Egap,tn,tp,...
                                        twn0,twp0,twn1,twp1,n0,p0)
  %%
  %% Tl = ThDDGOXupdatelattice_temp(mesh,Dnodes,Tl,Tn,Tp,n,p,...
  %%				kappa,Egap,tn,tp,...
  %%                            twn0,twp0,twn1,twp1,n0,p0)
    
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

  alpha = kappa*ones(Nelements,1);
  gamma = Tl.^(-4/3);
  eta   = ones (Nnodes,1);
  
  L = Uscharfettergummel3(mesh,alpha,gamma,eta,0);
  MASS_LHSn = Ucompmass2(mesh,1.5*n./twn1,1./twn0);
  MASS_LHSp = Ucompmass2(mesh,1.5*p./twp1,1./twp0);
  LHS = L+MASS_LHSn+MASS_LHSp;
  

  denom  = (tp*(n+sqrt(n0.*p0))+tn*(p+sqrt(n0.*p0)));
  U      = (p.*n-p0.*n0)./denom;
  RHS1  = Ucompconst(mesh,(Egap+1.5*(Tn + Tp)).*U,ones(Nelements,1));
  RHS2n  = Ucompconst(mesh,1.5*n.*Tn./twn1,1./twn0);
  RHS2p  = Ucompconst(mesh,1.5*p.*Tp./twp1,1./twp0);
  RHS    = RHS1 + RHS2n + RHS2p;

  Tl(Varnodes) = LHS(Varnodes,Varnodes) \...
      (RHS(Varnodes) - LHS(Varnodes,Dnodes)*Tl(Dnodes));
