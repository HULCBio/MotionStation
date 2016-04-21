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
## msh3m_nodes_on_faces(@var{mesh},@var{facelist})
##
## Return a list of @var{mesh} nodes lying on the faces specified in
## @var{facelist}.
##
## @seealso{msh3m_geometrical_properties, msh2m_nodes_on_faces}
## @end deftypefn

function [nodelist] = msh3m_nodes_on_faces(mesh,facelist);

  ## Check input
  if nargin != 2 # Number of input parameters
    error("msh3m_nodes_on_faces: wrong number of input parameters.");
  elseif !(isstruct(mesh)    && isfield(mesh,"p") &&
	   isfield(mesh,"t") && isfield(mesh,"e"))
    error("msh3m_nodes_on_faces: first input is not a valid mesh structure.");
  elseif !isnumeric(facelist)
    error("msh3m_nodes_on_faces: only numeric value admitted as facelist.");
  endif

  ## Search nodes
  facefaces = [];
  
  for ii=1:length(facelist)
    facefaces = [facefaces,find(mesh.e(10,:)==facelist(ii))];
  endfor

  facenodes = mesh.e(1:3,facefaces);
  nodelist  = unique(facenodes(:));
  
endfunction

%!shared x,y,z,mesh
% x = y = z = linspace(0,1,2);
% [mesh] = msh3m_structured_mesh(x,y,z,1,1:6);
%!test
% nodelist = msh3m_nodes_on_faces(mesh,1);
% assert(nodelist,[1 2 5 6]')
%!test
% nodelist = msh3m_nodes_on_faces(mesh,2);
% assert(nodelist,[3 4 7 8]')
%!test
% nodelist = msh3m_nodes_on_faces(mesh,3);
% assert(nodelist,[1 3 5 7]')
%!test
% nodelist = msh3m_nodes_on_faces(mesh,[1 2 3]);
% assert(nodelist,[1:8]')