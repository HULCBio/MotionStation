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
##
## @deftypefn {Function File} {[@var{gx},@var{gy}]} = @
## bim2c_pde_gradient(@var{mesh},@var{u}) 
##
## Compute the gradient of the piecewise linear conforming scalar
## function @var{u}.
##
## @seealso{bim2c_global_flux}
## @end deftypefn

function [gx, gy] = bim2c_pde_gradient(mesh,u)

  ## Check input  
  if nargin != 2
    error("bim2c_pde_gradient: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim2c_pde_gradient: first input is not a valid mesh structure.");
  endif

  nnodes = columns(mesh.p);

  if length(u) != nnodes
    error("bim2c_pde_gradient: length(u) != nnodes.");
  endif

  shgx = reshape(mesh.shg(1,:,:),3,[]);
  gx   = sum(shgx.*u(mesh.t(1:3,:)),1);
  shgy = reshape(mesh.shg(2,:,:),3,[]);
  gy   = sum(shgy.*u(mesh.t(1:3,:)),1);

endfunction
