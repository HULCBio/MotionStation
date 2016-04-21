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
## bim3a_rhs (@var{mesh}, @var{f}, @var{g}) 
##
## Build the finite element right-hand side of a diffusion problem
## employing mass-lumping.
##
## The equation taken into account is:
##
## @var{delta} * u =  @var{f} * @var{g}
## 
## where @var{f} is an element-wise constant scalar function, while
## @var{g} is a piecewise linear conforming scalar function.
## 
## @seealso{bim3a_reaction, bim3_laplacian, bim1a_reaction,
## bim2a_reaction} 
## @end deftypefn

function [b] = bim3a_rhs (mesh,f,g);

  ## Check input
  if nargin != 3
    error("bim3a_rhs: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim3a_rhs: first input is not a valid mesh structure.");
  endif

  nnodes    = columns (mesh.p);
  nelem     = length (mesh.t);

  ## Turn scalar input to a vector of appropriate size
  if isscalar(f)
    f = f*ones(nelem,1);
  endif
  if isscalar(g)
    g = g*ones(nnodes,1);
  endif

  if !( isvector(f) && isvector(g) )
    error("bim3a_rhs: coefficients are not valid vectors.");
  elseif length(f) != nelem
    error("bim3a_rhs: length of f is not equal to the number of elements.");
  elseif length(g) != nnodes
    error("bim3a_rhs: length of g is not equal to the number of nodes.");
  endif

  bloc    = zeros(4,nelem);
  coeff   = g(mesh.t(1:4,:));
  coeffe  = f;
  wjacdet = mesh.wjacdet;

  for inode = 1:4
    bloc(inode,:) = coeffe'.*coeff(inode,:).*wjacdet(inode,:);
  endfor

  gnode = (mesh.t(1:4,:));

  ## Global matrix
  b = sparse(gnode(:),1,bloc(:));

endfunction

%!shared mesh,f,g,nnodes,nelem
% x = y = z = linspace(0,1,4);
% [mesh] = msh3m_structured_mesh(x,y,z,1,1:6);
% [mesh] = bim3c_mesh_properties(mesh);
% nnodes = columns(mesh.p);
% nelem  = columns(mesh.t);
% g      = ones(columns(mesh.t),1);
% f      = ones(columns(mesh.p),1);
%!test
% [b] = bim3a_rhs(mesh,f,g);
% assert(size(b),[nnodes, 1]);
%!test
% [b1] = bim3a_rhs(mesh,3*f,g);
% [b2] = bim3a_rhs(mesh,f,3*g);
% assert(b1,b2);
%!test
% [b1] = bim2a_rhs(mesh,3*f,g);
% [b2] = bim2a_rhs(mesh,3,1);
% assert(b1,b2);