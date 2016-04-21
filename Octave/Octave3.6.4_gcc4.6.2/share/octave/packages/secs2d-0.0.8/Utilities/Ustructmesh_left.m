function [p,e,t]=Ustructmesh_left(x,y,region,sides)

% [p,e,t]=Ustructmesh(x,y,region,sides)

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

x = sort(x);
y = sort(y);

nx = length(x);
ny = length(y);
[XX,YY] = meshgrid(x,y);
p = [XX(:),YY(:)]';
iiv (ny,nx)=0;
iiv(:)=1:nx*ny;
iiv(end,:)=[];
iiv(:,end)=[];
iiv=iiv(:)';
t = [[iiv;iiv+ny;iiv+1],[iiv+1;iiv+ny;iiv+ny+1] ];
t (4,:)=region;

l1 = 1+ny*([1:nx]-1);
l4 = 1:ny;
l2 = ny*(nx-1)+1:nx*ny;
l3 = ny + l1 -1;

e = [ l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])
       l1([2:end]) l2([2:end]) l3([2:end]) l4([2:end])
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       l1([1:end-1])*0+sides(1) l2([1:end-1])*0+sides(2) l3([1:end-1])*0+sides(3) l4([1:end-1])*0+sides(4)
	   [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
	   [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0+region
	   ];


