function [current,divrg]=ThDDGOXddcurrent(Simesh,Sinodes,data,contacts);

% [current,divrg]=DDGOXddcurrent(Simesh,Sinodes,data,contacts);


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

load (file_in_path(path,'constants.mat'))


Nelements = size(mesh.t,2);
mobn0 = thermdata.mobn0([],Simesh,Sinodes,[],data);
mobp0 = thermdata.mobp0([],Simesh,Sinodes,[],data);
mobn1 = thermdata.mobn1([],Simesh,Sinodes,[],data);
mobp1 = thermdata.mobp1([],Simesh,Sinodes,[],data);
An  = Uscharfettergummel3(Simesh,mobn0,mobn1,data.Tn,data.V(Sinodes)-data.Tn);
Ap  = Uscharfettergummel3(Simesh,mobp0,mobp1,data.Tp,-data.V(Sinodes)-data.Tn);
divrg = An * data.n + Ap * data.p;

for con = 1:length(contacts)

    cedges = [];
    cedges=[cedges,find(mesh.e(5,:)==contacts(con))];
    cnodes = mesh.e(1:2,cedges);
    cnodes = [cnodes(1,:) cnodes(2,:)];
    cnodes = unique(cnodes);
    
    current(con) = sum(divrg(cnodes));
    
end

Is = q*data.us*data.Vs*data.ns;
current = current * Is;


