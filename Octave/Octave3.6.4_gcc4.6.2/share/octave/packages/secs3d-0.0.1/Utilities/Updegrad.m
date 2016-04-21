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

% [Fx,Fy]=Updegrad(mesh,F);
%
% computes piecewise constant
% gradient of a piecewise linear
% scalar function F defined on
% the mesh structure described by mesh

function [Fx,Fy,Fz]=Updegrad(mesh,F);

shgx = reshape(mesh.shg(1,:,:),4,[]);
Fx = sum(shgx.*F(mesh.t(1:4,:)),1);
shgy = reshape(mesh.shg(2,:,:),4,[]);
Fy = sum(shgy.*F(mesh.t(1:4,:)),1);
shgz = reshape(mesh.shg(3,:,:),4,[]);
Fz = sum(shgz.*F(mesh.t(1:4,:)),1);
