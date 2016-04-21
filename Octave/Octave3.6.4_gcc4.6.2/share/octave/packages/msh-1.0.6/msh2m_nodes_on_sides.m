## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     MSH - Meshing Software Package for Octave
##
##  MSH is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  MSH is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with MSH; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{nodelist}]} = @
## msh2m_nodes_on_sides(@var{mesh},@var{sidelist})
##
## Return a list of @var{mesh} nodes lying on the sides specified in
## @var{sidelist}.
##
## @seealso{msh2m_geometrical_properties, msh2m_topological_properties,
## msh3m_nodes_on_faces} 
## @end deftypefn

function [nodelist] = msh2m_nodes_on_sides(mesh,sidelist)

  ## Check input
  if nargin != 2 # Number of input parameters
    error("msh2m_nodes_on_sides: wrong number of input parameters.");
  elseif !(isstruct(mesh)    && isfield(mesh,"p") &&
	   isfield(mesh,"t") && isfield(mesh,"e"))
    error("msh2m_nodes_on_sides: first input is not a valid mesh structure.");
  elseif !isnumeric(sidelist)
    error("msh2m_nodes_on_sides: only numeric value admitted as sidelist.");
  endif

  ## Search nodes

  edgelist = [];
  
  for ii = 1:length(sidelist)
    edgelist=[edgelist,find(mesh.e(5,:)==sidelist(ii))];
  endfor

  nodelist = mesh.e(1:2,edgelist);
  nodelist = [nodelist(1,:) nodelist(2,:)];
  nodelist = unique(nodelist);

endfunction

%!test
%! [mesh1] = msh2m_structured_mesh(0:.5:1, 0:.5:1, 1, 1:4, 'left');
%! [mesh2] = msh2m_structured_mesh(1:.5:2, 0:.5:1, 1, 1:4, 'left');
%! [mesh] = msh2m_join_structured_mesh(mesh1,mesh2,2,4);
%! [nodelist] = msh2m_nodes_on_sides(mesh,[1 2]);
%! reallist = [1   4   7   8   9];
%! assert(nodelist,reallist);
