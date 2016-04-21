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
## @deftypefn {Function File} {[@var{nodelist}]} = @
## bim3c_unknowns_on_faces(@var{mesh},@var{facelist}) 
##
## Return the list of the mesh nodes that lie on the geometrical faces
## specified in @var{facelist}.
##
## @seealso{bim3c_unknown_on_faces, bim2c_pde_gradient,
## bim2c_global_flux}
##
## @end deftypefn
  
function [nodelist] = bim3c_unknowns_on_faces(mesh,facelist)

  ## Check input  
  if nargin != 2
    error("bim3c_unknowns_on_faces: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim3c_unknowns_on_faces: first input is not a valid mesh structure.");
  elseif !isnumeric(facelist)
    error("bim3c_unknowns_on_faces: second input is not a valid numeric vector.");
  endif
	
  [nodelist] = msh3m_nodes_on_faces(mesh,facelist);

endfunction

%!shared mesh
% x = y = z = linspace(0,1,2);
% [mesh] = msh3m_structured_mesh(x,y,z,1,1:6);
%!test
% assert( bim3c_unknowns_on_faces(mesh, 1),[1 2 5 6] )
%!test
% assert( bim3c_unknowns_on_faces(mesh, 2),[3 4 7 8] )
%!test
% assert( bim3c_unknowns_on_faces(mesh, [1 2]),1:8)