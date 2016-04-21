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
## @deftypefn {Function File} @
## {@var{A}} = bim1a_laplacian (@var{mesh},@var{epsilon},@var{kappa})
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
## @seealso{bim1a_rhs, bim1a_reaction, bim1a_advection_diffusion,
## bim2a_laplacian, bim3a_laplacian}
## @end deftypefn

function [A] = bim1a_laplacian(mesh,epsilon,kappa)
  
  ## Check input
  if nargin != 3
    error("bim1a_laplacian: wrong number of input parameters.");
  elseif !isvector(mesh)
    error("bim1a_laplacian: first argument is not a valid vector.");
  endif

  ## Input-type check inside bim1a_advection_diffusion
  nnodes = length(mesh);
  nelem  = nnodes - 1;
  
  A = bim1a_advection_diffusion (mesh, epsilon, kappa, ones(nnodes,1), 0);
  
endfunction