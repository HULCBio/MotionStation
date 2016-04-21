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
## @deftypefn {Function File} {[@var{mesh}]} = @
## msh3m_join_structured_mesh(@var{mesh1},@var{mesh2},@var{s1},@var{s2})
##
## Join the two structured meshes @var{mesh1} and @var{mesh2} into one
## single mesh. 
##
## The two meshes must share a common face identified by @var{s1} and
## @var{s2}. 
##
## @strong{WARNING}: the two meshes must share the same vertexes on the
## common face. 
##
## @seealso{msh3m_structured_mesh, msh3m_gmsh, msh3m_submesh,
## msh2m_join_structured_mesh} 
## @end deftypefn

function mesh = msh3m_join_structured_mesh(mesh1,mesh2,s1,s2)

  ## Check input
  if nargin != 4 # Number of input parameters
    error("msh3m_join_structured_mesh: wrong number of input parameters.");
  elseif !(isstruct(mesh1)     && isfield(mesh1,"p") && 
	   isfield (mesh1,"e") && isfield(mesh1,"t") &&
	   isstruct(mesh2)     && isfield(mesh2,"p") &&
	   isfield (mesh2,"e") && isfield(mesh2,"t") )
    error("msh3m_join_structured_mesh: invalid mesh structure passed as input.");
  elseif !(isvector(s1) && isvector(s2))
    error("msh3m_join_structured_mesh: shared geometrical sides are not vectors.");
  elseif (length(s1) != length(s2))
    error("msh3m_join_structured_mesh: vectors containing shared geometrical sides are not of the same length.");
  endif
  
  ## Join meshes

  ## Make sure that the outside world is always on the same side of the
  ## boundary of mesh1 
  [mesh1.e(8:9,:),I] = sort(mesh1.e(8:9,:));

  ## IF THE REGIONS ARE INVERTED THE VERTEX ORDER SHOULD ALSO BE
  ## INVERTED!!

  ## FIXME: here a check could be added to see whether
  ## the coordinate points of the two meshes coincide on the
  ## side edges

  ## Get interface nodes
  intfcnodes1 = msh3m_nodes_on_faces(mesh1,s1)';
  intfcnodes2 = msh3m_nodes_on_faces(mesh2,s2)';

  ## Sort interface nodes by position
  [tmp,I]     = sort(mesh1.p(1,intfcnodes1));
  intfcnodes1 = intfcnodes1(I);
  [tmp,I]     = sort(mesh1.p(2,intfcnodes1));
  intfcnodes1 = intfcnodes1(I);
  [tmp,I]     = sort(mesh1.p(3,intfcnodes1));
  intfcnodes1 = intfcnodes1(I);

  [tmp,I]     = sort(mesh2.p(1,intfcnodes2));
  intfcnodes2 = intfcnodes2(I);
  [tmp,I]     = sort(mesh2.p(2,intfcnodes2));
  intfcnodes2 = intfcnodes2(I);
  [tmp,I]     = sort(mesh2.p(3,intfcnodes2));
  intfcnodes2 = intfcnodes2(I);

  ## Delete redundant boundary faces but first remeber what region they
  ## were connected to 
  for is = 1:length(s2)
    ii           = find( mesh2.e(10,:)==s2(is) );
    adreg(is,:)  = unique(mesh2.e(9,ii)); 
  endfor

  for is = 1:length(s2)
    mesh2.e(:,find( mesh2.e(10,:)==s2(is) )) = [];
  endfor

  ## Change face numbers
  idx                = [];
  consecutives       = [];
  idx                = unique(mesh2.e(10,:));
  consecutives (idx) = [1:length(idx)] + max(mesh1.e(10,:));
  mesh2.e(10,:)      = consecutives(mesh2.e(10,:));

  ## Change node indices in connectivity matrix and edge list
  idx                   = [];
  consecutives          = [];
  idx                   = 1:size(mesh2.p,2);
  offint                = setdiff(idx,intfcnodes2);
  consecutives (offint) = [1:length(offint)]+size(mesh1.p,2);

  consecutives (intfcnodes2) = intfcnodes1;
  mesh2.e(1:3,:)             = consecutives(mesh2.e(1:3,:));
  mesh2.t(1:4,:)             = consecutives(mesh2.t(1:4,:));

  ## Delete redundant points
  mesh2.p(:,intfcnodes2) = [];

  ## Set region numbers
  regions             = unique(mesh1.t(5,:));# Mesh 1
  newregions(regions) = 1:length(regions);
  mesh1.t(5,:)        = newregions(mesh1.t(5,:));

  regions             = unique(mesh2.t(5,:));# Mesh 2
  newregions(regions) = [1:length(regions)]+max(mesh1.t(5,:));
  mesh2.t(5,:)        = newregions(mesh2.t(5,:));

  ## Set adjacent region numbers in face structure 2
  [i,j] = find(mesh2.e(8:9,:));
  i    += 7;

  mesh2.e(i,j) = newregions(mesh2.e(i,j));

  ## Set adjacent region numbers in edge structure 1
  for is = 1:length(s1)
    ii            = find( mesh1.e(10,:)==s1(is) );
    mesh1.e(8,ii) = newregions(adreg(is,:));
  endfor

  ## Build new mesh structure
  mesh.p = [mesh1.p mesh2.p];
  mesh.e = [mesh1.e mesh2.e];
  mesh.t = [mesh1.t mesh2.t];

endfunction

%!shared mesh1,mesh2,jmesh
% x  = y = z = linspace(0,1,2);
% x2 = linspace(1,2,2);
% [mesh1] = msh3m_structured_mesh(x,y,z,1,1:6);
% [mesh2] = msh3m_structured_mesh(x2,y,z,3,1:6);
% [jmesh] = msh3m_join_structured_mesh(mesh1,mesh2,2,1);
%!test
% assert(columns(jmesh.p),12)
%!test
% tmp = sort(unique(jmesh.e(10,:)));
% assert(tmp,1:11)
%!test
% assert(columns(jmesh.t),columns(mesh1.t)+columns(mesh2.t))
%!test
% assert(unique(jmesh.e(8:9,:)),0:2)
