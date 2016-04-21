function [jx,jy]=Ufvsgcurrent(omesh,n,psi,psith,coeffe);

% [jx,jy]=Udrawcurrent(omesh,n,psi,psith,coeffe);

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

Nelem = size(omesh.t,2);
jx = NaN*ones(Nelem,1);
jy = jx;

for iel=1:Nelem

	K = sum(omesh.wjacdet(:,iel));

	dpsi1 = psi(omesh.t(3,iel))-psi(omesh.t(2,iel));
	dvth1 = psith(omesh.t(3,iel))-psith(omesh.t(2,iel));
	vthm1 = Utemplogm(psith(omesh.t(3,iel)),psith(omesh.t(2,iel)));
	[bp,bn] = Ubern((dpsi1-dvth1)/vthm1);
	t1    = omesh.p(:,omesh.t(3,iel))-omesh.p(:,omesh.t(2,iel));
	l1    = norm(t1,2);
	t1    = t1/l1;
	j1    = vthm1*(coeffe(iel)/l1) * ( n(omesh.t(3,iel)) * bp - ...
		n(omesh.t(2,iel)) * bn) * t1;

	gg1= omesh.shg(:,2,iel)'*omesh.shg(:,3,iel)*l1^2;

	dpsi2 = psi(omesh.t(1,iel))-psi(omesh.t(3,iel));
	dvth2 = psith(omesh.t(1,iel))-psith(omesh.t(3,iel));
	vthm2 = Utemplogm(psith(omesh.t(1,iel)),psith(omesh.t(3,iel)));
	[bp,bn] = Ubern((dpsi2-dvth2)/vthm2);
	t2 = omesh.p(:,omesh.t(1,iel))-omesh.p(:,omesh.t(3,iel));
	l2 = norm(t2,2);
	t2 = t2/l2;
	j2 = vthm2*(coeffe(iel)/l2) * ( n(omesh.t(1,iel)) * bp - ...
		n(omesh.t(3,iel)) * bn) * t2;

	gg2= omesh.shg(:,1,iel)'*omesh.shg(:,3,iel)*l2^2;

	dpsi3 = psi(omesh.t(2,iel))-psi(omesh.t(1,iel));
	dvth3 = psith(omesh.t(2,iel))-psith(omesh.t(1,iel));
	vthm3 = Utemplogm(psith(omesh.t(2,iel)),psith(omesh.t(1,iel)));
	[bp,bn] = Ubern((dpsi3-dvth3)/vthm3);
	t3 = omesh.p(:,omesh.t(2,iel))-omesh.p(:,omesh.t(1,iel));
	l3 = norm(t3,2);
	t3 = t3/l3;
	j3 = vthm3*(coeffe(iel)/l3) * ( n(omesh.t(2,iel)) * bp - ...
		n(omesh.t(1,iel)) * bn) * t3;

	gg3= omesh.shg(:,2,iel)'*omesh.shg(:,1,iel)*l3^2;
	
	Jk = j1*gg1+j2*gg2+j3*gg3;
	jx(iel) = Jk(1);
	jy(iel) = Jk(2);

end