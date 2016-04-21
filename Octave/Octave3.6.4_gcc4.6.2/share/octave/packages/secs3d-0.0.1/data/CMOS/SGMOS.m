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

% single gate MOS mesh

close all
clear all

sx = 2;
sy = 1/2;
sz = 3;

xm1 =linspace(0,10,4*sx);
x0  =linspace(10,25,6*sx);
x1  =linspace(25,30,4*sx);
x2  =linspace(30,45,15*sx);
x3  =linspace(45,50,4*sx);
x4  =linspace(50,65,6*sx);
x5  =linspace(65,75,4*sx);

y =linspace(0,50,15*sy);
spacing = (linspace(0,1,15*sz)+5*linspace(0,1,15*sz).^4)/6;
z1 = 40*(1-spacing);
z2 = linspace(40,41.5,5*sz);

meshm11= Ustructmesh(xm1,y,z1,1,1:6);
mesh01 = Ustructmesh(x0,y,z1,1,1:6);
mesh11 = Ustructmesh(x1,y,z1,1,1:6);
mesh21 = Ustructmesh(x2,y,z1,1,1:6);     
mesh31 = Ustructmesh(x3,y,z1,1,1:6);     
mesh12 = Ustructmesh(x1,y,z2,1,1:6);
mesh22 = Ustructmesh(x2,y,z2,1,1:6);
mesh32 = Ustructmesh(x3,y,z2,1,1:6);
mesh41 = Ustructmesh(x4,y,z1,1,1:6);
mesh51 = Ustructmesh(x5,y,z1,1,1:6);

mesh     = Ujoinmeshes(mesh11,mesh21,2,1);
mesh     = Ujoinmeshes(mesh,mesh31,7,1);
mesh     = Ujoinmeshes(mesh,mesh22,11,5);
mesh     = Ujoinmeshes(mesh,mesh01,1,2);
mesh     = Ujoinmeshes(mesh,mesh41,12,1);
mesh     = Ujoinmeshes(mesh,meshm11,22,2);
mesh     = Ujoinmeshes(mesh,mesh51,27,1);
mesh     = Ujoinmeshes(mesh,mesh12,[6,17],[5,2]);
mesh     = Ujoinmeshes(mesh,mesh32,[16,18],[5,1]);

mesh.p   = 1e-9*mesh.p;

fpl_vtk_write_field("SGMOS_mesh", mesh, {}, {}, 0);