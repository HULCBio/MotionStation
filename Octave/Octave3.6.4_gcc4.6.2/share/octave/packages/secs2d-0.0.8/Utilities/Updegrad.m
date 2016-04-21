function [Fx,Fy]=Updegrad(mesh,F);

% [Fx,Fy]=Updegrad(mesh,F);
%
% computes piecewise constant
% gradient of a piecewise linear
% scalar function F defined on
% the mesh structure described by mesh



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




shgx = reshape(mesh.shg(1,:,:),3,[]);
Fx = sum(shgx.*F(mesh.t(1:3,:)),1);
shgy = reshape(mesh.shg(2,:,:),3,[]);
Fy = sum(shgy.*F(mesh.t(1:3,:)),1);
