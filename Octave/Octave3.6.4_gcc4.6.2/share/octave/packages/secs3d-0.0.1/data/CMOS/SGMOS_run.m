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

% Simulate a single gate MOS with a classical model

clear all

fprintf ('build mesh\n');
SGMOS;

fprintf ('setup data\n');
SGMOS_data;

fprintf ('run simulation\n');
[odata, it, res] = DDGOXgummelmap (imesh, Dsides,...
                                   Simesh, Sinodes, Sielements, SiDsides,...
                                   idata, toll, maxit, ptoll, pmaxit, verbose);

fprintf ('posrprocess\n');
[odatads, omeshds] = Udescaling (imesh, odata);
[odatads, Siomeshds] = Udescaling (Simesh, odata);

fpl_vtk_write_field("SGMOS", omeshds, {odatads.V, "V"}, {}, 1);
fpl_vtk_write_field("SGMOS_Si", Siomeshds, {odatads.n, "n"; odatads.p, "p"; odatads.Fn, "Fn"; odatads.Fp, "Fp"}, {}, 1);