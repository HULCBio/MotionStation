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
## @deftypefn {Function File} {[@var{M}]} = @
## bim2a_boundary_mass(@var{mesh},@var{sidelist},@var{nodelist})
##
## Build the lumped boundary mass matrix needed to apply Robin boundary
## conditions.   
##
## The vector @var{sidelist} contains the list of the side edges
## contributing to the mass matrix.
##
## The optional argument @var{nodelist} contains the list of the
## degrees of freedom on the boundary.
##
## @seealso{bim2a_rhs, bim2a_advection_diffusion, bim2a_laplacian,
## bim2a_reaction} 
## @end deftypefn

function [M] = bim2a_boundary_mass(mesh,sidelist,nodelist)

  ## Check input
  if nargin > 3
    error("bim2a_boundary_mass: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim2a_boundary_mass: first input is not a valid mesh structure.");
  elseif !( isvector(sidelist) && isnumeric(sidelist) )
    error("bim2a_boundary_mass: second input is not a valid numeric vector.");
  endif

  if nargin<3
    [nodelist] = bim2c_unknowns_on_side(mesh,sidelist);
  endif

  edges = [];
  for ie = sidelist
    edges = [ edges,  mesh.e([1:2 5],mesh.e(5,:)==ie)];
  endfor
  l  = sqrt((mesh.p(1,edges(1,:))-mesh.p(1,edges(2,:))).^2 +
	    (mesh.p(2,edges(1,:))-mesh.p(2,edges(2,:))).^2);
  
  dd = zeros(size(nodelist));
  
  for in = 1:length(nodelist)
    dd (in) = (sum(l(edges(1,:)==nodelist(in)))+sum(l(edges(2,:)==nodelist(in))))/2;
  endfor
  
  M = sparse(diag(dd));

endfunction