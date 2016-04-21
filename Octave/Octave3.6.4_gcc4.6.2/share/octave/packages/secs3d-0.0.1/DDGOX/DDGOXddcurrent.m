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

% [current,divrg]=DDGOXddcurrent(mesh,Sinodes,data,contacts);

function [current,divrg]=DDGOXddcurrent(mesh,Sinodes,data,contacts);

load constants
Nelements = size(mesh.t,2);
mob = data.un*ones(Nelements,1);%Ufielddepmob(mesh,data.un,data.Fn,data.vsatn,data.mubn);
An        = Uscharfettergummel(mesh,data.V(Sinodes),mob);
mob = data.up*ones(Nelements,1);%Ufielddepmob(mesh,data.up,-data.V(Sinodes),data.vsatp,data.mubp);
Ap        = Uscharfettergummel(mesh,-data.V(Sinodes),mob);
divrg     = An * data.n - Ap * data.p;

for con = 1:length(contacts)
  
  cnodes = Ugetnodesonface(mesh,contacts(con));
  current(con) = sum(divrg(cnodes));
  
end

Is = q*data.us*data.Vs*data.ns;
current = current * Is;

