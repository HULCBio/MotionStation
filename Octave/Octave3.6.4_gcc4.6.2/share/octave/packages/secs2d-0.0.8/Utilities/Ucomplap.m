function L = Ucomplap (mesh,coeff)
  
                                % L = Ufastcomplap (mesh,coeff)


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
  
  %%fprintf(1,'*--------------------*\n');
  %%fprintf(1,'building Stiffness Matrix\n*');
  
  areak   = reshape(sum( mesh.wjacdet,1),1,1,Nelements);
  shg     = mesh.shg(:,:,:);
  M       = reshape(coeff,1,1,Nelements);
  
                                % build local matrix	
  Lloc=zeros(3,3,Nelements);	
  for inode=1:3
    for jnode=1:3
      
      Lloc(inode,jnode,:) = M .* sum( shg(:,inode,:) .* shg(:,jnode,:),1) .* areak;
      %%fprintf(1,'-');
      
      ginode(inode,jnode,:)=mesh.t(inode,:);
      gjnode(inode,jnode,:)=mesh.t(jnode,:);
      
      %%fprintf(1,'-');
      
    end
  end		
  
  L = sparse(ginode(:),gjnode(:),Lloc(:));
  %%fprintf(1,'--*\nDONE!\n\n\n');
  
  
