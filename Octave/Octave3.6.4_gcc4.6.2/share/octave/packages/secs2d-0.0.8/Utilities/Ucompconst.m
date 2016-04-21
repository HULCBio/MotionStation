function C = Ucompconst (imesh,coeffn,coeffe)

  %% C = Ucompconst (imesh,coeffn,coeffe)



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



  Nnodes    =size(imesh.p,2);
  Nelements =size(imesh.t,2);

  %%fprintf(1,'*--------------------*\n');
  %%fprintf(1,'building RHS\n*');

  coeff   = coeffn(imesh.t(1:3,:));
  wjacdet = imesh.wjacdet;
                                % build local matrix	
  Blocmat=zeros(3,Nelements);	
  for inode=1:3
    Blocmat(inode,:) = coeffe'.*coeff(inode,:).*wjacdet(inode,:);
    %%fprintf(1,'----');
  end

  gnode=(imesh.t(1:3,:));
  %%fprintf(1,'--');
                                % assemble global matrix

  C = sparse(gnode(:),1,Blocmat(:));

  %%fprintf(1,'----*\nDONE!\n\n\n');

