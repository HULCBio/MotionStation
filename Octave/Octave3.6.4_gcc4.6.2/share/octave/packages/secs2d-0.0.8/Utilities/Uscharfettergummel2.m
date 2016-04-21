function SG=Uscharfettergummel2(mesh,v,acoeff,bcoeff)

%
% SG=Ufastscharfettergummel2(mesh,v,acoeff,bcoeff)
% 
%
% Builds the Scharfetter-Gummel  matrix for the 
% the discretization of the LHS 
% of the Drift-Diffusion equation:
%
% $ -\div (a(x) (\grad (b(x) u) -  b(x) u \grad v'(x) ))= f $
%
% where a(x) is piecewise constant
% and v(x),b(x) is piecewise linear, so that 
% v'(x) is still piecewise constant
% and u is the unknown
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


Nnodes = length(mesh.p);
Nelements = length(mesh.t);

areak   = reshape (sum( mesh.wjacdet,1),1,1,Nelements);
shg     = mesh.shg(:,:,:);
M       = reshape (acoeff,1,1,Nelements);	


% build local Laplacian matrix	

Lloc=zeros(3,3,Nelements);	

for inode=1:3
  for jnode=1:3

    ginode(inode,jnode,:)=mesh.t(inode,:);
    gjnode(inode,jnode,:)=mesh.t(jnode,:);
    Lloc(inode,jnode,:)  = M .* sum( shg(:,inode,:) .* shg(:,jnode,:),1) .* areak;

  end
end		

vloc    = v(mesh.t(1:3,:));
bloc    = bcoeff(mesh.t(1:3,:));

blocm1 = Utemplogm(bloc(3,:),bloc(2,:));
blocm2 = Utemplogm(bloc(1,:),bloc(3,:));
blocm3 = Utemplogm(bloc(1,:),bloc(2,:));

[bp12,bm12] = Ubern(((vloc(2,:)-vloc(1,:))-(bloc(2,:)-bloc(1,:)))./blocm3);
[bp13,bm13] = Ubern(((vloc(3,:)-vloc(1,:))-(bloc(3,:)-bloc(1,:)))./blocm2);
[bp23,bm23] = Ubern(((vloc(3,:)-vloc(2,:))-(bloc(3,:)-bloc(2,:)))./blocm1);

bp12 = reshape(blocm3.*bp12,1,1,Nelements).*Lloc(1,2,:);
bm12 = reshape(blocm3.*bm12,1,1,Nelements).*Lloc(1,2,:);
bp13 = reshape(blocm2.*bp13,1,1,Nelements).*Lloc(1,3,:);
bm13 = reshape(blocm2.*bm13,1,1,Nelements).*Lloc(1,3,:);
bp23 = reshape(blocm1.*bp23,1,1,Nelements).*Lloc(2,3,:);
bm23 = reshape(blocm1.*bm23,1,1,Nelements).*Lloc(2,3,:);

SGloc(1,1,:) = -bm12-bm13;
SGloc(1,2,:) = bp12;
SGloc(1,3,:) = bp13;

SGloc(2,1,:) = bm12;
SGloc(2,2,:) = -bp12-bm23; 
SGloc(2,3,:) = bp23;

SGloc(3,1,:) = bm13;
SGloc(3,2,:) = bm23;
SGloc(3,3,:) = -bp13-bp23;

##SGloc=[-bm12-bm13,   bp12     ,   bp13
##       bm12     ,  -bp12-bm23,   bp23
##        bm13     ,   bm23     ,  -bp13-bp23];

SG = sparse(ginode(:),gjnode(:),SGloc(:));


