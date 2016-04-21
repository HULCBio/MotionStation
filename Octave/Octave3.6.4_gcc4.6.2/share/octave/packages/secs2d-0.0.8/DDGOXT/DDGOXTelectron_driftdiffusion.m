function n=DDGOXTelectron_driftdiffusion(mesh,Dsides,nin,pin,V,un,tn,tp,n0,p0,weight)

%%
%   n=DDGelectron_driftdiffusion(mesh,Dsides,nin,pin,V,un,tn,tp,n0,p0,weight)
%
%   IN:
%     V      = electric potential
%     mesh   = integration domain
%     nin    = electron density in the past + initial guess
%     pin    = hole density in the past
%     n0,p0  = equilibrium densities
%     tn,tp  = carrier lifetimes
%     weight = BDF weights
%     un     = mobility
%
%   OUT:
%     n      = updated electron density
%
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


BDForder = length(weight)-1;



denom = (tp*(nin(:,end)+sqrt(n0.*p0))+tn*(pin(:,end)+sqrt(n0.*p0)));
M     = weight(1) + pin(:,end)./denom;

u     = un;

U     = p0.*n0./denom;
for ii=1:BDForder
  U  += -nin(:,end-ii)*weight(ii+1);
end

guess = nin(:,end);
n     = Udriftdiffusion(mesh,Dsides,guess,M,U,V,u);


