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

% omesh = Umeshproperties (imesh)
% Precompute mesh data.

function omesh = Umeshproperties(imesh)

omesh = imesh;

Nnodes    = size(imesh.p,2);
Nelements = size(imesh.t,2);

weight    = [1/4 1/4 1/4 1/4]';

for iel=1:Nelements
  
  x1=imesh.p(1,imesh.t(1,iel));
  y1=imesh.p(2,imesh.t(1,iel));
  z1=imesh.p(3,imesh.t(1,iel));
  x2=imesh.p(1,imesh.t(2,iel));
  y2=imesh.p(2,imesh.t(2,iel));
  z2=imesh.p(3,imesh.t(2,iel));
  x3=imesh.p(1,imesh.t(3,iel));
  y3=imesh.p(2,imesh.t(3,iel));
  z3=imesh.p(3,imesh.t(3,iel));
  x4=imesh.p(1,imesh.t(4,iel));
  y4=imesh.p(2,imesh.t(4,iel));
  z4=imesh.p(3,imesh.t(4,iel));
  
  
  Nb2 = y1*(z3-z4) + y3*(z4-z1) + y4*(z1-z3);
  Nb3 = y1*(z4-z2) + y2*(z1-z4) + y4*(z2-z1);
  Nb4 = y1*(z2-z3) + y2*(z3-z1) + y3*(z1-z2);
  
  
  detJ = (x2-x1)*Nb2 +(x3-x1)*Nb3 +(x4-x1)*Nb4;
  % Determinant of the Jacobian of the 
  % transformation from the base tetrahedron
  % to the tetrahedron K
  Kkvolume = 1/6;
  % Volume of the reference tetrahedron
  omesh.wjacdet(:,iel) = Kkvolume * weight * detJ;
  
  % Shape function gradients follow
  % first index represents space direction
  % second index represents the shape function
  % third index represents the tetrahedron number
  omesh.shg(:,1,iel) = [ y2*(z4-z3) + y3*(z2-z4) + y4*(z3-z2) 
                      x2*(z3-z4) + x3*(z4-z2) + x4*(z2-z3)
                      x2*(y4-y3) + x3*(y2-y4) + x4*(y3-y2) ] / detJ;
  
  omesh.shg(:,2,iel) = [ Nb2
                      x1*(z4-z3) + x3*(z1-z4) + x4*(z3-z1)
                      x1*(y3-y4) + x3*(y4-y1) + x4*(y1-y3) ] / detJ;
  
  omesh.shg(:,3,iel) = [ Nb3
                      x1*(z2-z4) + x2*(z4-z1) + x4*(z1-z2)
                      x1*(y4-y2) + x2*(y1-y4) + x4*(y2-y1) ] / detJ;
  
  omesh.shg(:,4,iel) = [ Nb4
                      x1*(z3-z2) + x2*(z1-z3) + x3*(z2-z1)
                      x1*(y2-y3) + x2*(y3-y1) + x3*(y1-y2) ] / detJ;
  
  omesh.shp = eye(4);
end    
