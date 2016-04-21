function [odata,omesh] = Udescaling(imesh,idata);

%  [odata,omesh] = Udescaling(imesh,idata);

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

load (file_in_path(path,'constants.mat'));

omesh      = imesh;
odata      = idata;

% scaling factors
% odata.xs   = max(abs([max(imesh.p(1,:))-min(imesh.p(1,:)),max(imesh.p(2,:))-min(imesh.p(2,:))]));
% odata.Vs   = Vth;
% odata.ns   = norm(idata.D,inf);
% odata.us   = un;

% adimensional constants
% odata.etan2 = hbar^2 / (2*mndos*odata.xs^2*q);
% odata.etap2 = hbar^2 / (2*mpdos*odata.xs^2*q);
% odata.beta  = Vth/odata.Vs;
% odata.dn2   = hbar^2 / (6*mndos*odata.xs^2*q*odata.Vs);
% odata.dp2   = hbar^2 / (6*mpdos*odata.xs^2*q*odata.Vs);
% odata.l2    = (odata.Vs*esi) / (odata.ns*odata.xs^2*q);
% odata.un    = un/odata.us;
% odata.up    = up/odata.us;

% scaled quantities
odata.D     = idata.D*odata.ns;
odata.n     = idata.n*odata.ns;
odata.p     = idata.p*odata.ns;
odata.Fn    = (idata.Fn+log(ni/odata.ns))*odata.Vs;
odata.Fp    = (idata.Fp-log(ni/odata.ns))*odata.Vs;
odata.V     = idata.V*odata.Vs;
if (isfield(idata,'G'))
    odata.G = idata.G*odata.Vs;
end
if (isfield(idata,'dt'))
    odata.dt = idata.dt*odata.ts;
end

if (isfield(idata,'un'))    
    odata.un    = idata.un*odata.us;  
else
    odata.un    = un;
end

if (isfield(idata,'n0'))    
    odata.n0    = idata.n0*odata.ns;  
    odata.p0    = idata.p0*odata.ns;  
else
    odata.p0    = ni;
    odata.n0    = ni;
end

if (isfield(idata,'up'))
    odata.up    = idata.up*odata.us;
else
    odata.up    = up;
end
if (isfield(idata,'FDn'))    
    odata.FDn    = idata.FDn*odata.Vs;  
end
if (isfield(idata,'FDp'))    
    odata.FDp    = idata.FDp*odata.Vs;  
end

if (isfield(idata,'Tl'))    
    odata.Tl    = idata.Tl*odata.Ts;  
end

if (isfield(idata,'Tn'))    
    odata.Tn    = idata.Tn*odata.Ts;  
end

if (isfield(idata,'Tp'))    
    odata.Tp    = idata.Tp*odata.Ts;  
end

omesh.p     = imesh.p*odata.xs;
