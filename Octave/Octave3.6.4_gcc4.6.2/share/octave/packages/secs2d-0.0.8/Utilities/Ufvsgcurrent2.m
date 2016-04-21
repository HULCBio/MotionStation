function [jx,jy]=Ufvsgcurrent2(omesh,n,psi,psith,coeffe);

  %% [jx,jy]=Udrawcurrent2(omesh,n,psi,psith,coeffe);
  
  %% This file is part of 
  %%
  %%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
  %%         -------------------------------------------------------------------
  %%            Copyright (C) 2004-2006  Carlo de Falco
  %%
  %%
  %%
  %%  SECS2D is free software; you can redistribute it and/or modify
  %%  it under the terms of the GNU General Public License as published by
  %%  the Free Software Foundation; either version 2 of the License, or
  %%  (at your option) any later version.
  %%
  %%  SECS2D is distributed in the hope that it will be useful,
  %%  but WITHOUT ANY WARRANTY; without even the implied warranty of
  %%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %%  GNU General Public License for more details.
  %%
  %%  Youx should have received a copy of the GNU General Public License
  %%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
  
  Nelem = size(omesh.t,2);
  jx = NaN*ones(Nelem,1);
  jy = jx;
  coeffe = coeffe';
  %%for iel=1:Nelem
  
  
  dpsi1 = (psi(omesh.t(3,:))-psi(omesh.t(2,:)))';
  dvth1 = (psith(omesh.t(3,:))-psith(omesh.t(2,:)))';
  vthm1 = Utemplogm(psith(omesh.t(3,:)),psith(omesh.t(2,:)))';
  [bp,bn] = Ubern((dpsi1-dvth1)./vthm1);
  t1x    = omesh.p(1,omesh.t(3,:))-omesh.p(1,omesh.t(2,:));
  t1y    = omesh.p(2,omesh.t(3,:))-omesh.p(2,omesh.t(2,:));
  l1     = sqrt(t1x.^2+t1y.^2);
  t1x    = t1x./l1;
  t1y    = t1y./l1;

  j1x    = vthm1.*(coeffe./l1) .* ( n(omesh.t(3,:))' .* bp - ...
				   n(omesh.t(2,:))' .* bn) .* t1x;
  j1y    = vthm1.*(coeffe./l1) .* ( n(omesh.t(3,:))' .* bp - ...
				   n(omesh.t(2,:))' .* bn) .* t1y;
  gg1= -reshape(omesh.shg(1,2,:).*omesh.shg(1,3,:)+...
		omesh.shg(2,2,:).*omesh.shg(2,3,:),1,[]).*l1.^2;
  
  dpsi2 = (psi(omesh.t(1,:))-psi(omesh.t(3,:)))';
  dvth2 = (psith(omesh.t(1,:))-psith(omesh.t(3,:)))';
  vthm2 = Utemplogm(psith(omesh.t(1,:)),psith(omesh.t(3,:)))';
  [bp,bn] = Ubern((dpsi2-dvth2)./vthm2);
  t2x = omesh.p(1,omesh.t(1,:))-omesh.p(1,omesh.t(3,:));
  t2y = omesh.p(2,omesh.t(1,:))-omesh.p(2,omesh.t(3,:));
  l2 = sqrt(t2x.^2+t2y.^2);
  t2x = t2x./l2;
  t2y = t2y./l2;
  j2x = vthm2.*(coeffe./l2) .* ( n(omesh.t(1,:))' .* bp - ...
				n(omesh.t(3,:))' .* bn) .* t2x;
  j2y = vthm2.*(coeffe./l2) .* ( n(omesh.t(1,:))' .* bp - ...
				n(omesh.t(3,:))' .* bn) .* t2y;
  gg2= -reshape(omesh.shg(1,1,:).*omesh.shg(1,3,:)+...
		omesh.shg(2,1,:).*omesh.shg(2,3,:),1,[]).*l2.^2;
  
  dpsi3 = (psi(omesh.t(2,:))-psi(omesh.t(1,:)))';
  dvth3 = (psith(omesh.t(2,:))-psith(omesh.t(1,:)))';
  vthm3 = Utemplogm(psith(omesh.t(2,:)),psith(omesh.t(1,:)))';
  [bp,bn] = Ubern((dpsi3-dvth3)./vthm3);
  t3x = omesh.p(1,omesh.t(2,:))-omesh.p(1,omesh.t(1,:));
  t3y = omesh.p(2,omesh.t(2,:))-omesh.p(2,omesh.t(1,:));
  l3  = sqrt(t3x.^2+t3y.^2);
  t3x = t3x./l3;
  t3y = t3y./l3;
  j3x = vthm3.*(coeffe./l3) .* ( n(omesh.t(2,:))' .* bp - ...
				n(omesh.t(1,:))' .* bn) .* t3x;
  j3y = vthm3.*(coeffe./l3) .* ( n(omesh.t(2,:))' .* bp - ...
				n(omesh.t(1,:))' .* bn) .* t3y;
  gg3= -reshape(omesh.shg(1,2,:).*omesh.shg(1,1,:)+...
		omesh.shg(2,2,:).*omesh.shg(2,1,:),1,[]).*l3.^2;
  
  jx = j1x.*gg1+j2x.*gg2+j3x.*gg3;
  jy = j1y.*gg1+j2y.*gg2+j3y.*gg3;
  
  %%end

