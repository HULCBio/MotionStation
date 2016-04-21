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

%
% function [odata,omesh] = Uscaling(imesh,idata);
% 
% Convert input data to non-dimensional form.
%

function [odata,omesh] = Uscaling(imesh,idata);

% [odata,omesh] = Uscaling(imesh,idata);
load constants

omesh      = imesh;
odata      = idata;

% scaling factors
odata.xs   = max(abs([max(imesh.p(1,:))-min(imesh.p(1,:)),max(imesh.p(2,:))-min(imesh.p(2,:))]));
odata.Vs   = Vth;
odata.ns   = norm(idata.D,inf);
odata.us   = un;
odata.ts   = odata.xs/(odata.Vs*odata.us);

% adimensional constants
odata.etan2 = hbar^2 / (2*mndos*odata.xs^2*q*odata.Vs);
% 3-valley masses
odata.etanxx2 = hbar^2 / (2*mnl*odata.xs^2*q*odata.Vs);
odata.etanxy2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);

odata.etanyx2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);
odata.etanyy2 = hbar^2 / (2*mnl*odata.xs^2*q*odata.Vs);

odata.etanzx2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);
odata.etanzy2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);


odata.etap2 = hbar^2 / (2*mhdos*odata.xs^2*q*odata.Vs);
odata.beta  = Vth/odata.Vs;
odata.dn2   = hbar^2 / (4*rn*mndos*odata.xs^2*q*odata.Vs);
odata.dp2   = hbar^2 / (4*rp*mhdos*odata.xs^2*q*odata.Vs);
odata.l2    = (odata.Vs*esi) / (odata.ns*odata.xs^2*q);
odata.l2ox  = (odata.Vs*esio2) / (odata.ns*odata.xs^2*q);

if (isfield(idata,'un'))    
  odata.un    = idata.un/odata.us;  
else
  odata.un    = un/odata.us;
end

if (isfield(idata,'up'))
  odata.up    = idata.up/odata.us;
else
  odata.up    = up/odata.us;
end

if (isfield(idata,'FDn'))    
  odata.FDn    = idata.FDn/odata.Vs;  
end
if (isfield(idata,'FDp'))    
  odata.FDp    = idata.FDp/odata.Vs;  
end

if (isfield(idata,'tn')) 
  odata.tn    = idata.tn/odata.ts;
else
  odata.tn    = tn/odata.ts;
end
if (isfield(idata,'tp')) 
  odata.tp    = idata.tp/odata.ts;
else
  odata.tp   = tp/odata.ts;
end
odata.ni    = ni/odata.ns;
odata.Nc    = Nc/odata.ns;
odata.Nv    = Nv/odata.ns;

odata.ei    = Egap/(2*q*odata.Vs) - log(Nv/Nc)/2; 
odata.eip   = Egap/(2*q*odata.Vs) + log(Nv/Nc)/2; 

odata.wn2   = 6*sqrt(mndos*2*Kb*T0/(pi*hbar^2))/(ni*odata.xs^2);

odata.vsatn     = vsatn * odata.xs / (odata.us * odata.Vs);
odata.vsatp     = vsatp * odata.xs / (odata.us * odata.Vs);
odata.mubn      = mubn;
odata.mubp      = mubp;
odata.mudopparn = [ mudopparn(1:3)/odata.us;
                    mudopparn(4:6)/odata.ns;
                    mudopparn(7:8) ];
odata.mudopparp = [ mudopparp(1:3)/odata.us;
                    mudopparp(4:6)/odata.ns;
                    mudopparp(7:8) ];

% 3-valley weights
odata.wnx2   = 2*sqrt(mnt*2*Kb*T0/(pi*hbar^2))/(ni*odata.xs^2);
odata.wny2   = odata.wnx2;
odata.wnz2   = 2*sqrt(mnl*2*Kb*T0/(pi*hbar^2))/(ni*odata.xs^2);

% 3-valley weights
odata.wnx2FD   = 2*sqrt(mnt*2*Kb*T0/(pi*hbar^2))/(odata.ns*odata.xs^2);
odata.wny2FD   = odata.wnx2FD;
odata.wnz2FD   = 2*sqrt(mnl*2*Kb*T0/(pi*hbar^2))/(odata.ns*odata.xs^2);

odata.mg    = Egap/(2*Kb*T0) - log(Nv/Nc)/2;


% scaled quantities
odata.D     = idata.D/odata.ns;
odata.n     = idata.n/odata.ns;
odata.p     = idata.p/odata.ns;
odata.Fn    = idata.Fn/odata.Vs-log(ni/odata.ns);
odata.Fp    = idata.Fp/odata.Vs+log(ni/odata.ns);
odata.V     = idata.V/odata.Vs;
if (isfield(idata,'G'))
  odata.G= idata.G/odata.Vs;
end
if (isfield(idata,'dt'))
  odata.dt= idata.dt/odata.ts;
end

omesh.p     = imesh.p/odata.xs;

% Last Revision:
% $Author: carlo $
% $Date: 2005/05/27 15:29:23 $


