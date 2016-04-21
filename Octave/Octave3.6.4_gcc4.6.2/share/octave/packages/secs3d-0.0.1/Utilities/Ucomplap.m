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

% L = Ucomplap (mesh,coeff)

function L = Ucomplap (mesh,coeff)

p=mesh.p;
t=mesh.t;
Nnodes = length(p);
Nelements = length(t);

L=spalloc(Nnodes,Nnodes,5*Nnodes);

fprintf(1,'*--------------------*\n');
fprintf(1,'building Stiffness Matrix\n*');
L = bim3a_laplacian (mesh, coeff, ones(Nnodes, 1));
fprintf(1,'--------------------*\nDONE!\n\n\n');


