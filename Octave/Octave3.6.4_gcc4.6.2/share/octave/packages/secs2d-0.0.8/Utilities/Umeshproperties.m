function mesh=Umeshproperties(mesh)

%
% mesh=Umeshproperties(mesh)
% precomputes some useful mesh properties
%



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




weight = [1/3 1/3 1/3];
areakk = 1/2;
Nelements = Ucolumns(mesh.t);

jac([1,2],:) = [mesh.p(1,mesh.t(2,:))-mesh.p(1,mesh.t(1,:));
	    mesh.p(1,mesh.t(3,:))-mesh.p(1,mesh.t(1,:))];
jac([3,4],:) = [mesh.p(2,mesh.t(2,:))-mesh.p(2,mesh.t(1,:));
            mesh.p(2,mesh.t(3,:))-mesh.p(2,mesh.t(1,:))];
jacdet = jac(1,:).*jac(4,:)-jac(2,:).*jac(3,:);

degen=find(jacdet <= 0);
if ~isempty(degen)
  fprintf(1,'invalid mesh element:  %d  fixing...\n',degen);
  mesh.t(1:3,degen) = mesh.t([2,1,3],degen);
  jac([1,2],degen) = [mesh.p(1,mesh.t(2,degen))-mesh.p(1,mesh.t(1,degen));
		      mesh.p(1,mesh.t(3,degen))-mesh.p(1,mesh.t(1,degen))];
  jac([3,4],degen) = [mesh.p(2,mesh.t(2,degen))-mesh.p(2,mesh.t(1,degen));
		      mesh.p(2,mesh.t(3,degen))-mesh.p(2,mesh.t(1,degen))];
  jacdet(degen) = jac(1,degen).*jac(4,degen)-jac(2,degen).*jac(3,degen);
end

for inode = 1:3
  mesh.wjacdet(inode,:) = areakk .* jacdet .* weight(inode);
end

mesh.shp     = eye(3);

x0 = mesh.p(1,mesh.t(1,:));
y0 = mesh.p(2,mesh.t(1,:));
x1 = mesh.p(1,mesh.t(2,:));
y1 = mesh.p(2,mesh.t(2,:));
x2 = mesh.p(1,mesh.t(3,:));
y2 = mesh.p(2,mesh.t(3,:));

denom = (-(x1.*y0) + x2.*y0 + x0.*y1 - x2.*y1 - x0.*y2 + x1.*y2);
mesh.shg(1,1,:)  =  (y1 - y2)./denom;
mesh.shg(2,1,:)  = -(x1 - x2)./denom;
mesh.shg(1,2,:)  = -(y0 - y2)./denom;
mesh.shg(2,2,:)  =  (x0 - x2)./denom;
mesh.shg(1,3,:)  =  (y0 - y1)./denom;
mesh.shg(2,3,:)  = -(x0 - x1)./denom;


