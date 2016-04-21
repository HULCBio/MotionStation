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
## @deftypefn {Function File} {[@var{b}]} = @
## bim2a_rhs(@var{mesh},@var{f},@var{g}) 
##
## Build the finite element right-hand side of a diffusion problem
## employing mass-lumping.
##
## The equation taken into account is:
##
## @var{delta} * u = f * g
## 
## where @var{f} is an element-wise constant scalar function, while
## @var{g} is a piecewise linear conforming scalar function.
## 
## @seealso{bim2a_reaction, bim2a_advection_diffusion, bim2a_laplacian,
## bim1a_reaction, bim3a_reaction}
## @end deftypefn

function b = bim2a_rhs(mesh,f,g)

  ## Check input
  if nargin != 3
    error("bim2a_rhs: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim2a_rhs: first input is not a valid mesh structure.");
  endif

  nnodes = columns(mesh.p);
  nelem  = columns(mesh.t);

  ## Turn scalar input to a vector of appropriate size
  if isscalar(f)
    f = f*ones(nelem,1);
  endif
  if isscalar(g)
    g = g*ones(nnodes,1);
  endif

  if !( isvector(f) && isvector(g) )
    error("bim2a_rhs: coefficients are not valid vectors.");
  elseif length(f) != nelem
    error("bim2a_rhs: length of f is not equal to the number of elements.");
  elseif length(g) != nnodes
    error("bim2a_rhs: length of g is not equal to the number of nodes.");
  endif

  g       = g(mesh.t(1:3,:));
  wjacdet = mesh.wjacdet;

  ## Build local matrix	
  Blocmat=zeros(3,nelem);	
  for inode=1:3
    Blocmat(inode,:) = f'.*g(inode,:).*wjacdet(inode,:);
  endfor

  gnode=(mesh.t(1:3,:));
  
  ## Assemble global matrix
  b = sparse(gnode(:),1,Blocmat(:));

endfunction

%!shared mesh,f,g,nnodes,nelem
% x = y = linspace(0,1,4);
% [mesh] = msh2m_structured_mesh(x,y,1,1:4);
% [mesh] = bim2c_mesh_properties(mesh);
% nnodes = columns(mesh.p);
% nelem  = columns(mesh.t);
% g      = ones(columns(mesh.t),1);
% f      = ones(columns(mesh.p),1);
%!test
% [b] = bim2a_rhs(mesh,f,g);
% assert(size(b),[nnodes, 1]);
%!test
% [b1] = bim2a_rhs(mesh,3*f,g);
% [b2] = bim2a_rhs(mesh,f,3*g);
% assert(b1,b2);
%!test
% [b1] = bim2a_rhs(mesh,3*f,g);
% [b2] = bim2a_rhs(mesh,3,1);
% assert(b1,b2);