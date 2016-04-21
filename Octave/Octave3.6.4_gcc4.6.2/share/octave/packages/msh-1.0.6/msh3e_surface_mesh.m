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
## @deftypefn {Function File} {[@var{emesh},@var{snodes},@var{ssides},@var{striangles}]} = @
## msh3e_surface_mesh(@var{mesh},@var{nsrf},@var{nsides})
##
## Extract the plane surface @var{nsrf} delimited by @var{nsides} from
## @var{mesh}.
## 
## Return the vector @var{snodes} containing the references to input
## mesh nodes (field @code{mesh.p}), the vector @var{ssides} containing
## the references to input mesh side (field @code{mesh.s}) and the
## vector @var{striangles} containing the references to input mesh side
## edges (field @code{mesh.e}).
##
## @strong{WARNING}: the suface MUST be ortogonal to either X, Y or Z
## axis. This should be changed to account for generic 2D surface. 
##
## @end deftypefn

function [emesh,snodes,ssides,striangles] = msh3e_surface_mesh(mesh,nsrf,nsides)
  
  ## Check input
  if nargin != 3
    error("msh3e_surface_mesh: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("msh3e_surface_mesh: first input is not a valid mesh structure.");
  elseif !isscalar(nsrf)
    error("msh3e_surface_mesh: second input is not a valid scalar.");
  elseif !(isvector(nsides) && isnumeric(nsides))
    error("msh3e_surface_mesh: third input is not a valid numeric vector.");
  endif

  ## Surface extraction

  ## Extraction of 2D surface elements
  striangles = find( mesh.e(10,:) == nsrf );
  t          = mesh.e(1:3,striangles);
  tmp        = reshape(t,[],1);
  ## Renumbering
  [snodes,ii,jj] = unique(tmp);
  nds            = 1:length(snodes);
  emesh.t        = reshape(nds(jj),3,[]);

  ## Extraction of 2D mesh points
  points = mesh.p(:,snodes);

  ## Test for normals
  ## FIXME: this should disappear as soon as 2D mesh are not supposed to
  ## lie on a plane.
  if length(unique(points(1,:))) == 1
    xyz = [2,3]; # normal to X coordinate
  elseif length(unique(points(2,:))) == 1
    xyz = [1,3]; # normal to Y coordinate
  else
    xyz = [1,2]; # normal to Z coordinate
  endif
 
  emesh.p = points(xyz,:);
  
  ## Extraction of 1D side edges
  ssides = [];

  for ll = nsides
    tmp    = find ( mesh.s(3,:) == ll );
    ssides = [ssides,tmp];
  endfor
  
  nedges       = length(ssides);
  emesh.e      = zeros(7,nedges);
  emesh.e(5,:) = mesh.s(3,ssides);

  tmp               = reshape(mesh.s(1:2,ssides),[],1);
  [enodes,nn,mm]    = unique(tmp);
  [tmp1, nds, tmp2] = intersect(snodes,enodes);
  emesh.e(1:2,:)    = reshape(nds(mm),2,[]);
  
  ## Compute mesh properties
  ## FIXME: this has to be removed. MSH should not depend on BIM.
  emesh = bim2c_mesh_properties(emesh);

endfunction