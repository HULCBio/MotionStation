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
## @deftypefn {Function File} {[@var{omesh}]} = @
## bim3c_mesh_properties(@var{imesh})
##
## Compute the properties of @var{imesh} needed by BIM method and append
## them to @var{omesh} as fields.
##
## @seealso{bim3a_reaction, bim3a_rhs, bim3a_laplacian}
## @end deftypefn

function [omesh] = bim3c_mesh_properties (imesh)

  ## Check input  
  if nargin != 1
    error("bim3c_mesh_properties: wrong number of input parameters.");
  elseif (! isstruct (imesh) || any (! isfield (imesh, {"p", "e", "t"}))) 
    error ("bim3c_mesh_properties: first input is not a valid mesh structure.");
  endif

  ## Compute properties
  omesh = imesh;
  [omesh.wjacdet,omesh.area,omesh.shg,omesh.shp] = ...
      msh3m_geometrical_properties (imesh, "wjacdet", "area", "shg", "shp");

endfunction

%!shared mesh
% x = y = z = linspace(0,1,4);
% mesh = msh3m_structured_mesh(x,y,z,1,1:6);
% mesh = bim3c_mesh_properties (mesh);
%!test
% tmp = msh3m_geometrical_properties (mesh, "wjacdet");
% assert(mesh.wjacdet,tmp);
%!test
% tmp = msh3m_geometrical_properties(mesh,"shg");
% assert(mesh.shg,tmp);
%!test
% tmp = msh3m_geometrical_properties(mesh,"shp");
% assert(mesh.shp,tmp);
%!test
% assert(mesh.area,sum(mesh.wjacdet,1));

