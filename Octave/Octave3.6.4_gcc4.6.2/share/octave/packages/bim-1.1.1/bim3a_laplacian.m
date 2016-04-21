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
## @deftypefn {Function File} @
## {@var{A}} = bim3a_laplacian (@var{mesh}, @var{epsilon}, @var{kappa})
##
## Build the standard finite element stiffness matrix for a diffusion
## problem. 
##
## The equation taken into account is:
##
## - (@var{epsilon} * @var{kappa} ( u' ))' = f
## 
## where @var{epsilon} is an element-wise constant scalar function,
## while @var{kappa} is a piecewise linear conforming scalar function.
##
## @seealso{bim3a_rhs, bim3a_reaction, bim2a_laplacian, bim3a_laplacian}
## @end deftypefn

function [A] = bim3a_laplacian (mesh,epsilon,kappa)

  ## Check input
  if nargin != 3
    error("bim3a_laplacian: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim3a_laplacian: first input is not a valid mesh structure.");
  endif

  p      = mesh.p;
  t      = mesh.t;
  nnodes = columns(p);
  nelem  = columns(t);

  ## Turn scalar input to a vector of appropriate size
  if isscalar(epsilon)
    epsilon  = epsilon * ones(nelem,1);
  endif
  if isscalar(kappa)
    kappa = kappa*ones(nnodes,1);
  endif

  if !( isvector(epsilon) && isvector(kappa) )
    error("bim3a_laplacian: coefficients are not valid vectors.");
  elseif length(epsilon) != nelem
    error("bim3a_laplacian: length of epsilon is not equal to the number of elements.");
  elseif length(kappa) != nnodes
    error("bim2a_laplacian: length of kappa is not equal to the number of nodes.");
  endif

  ## Local contributions
  Lloc = zeros(4,4,nelem);

  epsilonareak = reshape (epsilon .* mesh.area',1,1,nelem);
  shg = mesh.shg(:,:,:);
  
  ## Computation
  for inode = 1:4
    for jnode = 1:4
      ginode(inode,jnode,:) = mesh.t(inode,:);
      gjnode(inode,jnode,:) = mesh.t(jnode,:);
      Lloc(inode,jnode,:)   = sum( kappa(inode) * shg(:,inode,:) .* shg(:,jnode,:),1) .* epsilonareak;
    endfor
  endfor

  ## Assembly
  A = sparse(ginode(:),gjnode(:),Lloc(:));

endfunction

%!shared mesh,epsilon,kappa,nnodes,nelem
% x = y = z = linspace(0,1,4);
% [mesh] = msh3m_structured_mesh(x,y,z,1,1:6);
% [mesh] = bim3c_mesh_properties(mesh);
% nnodes = columns(mesh.p);
% nelem  = columns(mesh.t);
% epsilon = ones(columns(mesh.t),1);
% kappa   = ones(columns(mesh.p),1);
%!test
% [A] = bim3a_laplacian(mesh,epsilon,kappa);
% assert(size(A),[nnodes, nnodes]);
%!test
% [A1] = bim3a_laplacian(mesh,3*epsilon,kappa);
% [A2] = bim3a_laplacian(mesh,epsilon,3*kappa);
% assert(A1,A2);
%!test
% [A1] = bim3a_laplacian(mesh,epsilon,kappa);
% [A2] = bim3a_laplacian(mesh,1,1);
% assert(A1,A2);