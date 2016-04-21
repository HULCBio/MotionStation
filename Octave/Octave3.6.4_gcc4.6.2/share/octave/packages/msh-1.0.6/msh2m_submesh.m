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
## msh2m_submesh(@var{imesh},@var{intrfc},@var{sdl})
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
## @seealso{msh2m_join_structured_mesh, msh3m_submesh,
## msh3e_surface_mesh} 
## @end deftypefn

function [omesh,nodelist,elementlist] = msh2m_submesh(imesh,intrfc,sdl)

  ## Check input
  if nargin != 3
    error("msh2m_submesh: wrong number of input parameters.");
  endif
  if !isstruct(imesh)
    error("msh2m_submesh: first input is not a valid mesh structure.");
  endif
  if !isvector(sdl)
    error("msh2m_submesh: third input is not a valid vector.");
  endif
  
  ## Extract sub-mesh
  nsd = length(sdl); # number of subdomains

  ## Set list of output triangles 
  elementlist=[];
  for isd=1:nsd
    elementlist = [elementlist find(imesh.t(4,:) == sdl(isd))];
  endfor

  omesh.t = imesh.t(:,elementlist);

  ## Set list of output nodes
  nodelist          = unique(reshape(imesh.t(1:3,elementlist),1,[]));
  omesh.p         = imesh.p(:,nodelist);

  ## Use new node numbering in connectivity matrix
  indx(nodelist) = [1:length(nodelist)];
  iel = [1:length(elementlist)];
  omesh.t(1:3,iel) = indx(omesh.t(1:3,iel));

  ## Set list of output edges
  omesh.e =[];
  for isd=1:nsd
    omesh.e = [omesh.e imesh.e(:,imesh.e(7,:)==sdl(isd))];
    omesh.e = [omesh.e imesh.e(:,imesh.e(6,:)==sdl(isd))];
  endfor
  omesh.e=unique(omesh.e',"rows")';

  ## Use new node numbering in boundary segment list
  ied = [1:size(omesh.e,2)];
  omesh.e(1:2,ied) = indx(omesh.e(1:2,ied));

endfunction

%!test
%! [mesh1] = msh2m_structured_mesh(0:.5:1, 0:.5:1, 1, 1:4, 'left');
%! [mesh2] = msh2m_structured_mesh(1:.5:2, 0:.5:1, 1, 1:4, 'left');
%! [mesh]  = msh2m_join_structured_mesh(mesh1,mesh2,2,4);
%! [omesh,nodelist,elementlist] = msh2m_submesh(mesh,[],2);
%! p = [1.00000   1.00000   1.00000   1.50000   1.50000   1.50000   2.00000   2.00000   2.00000
%!      0.00000   0.50000   1.00000   0.00000   0.50000   1.00000   0.00000   0.50000   1.00000];
%! e = [1   1   2   3   4   6   7   8
%!      2   4   3   6   7   9   8   9
%!      0   0   0   0   0   0   0   0
%!      0   0   0   0   0   0   0   0
%!      2   5   2   7   5   7   6   6
%!      2   0   2   0   0   0   0   0
%!      1   2   1   2   2   2   2   2];
%! t = [1   2   4   5   2   3   5   6
%!      4   5   7   8   4   5   7   8
%!      2   3   5   6   5   6   8   9
%!      2   2   2   2   2   2   2   2];
%! nl = [7    8    9   10   11   12   13   14   15];
%! el = [9   10   11   12   13   14   15   16];
%! toll = 1e-4;
%! assert(omesh.p,p,toll);
%! assert(omesh.e,e);
%! assert(omesh.t,t);
%! assert(nodelist,nl);
%! assert(elementlist,el);

%!demo
%! name = [tmpnam ".geo"];
%! fid = fopen (name, "w");
%! fputs (fid, "Point(1) = {0, 0, 0, .1};\n");
%! fputs (fid, "Point(2) = {1, 0, 0, .1};\n");
%! fputs (fid, "Point(3) = {1, 0.5, 0, .1};\n");
%! fputs (fid, "Point(4) = {1, 1, 0, .1};\n");
%! fputs (fid, "Point(5) = {0, 1, 0, .1};\n");
%! fputs (fid, "Point(6) = {0, 0.5, 0, .1};\n");
%! fputs (fid, "Line(1) = {1, 2};\n");
%! fputs (fid, "Line(2) = {2, 3};\n");
%! fputs (fid, "Line(3) = {3, 4};\n");
%! fputs (fid, "Line(4) = {4, 5};\n");
%! fputs (fid, "Line(5) = {5, 6};\n");
%! fputs (fid, "Line(6) = {6, 1};\n");
%! fputs (fid, "Point(7) = {0.2, 0.6, 0};\n");
%! fputs (fid, "Point(8) = {0.5, 0.4, 0};\n");
%! fputs (fid, "Point(9) = {0.7, 0.6, 0};\n");
%! fputs (fid, "BSpline(7) = {6, 7, 8, 9, 3};\n");
%! fputs (fid, "Line Loop(8) = {6, 1, 2, -7};\n");
%! fputs (fid, "Plane Surface(9) = {8};\n");
%! fputs (fid, "Line Loop(10) = {7, 3, 4, 5};\n");
%! fputs (fid, "Plane Surface(11) = {10};\n");
%! fclose (fid);
%! mesh  = msh2m_gmsh (canonicalize_file_name (name)(1:end-4), "clscale", ".5");
%! mesh1 = msh2m_submesh (mesh, 7, 9);
%! subplot (1, 2, 1);
%! trimesh (mesh.t(1:3,:)', mesh.p(1,:)', mesh.p(2,:)');
%! axis ("equal"); title ("full mesh")
%! subplot (1, 2, 2);
%! trimesh (mesh1.t(1:3,:)', mesh1.p(1,:)', mesh1.p(2,:)');
%! axis ("equal"); title ("sub-mesh")
%! unlink (canonicalize_file_name (name))