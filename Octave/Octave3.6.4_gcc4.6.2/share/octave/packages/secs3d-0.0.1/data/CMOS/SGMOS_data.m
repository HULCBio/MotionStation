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

% single gate MOS data

load constants;

SiDsides = [ 36 41 35 25 5 10 15 30 40 ];
Dsides   = [ SiDsides 45 21 49];
Intsides = [ 6 11 16];


[Simesh,Sinodes] = Usubmesh(mesh,[],[1:3,5:8],1);

% Set list of Interface nodes 
Intnodes = Ugetnodesonface(Simesh,Intsides);

x = Simesh.p(1,:)'; 
y = Simesh.p(2,:)'; 
z = Simesh.p(3,:)'; 

lung = max(x)-min(x);
lungy= max(y)-min(y);
lungz= max(z)-min(z);

xm = (max(x)-min(x))/2;
ym = (max(y)-min(y))/2;
zm = (max(z)-min(z))/2;

vs   = 0;
vd   = 0.3;
vg   = 0.1;
vb   = 0.0;

[tmpmesh,source] =Usubmesh(Simesh,[ ],[7 5 1],1);
clear tmpmesh;
source = source(find(z(source)>=zm));

[tmpmesh,drain] =Usubmesh(Simesh,[],[8 3 6],1);
clear tmpmesh;
drain = drain(find(z(drain)>=zm));

[tmpmesh,channel] =Usubmesh(Simesh,[],[2],1);
clear tmpmesh;

[tmpmesh,oxide] = Usubmesh(mesh,[],[9 4 10],1);
clear tmpmesh;

bulkdoping     = -2e25;
sourcedoping   = 5e25;
draindoping    = 5e25;
channeldoping = -2e25;

data.D            = 0*x+bulkdoping;
data.D(source)    = sourcedoping;
data.D(drain)     = draindoping;
data.D(channel)  = channeldoping;

data.n = data.D .* (data.D > 0);
data.p = -data.D .* (data.D < 0);

data.n = data.n - (ni^2 ./ data.D) .* (data.D < 0);
data.p = data.p + (ni^2 ./ data.D) .* (data.D > 0);

data.n(Intnodes) = 1e-2;
data.p(Intnodes) = 1e-2;

data.Fn             = 0*x+vb;
data.Fn(drain)      = vd;
data.Fn(source)     = vs;
data.Fn(channel)   = vb;

data.Fp= data.Fn;

data.V          = 0*mesh.p(2,:)'+vg-Phims;
data.V(oxide)   = vg-Phims;
data.V(Sinodes) = data.Fn + Vth * log(data.n/ni);

[idata,imesh]=Uscaling(mesh,data);
idata.n0 = idata.n;
idata.p0 = idata.p;

imesh = bim3c_mesh_properties (imesh);
[Simesh,Sinodes,Sielements] = Usubmesh(imesh,[],[1:3,5:8],0);

toll     = 1e-4;
stoll    = 1e-4;
ptoll    = 1e-10;
smaxit   = 10;
maxit    = 50;
pmaxit   = 100;
verbose  = 2;
options.holes = 0;
options.SRH   = 0;
optionds.FD   = 0;

save -binary SGMOS_data 
