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


% SG=Uscharfettergummel(mesh,v,acoeff)
% 
%
% Builds the Scharfetter-Gummel  matrix for the 
% the discretization of the LHS 
% of the Drift-Diffusion equation:
%
% $ -\div (a(x) (\grad u -  u \grad v'(x) ))= f $
%
% where a(x) is piecewise constant
% and v(x) is piecewise linear, so that 
% v'(x) is still piecewise constant
% b is a constant independent of x
% and u is the unknown
%

function SG=Uscharfettergummel(mesh,v,acoeff)

p=mesh.p;
t=mesh.t;

Nnodes = length(p);
Nelements = length(t);

fprintf(1,'*--------------------*\n');
fprintf(1,'building SG Matrix\n*');
SG = bim3a_advection_diffusion (mesh, acoeff, v);
fprintf(1,'--------------------*\nDONE!\n\n\n');
