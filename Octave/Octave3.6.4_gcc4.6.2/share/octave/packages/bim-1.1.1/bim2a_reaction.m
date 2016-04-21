## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     BIM - Diffusion Advection Reaction PDE Solver
##
##  BIM is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  BIM is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with BIM; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{C}]} = @
## bim2a_reaction(@var{mesh},@var{delta},@var{zeta}) 
##
## Build the lumped finite element mass matrix for a diffusion
## problem. 
##
## The equation taken into account is:
##
## @var{delta} * @var{zeta} * u = f
## 
## where @var{delta} is an element-wise constant scalar function, while
## @var{zeta} is a piecewise linear conforming scalar function.
##
## @seealso{bim2a_rhs, bim2a_advection_diffusion, bim2a_laplacian,
## bim1a_reaction, bim3a_reaction}
## @end deftypefn

function [C] = bim2a_reaction(mesh,delta,zeta)

  ## Check input
  if nargin != 3
    error("bim2a_reaction: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim2a_reaction: first input is not a valid mesh structure.");
  endif

  nnodes = size(mesh.p,2);
  nelem  = size(mesh.t,2);

  ## Turn scalar input to a vector of appropriate size
  if isscalar(delta)
    delta = delta*ones(nelem,1);
  endif
  if isscalar(zeta)
    zeta = zeta*ones(nnodes,1);
  endif

  if !( isvector(delta) && isvector(zeta) )
    error("bim2a_reaction: coefficients are not valid vectors.");
  elseif length(delta) != nelem
    error("bim2a_: length of alpha is not equal to the number of elements.");
  elseif length(zeta) != nnodes
    error("bim2a_: length of gamma is not equal to the number of nodes.");
  endif

  wjacdet   = mesh.wjacdet(:,:);
  coeff     = zeta(mesh.t(1:3,:));
  coeffe    = delta(:);
  
  ## Local matrix	
  Blocmat = zeros(3,nelem);	
  for inode = 1:3
    Blocmat(inode,:) = coeffe'.*coeff(inode,:).*wjacdet(inode,:);
  endfor
  
  gnode = (mesh.t(1:3,:));
  
  ## Global matrix
  C = sparse(gnode(:),gnode(:),Blocmat(:));

endfunction

%!shared mesh,delta,zeta,nnodes,nelem
% x = y = linspace(0,1,4);
% [mesh] = msh2m_structured_mesh(x,y,,1:4;
% [mesh] = bim2c_mesh_properties(mesh);
% nnodes = columns(mesh.p);
% nelem  = columns(mesh.t);
% delta  = ones(columns(mesh.t),1);
% zeta   = ones(columns(mesh.p),1);
%!test
% [C] = bim2a_reaction(mesh,delta,zeta);
% assert(size(C),[nnodes, nnodes]);
%!test
% [C1] = bim2a_reaction(mesh,3*delta,zeta);
% [C2] = bim2a_reaction(mesh,delta,3*zeta);
% assert(C1,C2);
%!test
% [C1] = bim2a_reaction(mesh,3*delta,zeta);
% [C2] = bim2a_reaction(mesh,3,1);
% assert(C1,C2);