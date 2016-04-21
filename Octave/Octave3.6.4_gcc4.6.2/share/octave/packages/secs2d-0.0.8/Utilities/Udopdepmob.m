function mob=Udopdepmob (mesh,mu,par,D);

% Udopdepmob (mu,par,D);

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

NI  = sum(D(mesh.t(1:3,:)),1)'/3;
mob =   par(1)*exp(-par(4)./NI) +...
    (mu-par(2))./(1+(NI/par(5)).^par(7)) -...
    par(3)./(1+(par(6)./NI).^par(8));

