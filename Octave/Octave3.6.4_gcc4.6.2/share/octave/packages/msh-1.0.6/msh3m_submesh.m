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
## @deftypefn {Function File} {[@var{omesh},@var{nodelist},@var{elementlist}]} = @
## msh3m_submesh(@var{imesh},@var{intrfc},@var{sdl})
##
## Extract the subdomain(s) in @var{sdl} from @var{imesh}.
##
## The row vector @var{intrfc} contains the internal interface sides to
## be maintained (field @code{mesh.e(5,:)}). It can be empty.
##
## Return the vectors @var{nodelist} and @var{elementlist} containing
## respectively the list of nodes and elements of the original mesh that
## are part of the selected subdomain(s).
##
## @seealso{msh3m_join_structured_mesh, msh2m_join_structured_mesh,
## msh3m_submesh} 
## @end deftypefn

function [omesh,nodelist,elementlist] = msh3m_submesh(imesh,intrfc,sdl)
  
  ## Check input
  if nargin != 3
    error("msh3m_submesh: wrong number of input parameters.");
  elseif !(isstruct(imesh)     && isfield(imesh,"p") &&
	   isfield (imesh,"t") && isfield(imesh,"e"))
    error("msh3m_submesh: first input is not a valid mesh structure.");
  elseif !isvector(sdl)
    error("msh3m_submesh: third input is not a valid vector.");
  endif

  ## Extract sub-mesh

  ## Build element list
  elementlist=[];
  for ir = 1:length(sdl)
    elementlist = [ elementlist find(imesh.t(5,:)==sdl(ir)) ];
  endfor

  ## Build nodelist
  nodelist = reshape(imesh.t(1:4,elementlist),1,[]);
  nodelist = unique(nodelist);
  
  ## Extract submesh
  omesh.p         = imesh.p  (:,nodelist);
  indx(nodelist)  = 1:length (nodelist);
  omesh.t         = imesh.t  (:,elementlist);
  omesh.t(1:4,:)  = indx(omesh.t(1:4,:));

  omesh.e  = [];
  for ifac = 1:size(imesh.e,2)
    if (length(intersect(imesh.e(1:3,ifac),nodelist) )== 3)
      omesh.e = [omesh.e imesh.e(:,ifac)];
    endif
  endfor

  omesh.e(1:3,:)  = indx(omesh.e(1:3,:));

endfunction

%!shared mesh1,mesh2,jmesh,exmesh,nodelist,elemlist
% x = y = z = linspace(0,1,2);
% x2 = linspace(1,2,2);
% [mesh1] = msh3m_structured_mesh(x,y,z,1,1:6);
% [mesh2] = msh3m_structured_mesh(x2,y,z,1,1:6);
% [jmesh] = msh3m_join_structured_mesh(mesh1,mesh2,2,1);
% [exmesh,nodelist,elemlist] = msh3m_submesh(jmesh,2,1);
%!test
% assert(size(exmesh.p),size(mesh1.p))
%!test
% assert(size(exmesh.t),size(mesh1.t))
%!test
% assert(size(exmesh.e),size(mesh1.e))